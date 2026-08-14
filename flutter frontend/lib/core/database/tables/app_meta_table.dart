import 'package:drift/drift.dart';

/// Key-value store for local app metadata:
/// - schema version
/// - device ID (generated once at first run)
/// - client build version
/// - last full-sync timestamp
class AppMetaTable extends Table {
  @override
  String get tableName => 'app_meta';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
