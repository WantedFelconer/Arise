import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables/character_snapshot_table.dart';
import 'tables/quests_table.dart';
import 'tables/local_event_queue_table.dart';
import 'tables/sync_meta_table.dart';
import 'tables/app_meta_table.dart';
import 'tables/bosses_table.dart';
import 'tables/dungeons_table.dart';
import 'tables/gate_sessions_table.dart';

part 'arise_database.g.dart';

/// The root Drift database for the ARISE Flutter client.
///
/// Opens `arise.db` in the app's documents directory via drift_flutter.
/// This is the single persistent SQLite database that backs all
/// offline-first repositories.
///
/// Architecture contract (SRS §6.3):
///   - This database is a client PROJECTION + PENDING OPERATIONS store.
///   - It is NEVER authoritative for XP, Level, Mana, Energy, Boss HP,
///     streaks, or achievements. Those values are server-authoritative.
///   - Every locally-mutable row carries a `sync_status` column.
///
/// Migrations: version 1 → production migrations must be additive.
/// During development, `destructiveFallback` is enabled; remove before
/// shipping to production.
@DriftDatabase(tables: [
  CharacterSnapshotTable,
  QuestsTable,
  BossesTable,
  DungeonsTable,
  GateSessionsTable,
  LocalEventQueueTable,
  SyncMetaTable,
  AppMetaTable,
])
class AriseDatabase extends _$AriseDatabase {
  AriseDatabase() : super(_openConnection());

