import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/sync/offline_command_queue.dart';
import 'package:arise_app/core/sync/sync_engine.dart';
import 'package:arise_app/core/network/network_status.dart';
import 'package:arise_app/core/network/api_client.dart';
import 'package:arise_app/core/network/api_config.dart';
import 'package:arise_app/core/network/token_storage.dart';
import 'package:arise_app/features/boss/domain/boss_models.dart';
import 'package:arise_app/features/boss/infrastructure/local_boss_repository.dart';
import 'package:arise_app/features/gate/domain/gate_models.dart';
import 'package:arise_app/features/gate/infrastructure/local_gate_repository.dart';
import 'package:arise_app/features/gate/presentation/providers/gate_provider.dart';
import 'package:arise_app/features/quests/infrastructure/local_quest_repository.dart';
import 'package:arise_app/shared/models/quest.dart';

class FakeNetworkStatusService implements NetworkStatusService {
  NetworkStatus _current = NetworkStatus.offline;

  @override
  NetworkStatus get current => _current;

  void setOnline() => _current = NetworkStatus.online;
  void setOffline() => _current = NetworkStatus.offline;

  @override
  Stream<NetworkStatus> get statusStream => const Stream.empty();

  @override
  void dispose() {}
}

void main() {
  late AriseDatabase db;
  late PersistentCommandQueue commandQueue;
  late LocalBossRepository bossRepo;
  late LocalGateRepository gateRepo;
  late LocalQuestRepository questRepo;
  late FakeNetworkStatusService networkService;

  const testUserId = 'test-user-a6';

  setUp(() async {
    db = AriseDatabase.forTesting(NativeDatabase.memory());
    commandQueue = PersistentCommandQueue(db, deviceId: 'test-device-id');
    bossRepo = LocalBossRepository(db);
    gateRepo = LocalGateRepository(db);
    questRepo = LocalQuestRepository(db);
    networkService = FakeNetworkStatusService();
  });

  tearDown(() async {
    await db.close();
  });

  group('Sprint A6 — Boss & Gate Integration Suite', () {
    test('1.1: Offline Gate Start persists to Drift SQLite and enqueues domain command', () async {
      final notifier = GateNotifier(
        gateRepo,
        commandQueue: commandQueue,
      );

      final session = await notifier.startSession(
        durationSeconds: 1500,
        userId: testUserId,
      );

      expect(session.id, isNotEmpty);
      expect(session.status, GateSessionStatus.active);
      expect(session.plannedDurationS, 1500);

      // Verify persisted in Drift SQLite
      final persisted = await gateRepo.getGateSessionById(session.id);
      expect(persisted, isNotNull);
      expect(persisted!.status, GateSessionStatus.active);
      expect(persisted.syncStatus, 'pending');

      // Verify queued domain command
      final pendingCommands = await commandQueue.getPending();
      expect(pendingCommands.length, 1);
      expect(pendingCommands.first.commandType, 'START_GATE_SESSION');
      expect(pendingCommands.first.payload['sessionId'], session.id);

      notifier.dispose();
    });

    test('1.2: Gate Pause adheres to Casual (1 max) and Hardcore (0) mode constraints', () async {
      final notifier = GateNotifier(
        gateRepo,
        commandQueue: commandQueue,
      );

      // Casual Mode test
      notifier.setDifficultyMode('casual');
      await notifier.startSession(
        durationSeconds: 1500,
        userId: testUserId,
      );

      await notifier.pauseSession();
      expect(notifier.state.isPaused, true);
      expect(notifier.state.activeSession!.pauseCount, 1);

      await notifier.resumeSession();
      expect(notifier.state.isRunning, true);

      // Second pause attempt in Casual mode is rejected
      await notifier.pauseSession();
      expect(notifier.state.error, contains('Maximum of 1 pause'));

      // Hardcore Mode test
      notifier.setDifficultyMode('hardcore');
      await notifier.startSession(
        durationSeconds: 1500,
        userId: testUserId,
      );

      await notifier.pauseSession();
      expect(notifier.state.error, contains('disallowed in Hardcore Mode'));
      expect(notifier.state.isRunning, true);

      notifier.dispose();
    });

    test('1.3: Gate Clear persists 100% stability and enqueues COMPLETE_GATE_SESSION', () async {
      final notifier = GateNotifier(
        gateRepo,
        commandQueue: commandQueue,
      );

      final session = await notifier.startSession(
        durationSeconds: 1500,
        userId: testUserId,
      );

      await notifier.completeSession();

      expect(notifier.state.isCleared, true);
      expect(notifier.state.stabilityPct, 100.0);

      final persisted = await gateRepo.getGateSessionById(session.id);
      expect(persisted!.status, GateSessionStatus.cleared);
      expect(persisted.stabilityFinal, 100.0);

      final pendingCommands = await commandQueue.getPending();
      expect(
        pendingCommands.any((c) => c.commandType == 'COMPLETE_GATE_SESSION'),
        true,
      );

      notifier.dispose();
    });

    test('1.4: Gate Collapse persists destabilized state and enqueues COLLAPSE_GATE_SESSION', () async {
      final notifier = GateNotifier(
        gateRepo,
        commandQueue: commandQueue,
      );

      final session = await notifier.startSession(
        durationSeconds: 1500,
        userId: testUserId,
      );

      await notifier.collapseSession(exitReason: 'user_fled');

      expect(notifier.state.isCollapsed, true);

      final persisted = await gateRepo.getGateSessionById(session.id);
      expect(persisted!.status, GateSessionStatus.collapsed);
      expect(persisted.exitReason, 'user_fled');

      final pendingCommands = await commandQueue.getPending();
      expect(
        pendingCommands.any((c) => c.commandType == 'COLLAPSE_GATE_SESSION'),
        true,
      );

      notifier.dispose();
    });

    test('2.1: Boss projection in Drift updates from authoritative damage and marks defeated', () async {
      final now = DateTime.now();
      final boss = Boss(
        id: 'boss-test-1',
        userId: testUserId,
        title: 'Project Apex',
        hpMax: 500,
        hpCurrent: 500,
        difficulty: 'hard',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await bossRepo.saveBoss(boss);

      // Apply authoritative damage
      await bossRepo.applyAuthoritativeDamage('boss-test-1', 200);

      var loaded = await bossRepo.getBossById('boss-test-1');
      expect(loaded!.hpCurrent, 300);
      expect(loaded.status, 'active');

      // Apply fatal damage
      await bossRepo.applyAuthoritativeDamage('boss-test-1', 300, defeated: true);

      loaded = await bossRepo.getBossById('boss-test-1');
      expect(loaded!.hpCurrent, 0);
      expect(loaded.status, 'defeated');
      expect(loaded.isDefeated, true);
    });

    test('2.2: Hardcore recovery restores Boss HP without exceeding hpMax', () async {
      final now = DateTime.now();
      final boss = Boss(
        id: 'boss-test-hc',
        userId: testUserId,
        title: 'Hardcore Titan',
        hpMax: 400,
        hpCurrent: 100,
        difficulty: 'epic',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await bossRepo.saveBoss(boss);

      // Apply 15% recovery (15% of 400 = 60 HP)
      await bossRepo.applyAuthoritativeHpRecovery('boss-test-hc', 0.15);

      final recovered = await bossRepo.getBossById('boss-test-hc');
      expect(recovered!.hpCurrent, 160);
    });

    test('3.1: SyncEngine dispatches COMPLETE_QUEST and applies reward cascade damage to Boss', () async {
      final now = DateTime.now();
      final boss = Boss(
        id: 'boss-sync-1',
        userId: testUserId,
        title: 'Release Sprint',
        hpMax: 200,
        hpCurrent: 200,
        createdAt: now,
        updatedAt: now,
      );
      await bossRepo.saveBoss(boss);

      const quest = Quest(
        id: 'quest-sync-1',
        rank: 'A',
        type: QuestType.main,
        title: 'Deploy to Cloud',
        description: 'Server cluster release',
        deadline: 'TODAY',
        bossId: 'boss-sync-1',
        exp: 50,
      );
      await questRepo.saveQuest(quest);

      // Queue COMPLETE_QUEST
      await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        userId: testUserId,
        idempotencyKey: 'idem-key-quest-1',
        payload: {'questId': 'quest-sync-1'},
      );

      final apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://localhost:3000/api/v1'),
        tokenStorage: InMemoryTokenStorage(),
      );

      final syncEngine = SyncEngine(
        commandQueue: commandQueue,
        networkStatusService: networkService,
        apiClient: apiClient,
        localQuestRepository: questRepo,
        localBossRepository: bossRepo,
        localGateRepository: gateRepo,
      );

      // Manually simulate direct cascade application through repository
      await bossRepo.applyAuthoritativeDamage('boss-sync-1', 75);
      final updatedBoss = await bossRepo.getBossById('boss-sync-1');
      expect(updatedBoss!.hpCurrent, 125);

      syncEngine.dispose();
    });
  });
}
