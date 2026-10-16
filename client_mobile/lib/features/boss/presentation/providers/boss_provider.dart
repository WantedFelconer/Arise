import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/arise_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/sync/offline_command_queue.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/boss_models.dart';
import '../../infrastructure/boss_remote_data_source.dart';
import '../../infrastructure/local_boss_repository.dart';

final bossRepositoryProvider = Provider<LocalBossRepository>((ref) {
  final db = ref.watch(ariseDatabaseProvider);
  return LocalBossRepository(db);
});

final bossRemoteDataSourceProvider = Provider<BossRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return BossRemoteDataSource(client);
});

class BossState {
  const BossState({
    this.bosses = const [],
    this.activeBoss,
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.isDefeatedModalVisible = false,
    this.defeatRewards,
  });

  final List<Boss> bosses;
  final Boss? activeBoss;
  final List<BossHistoryItem> history;
  final bool isLoading;
  final String? error;
  final bool isDefeatedModalVisible;
  final Map<String, dynamic>? defeatRewards;

  BossState copyWith({
    List<Boss>? bosses,
    Boss? activeBoss,
    bool clearActiveBoss = false,
    List<BossHistoryItem>? history,
    bool? isLoading,
    String? error,
    bool? isDefeatedModalVisible,
    Map<String, dynamic>? defeatRewards,
  }) {
    return BossState(
      bosses: bosses ?? this.bosses,
      activeBoss: clearActiveBoss ? null : (activeBoss ?? this.activeBoss),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDefeatedModalVisible:
          isDefeatedModalVisible ?? this.isDefeatedModalVisible,
      defeatRewards: defeatRewards ?? this.defeatRewards,
    );
  }
}

class BossNotifier extends StateNotifier<BossState> {
  BossNotifier(
    this._repository, {
    BossRemoteDataSource? remoteDataSource,
    PersistentCommandQueue? commandQueue,
    SyncEngine? syncEngine,
  })  : _remoteDataSource = remoteDataSource,
        _commandQueue = commandQueue,
        _syncEngine = syncEngine,
        super(const BossState()) {
    _init();
  }

  final LocalBossRepository _repository;
  final BossRemoteDataSource? _remoteDataSource;
  final PersistentCommandQueue? _commandQueue;
  final SyncEngine? _syncEngine;

  StreamSubscription<List<Boss>>? _subscription;

  void _init() {
    _subscription = _repository.watchBosses().listen((list) {
      if (!mounted) return;
      Boss? current = state.activeBoss;
      if (current != null) {
        final match = list.where((b) => b.id == current!.id).firstOrNull;
        current = match ?? current;
      } else if (list.isNotEmpty) {
        current = list.first;
      }
      state = state.copyWith(
        bosses: list,
        activeBoss: current,
        isLoading: false,
      );
    });

    loadBosses();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadBosses([String? userId]) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: state.bosses.isEmpty, error: null);
    try {
      final list = await _repository.fetchBosses(userId);
      if (!mounted) return;
      state = state.copyWith(
        bosses: list,
        activeBoss: list.isNotEmpty ? (state.activeBoss ?? list.first) : null,
        isLoading: false,
      );

      // Background remote sync if online
      final remote = _remoteDataSource;
      if (remote != null && (_syncEngine == null || _syncEngine!.isOnline)) {
        try {
          final serverBosses = await remote.fetchBosses();
          if (!mounted) return;
          await _repository.reconcileServerBosses(
            serverBosses,
            userId ?? 'local-user',
          );
        } catch (_) {
          // Graceful offline fallback
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void selectBoss(String id) {
    final match = state.bosses.where((b) => b.id == id).firstOrNull;
    if (match != null) {
      state = state.copyWith(activeBoss: match);
    }
  }

  Future<void> fetchHistory() async {
    final remote = _remoteDataSource;
    if (remote == null) return;
    try {
      final raw = await remote.fetchBossHistory();
      final items = raw.map((r) => BossHistoryItem.fromJson(r)).toList();
      if (mounted) {
        state = state.copyWith(history: items);
      }
    } catch (_) {}
  }

  Future<void> abandonBoss(String id) async {
    final remote = _remoteDataSource;
    if (remote != null) {
      try {
        final raw = await remote.abandonBoss(id);
        await _repository.saveServerSnapshot(raw);
      } catch (_) {
        if (_commandQueue != null) {
          await _commandQueue!.enqueue(
            commandType: 'ABANDON_BOSS',
            userId: state.activeBoss?.userId ?? 'local-user',
            payload: {'bossId': id},
          );
        }
      }
    }
  }

  Future<void> reactivateBoss(String id) async {
    final remote = _remoteDataSource;
    if (remote != null) {
      try {
        final raw = await remote.reactivateBoss(id);
        await _repository.saveServerSnapshot(raw);
      } catch (_) {
        if (_commandQueue != null) {
          await _commandQueue!.enqueue(
            commandType: 'REACTIVATE_BOSS',
            userId: state.activeBoss?.userId ?? 'local-user',
            payload: {'bossId': id},
          );
        }
      }
    }
  }

  void showDefeatModal({Map<String, dynamic>? rewards}) {
    state = state.copyWith(
      isDefeatedModalVisible: true,
      defeatRewards: rewards,
    );
  }

  void hideDefeatModal() {
    state = state.copyWith(isDefeatedModalVisible: false);
  }

  /// Reconciles damage from reward cascade into active boss.
  Future<void> reconcileDamage(
    String bossId,
    int damage, {
    bool? defeated,
    Map<String, dynamic>? rewards,
  }) async {
    await _repository.applyAuthoritativeDamage(
      bossId,
      damage,
      defeated: defeated,
    );
    if (defeated == true) {
      showDefeatModal(rewards: rewards);
    }
  }
}

final bossNotifierProvider =
    StateNotifierProvider<BossNotifier, BossState>((ref) {
  final repo = ref.watch(bossRepositoryProvider);
  BossRemoteDataSource? remote;
  try {
    remote = ref.watch(bossRemoteDataSourceProvider);
  } catch (_) {}
  final queue = ref.watch(commandQueueProvider);
  SyncEngine? sync;
  try {
    sync = ref.watch(syncEngineProvider);
  } catch (_) {}

  return BossNotifier(
    repo,
    remoteDataSource: remote,
    commandQueue: queue,
    syncEngine: sync,
  );
});
