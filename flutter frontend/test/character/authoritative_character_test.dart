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
import 'package:arise_app/core/sync/offline_command_queue.dart';
import 'package:arise_app/core/sync/sync_engine.dart';
import 'package:arise_app/features/character/infrastructure/character_remote_data_source.dart';
import 'package:arise_app/features/character/infrastructure/local_player_repository.dart';
import 'package:arise_app/shared/models/player_data.dart';

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
  group('Sprint A3 — Authoritative Character & RPG State Integration Suite', () {
    late AriseDatabase db;
    late InMemoryTokenStorage tokenStorage;
    late MockHttpAdapter mockAdapter;
    late Dio dio;
    late ApiClient apiClient;
    late CharacterRemoteDataSource remoteDataSource;
    late LocalPlayerRepository localPlayerRepo;
    late PersistentCommandQueue commandQueue;
    late FakeNetworkStatusService networkStatusService;
    late ProviderContainer container;

    setUp(() {
      db = AriseDatabase.forTesting(NativeDatabase.memory());
      tokenStorage = InMemoryTokenStorage();
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://test.arise.sys/api/v1'));
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(
        config: const ApiConfig(baseUrl: 'http://test.arise.sys/api/v1'),
        tokenStorage: tokenStorage,
        dio: dio,
      );

      remoteDataSource = CharacterRemoteDataSource(apiClient: apiClient);
      localPlayerRepo = LocalPlayerRepository(db);
      commandQueue = PersistentCommandQueue(db, deviceId: 'test-device-id');
      networkStatusService = FakeNetworkStatusService();

      container = ProviderContainer(
        overrides: [
          ariseDatabaseProvider.overrideWithValue(db),
          playerRepositoryProvider.overrideWithValue(localPlayerRepo),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          apiClientProvider.overrideWithValue(apiClient),
          characterRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
          commandQueueProvider.overrideWithValue(commandQueue),
          networkStatusServiceProvider.overrideWithValue(networkStatusService),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      networkStatusService.dispose();
      await db.close();
    });

    // ========================================================================
    // Proof 1: Fresh character appears from backend
    // ========================================================================
    test('Proof 1: Fresh character loads from backend GET /character and persists to Drift SQLite', () async {
      mockAdapter.handler = (options) async {
        if (options.path.contains('/character')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_uuid_999',
                'userId': 'user_uuid_999',
                'level': 5,
                'totalXp': 1600,
                'xpToNextLevel': 900,
                'currentMana': 120,
                'maxMana': 120,
                'coins': 350,
                'gems': 25,
                'rank': 'E',
                'activeTitleId': 'wolf_slayer',
                'stats': {
                  'fitness': 18,
                  'discipline': 14,
                  'health': 15,
                  'intelligence': 16,
                  'creativity': 12,
                }
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      final playerNotifier = container.read(playerProvider.notifier);
      final refreshed = await playerNotifier.refreshFromServer();

      expect(refreshed, isNotNull);
      expect(refreshed!.id, 'char_uuid_999');
      expect(refreshed.level, 5);
      expect(refreshed.exp, 1600);
      expect(refreshed.maxExp, 2500); // 1600 + 900
      expect(refreshed.mp, 120);
      expect(refreshed.maxMp, 120);
      expect(refreshed.gold, 350);
      expect(refreshed.gems, 25);
      expect(refreshed.str, 18);
      expect(refreshed.syncStatus, 'verified');

      // Verify persisted in Drift SQLite table
      final snapshot = await db.getCharacterSnapshot('char_uuid_999');
      expect(snapshot, isNotNull);
      expect(snapshot!.level, 5);
      expect(snapshot.totalXp, 1600);
      expect(snapshot.mana, 120);
      expect(snapshot.syncStatus, 'verified');
    });

    // ========================================================================
    // Proof 2: Restart retains local character projection
    // ========================================================================
    test('Proof 2: Offline app restart retains local character projection from Drift SQLite', () async {
      // 1. Seed character into local DB (as if persisted during previous session)
      await localPlayerRepo.updatePlayerData(
        const PlayerData(
          id: 'char_uuid_cached',
          name: 'HUNTER',
          title: 'SHADOW MONARCH',
          level: 10,
          rank: 'D',
          hp: 100,
          maxHp: 100,
          mp: 150,
          maxMp: 150,
          exp: 8100,
          maxExp: 10000,
          gold: 1200,
          gems: 50,
          streak: 7,
          str: 25,
          agi: 22,
          vit: 20,
          intStat: 30,
          per: 18,
          remainingPoints: 0,
          syncStatus: 'verified',
        ),
      );

      // 2. Create fresh notifier instance reading the same database (simulating fresh app launch offline)
      final restartedNotifier = PlayerNotifier(localPlayerRepo);
      // Wait for initial load
      await restartedNotifier.reloadFromDatabase('char_uuid_cached');

      // 3. Verify state matches local SQLite projection without making network calls
      expect(restartedNotifier.state.id, 'char_uuid_cached');
      expect(restartedNotifier.state.level, 10);
      expect(restartedNotifier.state.rank, 'D');
      expect(restartedNotifier.state.exp, 8100);
      expect(restartedNotifier.state.mp, 150);
      expect(restartedNotifier.state.gold, 1200);
      expect(restartedNotifier.state.gems, 50);
      expect(restartedNotifier.state.str, 25);
      expect(restartedNotifier.state.intStat, 30);
    });

    // ========================================================================
    // Proof 3: Server update appears after sync
    // ========================================================================
    test('Proof 3: Domain command sync triggers server reward cascade and reconciles character', () async {
      int characterFetchCount = 0;
      int serverXp = 0;
      int serverLevel = 1;

      mockAdapter.handler = (options) async {
        if (options.path.contains('/sync/idempotency-test')) {
          serverXp += 2500; // Level 6 in RpgEngine: floor(0.1 * sqrt(2500)) + 1 = 5 + 1 = 6
          serverLevel = 6;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'success': true,
                'xpAwarded': 2500,
                'newLevel': 6,
                'newRank': 'E',
                'totalXp': serverXp,
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/character')) {
          characterFetchCount++;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_user_sync',
                'level': serverLevel,
                'totalXp': serverXp,
                'xpToNextLevel': 1100,
                'currentMana': 100,
                'maxMana': 100,
                'coins': 50,
                'gems': 5,
                'rank': 'E',
                'stats': {'fitness': 15, 'discipline': 15}
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return ResponseBody.fromString('{}', 200);
      };

      // 1. Initial character setup
      await container.read(playerProvider.notifier).refreshFromServer();
      expect(container.read(playerProvider).level, 1);
      expect(container.read(playerProvider).exp, 0);

      // 2. Queue domain progression command
      await commandQueue.enqueue(
        commandType: 'TEST_REWARD_COMMAND',
        userId: 'char_user_sync',
        payload: {'amount': 2500},
      );

      // 3. Execute sync engine
      final syncEngine = SyncEngine(
        commandQueue: commandQueue,
        networkStatusService: networkStatusService,
        apiClient: apiClient,
        onSyncCompleted: () async {
          await container.read(playerProvider.notifier).refreshFromServer();
        },
      );

      await syncEngine.triggerSync();

      // 4. Verify command marked synced and character updated from authoritative server response
      final pendingAfter = await commandQueue.getPending();
      expect(pendingAfter, isEmpty);

      final player = container.read(playerProvider);
      expect(player.level, 6);
      expect(player.exp, 2500);
      expect(player.syncStatus, 'verified');
      expect(characterFetchCount, greaterThanOrEqualTo(2));
      syncEngine.dispose();
    });

    // ========================================================================
    // Proof 4: Anti-cheat / No client authority
    // ========================================================================
    test('Proof 4: Client cannot establish arbitrary XP; progression operations are raw domain commands', () async {
      final playerNotifier = container.read(playerProvider.notifier);

      // Verify that calling applyPendingXpDelta modifies presentation exp optimistically
      // but DOES NOT calculate authoritative level or rank client-side!
      playerNotifier.applyPendingXpDelta(999999);

      final state = container.read(playerProvider);
      expect(state.exp, 999999); // Optimistic visual display
      expect(state.level, 1); // LEVEL MUST NOT JUMP TO 100+ CLIENT-SIDE
      expect(state.rank, 'E'); // RANK MUST NOT JUMP TO S CLIENT-SIDE
      expect(state.syncStatus, 'pending');
      expect(state.isProgressionPending, true);

      // Enqueued operations are domain commands (e.g. COMPLETE_QUEST, TEST_REWARD_COMMAND),
      // NEVER raw "SET_XP = 999999"
      final eventId = await commandQueue.enqueue(
        commandType: 'COMPLETE_QUEST',
        userId: 'hunter_test',
        payload: {'questId': 'quest-123'},
      );

      final commands = await commandQueue.getPending();
      expect(commands.first.commandType, 'COMPLETE_QUEST');
      expect(commands.first.payload.containsKey('xp'), false);
      expect(commands.first.payload.containsKey('level'), false);
      expect(commands.first.eventId, eventId);
    });

    // ========================================================================
    // Proof 5: Offline optimistic reconciliation
    // ========================================================================
    test('Proof 5: Offline domain actions queue locally and reconcile server state upon reconnection', () async {
      networkStatusService.setStatus(NetworkStatus.offline);

      int syncCalled = 0;
      mockAdapter.handler = (options) async {
        if (options.path.contains('/sync/idempotency-test')) {
          syncCalled++;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'success': true,
                'xpAwarded': 400,
                'newLevel': 3,
                'newRank': 'E',
                'totalXp': 400,
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/character')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_offline_reconcile',
                'level': 3,
                'totalXp': 400,
                'xpToNextLevel': 500,
                'currentMana': 100,
                'maxMana': 100,
                'coins': 100,
                'gems': 0,
                'rank': 'E',
                'stats': {'fitness': 12, 'discipline': 12}
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      // 1. User performs action offline -> Queued locally with optimistic prediction
      final playerNotifier = container.read(playerProvider.notifier);
      playerNotifier.applyPendingXpDelta(400);

      await commandQueue.enqueue(
        commandType: 'TEST_REWARD_COMMAND',
        userId: 'char_offline_reconcile',
        payload: {'amount': 400},
      );

      expect(container.read(playerProvider).syncStatus, 'pending');
      expect((await commandQueue.getPending()).length, 1);

      // 2. Network reconnects -> SyncEngine triggers automatically
      final syncEngine = SyncEngine(
        commandQueue: commandQueue,
        networkStatusService: networkStatusService,
        apiClient: apiClient,
        onSyncCompleted: () async {
          await container.read(playerProvider.notifier).refreshFromServer();
        },
      );

      networkStatusService.setStatus(NetworkStatus.online);
      await syncEngine.triggerSync();

      // 3. Verify server state is reconciled and confirmed verified
      final finalPlayer = container.read(playerProvider);
      expect(syncCalled, 1);
      expect(finalPlayer.level, 3);
      expect(finalPlayer.exp, 400);
      expect(finalPlayer.syncStatus, 'verified');
      expect(finalPlayer.isProgressionPending, false);
      expect(await commandQueue.getPending(), isEmpty);

      syncEngine.dispose();
    });

    // ========================================================================
    // Proof 6: XP / Mana Ledger & Aggregates
    // ========================================================================
    test('Proof 6: Transaction ledger and aggregates integrate from GET /character/history and GET /character/aggregates', () async {
      mockAdapter.handler = (options) async {
        if (options.path.contains('/character/history')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'xpTransactions': [
                  {
                    'id': 'tx-101',
                    'amount': 150,
                    'sourceType': 'quest',
                    'sourceId': 'quest-morning-run',
                    'reason': 'Quest Cleared: Morning Run',
                    'createdAt': '2026-08-14T08:30:00.000Z',
                  },
                  {
                    'id': 'tx-102',
                    'amount': -30,
                    'sourceType': 'penalty',
                    'sourceId': 'penalty-missed',
                    'reason': 'Missed: Evening Meditation',
                    'createdAt': '2026-08-13T22:00:00.000Z',
                  }
                ],
                'manaTransactions': [
                  {
                    'id': 'mtx-201',
                    'delta': -25,
                    'sourceType': 'screen_time',
                    'reason': 'Excess Instagram usage',
                    'createdAt': '2026-08-14T14:00:00.000Z',
                  }
                ]
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/character/aggregates')) {
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'today': 150,
                'thisWeek': 850,
                'thisMonth': 3200,
                'lifetime': 12500,
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return ResponseBody.fromString('{}', 200);
      };

      final history = await remoteDataSource.fetchTransactionHistory();
      expect(history.xpTransactions.length, 2);
      expect(history.xpTransactions.first.amount, 150);
      expect(history.xpTransactions.first.reason, 'Quest Cleared: Morning Run');
      expect(history.xpTransactions.last.amount, -30);
      expect(history.manaTransactions.length, 1);
      expect(history.manaTransactions.first.delta, -25);

      final aggregates = await remoteDataSource.fetchXpAggregates();
      expect(aggregates.today, 150);
      expect(aggregates.thisWeek, 850);
      expect(aggregates.thisMonth, 3200);
      expect(aggregates.lifetime, 12500);
    });

    // ========================================================================
    // Proof 7: Server title equipping integration
    // ========================================================================
    test('Proof 7: Equipping title sends PATCH /character/title and updates state', () async {
      int patchCalled = 0;
      mockAdapter.handler = (options) async {
        if (options.path.contains('/character/title')) {
          patchCalled++;
          return ResponseBody.fromString(
            json.encode({
              'data': {
                'id': 'char_uuid_title',
                'activeTitleId': 'wolf_slayer',
                'level': 5,
                'totalXp': 1600,
                'currentMana': 100,
                'maxMana': 100,
                'rank': 'E',
                'stats': {}
              }
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      };

      final playerNotifier = container.read(playerProvider.notifier);
      await playerNotifier.equipTitle('wolf_slayer');

      expect(patchCalled, 1);
      expect(container.read(playerProvider).activeTitleId, 'wolf_slayer');
      expect(container.read(playerProvider).syncStatus, 'verified');
    });
  });
}
