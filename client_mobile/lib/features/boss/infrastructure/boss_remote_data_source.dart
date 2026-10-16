import '../../../../core/network/api_client.dart';

/// Remote HTTP data source for Boss endpoints (SRS §8.7).
class BossRemoteDataSource {
  BossRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchBosses({
    String? status,
    String? dungeonId,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (dungeonId != null) query['dungeonId'] = dungeonId;

    final res = await _apiClient.get('/bosses', queryParameters: query);
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchBoss(String id) async {
    final res = await _apiClient.get('/bosses/$id');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchBossHistory() async {
    final res = await _apiClient.get('/bosses/history');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createBoss(
    Map<String, dynamic> payload, {
    String? idempotencyKey,
  }) async {
    final res = await _apiClient.post(
      '/bosses',
      data: payload,
      idempotencyKey: idempotencyKey,
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBoss(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.patch('/bosses/$id', data: payload);
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> abandonBoss(String id) async {
    final res = await _apiClient.post('/bosses/$id/abandon');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> reactivateBoss(String id) async {
    final res = await _apiClient.post('/bosses/$id/reactivate');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }
}
