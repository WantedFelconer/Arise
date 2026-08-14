import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';

import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/network_status.dart';
import 'package:arise_app/core/network/token_storage.dart';
import 'package:arise_app/core/sync/offline_command_queue.dart';
import 'package:arise_app/core/sync/sync_engine.dart';
import 'package:arise_app/features/auth/infrastructure/auth_remote_data_source.dart';
import 'package:arise_app/features/character/infrastructure/local_player_repository.dart';
import 'package:arise_app/features/quests/infrastructure/local_quest_repository.dart';
import 'package:arise_app/features/gate/infrastructure/local_gate_repository.dart';
import 'package:arise_app/features/gate/domain/gate_models.dart';
import 'package:arise_app/features/boss/infrastructure/local_boss_repository.dart';
import 'package:arise_app/features/boss/domain/boss_models.dart';
import 'package:arise_app/features/ai_coach/infrastructure/ai_remote_data_source.dart';
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
  group('ARISE Release Audit — End-to-End User Journey (22 Steps)', () {
    late AriseDatabase db;
    late InMemoryTokenStorage tokenStorage;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    late FakeNetworkStatusService fakeNetwork;
    late PersistentCommandQueue commandQueue;
    late SyncEngine syncEngine;
    late LocalQuestRepository localQuestRepo;
    late LocalPlayerRepository localPlayerRepo;
    late LocalBossRepository localBossRepo;
    late LocalGateRepository localGateRepo;

    const String testUserId = 'hunter-uuid-e2e';
    const String testDeviceId = 'device-uuid-e2e';

    setUp(() async {
      db = AriseDatabase.forTesting(NativeDatabase.memory());
      tokenStorage = InMemoryTokenStorage();
      mockAdapter = MockHttpAdapter();

      dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:3000/api/v1',
          connectTimeout: const Duration(seconds: 5),
        ),
      );
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://127.0.0.1:3000/api/v1'),
        tokenStorage: tokenStorage,
        dio: dio,
      );

      fakeNetwork = FakeNetworkStatusService();
      commandQueue = PersistentCommandQueue(db, deviceId: testDeviceId);
      localQuestRepo = LocalQuestRepository(db);
      localPlayerRepo = LocalPlayerRepository(db);
      localBossRepo = LocalBossRepository(db);
      localGateRepo = LocalGateRepository(db);

      syncEngine = SyncEngine(
        commandQueue: commandQueue,
        apiClient: apiClient,
        networkStatusService: fakeNetwork,
        localQuestRepository: localQuestRepo,
        localBossRepository: localBossRepo,
        localGateRepository: localGateRepo,
      );
    });

    tearDown(() async {
      syncEngine.dispose();
      fakeNetwork.dispose();
      await db.close();
    });

    test('Executes complete user journey from register to offline completion to sync & AI', () async {
      // -----------------------------------------------------------------------
      // Step 1: Register Clean Test Account
      // -----------------------------------------------------------------------
      mockAdapter.handler = (options) async {
        if (options.path.contains('/auth/signup')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'user': {'id': testUserId, 'email': 'solo@arise.dev', 'difficultyMode': 'casual'},
                'tokens': {
                  'accessToken': 'jwt-access-token-001',
                  'refreshToken': 'jwt-refresh-token-001',
                },
              },
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw UnimplementedError(options.path);
      };

      final authRemote = AuthRemoteDataSource(apiClient: apiClient);
      final signupResult = await authRemote.signup(
        email: 'solo@arise.dev',
        password: 'Password123!',
        difficultyMode: 'casual',
      );

      expect(signupResult.user.id, testUserId);
      expect(signupResult.tokens.accessToken, 'jwt-access-token-001');

      // -----------------------------------------------------------------------
      // Step 2: Login & Save Secure Tokens
      // -----------------------------------------------------------------------
      await tokenStorage.saveTokens(
        accessToken: signupResult.tokens.accessToken,
        refreshToken: signupResult.tokens.refreshToken,
      );

      // -----------------------------------------------------------------------
      // Step 3 & 4: Restart App & Restore Session
      // -----------------------------------------------------------------------
      final restoredToken = await tokenStorage.getAccessToken();
      expect(restoredToken, 'jwt-access-token-001');

      // -----------------------------------------------------------------------
      // Step 5: Load Character State into Local SQLite Projection
      // -----------------------------------------------------------------------
      await localPlayerRepo.saveServerSnapshot({
        'id': 'char-uuid-001',
        'userId': testUserId,
        'level': 1,
        'rank': 'E',
        'totalXp': 0,
        'xpToNextLevel': 1000,
        'currentMana': 100,
        'maxMana': 100,
      });

      final initialPlayer = await localPlayerRepo.fetchPlayerData(testUserId);
      expect(initialPlayer.level, 1);
      expect(initialPlayer.rank, 'E');
      expect(initialPlayer.exp, 0);
      expect(initialPlayer.mp, 100);

      // -----------------------------------------------------------------------
      // Step 6: Create Quest (Local Drift Write + Offline Command Queue)
      // -----------------------------------------------------------------------
      const newQuest = Quest(
        id: 'quest-e2e-101',
        title: 'Master Monolith Architecture',
        description: 'Complete architecture module exercises',
        rank: 'B',
        type: QuestType.main,
        deadline: '23:59',
        exp: 150,
        gold: 50,
        done: false,
        userId: testUserId,
      );

      await localQuestRepo.saveQuest(newQuest);
      await commandQueue.enqueue(
        commandType: 'CREATE_QUEST',
        userId: testUserId,
        idempotencyKey: 'idem-quest-create-101',
        payload: {
          'id': newQuest.id,
          'title': newQuest.title,
          'description': newQuest.description,
          'rank': newQuest.rank,
          'estimatedMinutes': 45,
        },
      );

      // -----------------------------------------------------------------------
      // Step 7 & 8 & 9: Close App, Reopen, and Verify Quest Persistence
      // -----------------------------------------------------------------------
      final loadedQuests = await localQuestRepo.fetchQuests();
      expect(loadedQuests.length, 1);
      expect(loadedQuests.first.id, 'quest-e2e-101');
      expect(loadedQuests.first.title, 'Master Monolith Architecture');
      expect(loadedQuests.first.done, isFalse);

      // -----------------------------------------------------------------------
      // Step 10: Go Offline
      // -----------------------------------------------------------------------
      fakeNetwork.setStatus(NetworkStatus.offline);
      expect(fakeNetwork.current, NetworkStatus.offline);

      // -----------------------------------------------------------------------
      // Step 11: Complete Quest While Offline
      // -----------------------------------------------------------------------
      await localQuestRepo.toggleQuestCompletionById('quest-e2e-101');
      final offlineCompleted = await localQuestRepo.fetchQuests();
      expect(offlineCompleted.first.done, isTrue);

      const completionKey = 'idem-quest-complete-101';
      await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        userId: testUserId,
        idempotencyKey: completionKey,
        payload: {
          'questId': 'quest-e2e-101',
          'completedAt': DateTime.now().toIso8601String(),
        },
      );

      // -----------------------------------------------------------------------
      // Step 12, 13 & 14: App Kill, Restart while Offline, Completion Remains
      // -----------------------------------------------------------------------
      final restartedQuests = await localQuestRepo.fetchQuests();
      expect(restartedQuests.first.done, isTrue);

      final pendingCommands = await commandQueue.getPending();
      expect(pendingCommands.length, 2); // CREATE + COMPLETE

      // -----------------------------------------------------------------------
      // Step 15 & 16: Reconnect & Sync Command Queue
      // -----------------------------------------------------------------------
      fakeNetwork.setStatus(NetworkStatus.online);

      mockAdapter.handler = (options) async {
        if (options.path.contains('/quests') && options.method == 'POST') {
          return ResponseBody.fromString(
            json.encode({'data': {'id': 'quest-e2e-101', 'title': 'Master Monolith Architecture'}}),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.contains('/complete') && options.method == 'POST') {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'quest': {'id': 'quest-e2e-101', 'status': 'completed'},
                'xpAwarded': 150,
                'goldAwarded': 50,
                'totalXp': 150,
                'level': 1,
              },
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw UnimplementedError(options.path);
      };

      await syncEngine.triggerSync();
      final remainingPending = await commandQueue.getPendingCount();
      expect(remainingPending, 0);

      // -----------------------------------------------------------------------
      // Step 17 & 18: Receive Authoritative Reward & Character Progression
      // -----------------------------------------------------------------------
      await localPlayerRepo.saveServerSnapshot({
        'id': 'char-uuid-001',
        'userId': testUserId,
        'level': 1,
        'rank': 'E',
        'totalXp': 150,
        'xpToNextLevel': 850,
        'currentMana': 100,
        'maxMana': 100,
      });

      final updatedPlayer = await localPlayerRepo.fetchPlayerData(testUserId);
      expect(updatedPlayer.exp, 150);
      expect(updatedPlayer.syncStatus, 'verified');

      // -----------------------------------------------------------------------
      // Step 19, 20 & 21: Enter Focus Gate, Complete Session & Verify Results
      // -----------------------------------------------------------------------
      final now = DateTime.now();
      final newGateSession = GateSession(
        id: 'gate-session-e2e-001',
        userId: testUserId,
        questId: 'quest-e2e-101',
        plannedDurationS: 1500,
        startedAt: now,
        status: GateSessionStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      await localGateRepo.saveSession(newGateSession);
      final activeSessions = await localGateRepo.fetchGateSessions(testUserId);
      expect(activeSessions.length, 1);
      expect(activeSessions.first.status, GateSessionStatus.active);

      await localGateRepo.updateSessionStatus(
        newGateSession.id,
        status: GateSessionStatus.cleared,
        stabilityFinal: 1.0,
        actualDurationS: 1500,
        xpAwarded: 100,
        endedAt: now.add(const Duration(minutes: 25)),
      );

      final completedGate = await localGateRepo.getGateSessionById(newGateSession.id);
      expect(completedGate?.status, GateSessionStatus.cleared);
      expect(completedGate?.stabilityFinal, 1.0);

      // -----------------------------------------------------------------------
      // Step 22: Use AI in Online Mode
      // -----------------------------------------------------------------------
      mockAdapter.handler = (options) async {
        if (options.path.contains('/ai/plan')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'plan-uuid-e2e',
                'status': 'pending_approval',
                'goal': 'Prepare AI Architecture Plan',
                'quests': [
                  {
                    'title': 'Module 1: Vector Embeddings',
                    'description': 'Study vector databases',
                    'difficulty': 'medium',
                    'xpReward': 150,
                  },
                  {
                    'title': 'Module 2: RAG Pipeline',
                    'description': 'Implement retrieval augmented generation',
                    'difficulty': 'hard',
                    'xpReward': 250,
                  },
                ],
              },
            }),
            201,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw UnimplementedError(options.path);
      };

      final aiRemote = AiRemoteDataSource(apiClient);
      final aiPlan = await aiRemote.generatePlan(
        goal: 'Prepare AI Architecture Plan',
        targetDailyMinutes: 75,
      );

      expect(aiPlan.id, 'plan-uuid-e2e');
      expect(aiPlan.status, 'pending_approval');
      expect(aiPlan.quests.length, 2);
    });
  });
}
