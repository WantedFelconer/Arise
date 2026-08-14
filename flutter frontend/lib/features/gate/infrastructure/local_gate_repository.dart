import 'package:drift/drift.dart';
import '../../../core/database/arise_database.dart';
import '../domain/gate_models.dart';

/// Offline-first repository for Gate Expedition sessions backed by Drift SQLite.
class LocalGateRepository {
  LocalGateRepository(this._db);

  final AriseDatabase _db;

  Stream<List<GateSession>> watchGateSessions([String? userId]) {
    return _db
        .watchGateSessions(userId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<GateSession>> fetchGateSessions([String? userId]) async {
    final rows = await _db.getGateSessions(userId);
    return rows.map(_toDomain).toList();
  }

  Future<GateSession?> getGateSessionById(String id) async {
    final row = await _db.getGateSessionById(id);
    return row != null ? _toDomain(row) : null;
  }

  Future<void> saveSession(GateSession session) async {
    await _db.upsertGateSession(_toCompanion(session));
  }

  Future<void> updateSessionStatus(
    String sessionId, {
    required GateSessionStatus status,
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
    await _db.updateGateSessionState(
      sessionId,
      status: _statusToString(status),
      actualDurationS: actualDurationS,
      stabilityFinal: stabilityFinal,
      xpAwarded: xpAwarded,
      manaDelta: manaDelta,
      exitReason: exitReason,
      pausedAt: pausedAt,
      pauseCount: pauseCount,
      totalPausedDurationS: totalPausedDurationS,
      endedAt: endedAt,
      syncStatus: syncStatus,
    );
  }

  Future<void> reconcileServerSessions(
    List<Map<String, dynamic>> serverSessions, [
    String userId = 'local-user',
  ]) async {
    for (final raw in serverSessions) {
      final session = GateSession.fromJson(raw).copyWith(syncStatus: 'synced');
      await _db.upsertGateSession(_toCompanion(session));
    }
  }

  Future<GateSession> saveServerSnapshot(Map<String, dynamic> raw) async {
    final session = GateSession.fromJson(raw).copyWith(syncStatus: 'synced');
    await _db.upsertGateSession(_toCompanion(session));
    return session;
  }

  GateSession _toDomain(GateSessionsTableData row) {
    GateSessionStatus parseStatus(String s) {
      switch (s) {
        case 'active':
        case 'in_progress':
          return GateSessionStatus.active;
        case 'paused':
          return GateSessionStatus.paused;
        case 'cleared':
        case 'completed':
          return GateSessionStatus.cleared;
        case 'collapsed':
          return GateSessionStatus.collapsed;
        default:
          return GateSessionStatus.active;
      }
    }

    return GateSession(
      id: row.id,
      userId: row.userId,
      questId: row.questId,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      pausedAt: row.pausedAt,
      plannedDurationS: row.plannedDurationS,
      actualDurationS: row.actualDurationS,
      pauseCount: row.pauseCount,
      totalPausedDurationS: row.totalPausedDurationS,
      exitReason: row.exitReason,
      status: parseStatus(row.status),
      stabilityFinal: row.stabilityFinal,
      xpAwarded: row.xpAwarded,
      manaDelta: row.manaDelta,
      syncStatus: row.syncStatus,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  GateSessionsTableCompanion _toCompanion(GateSession session) {
    return GateSessionsTableCompanion(
      id: Value(session.id),
      userId: Value(session.userId),
      questId: Value(session.questId),
      startedAt: Value(session.startedAt),
      endedAt: Value(session.endedAt),
      pausedAt: Value(session.pausedAt),
      plannedDurationS: Value(session.plannedDurationS),
      actualDurationS: Value(session.actualDurationS),
      pauseCount: Value(session.pauseCount),
      totalPausedDurationS: Value(session.totalPausedDurationS),
      exitReason: Value(session.exitReason),
      status: Value(_statusToString(session.status)),
      stabilityFinal: Value(session.stabilityFinal),
      xpAwarded: Value(session.xpAwarded),
      manaDelta: Value(session.manaDelta),
      syncStatus: Value(session.syncStatus),
      createdAt: Value(session.createdAt),
      updatedAt: Value(session.updatedAt),
    );
  }

  String _statusToString(GateSessionStatus status) {
    switch (status) {
      case GateSessionStatus.active:
        return 'active';
      case GateSessionStatus.paused:
        return 'paused';
      case GateSessionStatus.cleared:
        return 'cleared';
      case GateSessionStatus.collapsed:
        return 'collapsed';
    }
  }
}
