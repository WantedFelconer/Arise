import '../../../../core/network/api_client.dart';

/// Remote HTTP data source for Dungeon endpoints (SRS §8.7).
class DungeonRemoteDataSource {
  DungeonRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchDungeons() async {
    final res = await _apiClient.get('/dungeons');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchDungeon(String id) async {
    final res = await _apiClient.get('/dungeons/$id');
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createDungeon(
    Map<String, dynamic> payload, {
    String? idempotencyKey,
  }) async {
    final res = await _apiClient.post(
      '/dungeons',
      data: payload,
      idempotencyKey: idempotencyKey,
    );
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDungeon(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.patch('/dungeons/$id', data: payload);
    final raw = res is Map<String, dynamic> && res.containsKey('data')
        ? res['data']
        : res;
    return raw as Map<String, dynamic>;
  }

  Future<void> deleteDungeon(String id) async {
    await _apiClient.delete('/dungeons/$id');
  }
}
