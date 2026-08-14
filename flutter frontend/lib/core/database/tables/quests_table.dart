import 'package:drift/drift.dart';

/// Local cache + pending mutations for the backend `quests` table.
/// Every locally-created or locally-mutated quest gets syncStatus='pending'
/// until the server acknowledges and reconciles.
///
/// SRS §6.2 quests schema + §6.3 local DB requirements.
class QuestsTable extends Table {
  @override
  String get tableName => 'quests';

  // UUID — client-generated for optimistic inserts, server-confirmed on sync
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();

  // Nullable FK to bosses — not yet a local table, stored as raw UUID string
  TextColumn get bossId => text().named('boss_id').nullable()();

  // Self-referential parent for subquests
  TextColumn get parentQuestId => text().named('parent_quest_id').nullable()();

  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();

  // ENUM: daily | main | side | recurring | boss | ai_generated
  TextColumn get questType =>
      text().named('quest_type').withDefault(const Constant('side'))();

  // ENUM: low | medium | high | critical
  TextColumn get priority =>
      text().withDefault(const Constant('medium'))();

  // ENUM: easy | normal | hard | extreme
  TextColumn get difficulty =>
      text().withDefault(const Constant('normal'))();

  DateTimeColumn get deadlineUtc =>
      dateTime().named('deadline_utc').nullable()();

  // Raw deadline string for backward compat with display code
  TextColumn get deadlineDisplay =>
      text().named('deadline_display').nullable()();

  IntColumn get estimatedMinutes =>
      integer().named('estimated_minutes').withDefault(const Constant(0))();

  IntColumn get actualMinutes =>
      integer().named('actual_minutes').nullable()();

  // ENUM: active | in_progress | completed | archived | trashed
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  // JSON array of tag strings: ["fitness","study"]
  TextColumn get tagsJson =>
      text().named('tags_json').withDefault(const Constant('[]'))();

  IntColumn get xpReward =>
      integer().named('xp_reward').withDefault(const Constant(0))();

  IntColumn get manaReward =>
      integer().named('mana_reward').withDefault(const Constant(0))();

  BoolColumn get isFavorite =>
      boolean().named('is_favorite').withDefault(const Constant(false))();

  BoolColumn get isPinned =>
      boolean().named('is_pinned').withDefault(const Constant(false))();

  // Idempotency key for server sync — UUID generated on first local write
  TextColumn get idempotencyKey =>
      text().named('idempotency_key')();

  // syncStatus: 'local' | 'pending' | 'syncing' | 'verified' | 'failed' | 'conflict'
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  // Whether the current local state has not yet been sent to server
  BoolColumn get isDirty =>
      boolean().named('is_dirty').withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();

  // Server-assigned revision number for conflict detection
  IntColumn get serverRevision =>
      integer().named('server_revision').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
