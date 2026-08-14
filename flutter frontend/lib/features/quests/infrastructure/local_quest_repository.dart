import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/arise_database.dart';
import '../../../core/repositories/quest_repository.dart';
import '../../../shared/models/quest.dart';

/// Persistent implementation of [QuestRepository] backed by Drift (SQLite).
///
/// All reads/writes go through [QuestsTable].
/// This never calls the network directly — the SyncEngine handles that.
///
/// Local-first write rule (SRS Rule 6, §17.3):
///   1. Write to local DB (syncStatus='pending', isDirty=true)
///   2. Return immediately → UI updates
///   3. SyncEngine picks up pending rows/commands and sends them asynchronously
class LocalQuestRepository implements QuestRepository {
  LocalQuestRepository(this._db);

  final AriseDatabase _db;
  static const _uuid = Uuid();

  // Sentinel user ID until auth integration in current session.
  static const String kLocalUserId = 'local-user';

  @override
  Future<List<Quest>> fetchQuests({String? userId, String? type, String? status}) async {
    final effectiveUserId = userId ?? kLocalUserId;
    final rows = await _db.getActiveQuests(effectiveUserId);
    var quests = rows.map(_rowToQuest).toList();

    if (type != null && type.isNotEmpty && type != 'ALL') {
      quests = quests.where((q) => q.type.name.toUpperCase() == type.toUpperCase()).toList();
    }
    if (status != null && status.isNotEmpty) {
      quests = quests.where((q) => q.status.toLowerCase() == status.toLowerCase()).toList();
    }
    return quests;
  }

  /// Live reactive Stream of active quests for UI widgets.
  Stream<List<Quest>> watchQuests({String? userId, String? type}) {
    final effectiveUserId = userId ?? kLocalUserId;
    return _db.watchActiveQuests(effectiveUserId).map((rows) {
      var quests = rows.map(_rowToQuest).toList();
      if (type != null && type.isNotEmpty && type != 'ALL') {
        quests = quests.where((q) => q.type.name.toUpperCase() == type.toUpperCase()).toList();
      }
      return quests;
    });
  }

  /// Retrieves a single quest by ID.
  Future<Quest?> getQuestById(String id) async {
    final row = await _db.getQuestById(id);
    if (row == null) return null;
    return _rowToQuest(row);
  }

  @override
  Future<void> saveQuest(Quest quest) async {
    final now = DateTime.now();
    final idempotencyKey =
        quest.idempotencyKey.isEmpty ? _uuid.v4() : quest.idempotencyKey;
    final questId = quest.id.isEmpty ? _uuid.v4() : quest.id;

    await _db.upsertQuest(
      QuestsTableCompanion(
        id: Value(questId),
        userId: Value(quest.userId ?? kLocalUserId),
        title: Value(quest.title),
        description: Value(quest.description),
        questType: Value(quest.type.name),
        priority: const Value('medium'),
        difficulty: Value(_rankToDifficulty(quest.rank)),
        bossId: Value(quest.bossId),
        deadlineDisplay: Value(quest.deadline.isEmpty ? null : quest.deadline),
        deadlineUtc: Value(quest.deadlineDt),
        tagsJson: const Value('[]'),
        xpReward: Value(quest.xpReward > 0 ? quest.xpReward : quest.exp),
        manaReward: Value(quest.manaReward),
        idempotencyKey: Value(idempotencyKey),
        syncStatus: Value(quest.syncStatus.isNotEmpty ? quest.syncStatus : 'pending'),
        isDirty: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        status: Value(quest.done ? 'completed' : 'active'),
        completedAt: quest.done ? Value(now) : const Value.absent(),
      ),
    );
  }

  /// Batch saves a list of quests to the local database.
  Future<void> saveQuests(List<Quest> quests) async {
    final now = DateTime.now();
    final companions = quests.map((quest) {
      final idempotencyKey =
          quest.idempotencyKey.isEmpty ? _uuid.v4() : quest.idempotencyKey;
      final questId = quest.id.isEmpty ? _uuid.v4() : quest.id;

      return QuestsTableCompanion(
        id: Value(questId),
        userId: Value(quest.userId ?? kLocalUserId),
        title: Value(quest.title),
        description: Value(quest.description),
        questType: Value(quest.type.name),
        priority: const Value('medium'),
        difficulty: Value(_rankToDifficulty(quest.rank)),
        bossId: Value(quest.bossId),
        deadlineDisplay: Value(quest.deadline.isEmpty ? null : quest.deadline),
        deadlineUtc: Value(quest.deadlineDt),
        tagsJson: const Value('[]'),
        xpReward: Value(quest.xpReward > 0 ? quest.xpReward : quest.exp),
        manaReward: Value(quest.manaReward),
        idempotencyKey: Value(idempotencyKey),
        syncStatus: Value(quest.syncStatus.isNotEmpty ? quest.syncStatus : 'pending'),
        isDirty: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        status: Value(quest.done ? 'completed' : 'active'),
        completedAt: quest.done ? Value(now) : const Value.absent(),
      );
    }).toList();

    await _db.batchUpsertQuests(companions);
  }

