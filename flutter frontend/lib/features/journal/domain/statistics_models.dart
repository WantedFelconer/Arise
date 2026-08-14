/// Aggregated lifetime statistics model (§6.20, FR-STAT-001).
class LifetimeStats {
  final QuestStats quests;
  final FocusStats focus;
  final BossStats bosses;
  final DungeonStats dungeons;
  final ProgressionStats progression;
  final ScreenTimeStats screenTime;
  final FitnessStats fitness;

  const LifetimeStats({
    this.quests = const QuestStats(),
    this.focus = const FocusStats(),
    this.bosses = const BossStats(),
    this.dungeons = const DungeonStats(),
    this.progression = const ProgressionStats(),
    this.screenTime = const ScreenTimeStats(),
    this.fitness = const FitnessStats(),
  });

  factory LifetimeStats.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    return LifetimeStats(
      quests: raw['quests'] is Map<String, dynamic>
          ? QuestStats.fromJson(raw['quests'] as Map<String, dynamic>)
          : const QuestStats(),
      focus: raw['focus'] is Map<String, dynamic>
          ? FocusStats.fromJson(raw['focus'] as Map<String, dynamic>)
          : const FocusStats(),
      bosses: raw['bosses'] is Map<String, dynamic>
          ? BossStats.fromJson(raw['bosses'] as Map<String, dynamic>)
          : const BossStats(),
      dungeons: raw['dungeons'] is Map<String, dynamic>
          ? DungeonStats.fromJson(raw['dungeons'] as Map<String, dynamic>)
          : const DungeonStats(),
      progression: raw['progression'] is Map<String, dynamic>
          ? ProgressionStats.fromJson(raw['progression'] as Map<String, dynamic>)
          : const ProgressionStats(),
      screenTime: raw['screenTime'] is Map<String, dynamic>
          ? ScreenTimeStats.fromJson(raw['screenTime'] as Map<String, dynamic>)
          : const ScreenTimeStats(),
      fitness: raw['fitness'] is Map<String, dynamic>
          ? FitnessStats.fromJson(raw['fitness'] as Map<String, dynamic>)
          : const FitnessStats(),
    );
  }
}

class QuestStats {
  final int total;
  final int completed;
  final int active;
  final int trashed;
  final int completionRatePct;
  final int totalEstimatedMinutes;
  final int totalActualMinutes;

  const QuestStats({
    this.total = 0,
    this.completed = 0,
    this.active = 0,
    this.trashed = 0,
    this.completionRatePct = 0,
    this.totalEstimatedMinutes = 0,
    this.totalActualMinutes = 0,
  });

  factory QuestStats.fromJson(Map<String, dynamic> json) {
    return QuestStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      trashed: (json['trashed'] as num?)?.toInt() ?? 0,
      completionRatePct: (json['completionRatePct'] as num?)?.toInt() ?? 0,
      totalEstimatedMinutes: (json['totalEstimatedMinutes'] as num?)?.toInt() ?? 0,
      totalActualMinutes: (json['totalActualMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class FocusStats {
  final int totalSessions;
  final int completedSessions;
  final int collapsedSessions;
  final int totalFocusMinutes;
  final int successRatePct;
  final int averageStabilityPct;

  const FocusStats({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.collapsedSessions = 0,
    this.totalFocusMinutes = 0,
    this.successRatePct = 0,
    this.averageStabilityPct = 100,
  });

  factory FocusStats.fromJson(Map<String, dynamic> json) {
    return FocusStats(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
      collapsedSessions: (json['collapsedSessions'] as num?)?.toInt() ?? 0,
      totalFocusMinutes: (json['totalFocusMinutes'] as num?)?.toInt() ?? 0,
      successRatePct: (json['successRatePct'] as num?)?.toInt() ?? 0,
      averageStabilityPct: (json['averageStabilityPct'] as num?)?.toInt() ?? 100,
    );
  }
}

class BossStats {
  final int total;
  final int active;
  final int defeated;

  const BossStats({
    this.total = 0,
    this.active = 0,
    this.defeated = 0,
  });

  factory BossStats.fromJson(Map<String, dynamic> json) {
    return BossStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      defeated: (json['defeated'] as num?)?.toInt() ?? 0,
    );
  }
}

class DungeonStats {
  final int total;
  final int active;
  final int completed;

  const DungeonStats({
    this.total = 0,
    this.active = 0,
    this.completed = 0,
  });

  factory DungeonStats.fromJson(Map<String, dynamic> json) {
    return DungeonStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressionStats {
  final int level;
  final String rank;
  final int totalXp;
  final int currentMana;
  final int maxMana;
  final int currentStreak;
  final int longestStreak;

  const ProgressionStats({
    this.level = 1,
    this.rank = 'E',
    this.totalXp = 0,
    this.currentMana = 100,
    this.maxMana = 100,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory ProgressionStats.fromJson(Map<String, dynamic> json) {
    return ProgressionStats(
      level: (json['level'] as num?)?.toInt() ?? 1,
      rank: json['rank'] as String? ?? 'E',
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentMana: (json['currentMana'] as num?)?.toInt() ?? 100,
      maxMana: (json['maxMana'] as num?)?.toInt() ?? 100,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }
}

class ScreenTimeStats {
  final int totalMinutes;
  final int manaDeltaNet;

  const ScreenTimeStats({
    this.totalMinutes = 0,
    this.manaDeltaNet = 0,
  });

  factory ScreenTimeStats.fromJson(Map<String, dynamic> json) {
    return ScreenTimeStats(
      totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
      manaDeltaNet: (json['manaDeltaNet'] as num?)?.toInt() ?? 0,
    );
  }
}

class FitnessStats {
  final int totalLogs;
  final int totalSteps;
  final int totalWorkoutMinutes;

  const FitnessStats({
    this.totalLogs = 0,
    this.totalSteps = 0,
    this.totalWorkoutMinutes = 0,
  });

  factory FitnessStats.fromJson(Map<String, dynamic> json) {
    return FitnessStats(
      totalLogs: (json['totalLogs'] as num?)?.toInt() ?? 0,
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 0,
      totalWorkoutMinutes: (json['totalWorkoutMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
