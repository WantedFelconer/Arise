import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/arise_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/sync/offline_command_queue.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/gate_models.dart';
import '../../infrastructure/gate_remote_data_source.dart';
import '../../infrastructure/local_gate_repository.dart';

final gateRepositoryProvider = Provider<LocalGateRepository>((ref) {
  final db = ref.watch(ariseDatabaseProvider);
  return LocalGateRepository(db);
});

final gateRemoteDataSourceProvider = Provider<GateRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return GateRemoteDataSource(client);
});

class GateState {
  const GateState({
    this.sessions = const [],
    this.activeSession,
    this.secondsRemaining = 25 * 60,
    this.stabilityPct = 0.0,
    this.stats = GateStats.empty,
    this.isLoading = false,
    this.error,
    this.lastCascadeResult,
    this.lastPenaltyResult,
    this.difficultyMode = 'casual',
  });

  final List<GateSession> sessions;
  final GateSession? activeSession;
  final int secondsRemaining;
  final double stabilityPct;
  final GateStats stats;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? lastCascadeResult;
  final Map<String, dynamic>? lastPenaltyResult;
  final String difficultyMode;

  bool get isRunning => activeSession?.isActive == true;
  bool get isPaused => activeSession?.isPaused == true;
  bool get isCleared => activeSession?.isCleared == true;
  bool get isCollapsed => activeSession?.isCollapsed == true;

  GateState copyWith({
    List<GateSession>? sessions,
    GateSession? activeSession,
    bool clearActiveSession = false,
    int? secondsRemaining,
    double? stabilityPct,
    GateStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? lastCascadeResult,
    Map<String, dynamic>? lastPenaltyResult,
    String? difficultyMode,
  }) {
    return GateState(
      sessions: sessions ?? this.sessions,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      stabilityPct: stabilityPct ?? this.stabilityPct,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastCascadeResult: lastCascadeResult ?? this.lastCascadeResult,
      lastPenaltyResult: lastPenaltyResult ?? this.lastPenaltyResult,
      difficultyMode: difficultyMode ?? this.difficultyMode,
    );
  }
}

class GateNotifier extends StateNotifier<GateState> {
  GateNotifier(
    this._repository, {
    GateRemoteDataSource? remoteDataSource,
    PersistentCommandQueue? commandQueue,
    SyncEngine? syncEngine,
  })  : _remoteDataSource = remoteDataSource,
        _commandQueue = commandQueue,
        _syncEngine = syncEngine,
        super(const GateState()) {
    _init();
  }

  final LocalGateRepository _repository;
  final GateRemoteDataSource? _remoteDataSource;
  final PersistentCommandQueue? _commandQueue;
  final SyncEngine? _syncEngine;

  StreamSubscription<List<GateSession>>? _subscription;
  Timer? _ticker;
  static const _uuid = Uuid();

  void _init() {
    _subscription = _repository.watchGateSessions().listen((list) {
      if (!mounted) return;
      state = state.copyWith(sessions: list);
      _recomputeLocalStats(list);
    });

    fetchStats();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void setDifficultyMode(String mode) {
    state = state.copyWith(difficultyMode: mode.toLowerCase());
  }

  /// Start a new Gate Expedition session.
  Future<GateSession> startSession({
    String? questId,
    int durationSeconds = 25 * 60,
    String? userId,
  }) async {
    _ticker?.cancel();

    final sessionId = _uuid.v4();
    final now = DateTime.now();
    final user = userId ?? 'local-user';

    final session = GateSession(
      id: sessionId,
      userId: user,
      questId: questId,
      startedAt: now,
      plannedDurationS: durationSeconds,
      status: GateSessionStatus.active,
      syncStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    // 1. Persist to Drift SQLite
    await _repository.saveSession(session);

    state = state.copyWith(
      activeSession: session,
      secondsRemaining: durationSeconds,
      stabilityPct: 0.0,
      clearError: true,
      lastCascadeResult: null,
      lastPenaltyResult: null,
    );

    // 2. Queue domain command for sync
    if (_commandQueue != null) {
      await _commandQueue!.enqueue(
        commandType: 'START_GATE_SESSION',
        userId: user,
        idempotencyKey: sessionId,
        payload: {
          'sessionId': sessionId,
          'questId': questId,
          'plannedDurationSeconds': durationSeconds,
          'startedAt': now.toIso8601String(),
        },
      );
      _syncEngine?.triggerSync();
    }

    // 3. Start local ticking
    _startTimer();

    return session;
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final active = state.activeSession;
      if (active == null || active.status != GateSessionStatus.active) {
        timer.cancel();
        return;
      }

      if (state.secondsRemaining > 1) {
        final newRemaining = state.secondsRemaining - 1;
        final elapsed = active.plannedDurationS - newRemaining;
        final newStability =
            ((elapsed / active.plannedDurationS) * 100).clamp(0.0, 100.0);

        state = state.copyWith(
          secondsRemaining: newRemaining,
          stabilityPct: newStability,
        );
      } else {
        // Timer completed (100% stability)
        timer.cancel();
        completeSession();
      }
    });
  }

