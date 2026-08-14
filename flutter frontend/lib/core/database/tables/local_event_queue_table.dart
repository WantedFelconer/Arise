import 'package:drift/drift.dart';

/// Persistent command queue — the offline-first sync backbone.
///
/// Every user mutation that needs server synchronization creates a row here.
/// This table is the client-side mirror of the backend `sync_events` table
/// described in SRS §7.2 / §6.2.
///
/// States (per SRS §7.2 state machine):
///   pending   → Queued, not yet sent
///   syncing   → In-flight to server
///   synced    → Server acknowledged + authoritative result applied
///   failed    → Network/server error; will retry with exponential backoff
///   conflict  → Server detected conflict; needs resolution per §7.3
///   cancelled → Superseded by a later local event before ever syncing
class LocalEventQueueTable extends Table {
  @override
  String get tableName => 'local_event_queue';

  // Client-generated UUID — also serves as the Idempotency-Key header
  TextColumn get eventId => text().named('event_id')();

  TextColumn get userId => text().named('user_id')();

  // Device identifier for multi-device conflict tracking
  TextColumn get deviceId => text().named('device_id')();

  // Event type matching SRS §7.1 catalog:
  // COMPLETE_QUEST | CREATE_QUEST | EDIT_QUEST | DELETE_QUEST |
  // START_GATE | COMPLETE_GATE | COLLAPSE_GATE | etc.
  TextColumn get eventType => text().named('event_type')();

  // Full validated payload as JSON
  TextColumn get payloadJson => text().named('payload_json')();

  // When the event was generated on the client (authoritative for ordering)
  DateTimeColumn get occurredAtClient =>
      dateTime().named('occurred_at_client')();

  // Current sync state
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  // Retry counter — incremented on each failed attempt
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();

  // Monotonic version — allows ordering commands for the same entity
  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  // Last error message for user-visible "sync failed" indicator
  TextColumn get lastError =>
      text().named('last_error').nullable()();

  // When the next retry is allowed (implements exponential backoff scheduling)
  DateTimeColumn get nextRetryAt =>
      dateTime().named('next_retry_at').nullable()();

  @override
  Set<Column> get primaryKey => {eventId};
}
