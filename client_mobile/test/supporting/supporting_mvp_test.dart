import 'package:flutter_test/flutter_test.dart';
import 'package:arise_app/features/settings/domain/settings_models.dart';
import 'package:arise_app/features/settings/infrastructure/settings_remote_data_source.dart';
import 'package:arise_app/features/settings/application/settings_notifier.dart';
import 'package:arise_app/features/notifications/domain/reminder_models.dart';
import 'package:arise_app/features/notifications/infrastructure/reminders_remote_data_source.dart';
import 'package:arise_app/features/notifications/application/reminders_notifier.dart';
import 'package:arise_app/features/journal/domain/statistics_models.dart';
import 'package:arise_app/features/journal/infrastructure/statistics_remote_data_source.dart';
import 'package:arise_app/features/character/domain/achievement_models.dart';
import 'package:arise_app/features/character/infrastructure/achievements_remote_data_source.dart';
import 'package:arise_app/features/manacore/domain/screen_time_models.dart';
import 'package:arise_app/features/manacore/infrastructure/screen_time_remote_data_source.dart';

class FakeSettingsRemoteDataSource implements SettingsRemoteDataSource {
  UserSettings settings = const UserSettings(
    userId: 'test-user',
    theme: 'void',
    soundEnabled: true,
    difficultyMode: 'casual',
  );

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<UserSettings> updateSettings(Map<String, dynamic> updates) async {
    settings = settings.copyWith(
      theme: updates['theme'] as String? ?? settings.theme,
      soundEnabled: updates['soundEnabled'] as bool? ?? settings.soundEnabled,
      notificationPreferences: updates['notificationPreferences'] as Map<String, bool>? ?? settings.notificationPreferences,
    );
    return settings;
  }

  @override
  Future<String> getDifficultyMode() async => settings.difficultyMode;

  @override
  Future<String> setDifficultyMode(String mode) async {
    settings = settings.copyWith(difficultyMode: mode);
    return mode;
  }

  @override
  Future<Map<String, dynamic>> exportUserData() async {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'user': {'id': 'test-user', 'difficultyMode': settings.difficultyMode},
      'quests': [],
      'bosses': [],
    };
  }

  @override
  Future<Map<String, dynamic>> requestAccountDeletion() async {
    settings = settings.copyWith(deletedAt: DateTime.now().add(const Duration(days: 30)));
    return {'status': 'pending_deletion'};
  }

  @override
  Future<Map<String, dynamic>> cancelAccountDeletion() async {
    settings = settings.copyWith(deletedAt: null);
    return {'status': 'active'};
  }
}

class FakeRemindersRemoteDataSource implements RemindersRemoteDataSource {
  List<SystemReminder> reminders = [];
  List<SystemNotificationItem> notifications = [];

