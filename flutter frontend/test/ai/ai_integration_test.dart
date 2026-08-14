import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:arise_app/core/database/arise_database.dart';
import 'package:arise_app/core/network/api_exceptions.dart';
import 'package:arise_app/core/network/network_status.dart';
import 'package:arise_app/features/ai_coach/domain/ai_plan.dart';
import 'package:arise_app/features/ai_coach/domain/ai_coach_models.dart';
import 'package:arise_app/features/ai_coach/infrastructure/ai_remote_data_source.dart';
import 'package:arise_app/features/ai_coach/application/ai_coach_notifier.dart';
import 'package:arise_app/features/quests/infrastructure/local_quest_repository.dart';

class FakeNetworkStatusService implements NetworkStatusService {
  NetworkStatus _current = NetworkStatus.online;

  @override
  NetworkStatus get current => _current;

  void setOnline() => _current = NetworkStatus.online;
  void setOffline() => _current = NetworkStatus.offline;

  @override
  Stream<NetworkStatus> get statusStream => const Stream.empty();

  @override
  void dispose() {}
}

class FakeAiRemoteDataSource implements AiRemoteDataSource {
  AiQuota quota = AiQuota(
    usedToday: 2,
    dailyLimit: 50,
    remaining: 48,
    resetAt: DateTime.now().add(const Duration(hours: 8)),
  );

  bool shouldFailWithQuota = false;
  bool shouldFailWithUnauthorized = false;
  bool shouldFailWithProviderOffline = false;

  AiGeneratedPlan lastStagedPlan = AiGeneratedPlan(
    id: 'staged-plan-123',
    userId: 'user-1',
    goal: 'Build Full Stack MVP',
    durationDays: 7,
    estimatedXp: 950,
    status: 'pending_approval',
    quests: const [
      AiPlanQuest(
        title: 'Backend DB Architecture',
        description: 'Set up PostgreSQL schema and migrations',
        difficulty: 'hard',
        rank: 'A',
        xpReward: 350,
        targetDurationMinutes: 60,
      ),
      AiPlanQuest(
        title: 'Flutter UI Integration',
        description: 'Connect screens to clean architecture',
        difficulty: 'medium',
        rank: 'B',
        xpReward: 250,
        targetDurationMinutes: 45,
      ),
    ],
    createdAt: DateTime.now(),
  );

  @override
  Future<AiQuota> getQuota() async {
    if (shouldFailWithUnauthorized) {
      throw const UnauthorizedException(message: 'Invalid or expired authentication token');
    }
    return quota;
  }

  @override
  Future<AiGeneratedPlan> generatePlan({
    required String goal,
    int durationDays = 7,
    List<String> constraints = const [],
    String? focusArea,
    int? targetDailyMinutes,
    String? difficultyPreference,
  }) async {
    if (shouldFailWithQuota) {
      throw const QuotaExceededException(message: 'Daily AI quota limit of 50 requests reached.');
    }
    if (shouldFailWithUnauthorized) {
      throw const UnauthorizedException(message: 'Unauthorized AI request');
    }
    if (shouldFailWithProviderOffline) {
      throw const ServerException(statusCode: 503, code: 'AI_OFFLINE_UNAVAILABLE', message: 'AI Provider is temporarily unreachable.');
    }

    quota = AiQuota(
      usedToday: quota.usedToday + 1,
      dailyLimit: quota.dailyLimit,
      remaining: quota.remaining - 1,
      resetAt: quota.resetAt,
    );

    lastStagedPlan = AiGeneratedPlan(
      id: 'staged-plan-123',
      userId: 'user-1',
      goal: goal,
      durationDays: durationDays,
      estimatedXp: 950,
      status: 'pending_approval',
      quests: const [
        AiPlanQuest(
          title: 'Backend DB Architecture',
          description: 'Set up PostgreSQL schema and migrations',
          difficulty: 'hard',
          rank: 'A',
          xpReward: 350,
          targetDurationMinutes: 60,
        ),
      ],
      createdAt: DateTime.now(),
    );

    return lastStagedPlan;
  }

  @override
  Future<AiGeneratedPlan> getPlan(String id) async => lastStagedPlan;