  /// Pause current session (Casual: 1 pause max; Hardcore: 0).
  Future<void> pauseSession() async {
    final active = state.activeSession;
    if (active == null || active.status != GateSessionStatus.active) return;

    if (state.difficultyMode == 'hardcore') {
      state = state.copyWith(
        error: 'Pausing is strictly disallowed in Hardcore Mode.',
      );
      return;
    }

    if (active.pauseCount >= 1) {
      state = state.copyWith(
        error: 'Maximum of 1 pause allowed per Gate session in Casual Mode.',
      );
      return;
    }

    _ticker?.cancel();
    final now = DateTime.now();

    final updated = active.copyWith(
      status: GateSessionStatus.paused,
      pausedAt: now,
      pauseCount: active.pauseCount + 1,
      syncStatus: 'pending',
    );

    state = state.copyWith(activeSession: updated, clearError: true);

    await _repository.updateSessionStatus(
      active.id,
      status: GateSessionStatus.paused,
      pausedAt: now,
      pauseCount: active.pauseCount + 1,
      syncStatus: 'pending',
    );
  }

  /// Resume paused session.
  Future<void> resumeSession() async {
    final active = state.activeSession;
    if (active == null || active.status != GateSessionStatus.paused) return;

    final now = DateTime.now();
    final pausedAt = active.pausedAt ?? now;
    final pauseDuration = now.difference(pausedAt).inSeconds;
    final totalPaused = active.totalPausedDurationS + pauseDuration;

    final updated = active.copyWith(
      status: GateSessionStatus.active,
      pausedAt: null,
      totalPausedDurationS: totalPaused,
      syncStatus: 'pending',
    );

    state = state.copyWith(activeSession: updated, clearError: true);

    await _repository.updateSessionStatus(
      active.id,
      status: GateSessionStatus.active,
      pausedAt: null,
      totalPausedDurationS: totalPaused,
      syncStatus: 'pending',
    );

    _startTimer();
  }

  /// Complete session (100% stability reached).
  Future<void> completeSession() async {
    _ticker?.cancel();
    final active = state.activeSession;
    if (active == null) return;

    final now = DateTime.now();
    final actualDuration = active.plannedDurationS - state.secondsRemaining;

    final updated = active.copyWith(
      status: GateSessionStatus.cleared,
      stabilityFinal: 100.0,
      actualDurationS: actualDuration > 0 ? actualDuration : active.plannedDurationS,
      endedAt: now,
      syncStatus: 'pending',
    );

    state = state.copyWith(
      activeSession: updated,
      secondsRemaining: 0,
      stabilityPct: 100.0,
    );

    await _repository.updateSessionStatus(
      active.id,
      status: GateSessionStatus.cleared,
      stabilityFinal: 100.0,
      actualDurationS: actualDuration > 0 ? actualDuration : active.plannedDurationS,
      endedAt: now,
      syncStatus: 'pending',
    );

    // Queue COMPLETE_GATE_SESSION
    if (_commandQueue != null) {
      await _commandQueue!.enqueue(
        commandType: 'COMPLETE_GATE_SESSION',
        userId: active.userId,
        idempotencyKey: _uuid.v4(),
        payload: {
          'sessionId': active.id,
          'actualDurationSeconds': actualDuration,
          'stabilityFinal': 100,
        },
      );
      _syncEngine?.triggerSync();
    }
  }

