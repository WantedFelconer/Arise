enum CommandSyncStatus { pending, syncing, synced, failed }

class QueuedCommand {
  final String id;
  final String idempotencyKey;
  final String commandType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  CommandSyncStatus status;
  int retryCount;

  QueuedCommand({
    required this.id,
    required this.idempotencyKey,
    required this.commandType,
    required this.payload,
    required this.createdAt,
    this.status = CommandSyncStatus.pending,
    this.retryCount = 0,
  });
}

class OfflineCommandQueue {
  final List<QueuedCommand> _queue = [];

  List<QueuedCommand> get pendingCommands =>
      _queue.where((c) => c.status == CommandSyncStatus.pending).toList();

  void enqueue({
    required String commandType,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) {
    final key = idempotencyKey ?? 'cmd-${DateTime.now().millisecondsSinceEpoch}';
    final cmd = QueuedCommand(
      id: 'queue-item-${_queue.length + 1}',
      idempotencyKey: key,
      commandType: commandType,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _queue.add(cmd);
  }

  void markSynced(String commandId) {
    final match = _queue.firstWhere((c) => c.id == commandId, orElse: () => throw Exception('Command not found'));
    match.status = CommandSyncStatus.synced;
  }
}
