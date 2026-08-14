/// Gate Expedition domain models (SRS §4.13, §6.2, §7.1).
enum GateSessionStatus {
  active,
  paused,
  cleared,
  collapsed,
}

class GateSession {
  const GateSession({
    required this.id,
    required this.userId,
    this.questId,
    required this.startedAt,
    this.endedAt,
    this.pausedAt,
    required this.plannedDurationS,
    this.actualDurationS,
    this.pauseCount = 0,
    this.totalPausedDurationS = 0,
    this.exitReason,
    this.status = GateSessionStatus.active,
    this.stabilityFinal,
    this.xpAwarded,
    this.manaDelta,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? questId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? pausedAt;
  final int plannedDurationS;
  final int? actualDurationS;
  final int pauseCount;
  final int totalPausedDurationS;
  final String? exitReason;
  final GateSessionStatus status;
  final double? stabilityFinal;
  final int? xpAwarded;
  final int? manaDelta;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == GateSessionStatus.active;
  bool get isPaused => status == GateSessionStatus.paused;
  bool get isCleared => status == GateSessionStatus.cleared;
  bool get isCollapsed => status == GateSessionStatus.collapsed;

  GateSession copyWith({
    String? id,
    String? userId,
    String? questId,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? pausedAt,
    int? plannedDurationS,
    int? actualDurationS,
    int? pauseCount,
    int? totalPausedDurationS,
    String? exitReason,
    GateSessionStatus? status,
    double? stabilityFinal,
    int? xpAwarded,
    int? manaDelta,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GateSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questId: questId ?? this.questId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      plannedDurationS: plannedDurationS ?? this.plannedDurationS,
      actualDurationS: actualDurationS ?? this.actualDurationS,
      pauseCount: pauseCount ?? this.pauseCount,
      totalPausedDurationS: totalPausedDurationS ?? this.totalPausedDurationS,
      exitReason: exitReason ?? this.exitReason,
      status: status ?? this.status,
      stabilityFinal: stabilityFinal ?? this.stabilityFinal,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      manaDelta: manaDelta ?? this.manaDelta,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GateSession.fromJson(Map<String, dynamic> json) {
    GateSessionStatus parseStatus(String? s) {
      switch (s) {
        case 'active':
        case 'in_progress':
          return GateSessionStatus.active;
        case 'paused':
          return GateSessionStatus.paused;
        case 'cleared':
        case 'completed':
          return GateSessionStatus.cleared;
        case 'collapsed':
          return GateSessionStatus.collapsed;
        default:
          return GateSessionStatus.active;
      }
    }

    return GateSession(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'local-user',
      questId: json['questId'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : null,
      pausedAt: json['pausedAt'] != null
          ? DateTime.tryParse(json['pausedAt'] as String)
          : null,
      plannedDurationS: (json['plannedDurationS'] as num?)?.toInt() ?? 1500,
      actualDurationS: (json['actualDurationS'] as num?)?.toInt(),
      pauseCount: (json['pauseCount'] as num?)?.toInt() ?? 0,
      totalPausedDurationS:
          (json['totalPausedDurationS'] as num?)?.toInt() ?? 0,
      exitReason: json['exitReason'] as String?,
      status: parseStatus(json['status'] as String?),
      stabilityFinal: (json['stabilityFinal'] as num?)?.toDouble(),
      xpAwarded: (json['xpAwarded'] as num?)?.toInt(),
      manaDelta: (json['manaDelta'] as num?)?.toInt(),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class GateStats {
  const GateStats({
    required this.totalSessions,
    required this.totalCleared,
    required this.totalCollapsed,
    required this.successRatePct,
    required this.longestExpeditionSeconds,
    required this.totalFocusTimeSeconds,
  });

  final int totalSessions;
  final int totalCleared;
  final int totalCollapsed;
  final int successRatePct;
  final int longestExpeditionSeconds;
  final int totalFocusTimeSeconds;

  factory GateStats.fromJson(Map<String, dynamic> json) {
    return GateStats(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalCleared: (json['totalCleared'] as num?)?.toInt() ?? 0,
      totalCollapsed: (json['totalCollapsed'] as num?)?.toInt() ?? 0,
      successRatePct: (json['successRatePct'] as num?)?.toInt() ?? 0,
      longestExpeditionSeconds:
          (json['longestExpeditionSeconds'] as num?)?.toInt() ?? 0,
      totalFocusTimeSeconds:
          (json['totalFocusTimeSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = GateStats(
    totalSessions: 0,
    totalCleared: 0,
    totalCollapsed: 0,
    successRatePct: 0,
    longestExpeditionSeconds: 0,
    totalFocusTimeSeconds: 0,
  );
}
