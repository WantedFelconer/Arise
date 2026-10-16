/// Represents a user or system scheduled reminder (§6.11).
class SystemReminder {
  final String id;
  final String title;
  final DateTime reminderTime;
  final String recurrence; // 'none' | 'daily' | 'weekdays' | 'weekly' | 'custom'
  final bool isActive;
  final String? questId;
  final String category; // 'PRODUCTIVITY' | 'WELLNESS' | 'BEHAVIORAL' | 'SYSTEM'
  final String icon;
  final int snoozeCount;

  const SystemReminder({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.recurrence = 'daily',
    this.isActive = true,
    this.questId,
    this.category = 'PRODUCTIVITY',
    this.icon = '⚔',
    this.snoozeCount = 0,
  });

  factory SystemReminder.fromJson(Map<String, dynamic> json) {
    final rawTime = json['reminderTime'] != null
        ? DateTime.tryParse(json['reminderTime'] as String) ?? DateTime.now()
        : DateTime.now();

    return SystemReminder(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      reminderTime: rawTime,
      recurrence: json['recurrence'] as String? ?? 'daily',
      isActive: json['isActive'] != false,
      questId: json['questId'] as String?,
      category: json['category'] as String? ?? 'PRODUCTIVITY',
      icon: json['icon'] as String? ?? '⚔',
      snoozeCount: (json['snoozeCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reminderTime': reminderTime.toIso8601String(),
      'recurrence': recurrence,
      'isActive': isActive,
      'questId': questId,
      'category': category,
      'icon': icon,
      'snoozeCount': snoozeCount,
    };
  }

  SystemReminder copyWith({
    String? id,
    String? title,
    DateTime? reminderTime,
    String? recurrence,
    bool? isActive,
    String? questId,
    String? category,
    String? icon,
    int? snoozeCount,
  }) {
    return SystemReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      reminderTime: reminderTime ?? this.reminderTime,
      recurrence: recurrence ?? this.recurrence,
      isActive: isActive ?? this.isActive,
      questId: questId ?? this.questId,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }
}

/// Represents an in-app system notification (§6.21).
class SystemNotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'achievement_unlock' | 'quest_reminder' | 'gate_alert' | 'penalty_warning'
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const SystemNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'general',
    this.read = false,
    required this.createdAt,
    this.data,
  });

  factory SystemNotificationItem.fromJson(Map<String, dynamic> json) {
    return SystemNotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
