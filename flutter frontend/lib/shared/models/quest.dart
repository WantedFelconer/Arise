// ignore_for_file: constant_identifier_names

enum QuestType { daily, main, side, recurring, boss, ai_generated }

/// Domain model for a Quest (client projection).
///
/// Architecture rules:
///   - idempotencyKey: UUID generated on first local write, sent as Idempotency-Key header on sync
///   - syncStatus: 'local' | 'pending' | 'syncing' | 'verified' | 'failed' | 'conflict'
///   - [backend-authoritative]: xpReward, manaReward — computed by centralized RPG engines.
class Quest {
  final String id; // UUID string — client-generated or server-assigned
  final String rank;
  final QuestType type;
  final String title;
  final String description;
  final int exp;
  final int gold;
  final bool overdue;
  final bool done;

  /// Raw display string — kept for backward compat with display code.
  final String deadline;

  /// Typed UTC deadline — null if no deadline set.
  final DateTime? deadlineDt;

  final int progress;

  /// Server-computed XP reward. Tagged as pending until server confirms.
  final int xpReward;

  /// Server-computed Mana reward.
  final int manaReward;

  /// Idempotency key — UUID generated once on first local write.
  final String idempotencyKey;

  /// Sync state: 'local' | 'pending' | 'syncing' | 'verified' | 'failed' | 'conflict'
  final String syncStatus;

  /// Owner user ID — null before first auth.
  final String? userId;

  /// Linked Boss ID — nullable UUID string linking quest to boss encounter
  final String? bossId;

  /// Quest status: 'pending' | 'active' | 'in_progress' | 'completed' | 'archived' | 'trashed' | 'failed'
  final String status;

  final bool isFavorite;
  final bool isPinned;
  final int estimatedMinutes;

  const Quest({
    this.id = '',
    required this.rank,
    required this.type,
    required this.title,
    required this.description,
    required this.exp,
    this.gold = 0,
    this.overdue = false,
    this.done = false,
    required this.deadline,
    this.deadlineDt,
    this.progress = 0,
    this.xpReward = 0,
    this.manaReward = 0,
    this.idempotencyKey = '',
    this.syncStatus = 'local',
    this.userId,
    this.bossId,
    this.status = 'active',
    this.isFavorite = false,
    this.isPinned = false,
    this.estimatedMinutes = 30,
  });

  Quest copyWith({
    String? id,
    String? rank,
    QuestType? type,
    String? title,
    String? description,
    int? exp,
    int? gold,
    bool? done,
    bool? overdue,
    String? deadline,
    DateTime? deadlineDt,
    int? progress,
    int? xpReward,
    int? manaReward,
    String? idempotencyKey,
    String? syncStatus,
    String? userId,
    String? bossId,
    String? status,
    bool? isFavorite,
    bool? isPinned,
    int? estimatedMinutes,
  }) {
    return Quest(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      exp: exp ?? this.exp,
      gold: gold ?? this.gold,
      overdue: overdue ?? this.overdue,
      done: done ?? this.done,
      deadline: deadline ?? this.deadline,
      deadlineDt: deadlineDt ?? this.deadlineDt,
      progress: progress ?? this.progress,
      xpReward: xpReward ?? this.xpReward,
      manaReward: manaReward ?? this.manaReward,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      syncStatus: syncStatus ?? this.syncStatus,
      userId: userId ?? this.userId,
      bossId: bossId ?? this.bossId,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}
