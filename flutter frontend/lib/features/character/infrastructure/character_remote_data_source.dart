import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/character_models.dart';

class CharacterRemoteDataSource {
  final ApiClient apiClient;

  CharacterRemoteDataSource({required this.apiClient});

  /// Fetches the authoritative character snapshot (SRS FR-CHAR-001..003).
  Future<Map<String, dynamic>> fetchCharacter() async {
    final body = await apiClient.get('/character');
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  /// Fetches the stats breakdown for the authenticated hunter.
  Future<Map<String, dynamic>> fetchStats() async {
    final body = await apiClient.get('/character/stats');
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  /// Fetches XP and Mana transaction ledger history (SRS FR-XP-001, FR-MANA-001).
  Future<CharacterTransactionHistory> fetchTransactionHistory() async {
    final body = await apiClient.get('/character/history');
    final data = (body is Map<String, dynamic> && body.containsKey('data'))
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return CharacterTransactionHistory.fromJson(data);
  }

  /// Fetches XP aggregates (today, thisWeek, thisMonth, lifetime).
  Future<XpAggregates> fetchXpAggregates() async {
    final body = await apiClient.get('/character/aggregates');
    final data = (body is Map<String, dynamic> && body.containsKey('data'))
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return XpAggregates.fromJson(data);
  }

  /// Equips an active title on the character.
  Future<Map<String, dynamic>> equipTitle(String? titleId) async {
    final body = await apiClient.patch(
      '/character/title',
      data: {'titleId': titleId},
    );
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  /// Executes an idempotent test progression command through the sync engine.
  Future<Map<String, dynamic>> syncTestCommand({
    required String idempotencyKey,
    int amount = 100,
  }) async {
    final body = await apiClient.post(
      '/sync/idempotency-test',
      data: {'amount': amount},
      idempotencyKey: idempotencyKey,
    );
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }
}

final characterRemoteDataSourceProvider = Provider<CharacterRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CharacterRemoteDataSource(apiClient: apiClient);
});
