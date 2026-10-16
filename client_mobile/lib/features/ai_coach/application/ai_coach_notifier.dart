import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/network_status.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../shared/models/quest.dart';
import '../domain/ai_coach_models.dart';
import '../domain/ai_plan.dart';
import '../infrastructure/ai_remote_data_source.dart';
import '../../quests/infrastructure/local_quest_repository.dart';

/// State of the AI Coach & Planner feature.
class AiCoachState {
  final AiQuota? quota;
  final AiGeneratedPlan? activePlan;
  final List<AiCoachMessage> messages;
  final List<AiCoachNudge> nudges;
  final bool isThinking;
  final bool isOffline;
  final bool isQuotaExceeded;
  final String? error;
  final String? errorCode;
  final DailyPlanProposal? dailyProposal;
  final WeeklyReviewSummary? weeklyReview;

  const AiCoachState({
    this.quota,
    this.activePlan,
    this.messages = const [],
    this.nudges = const [],
    this.isThinking = false,
    this.isOffline = false,
    this.isQuotaExceeded = false,
    this.error,
    this.errorCode,
    this.dailyProposal,
    this.weeklyReview,
  });

  AiCoachState copyWith({
    AiQuota? quota,
    AiGeneratedPlan? activePlan,
    bool clearActivePlan = false,
    List<AiCoachMessage>? messages,
    List<AiCoachNudge>? nudges,
    bool? isThinking,
    bool? isOffline,
    bool? isQuotaExceeded,
    String? error,
    bool clearError = false,
    String? errorCode,
    DailyPlanProposal? dailyProposal,
    WeeklyReviewSummary? weeklyReview,
  }) {
    return AiCoachState(
      quota: quota ?? this.quota,
      activePlan: clearActivePlan ? null : (activePlan ?? this.activePlan),
      messages: messages ?? this.messages,
      nudges: nudges ?? this.nudges,
      isThinking: isThinking ?? this.isThinking,
      isOffline: isOffline ?? this.isOffline,
      isQuotaExceeded: isQuotaExceeded ?? this.isQuotaExceeded,
      error: clearError ? null : (error ?? this.error),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      dailyProposal: dailyProposal ?? this.dailyProposal,
      weeklyReview: weeklyReview ?? this.weeklyReview,
    );
  }
}

