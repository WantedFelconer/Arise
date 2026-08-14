import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/reminder_models.dart';

/// Remote data source for Reminders (/api/v1/reminders) and Notifications (/api/v1/notifications).
class RemindersRemoteDataSource {
  final ApiClient _apiClient;

  RemindersRemoteDataSource(this._apiClient);

  // ---------------------------------------------------------------------------
  // Reminders (§6.11)
  // ---------------------------------------------------------------------------

  Future<List<SystemReminder>> listReminders({bool activeOnly = false}) async {
    final response = await _apiClient.get(
      '/reminders',
      queryParameters: activeOnly ? {'activeOnly': 'true'} : null,
    );
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    if (raw is List) {
      return raw.map((r) => SystemReminder.fromJson(r as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SystemReminder> createReminder(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/reminders', data: data);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return SystemReminder.fromJson(raw);
  }

  Future<SystemReminder> updateReminder(String id, Map<String, dynamic> updates) async {
    final response = await _apiClient.patch('/reminders/$id', data: updates);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return SystemReminder.fromJson(raw);
  }

  Future<SystemReminder> snoozeReminder(String id, {int snoozeMinutes = 15}) async {
    final response = await _apiClient.post('/reminders/$id/snooze', data: {
      'snoozeMinutes': snoozeMinutes,
    });
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return SystemReminder.fromJson(raw);
  }

  Future<void> deleteReminder(String id) async {
    await _apiClient.delete('/reminders/$id');
  }

  // ---------------------------------------------------------------------------
  // Notifications (§6.21)
  // ---------------------------------------------------------------------------

  Future<List<SystemNotificationItem>> listNotifications() async {
    final response = await _apiClient.get('/notifications');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    if (raw is List) {
      return raw.map((n) => SystemNotificationItem.fromJson(n as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return (raw['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.post('/notifications/read-all');
  }
}

/// Riverpod provider for RemindersRemoteDataSource.
final remindersRemoteDataSourceProvider = Provider<RemindersRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return RemindersRemoteDataSource(client);
});
