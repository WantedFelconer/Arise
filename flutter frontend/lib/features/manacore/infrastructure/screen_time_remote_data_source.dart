import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/screen_time_models.dart';

/// Remote data source communicating with /api/v1/screen-time.
class ScreenTimeRemoteDataSource {
  final ApiClient _apiClient;

  ScreenTimeRemoteDataSource(this._apiClient);

  Future<ScreenTimeInsights> getInsights() async {
    final response = await _apiClient.get('/screen-time/insights');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return ScreenTimeInsights.fromJson(raw);
  }

  Future<Map<String, dynamic>> ingestSessions(List<Map<String, dynamic>> sessions) async {
    final response = await _apiClient.post('/screen-time/sessions', data: {
      'sessions': sessions,
    });
    return response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});
  }
}

final screenTimeRemoteDataSourceProvider = Provider<ScreenTimeRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ScreenTimeRemoteDataSource(client);
});

final screenTimeInsightsProvider = FutureProvider<ScreenTimeInsights>((ref) async {
  final remote = ref.watch(screenTimeRemoteDataSourceProvider);
  return remote.getInsights();
});
