import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/achievement_models.dart';

/// Remote data source communicating with /api/v1/achievements.
class AchievementsRemoteDataSource {
  final ApiClient _apiClient;

  AchievementsRemoteDataSource(this._apiClient);

  Future<List<SystemAchievement>> listAchievements() async {
    final response = await _apiClient.get('/achievements');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    if (raw is List) {
      return raw.map((a) => SystemAchievement.fromJson(a as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<SystemAchievement>> listUnlocked() async {
    final response = await _apiClient.get('/achievements/unlocked');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    if (raw is List) {
      return raw.map((a) => SystemAchievement.fromJson(a as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

final achievementsRemoteDataSourceProvider = Provider<AchievementsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return AchievementsRemoteDataSource(client);
});

final achievementsProvider = FutureProvider<List<SystemAchievement>>((ref) async {
  final remote = ref.watch(achievementsRemoteDataSourceProvider);
  return remote.listAchievements();
});
