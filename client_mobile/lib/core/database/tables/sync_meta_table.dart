import 'package:drift/drift.dart';

/// Stores per-entity-type sync cursors so the client can perform
/// incremental pulls from the backend (`?updatedSince=<cursor>`).
///
/// One row per entity type (e.g., 'quest', 'character', 'boss').
class SyncMetaTable extends Table {
  @override
  String get tableName => 'sync_meta';

  // e.g., 'quest' | 'character' | 'boss' | 'dungeon' | 'gate_session'
  TextColumn get entityType => text().named('entity_type')();

  // Timestamp of the most recently synced server record for this entity type
  DateTimeColumn get lastSyncedAt =>
      dateTime().named('last_synced_at').nullable()();

  // Server-side revision/version cursor for delta pull
  IntColumn get serverRevision =>
      integer().named('server_revision').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entityType};
}