  /// Collapse session on early exit.
  Future<void> collapseSession({String exitReason = 'user_exit'}) async {
    _ticker?.cancel();
    final active = state.activeSession;
    if (active == null) return;

    final now = DateTime.now();
    final actualDuration = active.plannedDurationS - state.secondsRemaining;
    final stability = state.stabilityPct;

    final updated = active.copyWith(
      status: GateSessionStatus.collapsed,
      stabilityFinal: stability,
      actualDurationS: actualDuration,
      exitReason: exitReason,
      endedAt: now,
      syncStatus: 'pending',
    );

    state = state.copyWith(
      activeSession: updated,
    );

    await _repository.updateSessionStatus(
      active.id,
      status: GateSessionStatus.collapsed,
      stabilityFinal: stability,
      actualDurationS: actualDuration,
      exitReason: exitReason,
      endedAt: now,
      syncStatus: 'pending',
    );

    // Queue COLLAPSE_GATE_SESSION
    if (_commandQueue != null) {
      await _commandQueue!.enqueue(
        commandType: 'COLLAPSE_GATE_SESSION',
        userId: active.userId,
        idempotencyKey: _uuid.v4(),
        payload: {
          'sessionId': active.id,
          'exitReason': exitReason,
          'actualDurationSeconds': actualDuration,
          'difficultyMode': state.difficultyMode,
        },
      );
      _syncEngine?.triggerSync();
    }
  }

  /// Fetches gate expedition stats.
  Future<void> fetchStats() async {
    final remote = _remoteDataSource;
    if (remote != null && (_syncEngine == null || _syncEngine!.isOnline)) {
      try {
        final raw = await remote.getStats();
        final stats = GateStats.fromJson(raw);
        if (mounted) {
          state = state.copyWith(stats: stats);
        }
        return;
      } catch (_) {}
    }

    _recomputeLocalStats(state.sessions);
  }

  void _recomputeLocalStats(List<GateSession> sessions) {
    if (sessions.isEmpty) return;

    final cleared = sessions.where((s) => s.isCleared).length;
    final collapsed = sessions.where((s) => s.isCollapsed).length;
    final resolved = cleared + collapsed;
    final successRate = resolved == 0 ? 0 : ((cleared / resolved) * 100).round();

    int longest = 0;
    int totalFocus = 0;

    for (final s in sessions) {
      final dur = s.actualDurationS ?? s.plannedDurationS;
      totalFocus += dur;
      if (s.isCleared && dur > longest) {
        longest = dur;
      }
    }

    final localStats = GateStats(
      totalSessions: sessions.length,
      totalCleared: cleared,
      totalCollapsed: collapsed,
      successRatePct: successRate,
      longestExpeditionSeconds: longest,
      totalFocusTimeSeconds: totalFocus,
    );

    if (mounted) {
      state = state.copyWith(stats: localStats);
    }
  }

  void recordCascadeResult(Map<String, dynamic> result) {
    state = state.copyWith(lastCascadeResult: result);
  }

  void recordPenaltyResult(Map<String, dynamic> result) {
    state = state.copyWith(lastPenaltyResult: result);
  }
}

final gateNotifierProvider =
    StateNotifierProvider<GateNotifier, GateState>((ref) {
  final repo = ref.watch(gateRepositoryProvider);
  GateRemoteDataSource? remote;
  try {
    remote = ref.watch(gateRemoteDataSourceProvider);
  } catch (_) {}
  final queue = ref.watch(commandQueueProvider);
  SyncEngine? sync;
  try {
    sync = ref.watch(syncEngineProvider);
  } catch (_) {}

  return GateNotifier(
    repo,
    remoteDataSource: remote,
    commandQueue: queue,
    syncEngine: sync,
  );
});
