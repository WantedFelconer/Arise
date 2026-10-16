import '../../../shared/models/quest.dart';

/// Represents a single quest proposal inside an AI-generated plan.
class AiPlanQuest {
  final String title;
  final String description;
  final String difficulty; // 'trivial' | 'easy' | 'medium' | 'hard' | 'epic'
  final String rank; // 'E' | 'D' | 'C' | 'B' | 'A' | 'S'
  final int xpReward;
  final int manaCost;
  final int targetDurationMinutes;
  final int estimatedDays;
  final List<AiPlanSubquest> subquests;

  const AiPlanQuest({
    required this.title,
    required this.description,
    this.difficulty = 'medium',
    this.rank = 'B',
    this.xpReward = 150,
    this.manaCost = 10,
    this.targetDurationMinutes = 30,
    this.estimatedDays = 1,
    this.subquests = const [],
  });

  factory AiPlanQuest.fromJson(Map<String, dynamic> json) {
    final diff = json['difficulty'] as String? ?? 'medium';
    final rank = json['rank'] as String? ?? _difficultyToRank(diff);
    final subs = (json['subquests'] as List<dynamic>?)
            ?.map((s) => AiPlanSubquest.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return AiPlanQuest(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      difficulty: diff,
      rank: rank,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? (json['exp'] as num?)?.toInt() ?? 150,
      manaCost: (json['manaCost'] as num?)?.toInt() ?? 10,
      targetDurationMinutes: (json['targetDurationMinutes'] as num?)?.toInt() ??
          (json['estimatedMinutes'] as num?)?.toInt() ??
          30,
      estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 1,
      subquests: subs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'rank': rank,
      'xpReward': xpReward,
      'manaCost': manaCost,
      'targetDurationMinutes': targetDurationMinutes,
      'estimatedDays': estimatedDays,
      'subquests': subquests.map((s) => s.toJson()).toList(),
    };
  }

  static String _difficultyToRank(String diff) {
    switch (diff.toLowerCase()) {
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
}

/// Represents a subquest within an AI plan quest.
class AiPlanSubquest {
  final String title;
  final int xpReward;
  final int targetDurationMinutes;

  const AiPlanSubquest({
    required this.title,
    this.xpReward = 50,
    this.targetDurationMinutes = 15,
  });

  factory AiPlanSubquest.fromJson(Map<String, dynamic> json) {
    return AiPlanSubquest(
      title: json['title'] as String? ?? '',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? (json['exp'] as num?)?.toInt() ?? 50,
      targetDurationMinutes: (json['targetDurationMinutes'] as num?)?.toInt() ??
          (json['estimatedMinutes'] as num?)?.toInt() ??
          15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'xpReward': xpReward,
      'targetDurationMinutes': targetDurationMinutes,
    };
  }
}

/// Represents an AI-generated staged quest plan.
/// Rule 10: "AI proposes, it never commits".
/// Staged with status 'pending_approval' or 'edited' until user explicitly approves.
class AiGeneratedPlan {
  final String id;
  final String userId;
  final String goal;
  final int durationDays;
  final int estimatedXp;
  final String status; // 'pending_approval' | 'edited' | 'rejected' | 'approved'
  final List<AiPlanQuest> quests;
  final List<String> constraints;
  final String? focusArea;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<Quest> materializedQuests;

  const AiGeneratedPlan({
    required this.id,
    required this.userId,
    required this.goal,
    this.durationDays = 7,
    this.estimatedXp = 0,
    this.status = 'pending_approval',
    this.quests = const [],
    this.constraints = const [],
    this.focusArea,
    required this.createdAt,
    this.approvedAt,
    this.materializedQuests = const [],
  });

  bool get isPendingApproval => status == 'pending_approval' || status == 'edited';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory AiGeneratedPlan.fromJson(Map<String, dynamic> json) {
    final rawPlanData = json['planData'] is Map<String, dynamic>
        ? json['planData'] as Map<String, dynamic>
        : json;

    final questsList = (rawPlanData['quests'] as List<dynamic>?)
            ?.map((q) => AiPlanQuest.fromJson(q as Map<String, dynamic>))
            .toList() ??
        (json['quests'] as List<dynamic>?)
            ?.map((q) => AiPlanQuest.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    final constraintsList = (json['constraints'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        [];

    final materialized = (json['materializedQuests'] as List<dynamic>?)
            ?.map((q) {
              if (q is Map<String, dynamic>) {
                return Quest(
                  id: q['id'] as String? ?? '',
                  userId: q['userId'] as String?,
                  rank: (q['rank'] as String?) ?? 'B',
                  type: QuestType.ai_generated,
                  title: q['title'] as String? ?? '',
                  description: q['description'] as String? ?? '',
                  exp: (q['xpReward'] as num?)?.toInt() ?? 100,
                  xpReward: (q['xpReward'] as num?)?.toInt() ?? 100,
                  manaReward: (q['manaReward'] as num?)?.toInt() ?? 5,
                  deadline: q['deadlineDisplay'] as String? ?? 'TODAY',
                  status: q['status'] as String? ?? 'active',
                );
              }
              return null;
            })
            .whereType<Quest>()
            .toList() ??
        [];

    return AiGeneratedPlan(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      goal: json['goal'] as String? ?? rawPlanData['goal'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ??
          (rawPlanData['durationDays'] as num?)?.toInt() ??
          7,
      estimatedXp: (json['estimatedXp'] as num?)?.toInt() ??
          (rawPlanData['estimatedXp'] as num?)?.toInt() ??
          questsList.fold(0, (sum, q) => sum + q.xpReward),
      status: json['status'] as String? ?? 'pending_approval',
      quests: questsList,
      constraints: constraintsList,
      focusArea: json['focusArea'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'] as String)
          : null,
      materializedQuests: materialized,
    );
  }

  AiGeneratedPlan copyWith({
    String? id,
    String? userId,
    String? goal,
    int? durationDays,
    int? estimatedXp,
    String? status,
    List<AiPlanQuest>? quests,
    List<String>? constraints,
    String? focusArea,
    DateTime? createdAt,
    DateTime? approvedAt,
    List<Quest>? materializedQuests,
  }) {
    return AiGeneratedPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goal: goal ?? this.goal,
      durationDays: durationDays ?? this.durationDays,
      estimatedXp: estimatedXp ?? this.estimatedXp,
      status: status ?? this.status,
      quests: quests ?? this.quests,
      constraints: constraints ?? this.constraints,
      focusArea: focusArea ?? this.focusArea,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      materializedQuests: materializedQuests ?? this.materializedQuests,
    );
  }
}
