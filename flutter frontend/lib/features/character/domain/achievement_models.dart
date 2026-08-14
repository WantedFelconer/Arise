/// Domain model for an Achievement (§6.19).
class SystemAchievement {
  final String id;
  final String code;
  final String title;
  final String description;
  final String category;
  final int xpReward;
  final String? badgeAssetUrl;
  final bool unlocked;
  final DateTime? unlockedAt;

  const SystemAchievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.category = 'general',
    this.xpReward = 100,
    this.badgeAssetUrl,
    this.unlocked = false,
    this.unlockedAt,
  });

  String get icon {
    switch (category.toLowerCase()) {
      case 'combat':
      case 'boss':
        return '⚔';
      case 'focus':
      case 'gate':
        return '🏛';
      case 'streak':
      case 'habit':
        return '🔥';
      case 'craft':
      case 'mind':
        return '📚';
      case 'progression':
      case 'rank':
        return '👑';
      default:
        return '◈';
    }
  }

  String get rarity {
    if (xpReward >= 500) return 'legendary';
    if (xpReward >= 300) return 'epic';
    if (xpReward >= 150) return 'rare';
    if (xpReward >= 75) return 'uncommon';
    return 'common';
  }

  factory SystemAchievement.fromJson(Map<String, dynamic> json) {
    return SystemAchievement(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 100,
      badgeAssetUrl: json['badgeAssetUrl'] as String?,
      unlocked: json['unlocked'] == true,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'category': category,
      'xpReward': xpReward,
      'badgeAssetUrl': badgeAssetUrl,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}