  FakeRemindersRemoteDataSource() {
    reminders = [
      SystemReminder(
        id: 'rem-1',
        title: 'Daily Quest Check-in',
        reminderTime: DateTime.now(),
        category: 'PRODUCTIVITY',
        isActive: true,
      ),
    ];
    notifications = [
      SystemNotificationItem(
        id: 'notif-1',
        title: 'Level Up!',
        message: 'You reached Level 5.',
        type: 'achievement_unlock',
        read: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<SystemReminder>> listReminders({bool activeOnly = false}) async {
    return activeOnly ? reminders.where((r) => r.isActive).toList() : List.of(reminders);
  }

  @override
  Future<SystemReminder> createReminder(Map<String, dynamic> data) async {
    final r = SystemReminder(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      title: data['title'] as String,
      reminderTime: DateTime.parse(data['reminderTime'] as String),
      category: data['category'] as String? ?? 'PRODUCTIVITY',
      icon: data['icon'] as String? ?? '⚔',
      recurrence: data['recurrence'] as String? ?? 'daily',
    );
    reminders.add(r);
    return r;
  }

  @override
  Future<SystemReminder> updateReminder(String id, Map<String, dynamic> updates) async {
    final idx = reminders.indexWhere((r) => r.id == id);
    final curr = reminders[idx];
    final updated = curr.copyWith(
      title: updates['title'] as String? ?? curr.title,
      isActive: updates['isActive'] as bool? ?? curr.isActive,
    );
    reminders[idx] = updated;
    return updated;
  }

  @override
  Future<SystemReminder> snoozeReminder(String id, {int snoozeMinutes = 15}) async {
    final idx = reminders.indexWhere((r) => r.id == id);
    final curr = reminders[idx];
    final updated = curr.copyWith(
      snoozeCount: curr.snoozeCount + 1,
      reminderTime: curr.reminderTime.add(Duration(minutes: snoozeMinutes)),
    );
    reminders[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteReminder(String id) async {
    reminders.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<SystemNotificationItem>> listNotifications() async => List.of(notifications);

  @override
  Future<int> getUnreadCount() async => notifications.where((n) => !n.read).length;

  @override
  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = SystemNotificationItem(
        id: notifications[idx].id,
        title: notifications[idx].title,
        message: notifications[idx].message,
        type: notifications[idx].type,
        read: true,
        createdAt: notifications[idx].createdAt,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = SystemNotificationItem(
        id: notifications[i].id,
        title: notifications[i].title,
        message: notifications[i].message,
        type: notifications[i].type,
        read: true,
        createdAt: notifications[i].createdAt,
      );
    }
  }
}

class FakeStatisticsRemoteDataSource implements StatisticsRemoteDataSource {
  @override
  Future<LifetimeStats> getLifetimeStats() async {
    return const LifetimeStats(
      quests: QuestStats(total: 25, completed: 20, completionRatePct: 80),
      focus: FocusStats(totalSessions: 10, completedSessions: 9, totalFocusMinutes: 225),
      bosses: BossStats(total: 3, defeated: 2, active: 1),
      progression: ProgressionStats(level: 4, rank: 'D', totalXp: 1600, currentStreak: 7, longestStreak: 14),
      screenTime: ScreenTimeStats(totalMinutes: 140, manaDeltaNet: -15),
    );
  }
}

class FakeAchievementsRemoteDataSource implements AchievementsRemoteDataSource {
  @override
  Future<List<SystemAchievement>> listAchievements() async {
    return const [
      SystemAchievement(
        id: 'ach-1',
        code: 'FIRST_BLOOD',
        title: 'First Blood',
        description: 'Complete your first quest',
        category: 'combat',
        xpReward: 100,
        unlocked: true,
      ),
      SystemAchievement(
        id: 'ach-2',
        code: 'IRON_STREAK',
        title: 'Iron Streak',
        description: 'Maintain a 14-day streak',
        category: 'streak',
        xpReward: 250,
        unlocked: false,
      ),
    ];
  }

  @override
  Future<List<SystemAchievement>> listUnlocked() async {
    return const [
      SystemAchievement(
        id: 'ach-1',
        code: 'FIRST_BLOOD',
        title: 'First Blood',
        description: 'Complete your first quest',
        category: 'combat',
        xpReward: 100,
        unlocked: true,
      ),
    ];
  }
}

class FakeScreenTimeRemoteDataSource implements ScreenTimeRemoteDataSource {
  @override
  Future<ScreenTimeInsights> getInsights() async {
    return const ScreenTimeInsights(
      totalMinutes: 180,
      productiveMinutes: 90,
      unproductiveMinutes: 60,
      neutralMinutes: 30,
      netManaDelta: -20,
      appBreakdown: [
        AppScreenTimeDrain(packageName: 'com.instagram.android', name: 'Instagram', durationMinutes: 45, limitMinutes: 30),
      ],
    );
  }

  @override
  Future<Map<String, dynamic>> ingestSessions(List<Map<String, dynamic>> sessions) async {
    return {'ingestedCount': sessions.length};
  }
}

void main() {
  group('Sprint A7 — Supporting MVP Integration Tests', () {
    test('1. Settings & Difficulty Mode: Authoritative mode update and data export', () async {
      final remote = FakeSettingsRemoteDataSource();
      final notifier = SettingsNotifier(remote);

      await notifier.loadSettings();
      expect(notifier.state.settings.difficultyMode, 'casual');
      expect(notifier.state.settings.isHardcore, false);

      // Update to hardcore
      await notifier.updateDifficultyMode('hardcore');
      expect(notifier.state.settings.difficultyMode, 'hardcore');
      expect(notifier.state.settings.isHardcore, true);

      // Test data export
      final exportData = await notifier.exportData();
      expect(exportData, isNotNull);
      expect(exportData!.containsKey('user'), true);

      notifier.dispose();
    });

    test('2. Reminders & Notifications: CRUD, snooze, and unread count handling', () async {
      final remote = FakeRemindersRemoteDataSource();
      final notifier = RemindersNotifier(remote);

      await notifier.loadAll();
      expect(notifier.state.reminders.length, 1);
      expect(notifier.state.unreadCount, 1);

      // Create new reminder
      await notifier.createReminder(
        title: 'HYDRATION CHECK',
        category: 'WELLNESS',
        icon: '💧',
        recurrence: 'daily',
      );
      expect(notifier.state.reminders.length, 2);
      expect(notifier.state.reminders.first.title, 'HYDRATION CHECK');

      // Snooze reminder
      await notifier.snoozeReminder(notifier.state.reminders.first.id, snoozeMinutes: 20);
      expect(notifier.state.reminders.first.snoozeCount, 1);

      // Mark notification read
      await notifier.markAllNotificationsRead();
      expect(notifier.state.unreadCount, 0);

      notifier.dispose();
    });

    test('3. Statistics: Fetches aggregated lifetime stats', () async {
      final remote = FakeStatisticsRemoteDataSource();
      final stats = await remote.getLifetimeStats();

      expect(stats.quests.completed, 20);
      expect(stats.quests.completionRatePct, 80);
      expect(stats.focus.completedSessions, 9);
      expect(stats.progression.currentStreak, 7);
      expect(stats.bosses.defeated, 2);
    });

    test('4. Achievements: Parses catalog, unlocks, and category icons', () async {
      final remote = FakeAchievementsRemoteDataSource();
      final list = await remote.listAchievements();

      expect(list.length, 2);
      expect(list.first.unlocked, true);
      expect(list.first.icon, '⚔');
      expect(list.last.unlocked, false);
      expect(list.last.icon, '🔥');
    });

    test('5. Screen Time: Fetches insights and evaluates app drain limits', () async {
      final remote = FakeScreenTimeRemoteDataSource();
      final insights = await remote.getInsights();

      expect(insights.totalMinutes, 180);
      expect(insights.appBreakdown.length, 1);
      expect(insights.appBreakdown.first.name, 'Instagram');
      expect(insights.appBreakdown.first.isOverLimit, true);
    });
  });
}
