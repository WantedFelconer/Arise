import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/settings_models.dart';
import '../infrastructure/settings_remote_data_source.dart';

class SettingsState {
  final UserSettings settings;
  final bool isLoading;
  final String? error;
  final String? statusMessage;

  const SettingsState({
    this.settings = const UserSettings(),
    this.isLoading = false,
    this.error,
    this.statusMessage,
  });

  SettingsState copyWith({
    UserSettings? settings,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusMessage: clearStatusMessage ? null : (statusMessage ?? this.statusMessage),
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsNotifier(this._remoteDataSource) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final s = await _remoteDataSource.getSettings();
      if (mounted) {
        state = state.copyWith(settings: s, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> updateTheme(String themeId) async {
    final updated = state.settings.copyWith(theme: themeId);
    state = state.copyWith(settings: updated);
    try {
      await _remoteDataSource.updateSettings({'theme': themeId});
    } catch (_) {}
  }

  Future<void> updateSound(bool enabled) async {
    final updated = state.settings.copyWith(soundEnabled: enabled);
    state = state.copyWith(settings: updated);
    try {
      await _remoteDataSource.updateSettings({'soundEnabled': enabled});
    } catch (_) {}
  }

  Future<void> updateDifficultyMode(String mode) async {
    final updated = state.settings.copyWith(difficultyMode: mode);
    state = state.copyWith(settings: updated);
    try {
      await _remoteDataSource.setDifficultyMode(mode);
    } catch (_) {}
  }

  Future<void> toggleNotification(String key, bool enabled) async {
    final prefs = Map<String, bool>.from(state.settings.notificationPreferences);
    prefs[key] = enabled;
    final updated = state.settings.copyWith(notificationPreferences: prefs);
    state = state.copyWith(settings: updated);
    try {
      await _remoteDataSource.updateSettings({'notificationPreferences': prefs});
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> exportData() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _remoteDataSource.exportUserData();
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          statusMessage: 'Export generated successfully (${data.keys.length} tables exported).',
        );
      }
      return data;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: 'Export failed: $e');
      }
      return null;
    }
  }

  Future<void> requestAccountDeletion() async {
    try {
      await _remoteDataSource.requestAccountDeletion();
      await loadSettings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelAccountDeletion() async {
    try {
      await _remoteDataSource.cancelAccountDeletion();
      await loadSettings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final remote = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsNotifier(remote);
});
