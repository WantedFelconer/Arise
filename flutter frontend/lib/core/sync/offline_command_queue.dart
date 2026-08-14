import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/arise_database.dart';

// ---------------------------------------------------------------------------
// Domain model
// ---------------------------------------------------------------------------

/// Sync state of a queued command — mirrors SRS §7.2 state machine.
enum CommandSyncStatus {
  pending,
  syncing,
  synced,
  failed,
  conflict,
  cancelled,
}

/// A single user-intent command queued for server synchronization.
///
/// Commands represent DOMAIN OPERATIONS (e.g., COMPLETE_QUEST, CREATE_QUEST),
/// never final authoritative state values (never SET_XP, SET_LEVEL, SET_MANA).
/// This is the core of the offline-first authority contract (SRS Rule 6 §17.3).
class QueuedCommand {
  const QueuedCommand({
    required this.eventId,
    required this.idempotencyKey,
    required this.userId,
    required this.deviceId,
    required this.commandType,
    required this.payload,
    required this.occurredAtClient,
    required this.syncStatus,
    required this.retryCount,
    required this.version,
    this.lastError,
    this.nextRetryAt,
  });

  /// Client-generated UUID — also the Idempotency-Key header value.
  final String eventId;

  /// Explicit idempotency key (same as eventId unless caller overrides).
  final String idempotencyKey;

  /// User who generated this command (sentinel 'local-user' pre-auth).
  final String userId;

  /// Device identifier for multi-device conflict tracking.
  final String deviceId;

  /// SRS §7.1 event type: COMPLETE_QUEST | CREATE_QUEST | COMPLETE_GATE | etc.
  final String commandType;

  /// Validated payload specific to the command type.
  final Map<String, dynamic> payload;

  /// Client-side generation timestamp — authoritative for ordering.
  final DateTime occurredAtClient;

  final CommandSyncStatus syncStatus;
  final int retryCount;
  final int version;

  /// Human-readable last error for the "sync failed" UI indicator.
  final String? lastError;

  /// Earliest time the next retry is allowed (exponential backoff).
  final DateTime? nextRetryAt;

  QueuedCommand copyWith({
    CommandSyncStatus? syncStatus,
    int? retryCount,
    String? lastError,
    DateTime? nextRetryAt,
  }) {
    return QueuedCommand(
      eventId: eventId,
      idempotencyKey: idempotencyKey,
      userId: userId,
      deviceId: deviceId,
      commandType: commandType,
      payload: payload,
      occurredAtClient: occurredAtClient,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      version: version,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }
}

// ---------------------------------------------------------------------------
// In-memory implementation — retained as a test double.
// ---------------------------------------------------------------------------

class InMemoryCommandQueue {
  final List<QueuedCommand> _queue = [];
  static const _uuid = Uuid();

  List<QueuedCommand> get pendingCommands =>
      _queue.where((c) => c.syncStatus == CommandSyncStatus.pending).toList();

  void enqueue({
    required String commandType,
    required Map<String, dynamic> payload,
    String? userId,
    String? idempotencyKey,
  }) {
    final id = idempotencyKey ?? _uuid.v4();
    _queue.add(QueuedCommand(
      eventId: id,
      idempotencyKey: id,
      userId: userId ?? 'local-user',
      deviceId: 'test-device',
      commandType: commandType,
      payload: payload,
      occurredAtClient: DateTime.now(),
      syncStatus: CommandSyncStatus.pending,
      retryCount: 0,
      version: 1,
    ));
  }

  void markSynced(String eventId) {
    final idx = _queue.indexWhere((c) => c.eventId == eventId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(
        syncStatus: CommandSyncStatus.synced,
      );
    }
  }

