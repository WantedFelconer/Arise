/// Represents the user's application and game settings.
class UserSettings {
  final String userId;
  final String theme; // 'void' | 'gold' | 'shadow'
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String language;
  final String difficultyMode; // 'casual' | 'hardcore'
  final String? dailyReminderTime;
  final Map<String, bool> notificationPreferences;
  final DateTime? deletedAt;

  const UserSettings({
    this.userId = '',
    this.theme = 'void',
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.language = 'en',
    this.difficultyMode = 'casual',
    this.dailyReminderTime,
    this.notificationPreferences = const {
      'questReminders': true,
      'gateAlerts': true,
      'bossAttacks': true,
      'streakGuards': true,
    },
    this.deletedAt,
  });

  bool get isHardcore => difficultyMode.toLowerCase() == 'hardcore';
  bool get isPendingDeletion => deletedAt != null;

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final notifs = (raw['notificationPreferences'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v == true),
        ) ??
        const {
          'questReminders': true,
          'gateAlerts': true,
          'bossAttacks': true,
          'streakGuards': true,
        };

    return UserSettings(
      userId: raw['userId'] as String? ?? '',
      theme: raw['theme'] as String? ?? 'void',
      soundEnabled: raw['soundEnabled'] != false,
      hapticsEnabled: raw['hapticsEnabled'] != false,
      language: raw['language'] as String? ?? 'en',
      difficultyMode: raw['difficultyMode'] as String? ?? 'casual',
      dailyReminderTime: raw['dailyReminderTime'] as String?,
      notificationPreferences: notifs,
      deletedAt: raw['deletedAt'] != null ? DateTime.tryParse(raw['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'theme': theme,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'language': language,
      'difficultyMode': difficultyMode,
      'dailyReminderTime': dailyReminderTime,
      'notificationPreferences': notificationPreferences,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? userId,
    String? theme,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? language,
    String? difficultyMode,
    String? dailyReminderTime,
    Map<String, bool>? notificationPreferences,
    DateTime? deletedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      language: language ?? this.language,
      difficultyMode: difficultyMode ?? this.difficultyMode,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
