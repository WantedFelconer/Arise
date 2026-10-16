/// Boss domain models (SRS §4.11, §6.2, §7.1).
class Boss {
  const Boss({
    required this.id,
    required this.userId,
    this.dungeonId,
    required this.title,
    this.description,
    required this.hpMax,
    required this.hpCurrent,
    this.difficulty = 'medium',
    this.status = 'active',
    this.deadline,
    this.defeatedAt,
    this.syncStatus = 'synced',
    this.isDirty = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? dungeonId;
  final String title;
  final String? description;
  final int hpMax;
  final int hpCurrent;
  final String difficulty; // trivial, easy, medium, hard, epic
  final String status; // active, defeated, abandoned
  final DateTime? deadline;
  final DateTime? defeatedAt;
  final String syncStatus; // synced, pending, failed
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDefeated => status == 'defeated' || hpCurrent <= 0;
  bool get isAbandoned => status == 'abandoned';
  bool get isActive => status == 'active' && hpCurrent > 0;

  double get hpPercent => hpMax <= 0 ? 0.0 : (hpCurrent / hpMax).clamp(0.0, 1.0);

  String get rank {
    switch (difficulty.toLowerCase()) {
      case 'trivial':
        return 'E';
      case 'easy':
        return 'D';
      case 'medium':
        return 'C';
      case 'hard':
        return 'A';
      case 'epic':
        return 'S';
      default:
        return 'C';
    }
  }

  Boss copyWith({
    String? id,
    String? userId,
    String? dungeonId,
    String? title,
    String? description,
    int? hpMax,
    int? hpCurrent,
    String? difficulty,
    String? status,
    DateTime? deadline,
    DateTime? defeatedAt,
    String? syncStatus,
    bool? isDirty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Boss(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dungeonId: dungeonId ?? this.dungeonId,
      title: title ?? this.title,
      description: description ?? this.description,
      hpMax: hpMax ?? this.hpMax,
      hpCurrent: hpCurrent ?? this.hpCurrent,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      defeatedAt: defeatedAt ?? this.defeatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'local-user',
      dungeonId: json['dungeonId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      hpMax: (json['hpMax'] as num?)?.toInt() ?? 1000,
      hpCurrent: (json['hpCurrent'] as num?)?.toInt() ?? 1000,
      difficulty: json['difficulty'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'active',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      defeatedAt: json['defeatedAt'] != null
          ? DateTime.tryParse(json['defeatedAt'] as String)
          : null,
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dungeonId': dungeonId,
      'title': title,
      'description': description,
      'hpMax': hpMax,
      'hpCurrent': hpCurrent,
      'difficulty': difficulty,
      'status': status,
      'deadline': deadline?.toIso8601String(),
      'defeatedAt': defeatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BossHistoryItem {
  const BossHistoryItem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.hpMax,
    required this.defeatedAt,
    required this.createdAt,
    required this.timeToDefeatMs,
    required this.questsCompletedCount,
  });

  final String id;
  final String title;
  final String difficulty;
  final int hpMax;
  final DateTime defeatedAt;
  final DateTime createdAt;
  final int timeToDefeatMs;
  final int questsCompletedCount;

  factory BossHistoryItem.fromJson(Map<String, dynamic> json) {
    return BossHistoryItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'medium',
      hpMax: (json['hpMax'] as num?)?.toInt() ?? 1000,
      defeatedAt: json['defeatedAt'] != null
          ? DateTime.tryParse(json['defeatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      timeToDefeatMs: (json['timeToDefeatMs'] as num?)?.toInt() ?? 0,
      questsCompletedCount: (json['questsCompletedCount'] as num?)?.toInt() ?? 0,
    );
  }
}
