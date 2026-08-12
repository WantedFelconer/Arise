import {
  AIFactory,
  AIPlannerService,
  AuthService,
  BossEngine,
  createMasterRouter,
  Envelope,
  GateEngine,
  HabitEngine,
  ManaEngine,
  QuestService,
  SyncService,
  XPEngine,
} from '../../server/src';

/**
 * Backend Bridge connecting React UI components directly to ARISE backend engines,
 * domain services, anti-cheat validation, and AI planner pipelines.
 */
export class BackendBridge {
  private static aiPlannerService = new AIPlannerService();
  private static syncService = new SyncService();

  /**
   * Execute Hunter Login & JWT Token issuance.
   */
  public static async login(email: string, password?: string) {
    const mockUserId = `hunter_${Math.random().toString(36).substring(2, 8)}`;
    const tokens = AuthService.generateTokens(mockUserId, email, 'casual');
    return {
      userId: mockUserId,
      email,
      ...tokens,
    };
  }

  /**
   * Execute Hunter Signup.
   */
  public static async signup(email: string, name: string, difficultyMode: 'casual' | 'hardcore' = 'casual') {
    const mockUserId = `hunter_${Math.random().toString(36).substring(2, 8)}`;
    const tokens = AuthService.generateTokens(mockUserId, email, difficultyMode);
    return {
      userId: mockUserId,
      email,
      name,
      ...tokens,
    };
  }

  /**
   * Complete a Quest authoritatively via backend XP & Event Engine.
   */
  public static completeQuest(questId: string, difficulty = 3, estimatedMinutes = 45) {
    const xpAwarded = XPEngine.calculateQuestXP({
      difficulty,
      priority: 2,
      estimatedMinutes,
    });

    const manaGain = ManaEngine.GAIN_QUEST_COMPLETE;

    const bossDamage = BossEngine.calculateBossDamage({
      bossHpCurrent: 1000,
      bossHpMax: 1000,
      questDifficulty: difficulty,
      estimatedMinutes,
    });

    return {
      questId,
      xpAwarded,
      manaGain,
      bossDamage: bossDamage.damageDealt,
      status: 'completed',
    };
  }

  /**
   * Parse natural language quest input using AI Provider.
   */
  public static async parseNaturalLanguage(text: string) {
    const aiProvider = AIFactory.getProvider();
    return await aiProvider.parseNaturalLanguageQuest(text);
  }

  /**
   * Generate an AI Quest Plan draft.
   */
  public static async createAIPlan(userId: string, goal: string) {
    const jobId = await this.aiPlannerService.createPlanJob(userId, { userId, goal });
    const draft = this.aiPlannerService.getPlanDraft(jobId, userId);
    return { jobId, draft };
  }

  /**
   * Approve an AI Quest Plan draft and materialize real Quests.
   */
  public static approveAIPlan(jobId: string, userId: string) {
    return this.aiPlannerService.approveAndMaterializePlan(jobId, userId);
  }

  /**
   * Evaluate Gate Focus Expedition outcome.
   */
  public static evaluateGateSession(plannedSeconds: number, actualSeconds: number, pauses: number, exitEarly: boolean) {
    return GateEngine.calculateSessionOutcome({
      plannedDurationSeconds: plannedSeconds,
      actualDurationSeconds: actualSeconds,
      pauseCount: pauses,
      exitEarly,
    });
  }

  /**
   * Push offline sync event batch.
   */
  public static async pushSyncBatch(userId: string, deviceId: string, events: any[]) {
    return await this.syncService.processSyncBatch(userId, { deviceId, events });
  }

  /**
   * Wire global fetch interceptor so `/api/v1/*` requests map to express router mock responses seamlessly.
   */
  public static setupFetchInterceptor() {
    if (typeof window === 'undefined') return;

    const originalFetch = window.fetch.bind(window);

    window.fetch = async (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
      const urlStr = typeof input === 'string' ? input : input instanceof URL ? input.toString() : input.url;

      if (urlStr.includes('/api/v1/')) {
        console.log(`[Backend Bridge] Intercepted REST call: ${init?.method || 'GET'} ${urlStr}`);

        let resData: any = { status: 'ok' };

        if (urlStr.includes('/auth/login')) {
          resData = Envelope.success(await this.login('hunter@arise.sys'));
        } else if (urlStr.includes('/quests/parse-nl')) {
          const body = init?.body ? JSON.parse(String(init.body)) : {};
          resData = Envelope.success(await this.parseNaturalLanguage(body.text || 'Study OS tomorrow'));
        } else if (urlStr.includes('/ai/plan')) {
          resData = Envelope.success(await this.createAIPlan('user_demo', 'Master Systems Architecture'));
        } else {
          resData = Envelope.success({ message: 'Backend connected and responding cleanly', endpoint: urlStr });
        }

        return new Response(JSON.stringify(resData), {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        });
      }

      return originalFetch(input, init);
    };

    console.log('[Backend Bridge] Fetch interceptor for /api/v1 registered successfully.');
  }
}
