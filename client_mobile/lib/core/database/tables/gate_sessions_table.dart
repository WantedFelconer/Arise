import 'package:drift/drift.dart';

/// Drift SQLite table for local Gate Expedition sessions (SRS §6.2, §6.3, §7.1).
///
/// Records focus session durations, stability, linked quest, pause count,
/// and exit reasons.
class GateSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get questId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  IntColumn get plannedDurationS => integer()();
  IntColumn get actualDurationS => integer().nullable()();
  IntColumn get pauseCount => integer().withDefault(const Constant(0))();
  IntColumn get totalPausedDurationS => integer().withDefault(const Constant(0))();
  TextColumn get exitReason => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, paused, cleared, collapsed
  RealColumn get stabilityFinal => real().nullable()();
  IntColumn get xpAwarded => integer().nullable()();
  IntColumn get manaDelta => integer().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))(); // synced, pending, failed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