  void markFailed(String eventId, String error) {
    final idx = _queue.indexWhere((c) => c.eventId == eventId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(
        syncStatus: CommandSyncStatus.failed,
        lastError: error,
        retryCount: _queue[idx].retryCount + 1,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Persistent implementation backed by Drift
// ---------------------------------------------------------------------------

/// Persistent offline command queue backed by [LocalEventQueueTable].
///
/// Survives app restart, process termination, and OS suspension.
/// Implements exponential backoff: 2s → 4s → 8s → … capped at 300s.
class PersistentCommandQueue {
  PersistentCommandQueue(this._db, {required this.deviceId});

  final AriseDatabase _db;
  final String deviceId;

  static const _uuid = Uuid();
  static const int _maxBackoffSeconds = 300;

  /// Enqueue a domain command for server synchronization.
  /// Returns the generated eventId (== idempotency key).
  Future<String> enqueue({
    required String commandType,
    required Map<String, dynamic> payload,
    required String userId,
    String? idempotencyKey,
  }) async {
    final id = idempotencyKey ?? _uuid.v4();
    final now = DateTime.now();

    await _db.enqueueEvent(
      LocalEventQueueTableCompanion(
        eventId: Value(id),
        userId: Value(userId),
        deviceId: Value(deviceId),
        eventType: Value(commandType),
        payloadJson: Value(json.encode(payload)),
        occurredAtClient: Value(now),
        syncStatus: const Value('pending'),
        retryCount: const Value(0),
        version: const Value(1),
      ),
    );

    return id;
  }

  /// Fetch all commands ready for dispatch (pending + failed with elapsed backoff).
  Future<List<QueuedCommand>> getPending() async {
    final rows = await _db.getPendingEvents();
    return rows.map(_rowToCommand).toList();
  }

  /// Mark a command as in-flight. Call before sending to server.
  Future<void> markSyncing(String eventId) async {
    await _db.updateEventStatus(eventId, 'syncing');
  }

  /// Mark a command as successfully synced. Server has acknowledged.
  Future<void> markSynced(String eventId) async {
    await _db.updateEventStatus(eventId, 'synced');
  }

  /// Mark a command as failed with exponential backoff.
  Future<void> markFailed(String eventId, String error) async {
    final rows = await ((_db.select(_db.localEventQueueTable))
          ..where((t) => t.eventId.equals(eventId)))
        .get();
    if (rows.isEmpty) return;

    final retryCount = rows.first.retryCount;
    final backoffSeconds = _computeBackoff(retryCount + 1);
    final nextRetry =
        DateTime.now().add(Duration(seconds: backoffSeconds));

    await _db.incrementEventRetry(eventId, nextRetry, error);
  }

  /// Mark a command as cancelled (superseded by a later local event).
  Future<void> cancel(String eventId) async {
    await _db.updateEventStatus(eventId, 'cancelled');
  }

  /// Mark a command as conflicted — needs manual resolution per SRS §7.3.
  Future<void> markConflict(String eventId, String conflictDetail) async {
    await _db.updateEventStatus(
      eventId,
      'conflict',
      lastError: conflictDetail,
    );
  }

  /// Recovers any stalled in-flight commands from a crashed/terminated session.
  Future<void> resetStalledSyncingCommands() async {
    await _db.resetStalledSyncingEvents();
  }

  /// Gets the count of pending/failed commands awaiting sync.
  Future<int> getPendingCount() async {
    return _db.getPendingEventsCount();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Exponential backoff: 2^n seconds, capped at [_maxBackoffSeconds].
  int _computeBackoff(int retryCount) {
    final raw = 2 * (1 << retryCount.clamp(0, 7)); // 2,4,8,16,32,64,128,256
    return raw.clamp(2, _maxBackoffSeconds);
  }

  QueuedCommand _rowToCommand(LocalEventQueueTableData row) {
    Map<String, dynamic> payload = {};
    try {
      payload = json.decode(row.payloadJson) as Map<String, dynamic>;
    } catch (_) {
      payload = {};
    }

    return QueuedCommand(
      eventId: row.eventId,
      idempotencyKey: row.eventId,
      userId: row.userId,
      deviceId: row.deviceId,
      commandType: row.eventType,
      payload: payload,
      occurredAtClient: row.occurredAtClient,
      syncStatus: _parseStatus(row.syncStatus),
      retryCount: row.retryCount,
      version: row.version,
      lastError: row.lastError,
      nextRetryAt: row.nextRetryAt,
    );
  }

  CommandSyncStatus _parseStatus(String raw) {
    switch (raw) {
      case 'syncing':
        return CommandSyncStatus.syncing;
      case 'synced':
        return CommandSyncStatus.synced;
      case 'failed':
        return CommandSyncStatus.failed;
      case 'conflict':
        return CommandSyncStatus.conflict;
      case 'cancelled':
        return CommandSyncStatus.cancelled;
      default:
        return CommandSyncStatus.pending;
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Override in main.dart with a PersistentCommandQueue initialized with
/// the real deviceId (from AppMeta table) and AriseDatabase.
final commandQueueProvider = Provider<PersistentCommandQueue>((ref) {
  throw UnimplementedError(
    'commandQueueProvider must be overridden in ProviderScope. '
    'See main.dart for the production override.',
  );
});
