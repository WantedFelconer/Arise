import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/ai_plan.dart';
import '../domain/ai_coach_models.dart';

/// Remote data source communicating with NestJS AI Intelligence Layer (/api/v1/ai).
/// Rule 8: Flutter never contains vendor AI keys (OpenAI, Gemini, Anthropic).
/// All AI communication routes strictly through NestJS backend AI abstraction.
class AiRemoteDataSource {
  final ApiClient _apiClient;

  AiRemoteDataSource(this._apiClient);

  // ---------------------------------------------------------------------------
  // AI Quest Planner (§6.12, §10.2, §10.3)
  // ---------------------------------------------------------------------------

  /// Generates a structured quest plan proposal staged in 'pending_approval' state.
  /// Rule 10: AI proposes, it never commits.
  Future<AiGeneratedPlan> generatePlan({
    required String goal,
    int durationDays = 7,
    List<String> constraints = const [],
    String? focusArea,
    int? targetDailyMinutes,
    String? difficultyPreference,
  }) async {
    final body = <String, dynamic>{
      'goal': goal,
      'durationDays': durationDays,
      'constraints': constraints,
    };
    if (focusArea != null && focusArea.isNotEmpty) body['focusArea'] = focusArea;
    if (targetDailyMinutes != null) body['targetDailyMinutes'] = targetDailyMinutes;
    if (difficultyPreference != null) body['difficultyPreference'] = difficultyPreference;

    final response = await _apiClient.post('/ai/plan', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiGeneratedPlan.fromJson(raw);
  }

  /// Retrieves a staged quest plan by ID.
  Future<AiGeneratedPlan> getPlan(String id) async {
    final response = await _apiClient.get('/ai/plan/$id');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiGeneratedPlan.fromJson(raw);
  }

  /// Edits a staged plan before approval.
  Future<AiGeneratedPlan> editPlan(String id, Map<String, dynamic> editData) async {
    final response = await _apiClient.patch('/ai/plan/$id', data: editData);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiGeneratedPlan.fromJson(raw);
  }

  /// Re-prompts the AI with user feedback to regenerate a plan draft.
  Future<AiGeneratedPlan> regeneratePlan(
    String id, {
    String? feedback,
    List<String>? adjustedConstraints,
  }) async {
    final body = <String, dynamic>{};
    if (feedback != null && feedback.isNotEmpty) body['feedback'] = feedback;
    if (adjustedConstraints != null) body['adjustedConstraints'] = adjustedConstraints;

    final response = await _apiClient.post('/ai/plan/$id/regenerate', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiGeneratedPlan.fromJson(raw);
  }

  /// Rejects/discards a staged plan draft.
  Future<AiGeneratedPlan> rejectPlan(String id) async {
    final response = await _apiClient.post('/ai/plan/$id/reject');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiGeneratedPlan.fromJson(raw);
  }

  /// Approves a staged plan and materializes it into real quests.
  /// Rule 10: Only after explicit approval are real quests created.
  Future<Map<String, dynamic>> approvePlan(
    String id, {
    String? titlePrefix,
    String? parentQuestId,
    String? bossId,
  }) async {
    final body = <String, dynamic>{};
    if (titlePrefix != null) body['titlePrefix'] = titlePrefix;
    if (parentQuestId != null) body['parentQuestId'] = parentQuestId;
    if (bossId != null) body['bossId'] = bossId;

    final response = await _apiClient.post('/ai/plan/$id/approve', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return raw;
  }

  // ---------------------------------------------------------------------------
  // AI Quota & Budget (§10.5)
  // ---------------------------------------------------------------------------

  /// Fetches authoritative daily AI quota state.
  Future<AiQuota> getQuota() async {
    final response = await _apiClient.get('/ai/quota');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return AiQuota.fromJson(raw);
  }

  // ---------------------------------------------------------------------------
  // AI Coach (§6.13, §10.4)
  // ---------------------------------------------------------------------------

  /// Sends a coach chat message (direct or conversation-scoped).
  Future<Map<String, dynamic>> sendCoachMessage(
    String message, {
    String? conversationId,
  }) async {
    final body = <String, dynamic>{
      'message': message,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversationId'] = conversationId;
    }

    final response = await _apiClient.post('/ai/coach/chat', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return raw;
  }

  /// Fetches proactive nudges (overload, procrastination, boss momentum).
  Future<List<AiCoachNudge>> getNudges() async {
    final response = await _apiClient.get('/ai/coach/nudges');
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    if (raw is List) {
      return raw.map((item) => AiCoachNudge.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Generates a daily schedule proposal.
  Future<DailyPlanProposal> getDailyProposal({
    DateTime? targetDate,
    String? chronotype,
    int? availableMinutes,
  }) async {
    final body = <String, dynamic>{};
    if (targetDate != null) body['date'] = targetDate.toIso8601String().split('T')[0];
    if (chronotype != null) body['chronotype'] = chronotype;
    if (availableMinutes != null) body['availableMinutes'] = availableMinutes;

    final response = await _apiClient.post('/ai/coach/daily', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return DailyPlanProposal.fromJson(raw);
  }

  /// Generates a weekly productivity review synthesis.
  Future<WeeklyReviewSummary> getWeeklyReview({
    int? weekNumber,
    int? year,
    String? focusReflections,
  }) async {
    final body = <String, dynamic>{};
    if (weekNumber != null) body['weekNumber'] = weekNumber;
    if (year != null) body['year'] = year;
    if (focusReflections != null) body['focusReflections'] = focusReflections;

    final response = await _apiClient.post('/ai/coach/weekly-review', data: body);
    final raw = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return WeeklyReviewSummary.fromJson(raw);
  }
}

/// Riverpod provider for AiRemoteDataSource.
final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return AiRemoteDataSource(client);
});
