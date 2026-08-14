import 'package:drift/drift.dart';
import '../../../core/database/arise_database.dart';
import '../domain/boss_models.dart';

/// Offline-first repository for Boss entities backed by Drift SQLite.
class LocalBossRepository {
  LocalBossRepository(this._db);

  final AriseDatabase _db;

  Stream<List<Boss>> watchBosses([String? userId]) {
    return _db.watchBosses(userId).map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<Boss>> fetchBosses([String? userId]) async {
    final rows = await _db.getBosses(userId);
    return rows.map(_toDomain).toList();
  }

  Future<Boss?> getBossById(String id) async {
    final row = await _db.getBossById(id);
    return row != null ? _toDomain(row) : null;
  }

  Future<void> saveBoss(Boss boss) async {
    await _db.upsertBoss(_toCompanion(boss));
  }

  /// Reconciles an array of server boss objects into the local Drift database.
  Future<void> reconcileServerBosses(
    List<Map<String, dynamic>> serverBosses, [
    String userId = 'local-user',
  ]) async {
    final companions = serverBosses.map((raw) {
      final boss = Boss.fromJson(raw).copyWith(
        syncStatus: 'synced',
        isDirty: false,
      );
      return _toCompanion(boss);
    }).toList();

    await _db.batchUpsertBosses(companions);
  }

  /// Reconciles a single server snapshot for a boss.
  Future<Boss> saveServerSnapshot(Map<String, dynamic> raw) async {
    final boss = Boss.fromJson(raw).copyWith(
      syncStatus: 'synced',
      isDirty: false,
    );
    await _db.upsertBoss(_toCompanion(boss));
    return boss;
  }

  /// Updates boss HP from server-authoritative reward cascade damage.
  Future<void> applyAuthoritativeDamage(
    String bossId,
    int damage, {
    bool? defeated,
  }) async {
    final current = await getBossById(bossId);
    if (current == null) return;

    final newHp = (current.hpCurrent - damage).clamp(0, current.hpMax);
    final isDefeated = defeated ?? (newHp == 0);

    await _db.updateBossHp(
      bossId,
      newHp,
      status: isDefeated ? 'defeated' : 'active',
      defeatedAt: isDefeated ? DateTime.now() : null,
      syncStatus: 'synced',
    );
  }

  /// Updates boss HP from hardcore mode recovery penalty.
  Future<void> applyAuthoritativeHpRecovery(
    String bossId,
    double recoveryRate,
  ) async {
    final current = await getBossById(bossId);
    if (current == null || current.isDefeated) return;

    final hpGain = (current.hpMax * recoveryRate).round();
    final newHp = (current.hpCurrent + hpGain).clamp(0, current.hpMax);

    await _db.updateBossHp(
      bossId,
      newHp,
      status: 'active',
      syncStatus: 'synced',
    );
  }

  Boss _toDomain(BossesTableData row) {
    return Boss(
      id: row.id,
      userId: row.userId,
      dungeonId: row.dungeonId,
      title: row.title,
      description: row.description,
      hpMax: row.hpMax,
      hpCurrent: row.hpCurrent,
      difficulty: row.difficulty,
      status: row.status,
      deadline: row.deadline,
      defeatedAt: row.defeatedAt,
      syncStatus: row.syncStatus,
      isDirty: row.isDirty,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  BossesTableCompanion _toCompanion(Boss boss) {
    return BossesTableCompanion(
      id: Value(boss.id),
      userId: Value(boss.userId),
      dungeonId: Value(boss.dungeonId),
      title: Value(boss.title),
      description: Value(boss.description),
      hpMax: Value(boss.hpMax),
      hpCurrent: Value(boss.hpCurrent),
      difficulty: Value(boss.difficulty),
      status: Value(boss.status),
      deadline: Value(boss.deadline),
      defeatedAt: Value(boss.defeatedAt),
      syncStatus: Value(boss.syncStatus),
      isDirty: Value(boss.isDirty),
      createdAt: Value(boss.createdAt),
      updatedAt: Value(boss.updatedAt),
    );
  }
}