  /// For testing — pass an in-memory executor directly.
  AriseDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future additive migrations go here.
      },
      beforeOpen: (details) async {
        // Enable WAL mode for better concurrent read/write performance.
        await customStatement('PRAGMA journal_mode=WAL');
        // Enable foreign key enforcement.
        await customStatement('PRAGMA foreign_keys=ON');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Character snapshot helpers
  // ---------------------------------------------------------------------------

  Future<CharacterSnapshotTableData?> getCharacterSnapshot(
      String userId) async {
    return (select(characterSnapshotTable)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> upsertCharacterSnapshot(
      CharacterSnapshotTableCompanion companion) async {
    await into(characterSnapshotTable).insertOnConflictUpdate(companion);
  }

  // ---------------------------------------------------------------------------
  // Quest helpers
  // ---------------------------------------------------------------------------

  Stream<List<QuestsTableData>> watchActiveQuests([String? userId]) {
    final query = select(questsTable)
      ..where((t) => t.status.isNotIn(['trashed', 'archived']))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.watch();
  }

  Future<List<QuestsTableData>> getActiveQuests([String? userId]) {
    final query = select(questsTable)
      ..where((t) => t.status.isNotIn(['trashed', 'archived']))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.get();
  }

  Future<QuestsTableData?> getQuestById(String id) {
    return (select(questsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<QuestsTableData>> getAllQuests([String? userId]) {
    final query = select(questsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.get();
  }

  Future<void> upsertQuest(QuestsTableCompanion companion) async {
    await into(questsTable).insertOnConflictUpdate(companion);
  }

  Future<void> batchUpsertQuests(List<QuestsTableCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(questsTable, companions);
    });
  }

  Future<void> updateQuestStatus(
      String questId, String status, DateTime now) async {
    await (update(questsTable)..where((t) => t.id.equals(questId))).write(
      QuestsTableCompanion(
        status: Value(status),
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        updatedAt: Value(now),
        completedAt:
            status == 'completed' ? Value(now) : const Value.absent(),
      ),
    );
  }

  Future<void> archiveQuest(String questId, DateTime now) async {
    await (update(questsTable)..where((t) => t.id.equals(questId))).write(
      QuestsTableCompanion(
        status: const Value('archived'),
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> restoreQuest(String questId, DateTime now) async {
    await (update(questsTable)..where((t) => t.id.equals(questId))).write(
      QuestsTableCompanion(
        status: const Value('active'),
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteQuest(String questId, DateTime now) async {
    await (update(questsTable)..where((t) => t.id.equals(questId))).write(
      QuestsTableCompanion(
        status: const Value('trashed'),
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteQuestPermanently(String questId) async {
    await (delete(questsTable)..where((t) => t.id.equals(questId))).go();
  }

  Future<void> updateQuestSyncStatus(
      String questId, String syncStatus, {bool isDirty = false}) async {
    await (update(questsTable)..where((t) => t.id.equals(questId))).write(
      QuestsTableCompanion(
        syncStatus: Value(syncStatus),
        isDirty: Value(isDirty),
      ),
    );
  }

  Future<List<QuestsTableData>> getPendingQuestsSync(String userId) {
    return (select(questsTable)
          ..where((t) =>
              t.userId.equals(userId) & t.syncStatus.isIn(['pending', 'failed'])))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Boss helpers
  // ---------------------------------------------------------------------------

  Stream<List<BossesTableData>> watchBosses([String? userId]) {
    final query = select(bossesTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.watch();
  }

  Future<List<BossesTableData>> getBosses([String? userId]) {
    final query = select(bossesTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.get();
  }

  Future<BossesTableData?> getBossById(String id) {
    return (select(bossesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertBoss(BossesTableCompanion companion) async {
    await into(bossesTable).insertOnConflictUpdate(companion);
  }

  Future<void> batchUpsertBosses(List<BossesTableCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(bossesTable, companions);
    });
  }

  Future<void> updateBossHp(
    String bossId,
    int newHp, {
    String? status,
    DateTime? defeatedAt,
    String? syncStatus,
  }) async {
    await (update(bossesTable)..where((t) => t.id.equals(bossId))).write(
      BossesTableCompanion(
        hpCurrent: Value(newHp),
        status: status != null ? Value(status) : const Value.absent(),
        defeatedAt: defeatedAt != null ? Value(defeatedAt) : const Value.absent(),
        syncStatus: syncStatus != null ? Value(syncStatus) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateBossStatus(String bossId, String status) async {
    await (update(bossesTable)..where((t) => t.id.equals(bossId))).write(
      BossesTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dungeon helpers
  // ---------------------------------------------------------------------------

  Stream<List<DungeonsTableData>> watchDungeons([String? userId]) {
    final query = select(dungeonsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.watch();
  }

  Future<List<DungeonsTableData>> getDungeons([String? userId]) {
    final query = select(dungeonsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.get();
  }

  Future<DungeonsTableData?> getDungeonById(String id) {
    return (select(dungeonsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertDungeon(DungeonsTableCompanion companion) async {
    await into(dungeonsTable).insertOnConflictUpdate(companion);
  }

  Future<void> batchUpsertDungeons(List<DungeonsTableCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(dungeonsTable, companions);
    });
  }

  // ---------------------------------------------------------------------------
  // Gate session helpers
  // ---------------------------------------------------------------------------

  Stream<List<GateSessionsTableData>> watchGateSessions([String? userId]) {
    final query = select(gateSessionsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.watch();
  }

  Future<List<GateSessionsTableData>> getGateSessions([String? userId]) {
    final query = select(gateSessionsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      query.where((t) => t.userId.equals(userId) | t.userId.equals('local-user'));
    }
    return query.get();
  }

  Future<GateSessionsTableData?> getGateSessionById(String id) {
    return (select(gateSessionsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertGateSession(GateSessionsTableCompanion companion) async {
    await into(gateSessionsTable).insertOnConflictUpdate(companion);
  }

  Future<void> updateGateSessionState(
    String sessionId, {
    required String status,
    int? actualDurationS,
    double? stabilityFinal,
    int? xpAwarded,
    int? manaDelta,
    String? exitReason,
    DateTime? pausedAt,
    int? pauseCount,
    int? totalPausedDurationS,
    DateTime? endedAt,
    String? syncStatus,
  }) async {
    await (update(gateSessionsTable)..where((t) => t.id.equals(sessionId))).write(
      GateSessionsTableCompanion(
        status: Value(status),
        actualDurationS:
            actualDurationS != null ? Value(actualDurationS) : const Value.absent(),
        stabilityFinal:
            stabilityFinal != null ? Value(stabilityFinal) : const Value.absent(),
        xpAwarded: xpAwarded != null ? Value(xpAwarded) : const Value.absent(),
        manaDelta: manaDelta != null ? Value(manaDelta) : const Value.absent(),
        exitReason:
            exitReason != null ? Value(exitReason) : const Value.absent(),
        pausedAt: pausedAt != null ? Value(pausedAt) : const Value.absent(),
        pauseCount:
            pauseCount != null ? Value(pauseCount) : const Value.absent(),
        totalPausedDurationS: totalPausedDurationS != null
            ? Value(totalPausedDurationS)
            : const Value.absent(),
        endedAt: endedAt != null ? Value(endedAt) : const Value.absent(),
        syncStatus:
            syncStatus != null ? Value(syncStatus) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Local event queue helpers
  // ---------------------------------------------------------------------------

  Future<void> enqueueEvent(LocalEventQueueTableCompanion companion) async {
    await into(localEventQueueTable).insert(companion);
  }

  Future<List<LocalEventQueueTableData>> getPendingEvents() {
    final now = DateTime.now();
    return (select(localEventQueueTable)
          ..where((t) =>
              t.syncStatus.isIn(['pending', 'failed']) &
              (t.nextRetryAt.isNull() | t.nextRetryAt.isSmallerOrEqualValue(now)))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAtClient)]))
        .get();
  }

  Future<void> updateEventStatus(
      String eventId, String status, {String? lastError, DateTime? nextRetryAt}) async {
    await (update(localEventQueueTable)
          ..where((t) => t.eventId.equals(eventId)))
        .write(LocalEventQueueTableCompanion(
      syncStatus: Value(status),
      lastError: lastError != null ? Value(lastError) : const Value.absent(),
      nextRetryAt:
          nextRetryAt != null ? Value(nextRetryAt) : const Value.absent(),
    ));
  }

  Future<void> incrementEventRetry(
      String eventId, DateTime nextRetryAt, String lastError) async {
    await customUpdate(
      'UPDATE local_event_queue SET retry_count = retry_count + 1, '
      'sync_status = ?, next_retry_at = ?, last_error = ? '
      'WHERE event_id = ?',
      variables: [
        Variable.withString('failed'),
        Variable.withDateTime(nextRetryAt),
        Variable.withString(lastError),
        Variable.withString(eventId),
      ],
      updates: {localEventQueueTable},
    );
  }

  Future<void> resetStalledSyncingEvents() async {
    await (update(localEventQueueTable)..where((t) => t.syncStatus.equals('syncing'))).write(
      const LocalEventQueueTableCompanion(
        syncStatus: Value('pending'),
      ),
    );
  }

  Future<int> getPendingEventsCount() async {
    final countExp = localEventQueueTable.eventId.count();
    final query = selectOnly(localEventQueueTable)
      ..addColumns([countExp])
      ..where(localEventQueueTable.syncStatus.isIn(['pending', 'failed']));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Sync meta helpers
  // ---------------------------------------------------------------------------

  Future<SyncMetaTableData?> getSyncMeta(String entityType) async {
    return (select(syncMetaTable)
          ..where((t) => t.entityType.equals(entityType)))
        .getSingleOrNull();
  }

  Future<void> upsertSyncMeta(SyncMetaTableCompanion companion) async {
    await into(syncMetaTable).insertOnConflictUpdate(companion);
  }

  // ---------------------------------------------------------------------------
  // App meta helpers
  // ---------------------------------------------------------------------------

  Future<String?> getAppMeta(String key) async {
    final row = await (select(appMetaTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setAppMeta(String key, String value) async {
    await into(appMetaTable).insertOnConflictUpdate(
      AppMetaTableCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
}

/// Opens the SQLite connection backed by a real file.
/// Uses drift_flutter's `DriftIsolate` for background I/O.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'arise_db');
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Global singleton provider for the Drift database.
/// Override in main.dart via ProviderScope for production,
/// and in tests via ProviderContainer overrides with AriseDatabase.forTesting().
final ariseDatabaseProvider = Provider<AriseDatabase>((ref) {
  throw UnimplementedError(
    'ariseDatabaseProvider must be overridden in ProviderScope. '
    'See main.dart for the production override.',
  );
});
