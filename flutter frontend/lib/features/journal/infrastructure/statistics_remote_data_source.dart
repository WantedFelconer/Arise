import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/statistics_models.dart';

/// Remote data source communicating with /api/v1/stats.
class StatisticsRemoteDataSource {
  final ApiClient _apiClient;

  StatisticsRemoteDataSource(this._apiClient);

  Future<LifetimeStats> getLifetimeStats() async {
    final response = await _apiClient.get('/stats');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return LifetimeStats.fromJson(raw);
  }
}

final statisticsRemoteDataSourceProvider = Provider<StatisticsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return StatisticsRemoteDataSource(client);
});

final lifetimeStatsProvider = FutureProvider<LifetimeStats>((ref) async {
  final remote = ref.watch(statisticsRemoteDataSourceProvider);
  return remote.getLifetimeStats();
});
