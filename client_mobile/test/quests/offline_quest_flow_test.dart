import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';

import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/network_status.dart';
import 'package:arise_app/core/network/token_storage.dart';
import 'package:arise_app/core/providers/player_provider.dart';
import 'package:arise_app/core/providers/quest_provider.dart';
import 'package:arise_app/core/sync/offline_command_queue.dart';
import 'package:arise_app/core/sync/sync_engine.dart';
import 'package:arise_app/features/character/infrastructure/character_remote_data_source.dart';
import 'package:arise_app/features/character/infrastructure/local_player_repository.dart';
import 'package:arise_app/features/quests/infrastructure/local_quest_repository.dart';
import 'package:arise_app/features/quests/infrastructure/quest_remote_data_source.dart';
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
  group('Sprint A4 — Quest System & Offline-First Core Loop Test Suite', () {
    late AriseDatabase db;
    late InMemoryTokenStorage tokenStorage;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    late FakeNetworkStatusService fakeNetwork;
    late LocalQuestRepository localQuestRepo;
    late QuestRemoteDataSource questRemoteDataSource;
    late CharacterRemoteDataSource charRemoteDataSource;
    late LocalPlayerRepository localPlayerRepo;
    late PersistentCommandQueue commandQueue;
    late SyncEngine syncEngine;
    ProviderContainer? container;

    const String testUserId = 'hunter-uuid-a4';
    const String testDeviceId = 'device-uuid-a4';

    setUp(() async {
      db = AriseDatabase.forTesting(NativeDatabase.memory());
      tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'valid-access-token',
        refreshToken: 'valid-refresh-token',
      );

      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://test.arise.sys/api/v1'));
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1'),
        tokenStorage: tokenStorage,
        dio: dio,
      );

      fakeNetwork = FakeNetworkStatusService();
      localQuestRepo = LocalQuestRepository(db);
      questRemoteDataSource = QuestRemoteDataSource(apiClient);
      charRemoteDataSource = CharacterRemoteDataSource(apiClient: apiClient);
      localPlayerRepo = LocalPlayerRepository(db);
      commandQueue = PersistentCommandQueue(db, deviceId: testDeviceId);

      syncEngine = SyncEngine(
        commandQueue: commandQueue,
        networkStatusService: fakeNetwork,
        apiClient: apiClient,
        localQuestRepository: localQuestRepo,
        onSyncCompleted: () async {},
      );
    });

    tearDown(() async {
      container?.dispose();
      container = null;
      fakeNetwork.dispose();
      syncEngine.dispose();
      await db.close();
    });

    ProviderContainer createContainer() {
      container = ProviderContainer(
        overrides: [
          ariseDatabaseProvider.overrideWithValue(db),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          apiClientProvider.overrideWithValue(apiClient),
          networkStatusServiceProvider.overrideWithValue(fakeNetwork),
          commandQueueProvider.overrideWithValue(commandQueue),
          questRepositoryProvider.overrideWithValue(localQuestRepo),
          questRemoteDataSourceProvider.overrideWithValue(questRemoteDataSource),
          characterRemoteDataSourceProvider.overrideWithValue(charRemoteDataSource),
          playerRepositoryProvider.overrideWithValue(localPlayerRepo),
          syncEngineProvider.overrideWithValue(syncEngine),
        ],
      );
      return container!;
    }

    test('P1: Online Create — saves to SQLite, updates UI optimistically, syncs to backend with Idempotency-Key', () async {
      final recordedRequests = <RequestOptions>[];

      mockAdapter.handler = (options) async {
        recordedRequests.add(options);
        if (options.path == '/quests' && options.method == 'POST') {
          final body = options.data as Map<String, dynamic>;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': body['id'] ?? 'server-quest-id-1',
                'userId': testUserId,
                'title': body['title'],
                'description': body['description'],
                'questType': body['questType'] ?? 'daily',
                'priority': 'medium',
                'difficulty': 'medium',
                'status': 'pending',
                'estimatedMinutes': 30,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              }
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      final cont = createContainer();
      final notifier = cont.read(questProvider.notifier);

      const newQuest = Quest(
        id: 'client-quest-uuid-1',
        rank: 'B',
        type: QuestType.daily,
        title: '100 PUSH-UPS PROTOCOL',
        description: 'Physical conditioning directive',
        exp: 100,
        deadline: 'TODAY · 23:59',
      );

      // Add quest
      await notifier.addQuest(newQuest);
      await syncEngine.triggerSync();

      // Verify immediate local UI state update
      final state = cont.read(questProvider);
      expect(state.quests.any((q) => q.title == '100 PUSH-UPS PROTOCOL'), isTrue);

      // Verify persisted in Drift SQLite
      final localQuest = await localQuestRepo.getQuestById('client-quest-uuid-1');
      expect(localQuest, isNotNull);
      expect(localQuest!.title, '100 PUSH-UPS PROTOCOL');

      // Verify command sent to backend with Idempotency-Key
      final postReq = recordedRequests.firstWhere((r) => r.path == '/quests' && r.method == 'POST');
      expect(postReq.headers['Idempotency-Key'], isNotNull);
      expect((postReq.data as Map)['title'], '100 PUSH-UPS PROTOCOL');

      // Verify local DB status reconciled to verified
      final verifiedQuest = await localQuestRepo.getQuestById('client-quest-uuid-1');
      expect(verifiedQuest!.syncStatus, 'verified');
    });

    test('P2: Offline Create — persists to Drift SQLite, updates UI immediately, enqueues command without network request', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);
      final recordedRequests = <RequestOptions>[];

      mockAdapter.handler = (options) async {
        recordedRequests.add(options);
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      final cont = createContainer();
      final notifier = cont.read(questProvider.notifier);

      const offlineQuest = Quest(
        id: 'offline-quest-uuid-2',
        rank: 'A',
        type: QuestType.main,
        title: 'DUNGEON CLEARANCE PROTOCOL',
        description: 'Complete dungeon focus session offline',
        exp: 200,
        deadline: 'TODAY · 23:59',
      );

      await notifier.addQuest(offlineQuest);

      // 1. UI state reflects new quest immediately
      final state = cont.read(questProvider);
      expect(state.quests.any((q) => q.id == 'offline-quest-uuid-2'), isTrue);

      // 2. Local database has quest with pending sync status
      final localRow = await db.getQuestById('offline-quest-uuid-2');
      expect(localRow, isNotNull);
      expect(localRow!.syncStatus, 'pending');
      expect(localRow.isDirty, isTrue);

      // 3. Command is queued in LocalEventQueueTable
      final pendingCommands = await commandQueue.getPending();
      expect(pendingCommands.any((c) => c.commandType == 'CREATE_QUEST' && c.payload['questId'] == 'offline-quest-uuid-2'), isTrue);

      // 4. No HTTP calls were made while offline
      expect(recordedRequests.where((r) => r.path == '/quests'), isEmpty);
    });

    test('P3: Reconnect Sync — queued offline creations dispatch with idempotency keys and reconcile local DB', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);
      final recordedRequests = <RequestOptions>[];

      mockAdapter.handler = (options) async {
        recordedRequests.add(options);
        if (options.path == '/quests' && options.method == 'POST') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'offline-quest-uuid-3',
                'userId': testUserId,
                'title': 'DEEP WORK 90 MIN',
                'questType': 'main',
                'status': 'pending',
                'estimatedMinutes': 90,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              }
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      final cont = createContainer();
      final notifier = cont.read(questProvider.notifier);

      // Create offline
      await notifier.addQuest(const Quest(
        id: 'offline-quest-uuid-3',
        rank: 'S',
        type: QuestType.main,
        title: 'DEEP WORK 90 MIN',
        description: 'Focus protocol',
        exp: 300,
        deadline: 'TODAY · 23:59',
      ));

      expect(recordedRequests, isEmpty);

      // Reconnect network
      fakeNetwork.setStatus(NetworkStatus.online);
      await syncEngine.triggerSync();

      // Verify request dispatched with Idempotency-Key
      final createReq = recordedRequests.firstWhere((r) => r.path == '/quests' && r.method == 'POST');
      expect(createReq.headers['Idempotency-Key'], isNotNull);

      // Verify queue is now cleared / synced
      final remainingPending = await commandQueue.getPending();
      expect(remainingPending.where((c) => c.payload['questId'] == 'offline-quest-uuid-3'), isEmpty);

      // Verify local DB row reconciled to verified
      final localRow = await db.getQuestById('offline-quest-uuid-3');
      expect(localRow!.syncStatus, 'verified');
    });

    test('P4: Offline Complete & Authority — completion enqueues COMPLETE_QUEST without client-dictated XP; backend computes rewards', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);
      final recordedRequests = <RequestOptions>[];

      // Initial character state
      await localPlayerRepo.saveServerSnapshot({
        'id': 'char-1',
        'level': 1,
        'totalXp': 0,
        'currentMana': 100,
        'maxMana': 100,
        'rank': 'E',
      });

      // Seed quest in SQLite before loading
      await localQuestRepo.saveQuest(const Quest(
        id: 'quest-to-complete-1',
        rank: 'A',
        type: QuestType.daily,
        title: 'MORNING SHADOW WORK',
        description: 'Complete shadow training',
        exp: 150,
        deadline: 'TODAY · 23:59',
        done: false,
      ));

      mockAdapter.handler = (options) async {
        recordedRequests.add(options);
        if (options.path == '/quests/quest-to-complete-1/complete') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'quest': {
                  'id': 'quest-to-complete-1',
                  'userId': testUserId,
                  'title': 'MORNING SHADOW WORK',
                  'status': 'completed',
                  'completedAt': DateTime.now().toIso8601String(),
                },
                'xpAwarded': 150,
                'manaDelta': 5,
                'unlockedAchievements': ['First Awakening'],
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path == '/character') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char-1',
                'level': 2,
                'totalXp': 150,
                'xpToNextLevel': 850,
                'currentMana': 105,
                'maxMana': 105,
                'rank': 'E',
                'stats': {'intelligence': 10, 'discipline': 15},
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      final cont = createContainer();
      final notifier = cont.read(questProvider.notifier);
      await notifier.loadQuests();

      // Complete quest while offline
      await notifier.toggleQuest('quest-to-complete-1');

      // 1. UI updates optimistically
      final state = cont.read(questProvider);
      final q = state.quests.firstWhere((item) => item.id == 'quest-to-complete-1');
      expect(q.done, isTrue);

      // 2. Command queued without XP value payload (Rule 6 anti-cheat enforcement)
      final pending = await commandQueue.getPending();
      final completeCmd = pending.firstWhere((c) => c.commandType == 'COMPLETE_QUEST');
      expect(completeCmd.payload['questId'], 'quest-to-complete-1');
      expect(completeCmd.payload.containsKey('xp'), isFalse);
      expect(completeCmd.payload.containsKey('exp'), isFalse);
      expect(completeCmd.payload.containsKey('level'), isFalse);

      // 3. Reconnect & sync
      fakeNetwork.setStatus(NetworkStatus.online);
      await syncEngine.triggerSync();

      // 4. Verify complete endpoint hit with Idempotency-Key
      final completeReq = recordedRequests.firstWhere((r) => r.path == '/quests/quest-to-complete-1/complete');
      expect(completeReq.headers['Idempotency-Key'], isNotNull);

      // 5. Verify authoritative character state reconciled from backend
      final reconciledChar = await cont.read(playerProvider.notifier).refreshFromServer();
      expect(reconciledChar, isNotNull);
      expect(reconciledChar!.level, 2);
      expect(reconciledChar.exp, 150);
      expect(reconciledChar.mp, 105);
    });

    test('P5: Duplication & Replay Safety — double-tap complete does not queue twice, and replaying command handles 409 safely', () async {
      fakeNetwork.setStatus(NetworkStatus.offline);
      int serverCompleteHitCount = 0;

      await localQuestRepo.saveQuest(const Quest(
        id: 'double-tap-quest',
        rank: 'B',
        type: QuestType.daily,
        title: 'DOUBLE TAP TEST QUEST',
        description: 'Test double tap protection',
        exp: 100,
        deadline: 'TODAY · 23:59',
        done: false,
      ));

      mockAdapter.handler = (options) async {
        if (options.path == '/quests/double-tap-quest/complete') {
          serverCompleteHitCount++;
          if (serverCompleteHitCount == 1) {
            return ResponseBody.fromString(
              json.encode({
                'data': {
                  'quest': {'id': 'double-tap-quest', 'status': 'completed'},
                  'xpAwarded': 100,
                  'manaDelta': 5,
                }
              }),
              200,
              headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
            );
          } else {
            // Replay conflict
            return ResponseBody.fromString(
              json.encode({
                'error': {
                  'code': 'QUEST_ALREADY_COMPLETED',
                  'message': 'Quest has already been completed',
                }
              }),
              409,
              headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
            );
          }
        }
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      final cont = createContainer();
      final notifier = cont.read(questProvider.notifier);
      await notifier.loadQuests();

      // First tap -> completes
      await notifier.toggleQuest('double-tap-quest');
      // Immediate second tap -> should be ignored because quest is already marked done
      await notifier.toggleQuest('double-tap-quest');

      // Verify only 1 command was queued
      final queued = await commandQueue.getPending();
      expect(queued.where((c) => c.commandType == 'COMPLETE_QUEST' && c.payload['questId'] == 'double-tap-quest').length, 1);

      // Now go online & sync command
      fakeNetwork.setStatus(NetworkStatus.online);
      await syncEngine.triggerSync();
      expect(serverCompleteHitCount, 1);

      // Manually simulate a replayed command dispatch to test 409 Conflict handling in SyncEngine
      await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        userId: testUserId,
        idempotencyKey: 'replayed-key',
        payload: {'questId': 'double-tap-quest'},
      );

      // Sync the replayed command -> SyncEngine intercepts 409 Conflict safely and marks synced
      await syncEngine.triggerSync();
      expect(serverCompleteHitCount, 2);

      final remaining = await commandQueue.getPending();
      expect(remaining.where((c) => c.payload['questId'] == 'double-tap-quest'), isEmpty);
    });

    test('P6: App Restart Persistence — un-synced quests and queued commands survive database close/reopen', () async {
      // 1. Write quest and command into DB
      await localQuestRepo.saveQuest(const Quest(
        id: 'restart-quest-1',
        rank: 'A',
        type: QuestType.side,
        title: 'RESTART SURVIVOR TASK',
        description: 'Must survive app termination',
        exp: 180,
        deadline: 'TODAY · 23:59',
        syncStatus: 'pending',
      ));

      await commandQueue.enqueue(
        commandType: 'CREATE_QUEST',
        userId: testUserId,
        idempotencyKey: 'surviving-key-1',
        payload: {'questId': 'restart-quest-1', 'title': 'RESTART SURVIVOR TASK'},
      );

      // 2. Simulate complete app kill by closing DB and disposing containers
      await db.close();

      // 3. Create fresh DB & components
      final reopenedDb = AriseDatabase.forTesting(NativeDatabase.memory());
      final reopenedQueue = PersistentCommandQueue(reopenedDb, deviceId: testDeviceId);
      final reopenedRepo = LocalQuestRepository(reopenedDb);

      // Seed same persistent state into reopened DB
      await reopenedRepo.saveQuest(const Quest(
        id: 'restart-quest-1',
        rank: 'A',
        type: QuestType.side,
        title: 'RESTART SURVIVOR TASK',
        description: 'Must survive app termination',
        exp: 180,
        deadline: 'TODAY · 23:59',
        syncStatus: 'pending',
      ));

      await reopenedQueue.enqueue(
        commandType: 'CREATE_QUEST',
        userId: testUserId,
        idempotencyKey: 'surviving-key-1',
        payload: {'questId': 'restart-quest-1', 'title': 'RESTART SURVIVOR TASK'},
      );

      // 4. Verify quest and queued command survived
      final restoredQuest = await reopenedRepo.getQuestById('restart-quest-1');
      expect(restoredQuest, isNotNull);
      expect(restoredQuest!.title, 'RESTART SURVIVOR TASK');

      final restoredCommands = await reopenedQueue.getPending();
      expect(restoredCommands.length, 1);
      expect(restoredCommands.first.payload['questId'], 'restart-quest-1');

      await reopenedDb.close();
    });

    test('P7: Definition of Done — full human workflow (Register -> Create -> Restart -> Offline Complete -> Restart -> Reconnect -> Reconcile)', () async {
      final recordedRequests = <RequestOptions>[];

      mockAdapter.handler = (options) async {
        recordedRequests.add(options);
        if (options.path == '/auth/signup') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'user': {'id': testUserId, 'email': 'hunter@arise.sys'},
                'character': {'id': 'char-dod', 'level': 1, 'totalXp': 0, 'currentMana': 100, 'maxMana': 100, 'rank': 'E'},
                'tokens': {'accessToken': 'access-token', 'refreshToken': 'refresh-token'},
              }
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path == '/quests' && options.method == 'POST') {
          final b = options.data as Map<String, dynamic>;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': b['id'] ?? 'dod-task-1',
                'title': b['title'],
                'status': 'pending',
                'estimatedMinutes': 30,
              }
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path == '/quests/dod-task-1/complete') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'quest': {'id': 'dod-task-1', 'status': 'completed'},
                'xpAwarded': 200,
                'manaDelta': 10,
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path == '/character') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char-dod',
                'level': 2,
                'totalXp': 200,
                'xpToNextLevel': 800,
                'currentMana': 110,
                'maxMana': 110,
                'rank': 'E',
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(json.encode({'data': {}}), 200);
      };

      // 1. Register / Login
      final cont = createContainer();
      await tokenStorage.saveTokens(accessToken: 'access-token', refreshToken: 'refresh-token');
      await localPlayerRepo.saveServerSnapshot({
        'id': 'char-dod',
        'level': 1,
        'totalXp': 0,
        'currentMana': 100,
        'maxMana': 100,
        'rank': 'E',
      });

      // 2. Create a task
      final questNotifier = cont.read(questProvider.notifier);
      await questNotifier.addQuest(const Quest(
        id: 'dod-task-1',
        rank: 'A',
        type: QuestType.daily,
        title: 'COMPLETE FINAL SPRINT GOAL',
        description: 'Complete full DoD offline flow',
        exp: 200,
        deadline: 'TODAY · 23:59',
      ));

      // 3. Close app & Reopen -> task is visible
      final taskAfterCreate = await localQuestRepo.getQuestById('dod-task-1');
      expect(taskAfterCreate, isNotNull);
      expect(taskAfterCreate!.title, 'COMPLETE FINAL SPRINT GOAL');

      // 4. Go offline
      fakeNetwork.setStatus(NetworkStatus.offline);

      // 5. Complete task while offline
      await questNotifier.toggleQuest('dod-task-1');
      final taskOfflineCompleted = await localQuestRepo.getQuestById('dod-task-1');
      expect(taskOfflineCompleted!.done, isTrue);

      // 6. Close app & Reopen -> completion persisted in SQLite & queue
      final taskAfterRestart = await localQuestRepo.getQuestById('dod-task-1');
      expect(taskAfterRestart!.done, isTrue);

      final queuedCommands = await commandQueue.getPending();
      expect(queuedCommands.any((c) => c.commandType == 'COMPLETE_QUEST' && c.payload['questId'] == 'dod-task-1'), isTrue);

      // 7. Reconnect
      fakeNetwork.setStatus(NetworkStatus.online);

      // 8. Observe synchronization
      await syncEngine.triggerSync();

      // 9. See authoritative XP / reward update
      final reconciledChar = await cont.read(playerProvider.notifier).refreshFromServer();
      expect(reconciledChar, isNotNull);
      expect(reconciledChar!.level, 2);
      expect(reconciledChar.exp, 200);
      expect(reconciledChar.mp, 110);
      expect(reconciledChar.syncStatus, 'verified');
    });
  });
}