  @override
  Future<void> toggleQuestCompletion(int id) async {
    throw UnimplementedError('Use toggleQuestCompletionById(String id)');
  }

  /// UUID-based toggle for local quest completion.
  Future<void> toggleQuestCompletionById(String questId) async {
    final now = DateTime.now();
    final row = await _db.getQuestById(questId);
    if (row == null) return;

    final newStatus = row.status == 'completed' ? 'active' : 'completed';
    await _db.updateQuestStatus(questId, newStatus, now);
  }

  /// Marks a quest completed locally.
  Future<void> completeQuestLocal(String questId) async {
    final now = DateTime.now();
    await _db.updateQuestStatus(questId, 'completed', now);
  }

  /// Archives a quest locally.
  Future<void> archiveQuestLocal(String questId) async {
    final now = DateTime.now();
    await _db.archiveQuest(questId, now);
  }

  /// Soft deletes a quest locally.
  Future<void> trashQuestLocal(String questId) async {
    final now = DateTime.now();
    await _db.softDeleteQuest(questId, now);
  }

  /// Restores a quest locally.
  Future<void> restoreQuestLocal(String questId) async {
    final now = DateTime.now();
    await _db.restoreQuest(questId, now);
  }

  /// Marks a quest as successfully synchronized with backend.
  Future<void> markQuestVerified(String questId, {Map<String, dynamic>? serverData}) async {
    if (serverData != null && serverData['id'] != null) {
      final companion = _serverDataToCompanion(serverData, 'verified', isDirty: false);
      await _db.upsertQuest(companion);
    } else {
      await _db.updateQuestSyncStatus(questId, 'verified', isDirty: false);
    }
  }