  @override
  Future<AiGeneratedPlan> editPlan(String id, Map<String, dynamic> editData) async {
    lastStagedPlan = lastStagedPlan.copyWith(
      goal: editData['goal'] as String? ?? lastStagedPlan.goal,
      status: 'edited',
    );
    return lastStagedPlan;
  }

  @override
  Future<AiGeneratedPlan> regeneratePlan(String id, {String? feedback, List<String>? adjustedConstraints}) async {
    if (shouldFailWithQuota) throw const QuotaExceededException(message: 'Daily quota exceeded');
    quota = AiQuota(
      usedToday: quota.usedToday + 1,
      dailyLimit: quota.dailyLimit,
      remaining: quota.remaining - 1,
      resetAt: quota.resetAt,
    );
    return lastStagedPlan;
  }

  @override
  Future<AiGeneratedPlan> rejectPlan(String id) async {
    lastStagedPlan = lastStagedPlan.copyWith(status: 'rejected');
    return lastStagedPlan;
  }

  @override
  Future<Map<String, dynamic>> approvePlan(String id, {String? titlePrefix, String? parentQuestId, String? bossId}) async {
    lastStagedPlan = lastStagedPlan.copyWith(
      status: 'approved',
      approvedAt: DateTime.now(),
    );

    return {
      'plan': {
        'id': lastStagedPlan.id,
        'goal': lastStagedPlan.goal,
        'status': lastStagedPlan.status,
      },
      'materializedQuests': [
        {
          'id': 'mat-quest-1',
          'userId': 'user-1',
          'title': 'Backend DB Architecture',
          'description': 'Set up PostgreSQL schema and migrations',
          'difficulty': 'hard',
          'xpReward': 350,
          'manaReward': 10,
          'status': 'active',
        },
        {
          'id': 'mat-quest-2',
          'userId': 'user-1',
          'title': 'Flutter UI Integration',
          'description': 'Connect screens to clean architecture',
          'difficulty': 'medium',
          'xpReward': 250,
          'manaReward': 5,
          'status': 'active',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> sendCoachMessage(String message, {String? conversationId}) async {
    if (shouldFailWithQuota) throw const QuotaExceededException(message: 'Daily AI quota exhausted');
    if (shouldFailWithUnauthorized) throw const UnauthorizedException(message: 'Authentication invalid');
    if (shouldFailWithProviderOffline) throw const ServerException(statusCode: 503, code: 'AI_OFFLINE_UNAVAILABLE', message: 'Provider offline');

    quota = AiQuota(
      usedToday: quota.usedToday + 1,
      dailyLimit: quota.dailyLimit,
      remaining: quota.remaining - 1,
      resetAt: quota.resetAt,
    );

    return {
      'message': 'Directive received and processed by the System. Push forward, Hunter.',
      'conversationId': 'conv-123',
    };
  }

  @override
  Future<List<AiCoachNudge>> getNudges() async {
    return const [
      AiCoachNudge(
        type: 'procrastination',
        title: 'Overdue Quest Alert',
        message: 'You have 2 overdue quests in your registry.',
      ),
    ];
  }

  @override
  Future<DailyPlanProposal> getDailyProposal({DateTime? targetDate, String? chronotype, int? availableMinutes}) async {
    return const DailyPlanProposal(
      date: '2026-08-15',
      summary: 'Optimal daily load: 3 quests focused on Craft and Mind.',
      targetXp: 500,
    );
  }

  @override
  Future<WeeklyReviewSummary> getWeeklyReview({int? weekNumber, int? year, String? focusReflections}) async {
    return const WeeklyReviewSummary(
      summary: 'Strong week with 82% quest completion rate.',
      completionRatePct: 82,
      xpEarned: 2450,
      focusMinutes: 320,
      reflection: 'Consistent focus maintained throughout the sprints.',
    );
  }
}

void main() {
  late AriseDatabase db;
  late LocalQuestRepository questRepo;
  late FakeNetworkStatusService netService;
  late FakeAiRemoteDataSource aiRemote;

  setUp(() async {
    db = AriseDatabase.forTesting(NativeDatabase.memory());
    questRepo = LocalQuestRepository(db);
    netService = FakeNetworkStatusService();
    aiRemote = FakeAiRemoteDataSource();
  });

  tearDown(() async {
    await db.close();
  });

  group('Sprint A7 — AI Intelligence Layer Integration Tests', () {
    test('1. AI Quota: Initial quota is fetched from backend and reflects authoritative budget', () async {
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      await notifier.refreshQuota();

      expect(notifier.state.quota, isNotNull);
      expect(notifier.state.quota!.dailyLimit, 50);
      expect(notifier.state.quota!.remaining, 48);
      expect(notifier.state.isQuotaExceeded, false);

      notifier.dispose();
    });

    test('2. Approval Gate (Rule 10): Plan generation stages draft without writing real quests until user approves', () async {
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      // Verify no quests exist initially in local Drift SQLite
      var localQuests = await questRepo.fetchQuests(userId: 'user-1');
      expect(localQuests.isEmpty, true);

      // Step 1: Request plan
      await notifier.requestPlan('Build Full Stack MVP', durationDays: 7);

      // Verify plan is staged in 'pending_approval' state
      expect(notifier.state.activePlan, isNotNull);
      expect(notifier.state.activePlan!.isPendingApproval, true);
      expect(notifier.state.activePlan!.status, 'pending_approval');
      expect(notifier.state.activePlan!.quests.length, 1);

      // Rule 10 Verification: 0 real quests created before approval
      localQuests = await questRepo.fetchQuests(userId: 'user-1');
      expect(localQuests.isEmpty, true);

      // Step 2: User approves plan -> materializes into real quests
      await notifier.approvePlan(notifier.state.activePlan!.id);

      // Verify active plan is cleared/approved
      expect(notifier.state.activePlan, isNull);

      // Verify real quests are now persisted in Drift SQLite database
      localQuests = await questRepo.fetchQuests(userId: 'user-1');
      expect(localQuests.length, 2);
      expect(localQuests.any((q) => q.title == 'Backend DB Architecture'), true);
      expect(localQuests.any((q) => q.title == 'Flutter UI Integration'), true);
      expect(localQuests.first.syncStatus, 'verified');

      notifier.dispose();
    });

    test('3. Quota Exceeded (HTTP 429): Handles quota exhaustion gracefully with clear error state', () async {
      aiRemote.shouldFailWithQuota = true;
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      await notifier.sendMessage('Generate another quest plan');

      expect(notifier.state.isThinking, false);
      expect(notifier.state.isQuotaExceeded, true);
      expect(notifier.state.errorCode, 'AI_DAILY_QUOTA_EXCEEDED');
      expect(notifier.state.messages.last.role, 'system');
      expect(notifier.state.messages.last.content.contains('QUOTA EXHAUSTED'), true);

      notifier.dispose();
    });

    test('4. Unauthorized (HTTP 401/403): Handles auth failures without crashing', () async {
      aiRemote.shouldFailWithUnauthorized = true;
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      await notifier.sendMessage('How is my focus today?');

      expect(notifier.state.isThinking, false);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.messages.last.content.contains('SYSTEM ERROR'), true);

      notifier.dispose();
    });

    test('5. Provider Unavailable (HTTP 503): Handles AI offline/provider failure gracefully', () async {
      aiRemote.shouldFailWithProviderOffline = true;
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      await notifier.sendMessage('Give me advice');

      expect(notifier.state.isThinking, false);
      expect(notifier.state.errorCode, 'AI_OFFLINE_UNAVAILABLE');

      notifier.dispose();
    });

    test('6. Explicit Offline Behavior: Network disconnection returns explicit offline feedback (no fake offline AI)', () async {
      netService.setOffline();
      final notifier = AiCoachNotifier(aiRemote, netService, questRepo);

      await notifier.sendMessage('Plan my sprint');

      expect(notifier.state.isOffline, true);
      expect(notifier.state.messages.last.role, 'system');
      expect(notifier.state.messages.last.content.contains('NEURAL UPLINK OFFLINE'), true);
      expect(notifier.state.activePlan, isNull);

      notifier.dispose();
    });
  });
}
