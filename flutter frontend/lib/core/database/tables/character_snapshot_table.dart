import 'package:drift/drift.dart';

/// Local-cached projection of the backend `characters` table.
/// Stores the server-reconciled snapshot of a user's RPG character.
/// syncStatus mirrors SRS §7 states: 'local' | 'pending' | 'syncing' | 'verified' | 'failed'
class CharacterSnapshotTable extends Table {
  @override
  String get tableName => 'character_snapshot';

  // Primary key — backend UUID (or sentinel 'local-user' before first auth)
  TextColumn get userId => text().named('user_id')();

  TextColumn get name => text().withDefault(const Constant('HUNTER'))();
  TextColumn get titleEquipped =>
      text().named('title_equipped').nullable()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get totalXp => integer().named('total_xp').withDefault(const Constant(0))();
  IntColumn get mana => integer().withDefault(const Constant(100))();
  IntColumn get maxMana => integer().named('max_mana').withDefault(const Constant(100))();
  IntColumn get energy => integer().withDefault(const Constant(100))();
  IntColumn get hp => integer().withDefault(const Constant(100))();
  IntColumn get maxHp => integer().named('max_hp').withDefault(const Constant(100))();
  IntColumn get coins => integer().withDefault(const Constant(0))();
  IntColumn get gems => integer().withDefault(const Constant(0))();
  TextColumn get rank => text().withDefault(const Constant('E'))();
  // Stats stored as JSON: {"str":0,"agi":0,"vit":0,"int":0,"per":0}
  TextColumn get statsJson => text().named('stats_json').withDefault(const Constant('{}'))();
  IntColumn get remainingStatPoints =>
      integer().named('remaining_stat_points').withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('local'))();
  // Optimistic pending XP (displayed while waiting for server confirmation)
  IntColumn get pendingXpDelta =>
      integer().named('pending_xp_delta').withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  DateTimeColumn get serverUpdatedAt =>
      dateTime().named('server_updated_at').nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
