import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/reminder_models.dart';
import '../infrastructure/reminders_remote_data_source.dart';

class RemindersState {
  final List<SystemReminder> reminders;
  final List<SystemNotificationItem> notifications;
  final int unreadCount;
  final String activeTab; // 'PRODUCTIVITY' | 'WELLNESS' | 'BEHAVIORAL' | 'SYSTEM'
  final bool isLoading;
  final String? error;

  const RemindersState({
    this.reminders = const [],
    this.notifications = const [],
    this.unreadCount = 0,
    this.activeTab = 'PRODUCTIVITY',
    this.isLoading = false,
    this.error,
  });

  RemindersState copyWith({
    List<SystemReminder>? reminders,
    List<SystemNotificationItem>? notifications,
    int? unreadCount,
    String? activeTab,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final RemindersRemoteDataSource _remoteDataSource;

  RemindersNotifier(this._remoteDataSource) : super(const RemindersState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rems = await _remoteDataSource.listReminders();
      final notifs = await _remoteDataSource.listNotifications();
      final unread = await _remoteDataSource.getUnreadCount();

      if (mounted) {
        state = state.copyWith(
          reminders: rems,
          notifications: notifs,
          unreadCount: unread,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> createReminder({
    required String title,
    required String category,
    required String icon,
    String recurrence = 'daily',
    DateTime? reminderTime,
  }) async {
    try {
      final newRem = await _remoteDataSource.createReminder({
        'title': title,
        'category': category,
        'icon': icon,
        'recurrence': recurrence,
        'reminderTime': (reminderTime ?? DateTime.now().add(const Duration(hours: 1))).toIso8601String(),
      });

      if (mounted) {
        state = state.copyWith(reminders: [newRem, ...state.reminders]);
      }
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleReminder(String id) async {
    final idx = state.reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final curr = state.reminders[idx];
    final newActive = !curr.isActive;

    final updated = List<SystemReminder>.from(state.reminders);
    updated[idx] = curr.copyWith(isActive: newActive);
    state = state.copyWith(reminders: updated);

    try {
      await _remoteDataSource.updateReminder(id, {'isActive': newActive});
    } catch (_) {}
  }

  Future<void> snoozeReminder(String id, {int snoozeMinutes = 15}) async {
    try {
      final updatedRem = await _remoteDataSource.snoozeReminder(id, snoozeMinutes: snoozeMinutes);
      final list = state.reminders.map((r) => r.id == id ? updatedRem : r).toList();
      if (mounted) {
        state = state.copyWith(reminders: list);
      }
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteReminder(String id) async {
    final list = state.reminders.where((r) => r.id != id).toList();
    state = state.copyWith(reminders: list);
    try {
      await _remoteDataSource.deleteReminder(id);
    } catch (_) {}
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _remoteDataSource.markAsRead(id);
      final notifs = state.notifications.map((n) => n.id == id ? SystemNotificationItem(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        read: true,
        createdAt: n.createdAt,
        data: n.data,
      ) : n).toList();

      if (mounted) {
        state = state.copyWith(
          notifications: notifs,
          unreadCount: (state.unreadCount - 1).clamp(0, 999),
        );
      }
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      final notifs = state.notifications.map((n) => SystemNotificationItem(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        read: true,
        createdAt: n.createdAt,
        data: n.data,
      )).toList();

      if (mounted) {
        state = state.copyWith(
          notifications: notifs,
          unreadCount: 0,
        );
      }
    } catch (_) {}
  }
}

final remindersNotifierProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  final remote = ref.watch(remindersRemoteDataSourceProvider);
  return RemindersNotifier(remote);
});
