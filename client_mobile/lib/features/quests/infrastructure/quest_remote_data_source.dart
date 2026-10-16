import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Remote data source for Quests communicating with NestJS backend API (/api/v1/quests).
class QuestRemoteDataSource {
  QuestRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches quests with optional server-side filtering.
  Future<List<Map<String, dynamic>>> fetchQuests({
    String? status,
    String? priority,
    String? difficulty,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (difficulty != null && difficulty.isNotEmpty) queryParams['difficulty'] = difficulty;
    if (tag != null && tag.isNotEmpty) queryParams['tag'] = tag;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) queryParams['sortOrder'] = sortOrder;

    final response = await _apiClient.get(
      '/quests',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final raw = response;
    if (raw is Map<String, dynamic> && raw['data'] is List) {
      return (raw['data'] as List).cast<Map<String, dynamic>>();
    } else if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Fetches a single quest by ID.
  Future<Map<String, dynamic>> getQuest(String id) async {
    final response = await _apiClient.get('/quests/$id');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Creates a quest on the backend with an optional Idempotency-Key.
  Future<Map<String, dynamic>> createQuest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.post(
      '/quests',
      data: data,
      idempotencyKey: idempotencyKey,
    );
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Updates an existing quest.
  Future<Map<String, dynamic>> updateQuest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch('/quests/$id', data: data);
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Completes a quest triggering the centralized atomic Reward Cascade.
  Future<Map<String, dynamic>> completeQuest(
    String id, {
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.post(
      '/quests/$id/complete',
      idempotencyKey: idempotencyKey,
    );
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Archives a quest.
  Future<Map<String, dynamic>> archiveQuest(String id) async {
    final response = await _apiClient.post('/quests/$id/archive');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Restores an archived or trashed quest.
  Future<Map<String, dynamic>> restoreQuest(String id) async {
    final response = await _apiClient.post('/quests/$id/restore');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Soft-deletes a quest (moves to trash).
  Future<Map<String, dynamic>> deleteQuest(String id) async {
    final response = await _apiClient.delete('/quests/$id');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Starts a quest (transitions status from pending to in_progress).
  Future<Map<String, dynamic>> startQuest(String id) async {
    final response = await _apiClient.post('/quests/$id/start');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }

  /// Pauses a quest (transitions status from in_progress to pending).
  Future<Map<String, dynamic>> pauseQuest(String id) async {
    final response = await _apiClient.post('/quests/$id/pause');
    final raw = response;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw is Map<String, dynamic> ? raw : {};
  }
}

/// Riverpod provider for QuestRemoteDataSource.
final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuestRemoteDataSource(client);
});
