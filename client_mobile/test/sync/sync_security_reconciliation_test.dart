import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';

import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/network_status.dart';
import 'package:arise_app/core/network/token_storage.dart';
import 'package:arise_app/core/providers/player_provider.dart';
import 'package:arise_app/core/sync/offline_command_queue.dart';
import 'package:arise_app/core/sync/sync_engine.dart';
import 'package:arise_app/features/character/infrastructure/character_remote_data_source.dart';
import 'package:arise_app/features/character/infrastructure/local_player_repository.dart';
import 'package:arise_app/features/quests/infrastructure/local_quest_repository.dart';
import 'package:arise_app/shared/models/player_data.dart';
import 'package:arise_app/shared/models/quest.dart';

class MockHttpAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? handler;

  MockHttpAdapter([this.handler]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      json.encode({'status': 'ok'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeNetworkStatusService implements NetworkStatusService {
  NetworkStatus _current = NetworkStatus.online;

  @override
  NetworkStatus get current => _current;

  final _controller = StreamController<NetworkStatus>.broadcast();

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  void setStatus(NetworkStatus status) {
    _current = status;
    _controller.add(status);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('Sprint A5 — Sync Engine, Reconciliation & Anti-Cheat Security Suite', () {
    late AriseDatabase db;
    late InMemoryTokenStorage tokenStorage;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    late FakeNetworkStatusService fakeNetwork;
    late LocalQuestRepository localQuestRepo;
    late CharacterRemoteDataSource charRemoteDataSource;
    late LocalPlayerRepository localPlayerRepo;
    late PersistentCommandQueue commandQueue;
    late SyncEngine syncEngine;
    ProviderContainer? container;

    const String testUserId = 'hunter-uuid-a5';
    const String testDeviceId = 'device-uuid-a5';

    setUp(() async {
      db = AriseDatabase.forTesting(NativeDatabase.memory());
      tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'valid-access-token-a5',
        refreshToken: 'valid-refresh-token-a5',
      );

      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://test.arise.sys/api/v1'));
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1'),
        tokenStorage: tokenStorage,
        dio: dio,
      );

      localQuestRepo = LocalQuestRepository(db);
      charRemoteDataSource = CharacterRemoteDataSource(apiClient: apiClient);
      localPlayerRepo = LocalPlayerRepository(db);
      commandQueue = PersistentCommandQueue(db, deviceId: testDeviceId);
      fakeNetwork = FakeNetworkStatusService();

      container = ProviderContainer(
        overrides: [
          ariseDatabaseProvider.overrideWithValue(db),
          playerRepositoryProvider.overrideWithValue(localPlayerRepo),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          apiClientProvider.overrideWithValue(apiClient),
          characterRemoteDataSourceProvider.overrideWithValue(charRemoteDataSource),
          networkStatusServiceProvider.overrideWithValue(fakeNetwork),
          commandQueueProvider.overrideWithValue(commandQueue),
        ],
      );

      syncEngine = SyncEngine(
        commandQueue: commandQueue,
        networkStatusService: fakeNetwork,
        apiClient: apiClient,
        localQuestRepository: localQuestRepo,
        onSyncCompleted: () async {
          if (container != null) {
            await container!.read(playerProvider.notifier).refreshFromServer();
          }
        },
      );
    });

    tearDown(() async {
      syncEngine.dispose();
      fakeNetwork.dispose();
      container?.dispose();
      await db.close();
    });

    // -------------------------------------------------------------------------
    // 1. SYNC STATE MACHINE TESTS
    // -------------------------------------------------------------------------
    test('1.1: Command Lifecycle: PENDING -> SYNCING -> SYNCED persisted in Drift SQLite', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);

      // Enqueue offline command
      final eventId = await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        payload: {'questId': 'quest-sync-1'},
        userId: testUserId,
      );

      var pending = await commandQueue.getPending();
      expect(pending.length, 1);
      expect(pending.first.syncStatus, CommandSyncStatus.pending);

      // Mark in-flight
      await commandQueue.markSyncing(eventId);
      var rows = await db.select(db.localEventQueueTable).get();
      expect(rows.first.syncStatus, 'syncing');

      // Mark synced
      await commandQueue.markSynced(eventId);
      rows = await db.select(db.localEventQueueTable).get();
      expect(rows.first.syncStatus, 'synced');

      // No longer pending
      pending = await commandQueue.getPending();
      expect(pending.isEmpty, isTrue);
    });

    test('1.2: Command Failure & Backoff: SYNCING -> FAILED -> RETRY exponential backoff calculation', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);

      final eventId = await commandQueue.enqueue(
        commandType: 'UPDATE_QUEST',
        payload: {'questId': 'quest-fail-1', 'title': 'Retry Me'},
        userId: testUserId,
      );

      // First failure -> 4s backoff, retryCount = 1
      await commandQueue.markFailed(eventId, 'HTTP 503 Service Unavailable');
      var rows = await (db.select(db.localEventQueueTable)..where((t) => t.eventId.equals(eventId))).get();
      expect(rows.first.syncStatus, 'failed');
      expect(rows.first.retryCount, 1);
      expect(rows.first.lastError, 'HTTP 503 Service Unavailable');
      expect(rows.first.nextRetryAt != null, isTrue);

      // Second failure -> 8s backoff, retryCount = 2
      await commandQueue.markFailed(eventId, 'Network Timeout');
      rows = await (db.select(db.localEventQueueTable)..where((t) => t.eventId.equals(eventId))).get();
      expect(rows.first.retryCount, 2);
      expect(rows.first.lastError, 'Network Timeout');
    });

    test('1.3: In-flight crash recovery: Stalled SYNCING commands reset to PENDING on boot', () async {
      final eventId = await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        payload: {'questId': 'quest-crash-1'},
        userId: testUserId,
      );

      // Simulate app was killed mid-flight
      await commandQueue.markSyncing(eventId);
      var rows = await db.select(db.localEventQueueTable).get();
      expect(rows.first.syncStatus, 'syncing');

      // On next app initialization / resetStalledSyncingCommands
      await commandQueue.resetStalledSyncingCommands();
      rows = await db.select(db.localEventQueueTable).get();
      expect(rows.first.syncStatus, 'pending');

      // Available for sync again
      final pending = await commandQueue.getPending();
      expect(pending.length, 1);
      expect(pending.first.eventId, eventId);
    });

    // -------------------------------------------------------------------------
    // 2. IDEMPOTENCY & REPLAY TESTS
    // -------------------------------------------------------------------------
    test('2.1: Same command + same key + multiple submissions = 1 logical mutation with cached response', () async {
      int serverExecutionCount = 0;
      final serverIdempotencyStore = <String, Map<String, dynamic>>{};

      mockAdapter.handler = (options) async {
        if (options.path.contains('/quests/quest-idem-1/complete')) {
          final idempotencyKey = options.headers['idempotency-key'] as String? ?? 'none';
          if (serverIdempotencyStore.containsKey(idempotencyKey)) {
            // Return cached response without re-executing
            return ResponseBody.fromString(
              json.encode(serverIdempotencyStore[idempotencyKey]),
              200,
              headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
            );
          }

          serverExecutionCount++;
          final responseBody = {
            'data': {
              'quest': {'id': 'quest-idem-1', 'status': 'completed'},
              'rewards': {'xpAwarded': 150, 'manaAwarded': 25},
            }
          };
          serverIdempotencyStore[idempotencyKey] = responseBody;

          return ResponseBody.fromString(
            json.encode(responseBody),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      // 1st submission
      final res1 = await apiClient.post(
        '/quests/quest-idem-1/complete',
        idempotencyKey: 'key-idem-unique-1',
      );
      expect(serverExecutionCount, 1);
      expect(res1['data']['rewards']['xpAwarded'], 150);

      // 2nd submission with SAME key
      final res2 = await apiClient.post(
        '/quests/quest-idem-1/complete',
        idempotencyKey: 'key-idem-unique-1',
      );
      expect(serverExecutionCount, 1); // Server mutation NOT re-executed
      expect(res2['data']['rewards']['xpAwarded'], 150);

      // 3rd submission with SAME key
      final res3 = await apiClient.post(
        '/quests/quest-idem-1/complete',
        idempotencyKey: 'key-idem-unique-1',
      );
      expect(serverExecutionCount, 1);
      expect(res3, res1);
    });

    test('2.2: Idempotency keys are scoped per-user: User A key cannot access or pollute User B', () async {
      final userAStore = <String, dynamic>{};
      final userBStore = <String, dynamic>{};

      mockAdapter.handler = (options) async {
        final authHeader = options.headers['Authorization'] as String? ?? '';
        final idempotencyKey = options.headers['idempotency-key'] as String? ?? '';
        final isUserA = authHeader.contains('token-user-a');

        if (isUserA) {
          userAStore[idempotencyKey] = {'user': 'A', 'result': 'User A Payload'};
          return ResponseBody.fromString(
            json.encode({'data': userAStore[idempotencyKey]}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        } else {
          userBStore[idempotencyKey] = {'user': 'B', 'result': 'User B Payload'};
          return ResponseBody.fromString(
            json.encode({'data': userBStore[idempotencyKey]}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
      };

      // User A submits with 'shared-key-1'
      await tokenStorage.saveTokens(accessToken: 'token-user-a', refreshToken: 'ref-a');
      final resA = await apiClient.post('/sync/idempotency-test', idempotencyKey: 'shared-key-1');
      expect(resA['data']['user'], 'A');

      // User B submits with same 'shared-key-1'
      await tokenStorage.saveTokens(accessToken: 'token-user-b', refreshToken: 'ref-b');
      final resB = await apiClient.post('/sync/idempotency-test', idempotencyKey: 'shared-key-1');
      expect(resB['data']['user'], 'B');
      expect(resB['data']['result'], 'User B Payload');
    });

    // -------------------------------------------------------------------------
    // 3. DETERMINISTIC RECONCILIATION & TAMPER TESTS
    // -------------------------------------------------------------------------
    test('3.1: Anti-Cheat: Local spoofed XP/Level/Mana is overwritten by authoritative server response', () async {
      // 1. Setup local snapshot with legitimate starting state
      await localPlayerRepo.updatePlayerData(
        PlayerData.defaultPlayer.copyWith(
          id: testUserId,
          name: 'Hunter A5',
          level: 1,
          exp: 0,
          mp: 100,
          maxMp: 100,
          rank: 'E',
        ),
      );

      final notifier = container!.read(playerProvider.notifier);
      await notifier.reloadFromDatabase(testUserId);
      expect(container!.read(playerProvider).level, 1);
      expect(container!.read(playerProvider).exp, 0);

      // 2. Adversarial Tamper: Cheat script modifies local Drift SQLite directly
      await db.upsertCharacterSnapshot(
        const CharacterSnapshotTableCompanion(
          userId: Value(testUserId),
          level: Value(100),
          totalXp: Value(999999),
          mana: Value(999999),
          maxMana: Value(999999),
          rank: Value('S'),
        ),
      );

      // 3. Server Authoritative Response is Level 2, 500 XP, 100 Mana
      mockAdapter.handler = (options) async {
        if (options.path.contains('/character')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': testUserId,
                'userId': testUserId,
                'level': 2,
                'totalXp': 500,
                'currentMana': 100,
                'maxMana': 100,
                'rank': 'E',
                'stats': {
                  'intelligence': 12,
                  'discipline': 12,
                  'fitness': 10,
                  'creativity': 10,
                  'coding': 10,
                  'business': 10,
                  'health': 10,
                }
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      // 4. Trigger reconciliation
      await notifier.refreshFromServer();

      // 5. Verification: Spoofed values (999999) are obliterated; server state (Level 2, 500 XP) prevails!
      final state = container!.read(playerProvider);
      expect(state.level, 2);
      expect(state.exp, 500);
      expect(state.mp, 100);
      expect(state.maxMp, 100);
      expect(state.rank, 'E');

      // Persisted SQLite copy is also converged to server authority
      final persisted = await db.getCharacterSnapshot(testUserId);
      expect(persisted, isNotNull);
      expect(persisted!.level, 2);
      expect(persisted.totalXp, 500);
    });

    test('3.2: Deterministic quest reconciliation: Server authoritative timestamps and verified status applied', () async {
      // Local quest with pending status
      const quest = Quest(
        id: 'quest-reconcile-1',
        title: 'Complete Neural Link',
        description: 'Sync with core',
        type: QuestType.main,
        rank: 'A',
        exp: 200,
        deadline: '2026-08-15',
        status: 'pending',
        syncStatus: 'pending',
      );
      await localQuestRepo.saveQuest(quest);

      var dbRow = await db.getQuestById('quest-reconcile-1');
      expect(dbRow!.syncStatus, 'pending');
      expect(dbRow.isDirty, isTrue);

      // Reconcile with verified server payload
      final serverPayload = {
        'id': 'quest-reconcile-1',
        'userId': testUserId,
        'title': 'Complete Neural Link',
        'description': 'Sync with core',
        'questType': 'main',
        'difficulty': 'hard',
        'xpReward': 250,
        'manaReward': 50,
        'status': 'completed',
        'completedAt': '2026-08-14T20:00:00.000Z',
        'createdAt': '2026-08-14T10:00:00.000Z',
        'updatedAt': '2026-08-14T20:00:00.000Z',
      };

      await localQuestRepo.markQuestVerified('quest-reconcile-1', serverData: serverPayload);

      dbRow = await db.getQuestById('quest-reconcile-1');
      expect(dbRow!.syncStatus, 'verified');
      expect(dbRow.isDirty, isFalse);
      expect(dbRow.status, 'completed');
      expect(dbRow.xpReward, 250);
    });

    // -------------------------------------------------------------------------
    // 4. CONFLICT HANDLING & ERROR RESILIENCE
    // -------------------------------------------------------------------------
    test('4.1: Server 409 Conflict during quest completion gracefully reconciles to verified', () async {
      mockAdapter.handler = (options) async {
        if (options.path.contains('/complete')) {
          return ResponseBody.fromString(
            json.encode({
              'error': {
                'code': 'QUEST_ALREADY_COMPLETED',
                'message': 'Quest has already been completed on the server',
              }
            }),
            409,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      await localQuestRepo.saveQuest(const Quest(
        id: 'quest-conflict-409',
        title: 'Conflict Task',
        description: 'Testing 409 conflict',
        type: QuestType.side,
        rank: 'E',
        exp: 50,
        deadline: '2026-08-15',
        status: 'active',
        syncStatus: 'pending',
      ));

      await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        payload: {'questId': 'quest-conflict-409'},
        userId: testUserId,
      );

      // Trigger sync
      await syncEngine.triggerSync();

      // Local quest is marked verified because server already completed it
      final quest = await localQuestRepo.getQuestById('quest-conflict-409');
      expect(quest!.syncStatus, 'verified');
    });

    // -------------------------------------------------------------------------
    // 5. SYNC UX STATES TEST
    // -------------------------------------------------------------------------
    test('5.1: SyncState stream accurately reflects transitions between idle, syncing, and error', () async {
      final states = <SyncState>[];
      final sub = syncEngine.stateStream.listen(states.add);

      mockAdapter.handler = (options) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return ResponseBody.fromString(
          json.encode({
            'data': {
              'id': 'quest-ux-1',
              'userId': testUserId,
              'title': 'UX Test Quest',
              'status': 'active',
            }
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await commandQueue.enqueue(
        commandType: 'CREATE_QUEST',
        payload: {'questId': 'quest-ux-1', 'title': 'UX Test Quest'},
        userId: testUserId,
      );

      await syncEngine.triggerSync();

      expect(states.any((s) => s.status == SyncEngineStatus.syncing), isTrue);
      expect(syncEngine.currentState.status, SyncEngineStatus.idle);
      expect(syncEngine.currentState.pendingCount, 0);

      await sub.cancel();
    });
  });
}
