import 'package:drift/drift.dart';

/// Drift SQLite table for local Boss entity projection (SRS §6.2, §6.3).
///
/// Boss HP and defeat states are server-authoritative;
/// the client stores a cached projection and pending operations.
class BossesTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get dungeonId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get hpMax => integer()();
  IntColumn get hpCurrent => integer()();
  TextColumn get difficulty =>
      text().withDefault(const Constant('medium'))(); // trivial, easy, medium, hard, epic
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, defeated, abandoned
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get defeatedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))(); // synced, pending, failed
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