/// StateNotifier orchestrating AI Coach chats, AI Quest Planner approval gates, and Quota synchronization.
class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final AiRemoteDataSource _remoteDataSource;
  final NetworkStatusService _networkStatus;
  final dynamic _questRepository;

  AiCoachNotifier(
    this._remoteDataSource,
    this._networkStatus,
    this._questRepository,
  ) : super(AiCoachState(
          messages: [
            AiCoachMessage(
              id: 'init-msg',
              role: 'assistant',
              content:
                  'UPLINK ESTABLISHED. I am the System. Your growth is my directive. Today\'s tactical analysis is ready. Ready for directives.',
              createdAt: DateTime.now(),
            ),
          ],
        )) {
    _init();
  }

  Future<void> _init() async {
    final isConnected = _networkStatus.current != NetworkStatus.offline;
    state = state.copyWith(isOffline: !isConnected);

    if (isConnected) {
      await refreshQuota();
      await fetchNudges();
    }
  }

  /// Refreshes authoritative backend AI quota status.
  Future<void> refreshQuota() async {
    try {
      final q = await _remoteDataSource.getQuota();
      if (mounted) {
        state = state.copyWith(
          quota: q,
          isQuotaExceeded: q.isExhausted,
          clearError: true,
        );
      }
    } on NetworkException {
      if (mounted) state = state.copyWith(isOffline: true);
    } catch (_) {}
  }

  /// Fetches proactive coach nudges.
  Future<void> fetchNudges() async {
    try {
      final nudges = await _remoteDataSource.getNudges();
      if (mounted) {
        state = state.copyWith(nudges: nudges);
      }
    } catch (_) {}
  }

  /// Sends a coach message or triggers relevant AI planner workflow.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Check connectivity first
    final isConnected = _networkStatus.current != NetworkStatus.offline;
    if (!isConnected) {
      final offlineMsg = AiCoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'system',
        content:
            '[ NEURAL UPLINK OFFLINE ] Live network connection required for AI System operations. Offline AI simulation is disabled.',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        isOffline: true,
        messages: [...state.messages, AiCoachMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}-user',
          role: 'user',
          content: trimmed,
          createdAt: DateTime.now(),
        ), offlineMsg],
      );
      return;
    }

    // Add user message
    final userMsg = AiCoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      clearError: true,
    );

    final lower = trimmed.toLowerCase();
    final isPlanRequest = lower.contains('plan') || lower.contains('week') || lower.contains('deploy');

    try {
      if (isPlanRequest) {
        // Generate structured quest plan draft
        final plan = await _remoteDataSource.generatePlan(
          goal: trimmed,
          durationDays: lower.contains('week') ? 7 : 3,
        );

        final responseMsg = AiCoachMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}-ai',
          role: 'assistant',
          content:
              'Acknowledged. Tactical quest sequence generated. Review the mission parameters below before authorizing deployment.',
          createdAt: DateTime.now(),
        );

        if (mounted) {
          state = state.copyWith(
            messages: [...state.messages, responseMsg],
            activePlan: plan,
            isThinking: false,
          );
        }
      } else {
        // Direct coach chat
        final response = await _remoteDataSource.sendCoachMessage(trimmed);
        final replyText = response['message'] as String? ??
            response['response'] as String? ??
            response['text'] as String? ??
            'Directive processed. Stay relentless, Hunter.';

        final aiMsg = AiCoachMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}-ai',
          role: 'assistant',
          content: replyText,
          createdAt: DateTime.now(),
        );

        if (mounted) {
          state = state.copyWith(
            messages: [...state.messages, aiMsg],
            isThinking: false,
          );
        }
      }

      // Update quota after request
      await refreshQuota();
    } on QuotaExceededException catch (e) {
      if (mounted) {
        state = state.copyWith(
          isThinking: false,
          isQuotaExceeded: true,
          error: e.message,
          errorCode: 'AI_DAILY_QUOTA_EXCEEDED',
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'system',
              content: '[ DAILY QUOTA EXHAUSTED ] ${e.message}',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        state = state.copyWith(
          isThinking: false,
          error: e.message,
          errorCode: e.code,
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'system',
              content: '[ SYSTEM ERROR ] ${e.message}',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isThinking: false,
          error: e.toString(),
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'system',
              content: '[ UPLINK ERROR ] ${e.toString()}',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
    }
  }

  /// Requests a structured plan with specific parameters.
  Future<void> requestPlan(String goal, {int durationDays = 7, List<String> constraints = const []}) async {
    final isConnected = _networkStatus.current != NetworkStatus.offline;
    if (!isConnected) {
      state = state.copyWith(
        isOffline: true,
        error: 'Neural uplink offline. Network connection required to generate plans.',
      );
      return;
    }

    state = state.copyWith(isThinking: true, clearError: true);

    try {
      final plan = await _remoteDataSource.generatePlan(
        goal: goal,
        durationDays: durationDays,
        constraints: constraints,
      );

      if (mounted) {
        state = state.copyWith(
          activePlan: plan,
          isThinking: false,
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'assistant',
              content: 'Tactical Quest Tree generated for "$goal". Awaiting user review and authorization.',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
      await refreshQuota();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isThinking: false, error: e.toString());
      }
    }
  }

  /// Edits a staged plan before approval.
  Future<void> editPlan(String id, Map<String, dynamic> editData) async {
    state = state.copyWith(isThinking: true);
    try {
      final updated = await _remoteDataSource.editPlan(id, editData);
      if (mounted) {
        state = state.copyWith(activePlan: updated, isThinking: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isThinking: false, error: e.toString());
      }
    }
  }

  /// Regenerates a staged plan with user feedback.
  Future<void> regeneratePlan(String id, {String? feedback}) async {
    state = state.copyWith(isThinking: true);
    try {
      final updated = await _remoteDataSource.regeneratePlan(id, feedback: feedback);
      if (mounted) {
        state = state.copyWith(activePlan: updated, isThinking: false);
      }
      await refreshQuota();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isThinking: false, error: e.toString());
      }
    }
  }

  /// Rejects/discards the staged plan.
  Future<void> rejectPlan(String id) async {
    try {
      await _remoteDataSource.rejectPlan(id);
      if (mounted) {
        state = state.copyWith(
          clearActivePlan: true,
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'system',
              content: '[ PLAN DISCARDED ] Quest tree dismissed without deployment.',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  /// Approves the staged plan, materializing real quests in backend and local Drift DB.
  /// Rule 10: "AI proposes, it never commits". Real quests are ONLY created here.
  Future<void> approvePlan(String id) async {
    state = state.copyWith(isThinking: true, clearError: true);

    try {
      final result = await _remoteDataSource.approvePlan(id);
      final rawQuests = result['materializedQuests'] as List<dynamic>? ??
          result['quests'] as List<dynamic>? ??
          [];

      final List<Quest> newQuests = [];
      for (final raw in rawQuests) {
        if (raw is Map<String, dynamic>) {
          final q = Quest(
            id: raw['id'] as String? ?? '',
            userId: raw['userId'] as String?,
            rank: raw['difficulty'] == 'epic' ? 'S' : raw['difficulty'] == 'hard' ? 'A' : 'B',
            type: QuestType.ai_generated,
            title: raw['title'] as String? ?? '',
            description: raw['description'] as String? ?? '',
            exp: (raw['xpReward'] as num?)?.toInt() ?? 150,
            xpReward: (raw['xpReward'] as num?)?.toInt() ?? 150,
            manaReward: (raw['manaReward'] as num?)?.toInt() ?? 5,
            deadline: raw['deadline'] != null ? 'SCHEDULED' : 'TODAY',
            status: 'active',
            syncStatus: 'verified',
          );
          newQuests.add(q);
        }
      }

      // If backend returned quests, save them immediately into local SQLite database
      if (newQuests.isNotEmpty && _questRepository is LocalQuestRepository) {
        await (_questRepository as LocalQuestRepository).saveQuests(newQuests);
      }

      if (mounted) {
        state = state.copyWith(
          isThinking: false,
          clearActivePlan: true,
          messages: [
            ...state.messages,
            AiCoachMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: 'assistant',
              content:
                  'QUEST TREE DEPLOYED. ${newQuests.length} objective(s) materialized into your active registry. The week belongs to you, Hunter.',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
      await refreshQuota();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isThinking: false, error: e.toString());
      }
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Riverpod provider for AiCoachNotifier.
final aiCoachNotifierProvider =
    StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  final remote = ref.watch(aiRemoteDataSourceProvider);
  final net = ref.watch(networkStatusServiceProvider);
  final repo = ref.watch(questRepositoryProvider);

  return AiCoachNotifier(remote, net, repo);
});
