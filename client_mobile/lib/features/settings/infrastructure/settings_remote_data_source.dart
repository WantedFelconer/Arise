import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/settings_models.dart';

/// Remote data source for user settings and account preferences (/api/v1/settings).
class SettingsRemoteDataSource {
  final ApiClient _apiClient;

  SettingsRemoteDataSource(this._apiClient);

  /// Retrieves the current user's settings.
  Future<UserSettings> getSettings() async {
    final response = await _apiClient.get('/settings');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return UserSettings.fromJson(raw);
  }

  /// Updates settings fields (theme, sounds, notificationPreferences, etc.).
  Future<UserSettings> updateSettings(Map<String, dynamic> updates) async {
    final response = await _apiClient.patch('/settings', data: updates);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return UserSettings.fromJson(raw);
  }

  /// Gets the authoritative difficulty mode.
  Future<String> getDifficultyMode() async {
    final response = await _apiClient.get('/settings/difficulty-mode');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return raw['difficultyMode'] as String? ?? 'casual';
  }

  /// Sets the authoritative difficulty mode ('casual' | 'hardcore').
  Future<String> setDifficultyMode(String mode) async {
    final response = await _apiClient.put('/settings/difficulty-mode', data: {
      'difficultyMode': mode.toLowerCase(),
    });
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return raw['difficultyMode'] as String? ?? mode;
  }

  /// Exports full account data dump as JSON (§6.23).
  Future<Map<String, dynamic>> exportUserData() async {
    final response = await _apiClient.get('/settings/export');
    return response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});
  }

  /// Requests 30-day soft-delete account deletion (§6.23).
  Future<Map<String, dynamic>> requestAccountDeletion() async {
    final response = await _apiClient.post('/settings/account/delete');
    return response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});
  }

  /// Cancels a pending account deletion request.
  Future<Map<String, dynamic>> cancelAccountDeletion() async {
    final response = await _apiClient.post('/settings/account/cancel-deletion');
    return response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});
  }
}

/// Riverpod provider for SettingsRemoteDataSource.
final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SettingsRemoteDataSource(client);
});