  /// Reconciles server quest list into local SQLite database.
  /// Server state updates existing items and adds new items while preserving
  /// pending local modifications (where is_dirty is true).
  Future<void> reconcileServerQuests(
    List<Map<String, dynamic>> serverQuests,
    String userId,
  ) async {
    final localRows = await _db.getAllQuests(userId);
    final localMap = {for (final row in localRows) row.id: row};

    final companions = <QuestsTableCompanion>[];
    for (final raw in serverQuests) {
      final id = raw['id'] as String? ?? '';
      if (id.isEmpty) continue;

      final existingLocal = localMap[id];
      // If there is an unsynced local mutation, do not overwrite with stale server data
      if (existingLocal != null && existingLocal.isDirty) {
        continue;
      }

      companions.add(_serverDataToCompanion(raw, 'verified', isDirty: false));
    }

    if (companions.isNotEmpty) {
      await _db.batchUpsertQuests(companions);
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  QuestsTableCompanion _serverDataToCompanion(
    Map<String, dynamic> raw,
    String syncStatus, {
    required bool isDirty,
  }) {
    final id = raw['id'] as String? ?? '';
    final userId = raw['userId'] as String? ?? kLocalUserId;
    final title = raw['title'] as String? ?? '';
    final description = raw['description'] as String? ?? '';
    final questType = raw['questType'] as String? ?? 'daily';
    final priority = raw['priority'] as String? ?? 'medium';
    final difficulty = raw['difficulty'] as String? ?? 'medium';
    final status = raw['status'] as String? ?? 'active';
    final estimatedMinutes = (raw['estimatedMinutes'] as num?)?.toInt() ?? 30;
    final actualMinutes = (raw['actualMinutes'] as num?)?.toInt();
    final isFavorite = raw['isFavorite'] == true;
    final isPinned = raw['isPinned'] == true;
    final xpReward = (raw['xpReward'] as num?)?.toInt() ?? _calculateXpReward(difficulty, estimatedMinutes);
    final manaReward = (raw['manaReward'] as num?)?.toInt() ?? 5;

    DateTime? deadlineUtc;
    if (raw['deadline'] != null) {
      try {
        deadlineUtc = DateTime.parse(raw['deadline'] as String);
      } catch (_) {}
    }

    DateTime createdAt = DateTime.now();
    if (raw['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(raw['createdAt'] as String);
      } catch (_) {}
    }

    DateTime updatedAt = DateTime.now();
    if (raw['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(raw['updatedAt'] as String);
      } catch (_) {}
    }

    DateTime? completedAt;
    if (raw['completedAt'] != null) {
      try {
        completedAt = DateTime.parse(raw['completedAt'] as String);
      } catch (_) {}
    }

    return QuestsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      questType: Value(questType),
      priority: Value(priority),
      difficulty: Value(difficulty),
      deadlineUtc: Value(deadlineUtc),
      deadlineDisplay: Value(deadlineUtc != null ? '${deadlineUtc.hour.toString().padLeft(2, '0')}:${deadlineUtc.minute.toString().padLeft(2, '0')}' : null),
      estimatedMinutes: Value(estimatedMinutes),
      actualMinutes: Value(actualMinutes),
      status: Value(status),
      tagsJson: const Value('[]'),
      xpReward: Value(xpReward),
      manaReward: Value(manaReward),
      isFavorite: Value(isFavorite),
      isPinned: Value(isPinned),
      idempotencyKey: Value(id),
      syncStatus: Value(syncStatus),
      isDirty: Value(isDirty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: Value(completedAt),
    );
  }

  Quest _rowToQuest(QuestsTableData row) {
    final isDone = row.status == 'completed';

    return Quest(
      id: row.id,
      userId: row.userId,
      rank: _difficultyToRank(row.difficulty),
      type: _parseQuestType(row.questType),
      title: row.title,
      description: row.description,
      exp: row.xpReward > 0 ? row.xpReward : _calculateXpReward(row.difficulty, row.estimatedMinutes),
      gold: 0,
      done: isDone,
      overdue: _isOverdue(row.deadlineUtc, isDone),
      deadline: row.deadlineDisplay ?? (row.deadlineUtc != null ? 'TODAY · ${row.deadlineUtc!.hour.toString().padLeft(2, '0')}:${row.deadlineUtc!.minute.toString().padLeft(2, '0')}' : 'NO DEADLINE'),
      deadlineDt: row.deadlineUtc,
      progress: isDone ? 100 : 0,
      xpReward: row.xpReward > 0 ? row.xpReward : _calculateXpReward(row.difficulty, row.estimatedMinutes),
      manaReward: row.manaReward > 0 ? row.manaReward : 5,
      idempotencyKey: row.idempotencyKey,
      syncStatus: row.syncStatus,
      bossId: row.bossId,
      status: row.status,
      isFavorite: row.isFavorite,
      isPinned: row.isPinned,
      estimatedMinutes: row.estimatedMinutes,
    );
  }

  static int _calculateXpReward(String difficulty, int estimatedMinutes) {
    final base = estimatedMinutes > 0 ? estimatedMinutes : 30;
    switch (difficulty.toLowerCase()) {
      case 'trivial':
        return (base * 0.5 * 3.33).round();
      case 'easy':
        return (base * 0.8 * 3.33).round();
      case 'hard':
        return (base * 1.5 * 3.33).round();
      case 'epic':
      case 'extreme':
        return (base * 2.0 * 3.33).round();
      default:
        return (base * 1.0 * 3.33).round();
    }
  }

  static String _difficultyToRank(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'epic':
      case 'extreme':
        return 'S';
      case 'hard':
        return 'A';
      case 'medium':
      case 'normal':
        return 'B';
      case 'easy':
        return 'D';
      case 'trivial':
        return 'E';
      default:
        return 'C';
    }
  }

  static String _rankToDifficulty(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return 'epic';
      case 'A':
        return 'hard';
      case 'B':
        return 'medium';
      case 'C':
      case 'D':
        return 'easy';
      default:
        return 'trivial';
    }
  }

  static QuestType _parseQuestType(String raw) {
    switch (raw.toLowerCase()) {
      case 'daily':
        return QuestType.daily;
      case 'main':
        return QuestType.main;
      case 'recurring':
        return QuestType.recurring;
      case 'boss':
      case 'boss_quest':
        return QuestType.boss;
      case 'ai_generated':
        return QuestType.ai_generated;
      default:
        return QuestType.side;
    }
  }

  static bool _isOverdue(DateTime? deadline, bool done) {
    if (done || deadline == null) return false;
    return deadline.isBefore(DateTime.now());
  }
}
