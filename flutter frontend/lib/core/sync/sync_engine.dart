import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/arise_database.dart';
import '../network/api_client.dart';
import '../network/api_exceptions.dart';
import '../network/network_status.dart';
import '../providers/player_provider.dart';
import '../../features/quests/infrastructure/local_quest_repository.dart';
import '../../features/boss/infrastructure/local_boss_repository.dart';
import '../../features/gate/infrastructure/local_gate_repository.dart';
import '../../features/gate/domain/gate_models.dart';
import 'offline_command_queue.dart';

// ---------------------------------------------------------------------------
// State types
// ---------------------------------------------------------------------------

enum SyncEngineStatus { idle, syncing, error }

class SyncState {
  const SyncState({
    this.status = SyncEngineStatus.idle,
    this.pendingCount = 0,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncEngineStatus status;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncState copyWith({
    SyncEngineStatus? status,
    int? pendingCount,
    String? lastError,
    DateTime? lastSyncedAt,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

// ---------------------------------------------------------------------------
// SyncEngine
// ---------------------------------------------------------------------------

/// Bridges the persistent command queue and the network layer.
///
/// Responsibilities:
///   1. Listen to [NetworkStatusService] for online/offline transitions.
///   2. On [NetworkStatus.online]: flush pending commands from
///      [PersistentCommandQueue] via [_dispatchCommand].
///   3. Implement exponential backoff retry on failures.
///   4. Reconcile authoritative character, boss, and gate progression after syncing.
///   5. Expose a [SyncState] stream for UI (idle / syncing / error indicator).
class SyncEngine {
  SyncEngine({
    required this.commandQueue,
    required NetworkStatusService networkStatusService,
    ApiClient? apiClient,
    LocalQuestRepository? localQuestRepository,
    LocalBossRepository? localBossRepository,
    LocalGateRepository? localGateRepository,
    Future<void> Function()? onSyncCompleted,
  })  : _networkStatusService = networkStatusService,
        _apiClient = apiClient,
        _localQuestRepository = localQuestRepository,
        _localBossRepository = localBossRepository,
        _localGateRepository = localGateRepository,
        _onSyncCompleted = onSyncCompleted {
    _init();
  }

  final PersistentCommandQueue commandQueue;
  final NetworkStatusService _networkStatusService;
  final ApiClient? _apiClient;
  final LocalQuestRepository? _localQuestRepository;
  final LocalBossRepository? _localBossRepository;
  final LocalGateRepository? _localGateRepository;
  final Future<void> Function()? _onSyncCompleted;

  final StreamController<SyncState> _stateController =
      StreamController<SyncState>.broadcast();

  SyncState _state = const SyncState();
  StreamSubscription<NetworkStatus>? _networkSubscription;
  bool _isSyncing = false;
  Future<void>? _currentSyncFuture;

  bool _isDisposed = false;

  /// Publicly observable sync state for UI.
  Stream<SyncState> get stateStream => _stateController.stream;
  SyncState get currentState => _state;
  bool get isOnline => _networkStatusService.current == NetworkStatus.online;

  void _init() {
    _networkSubscription =
        _networkStatusService.statusStream.listen(_onNetworkChange);

    // Reset any commands that were stalled in syncing from a crashed session, then process queue.
    Future.microtask(() async {
      if (_isDisposed) return;
      try {
        await commandQueue.resetStalledSyncingCommands();
        if (!_isDisposed && _networkStatusService.current == NetworkStatus.online) {
          await _processQueue();
        }
      } catch (e) {
        developer.log('[SyncEngine] Failed to init/reset stalled syncing commands: $e');
      }
    });
  }

  void _onNetworkChange(NetworkStatus status) {
    developer.log('[SyncEngine] Network status: $status');
    if (status == NetworkStatus.online && !_isSyncing && !_isDisposed) {
      _processQueue();
    }
  }

  /// Trigger a manual sync (e.g., after user action while online).
  Future<void> triggerSync() async {
    if (_isDisposed) return;
    if (_isSyncing && _currentSyncFuture != null) {
      await _currentSyncFuture;
      return;
    }
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isDisposed || _isSyncing) return;
    if (_networkStatusService.current != NetworkStatus.online) return;
    final completer = Completer<void>();
    _currentSyncFuture = completer.future;
    _isSyncing = true;

    try {
      final pending = await commandQueue.getPending();
      if (pending.isEmpty) {
        return;
      }

      _emitState(_state.copyWith(
        status: SyncEngineStatus.syncing,
        pendingCount: pending.length,
      ));

      int failCount = 0;
      int successCount = 0;

      for (final command in pending) {
        if (_isDisposed) break;

        try {
          await commandQueue.markSyncing(command.eventId);
          await _dispatchCommand(command);
          await commandQueue.markSynced(command.eventId);
          successCount++;
        } catch (e) {
          failCount++;
          final errorMsg = e.toString();
          developer.log(
            '[SyncEngine] Dispatch failed for ${command.commandType}: $errorMsg',
          );
          await commandQueue.markFailed(command.eventId, errorMsg);
        }
      }

      // After successfully synchronizing domain commands, trigger authoritative reconciliation
      if (successCount > 0 && _onSyncCompleted != null) {
        try {
          await _onSyncCompleted!();
        } catch (e) {
          developer.log('[SyncEngine] Reconciliation callback failed: $e');
        }
      }

      final now = DateTime.now();
      _emitState(_state.copyWith(
        status: failCount > 0
            ? SyncEngineStatus.error
            : SyncEngineStatus.idle,
        pendingCount: failCount,
        lastSyncedAt: now,
        lastError: failCount > 0 ? '$failCount command(s) failed' : null,
      ));
    } finally {
      _isSyncing = false;
      completer.complete();
    }
  }

  /// Dispatches a single command to the backend API with an Idempotency-Key.
  Future<void> _dispatchCommand(QueuedCommand command) async {
    developer.log(
      '[SyncEngine] Dispatching ${command.commandType} (eventId: ${command.eventId})',
    );

    final client = _apiClient;
    final localRepo = _localQuestRepository;
    final bossRepo = _localBossRepository;
    final gateRepo = _localGateRepository;

    if (client != null) {
      switch (command.commandType) {
        case 'COMPLETE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          try {
            final res = await client.post(
              '/quests/$questId/complete',
              idempotencyKey: command.idempotencyKey,
            );
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;

            // Reconcile quest completion
            if (localRepo != null) {
              final questData = data is Map<String, dynamic> &&
                      data.containsKey('quest')
                  ? data['quest'] as Map<String, dynamic>
                  : (data is Map<String, dynamic> ? data : null);
              await localRepo.markQuestVerified(questId, serverData: questData);
            }

            // Reconcile Boss damage from reward cascade
            if (bossRepo != null && data is Map<String, dynamic>) {
              final bossDamage = (data['bossDamage'] as num?)?.toInt();
              final bossDefeated = data['bossDefeated'] as bool?;
              final questData = data['quest'] as Map<String, dynamic>?;
              final bossId = questData?['bossId'] as String?;

              if (bossId != null && bossDamage != null && bossDamage > 0) {
                await bossRepo.applyAuthoritativeDamage(
                  bossId,
                  bossDamage,
                  defeated: bossDefeated,
                );
              }
            }
          } on ConflictException catch (_) {
            // Already completed on backend -> mark synced idempotently
            if (localRepo != null) {
              await localRepo.markQuestVerified(questId);
            }
          }
          break;

        case 'CREATE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          final res = await client.post(
            '/quests',
            data: command.payload,
            idempotencyKey: command.idempotencyKey,
          );
          if (localRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            await localRepo.markQuestVerified(
              questId,
              serverData: data is Map<String, dynamic> ? data : null,
            );
          }
          break;

        case 'UPDATE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          final res = await client.patch(
            '/quests/$questId',
            data: command.payload,
          );
          if (localRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            await localRepo.markQuestVerified(
              questId,
              serverData: data is Map<String, dynamic> ? data : null,
            );
          }
          break;

        case 'ARCHIVE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          await client.post('/quests/$questId/archive');
          if (localRepo != null) {
            await localRepo.archiveQuestLocal(questId);
            await localRepo.markQuestVerified(questId);
          }
          break;

        case 'TRASH_QUEST':
        case 'DELETE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          await client.delete('/quests/$questId');
          if (localRepo != null) {
            await localRepo.trashQuestLocal(questId);
            await localRepo.markQuestVerified(questId);
          }
          break;

        case 'RESTORE_QUEST':
          final questId = command.payload['questId'] as String? ?? '';
          await client.post('/quests/$questId/restore');
          if (localRepo != null) {
            await localRepo.restoreQuestLocal(questId);
            await localRepo.markQuestVerified(questId);
          }
          break;

        // ---------------------------------------------------------------------
        // Gate Expedition Commands (SRS §8.8)
        // ---------------------------------------------------------------------
        case 'START_GATE_SESSION':
          final sessionId = command.payload['sessionId'] as String? ?? '';
          try {
            final res = await client.post(
              '/gates/sessions',
              data: {
                'questId': command.payload['questId'],
                'plannedDurationSeconds': command.payload['plannedDurationSeconds'],
              },
              idempotencyKey: command.idempotencyKey,
            );
            if (gateRepo != null) {
              final raw = res;
              final data = raw is Map<String, dynamic> && raw.containsKey('data')
                  ? raw['data']
                  : raw;
              if (data is Map<String, dynamic>) {
                await gateRepo.saveServerSnapshot(data);
              }
            }
          } on ConflictException catch (_) {
            if (gateRepo != null) {
              await gateRepo.updateSessionStatus(
                sessionId,
                status: GateSessionStatus.active,
                syncStatus: 'synced',
              );
            }
          }
          break;

        case 'COMPLETE_GATE_SESSION':
          final sessionId = command.payload['sessionId'] as String? ?? '';
          try {
            final res = await client.post(
              '/gates/sessions/$sessionId/complete',
              idempotencyKey: command.idempotencyKey,
            );
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;

            if (gateRepo != null && data is Map<String, dynamic>) {
              await gateRepo.saveServerSnapshot(data);
            }
          } on ConflictException catch (_) {
            if (gateRepo != null) {
              await gateRepo.updateSessionStatus(
                sessionId,
                status: GateSessionStatus.cleared,
                syncStatus: 'synced',
              );
            }
          }
          break;

        case 'COLLAPSE_GATE_SESSION':
          final sessionId = command.payload['sessionId'] as String? ?? '';
          final difficultyMode =
              command.payload['difficultyMode'] as String? ?? 'casual';
          final exitReason =
              command.payload['exitReason'] as String? ?? 'user_exit';

          try {
            final res = await client.post(
              '/gates/sessions/$sessionId/collapse',
              data: {'exitReason': exitReason},
              options: Options(headers: {'x-difficulty-mode': difficultyMode}),
              idempotencyKey: command.idempotencyKey,
            );
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;

            if (gateRepo != null && data is Map<String, dynamic>) {
              await gateRepo.saveServerSnapshot(data);
            }
          } on ConflictException catch (_) {
            if (gateRepo != null) {
              await gateRepo.updateSessionStatus(
                sessionId,
                status: GateSessionStatus.collapsed,
                syncStatus: 'synced',
              );
            }
          }
          break;

        // ---------------------------------------------------------------------
        // Boss Commands (SRS §8.7)
        // ---------------------------------------------------------------------
        case 'CREATE_BOSS':
          final res = await client.post(
            '/bosses',
            data: command.payload,
            idempotencyKey: command.idempotencyKey,
          );
          if (bossRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            if (data is Map<String, dynamic>) {
              await bossRepo.saveServerSnapshot(data);
            }
          }
          break;

        case 'UPDATE_BOSS':
          final bossId = command.payload['bossId'] as String? ?? '';
          final res = await client.patch(
            '/bosses/$bossId',
            data: command.payload,
          );
          if (bossRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            if (data is Map<String, dynamic>) {
              await bossRepo.saveServerSnapshot(data);
            }
          }
          break;

        case 'ABANDON_BOSS':
          final bossId = command.payload['bossId'] as String? ?? '';
          final res = await client.post('/bosses/$bossId/abandon');
          if (bossRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            if (data is Map<String, dynamic>) {
              await bossRepo.saveServerSnapshot(data);
            }
          }
          break;

        case 'REACTIVATE_BOSS':
          final bossId = command.payload['bossId'] as String? ?? '';
          final res = await client.post('/bosses/$bossId/reactivate');
          if (bossRepo != null) {
            final raw = res;
            final data = raw is Map<String, dynamic> && raw.containsKey('data')
                ? raw['data']
                : raw;
            if (data is Map<String, dynamic>) {
              await bossRepo.saveServerSnapshot(data);
            }
          }
          break;

        case 'TEST_REWARD_COMMAND':
        case 'TEST_SYNC':
          await client.post(
            '/sync/idempotency-test',
            data: {'amount': command.payload['amount'] ?? 100},
            idempotencyKey: command.idempotencyKey,
          );
          break;

        case 'EQUIP_TITLE':
          await client.patch(
            '/character/title',
            data: {'titleId': command.payload['titleId']},
          );
          break;

        default:
          await Future.delayed(const Duration(milliseconds: 20));
          break;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 20));
    }

    developer.log('[SyncEngine] ${command.commandType} successfully synced.');
  }

  void _emitState(SyncState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void dispose() {
    _isDisposed = true;
    _networkSubscription?.cancel();
    _stateController.close();
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final queue = ref.watch(commandQueueProvider);
  final networkService = ref.watch(networkStatusServiceProvider);
  ApiClient? apiClient;
  try {
    apiClient = ref.watch(apiClientProvider);
  } catch (_) {}

  LocalQuestRepository? localQuestRepo;
  LocalBossRepository? localBossRepo;
  LocalGateRepository? localGateRepo;

  try {
    final db = ref.watch(ariseDatabaseProvider);
    localQuestRepo = LocalQuestRepository(db);
    localBossRepo = LocalBossRepository(db);
    localGateRepo = LocalGateRepository(db);
  } catch (_) {}

  final engine = SyncEngine(
    commandQueue: queue,
    networkStatusService: networkService,
    apiClient: apiClient,
    localQuestRepository: localQuestRepo,
    localBossRepository: localBossRepo,
    localGateRepository: localGateRepo,
    onSyncCompleted: () async {
      await ref.read(playerProvider.notifier).refreshFromServer();
    },
  );

  ref.onDispose(engine.dispose);
  return engine;
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.stateStream;
});
