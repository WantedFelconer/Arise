import 'package:drift/drift.dart';

/// Drift SQLite table for local Dungeon entity projection (SRS §6.2, §6.3).
class DungeonsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, completed
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))(); // synced, pending, failed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
