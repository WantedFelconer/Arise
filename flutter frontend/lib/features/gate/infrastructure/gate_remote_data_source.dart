import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

/// Remote HTTP data source for Gate Expedition endpoints (SRS §8.8).
class GateRemoteDataSource {
  GateRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> startSession(
    Map<String, dynamic> payload, {
    String? idempotencyKey,
  }) async {
    final res = await _apiClient.post(
      '/gates/sessions',
      data: payload,
      idempotencyKey: idempotencyKey,
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    final res = await _apiClient.get('/gates/sessions/$id');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pauseSession(
    String id, {
    String difficultyMode = 'casual',
  }) async {
    final res = await _apiClient.post(
      '/gates/sessions/$id/pause',
      options: Options(headers: {'x-difficulty-mode': difficultyMode}),
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resumeSession(String id) async {
    final res = await _apiClient.post('/gates/sessions/$id/resume');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeSession(
    String id, {
    String? idempotencyKey,
  }) async {
    final res = await _apiClient.post(
      '/gates/sessions/$id/complete',
      idempotencyKey: idempotencyKey,
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> collapseSession(
    String id, {
    String? exitReason,
    String difficultyMode = 'casual',
    String? idempotencyKey,
  }) async {
    final res = await _apiClient.post(
      '/gates/sessions/$id/collapse',
      data: {'exitReason': exitReason ?? 'user_exit'},
      options: Options(headers: {'x-difficulty-mode': difficultyMode}),
      idempotencyKey: idempotencyKey,
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _apiClient.get('/gates/stats');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }
}
