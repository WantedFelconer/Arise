import 'package:drift/drift.dart';
import '../../../core/database/arise_database.dart';
import '../domain/dungeon_models.dart';

/// Offline-first repository for Dungeons backed by Drift SQLite.
class LocalDungeonRepository {
  LocalDungeonRepository(this._db);

  final AriseDatabase _db;

  Stream<List<Dungeon>> watchDungeons([String? userId]) {
    return _db.watchDungeons(userId).map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<Dungeon>> fetchDungeons([String? userId]) async {
    final rows = await _db.getDungeons(userId);
    return rows.map(_toDomain).toList();
  }

  Future<Dungeon?> getDungeonById(String id) async {
    final row = await _db.getDungeonById(id);
    return row != null ? _toDomain(row) : null;
  }

  Future<void> saveDungeon(Dungeon dungeon) async {
    await _db.upsertDungeon(_toCompanion(dungeon));
  }

  Future<void> reconcileServerDungeons(
    List<Map<String, dynamic>> serverDungeons, [
    String userId = 'local-user',
  ]) async {
    final companions = serverDungeons.map((raw) {
      final dungeon = Dungeon.fromJson(raw);
      return _toCompanion(dungeon);
    }).toList();

    await _db.batchUpsertDungeons(companions);
  }

  Dungeon _toDomain(DungeonsTableData row) {
    return Dungeon(
      id: row.id,
      userId: row.userId,
      title: row.title,
      status: row.status,
      syncStatus: row.syncStatus,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  DungeonsTableCompanion _toCompanion(Dungeon dungeon) {
    return DungeonsTableCompanion(
      id: Value(dungeon.id),
      userId: Value(dungeon.userId),
      title: Value(dungeon.title),
      status: Value(dungeon.status),
      syncStatus: Value(dungeon.syncStatus),
      createdAt: Value(dungeon.createdAt),
      updatedAt: Value(dungeon.updatedAt),
    );
  }
}
