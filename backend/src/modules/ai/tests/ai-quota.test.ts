import { describe, it, expect, beforeEach } from 'vitest';
import { ConfigService } from '@nestjs/config';
import { AiQuotaService } from '../quota/ai-quota.service';
import { AiPlannerService } from '../planner/service/ai-planner.service';
import { MockAIProvider } from '../providers/mock.adapter';
import { QuestService } from '../../quests/service/quest.service';
import { QuestRepository } from '../../quests/repository/quest.repository';
import { RewardCascadeService } from '../../../core/reward-cascade.service';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { BossService } from '../../bosses/service/boss.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { memoryDb } from '../../../db/memory/memory-db';

describe('AI Quota & Cost Controls Suite (§10.5)', () => {
  let quotaService: AiQuotaService;
  let plannerService: AiPlannerService;
  let mockProvider: MockAIProvider;
  const userId = 'user-quota-test-123';

  beforeEach(() => {
    memoryDb.clear();

    memoryDb.users.set(userId, {
      id: userId,
      email: 'quota@example.com',
      passwordHash: 'hash',
      difficultyMode: 'casual',
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });

    memoryDb.characters.set(userId, {
      id: 'char-123',
      userId,
      level: 1,
      totalXp: 0,
      currentMana: 100,
      maxMana: 100,
      coins: 0,
      gems: 0,
      rank: 'E',
      activeTitleId: null,
      stats: {
        intelligence: 10,
        discipline: 10,
        fitness: 10,
        creativity: 10,
        coding: 10,
        business: 10,
        health: 10,
      },
      updatedAt: new Date(),
    });

    // Configure a small quota for testing (limit: 3)
    const configService = new ConfigService({ AI_DAILY_QUOTA: 3 });
    mockProvider = new MockAIProvider();
    quotaService = new AiQuotaService(configService);

    const characterRepo = new CharacterRepository();
    const characterService = new CharacterService(characterRepo);

    const bossRepo = new BossRepository();
    const bossService = new BossService(bossRepo);

    const questRepo = new QuestRepository();
    const questService = new QuestService(
      questRepo,
      bossService,
      characterService,
      undefined as unknown as RewardCascadeService,
    );

    plannerService = new AiPlannerService(
      mockProvider,
      quotaService,
      questService,
      characterService,
    );
  });

  it('1. Enforces daily AI quota limit and returns 429 AI_DAILY_QUOTA_EXCEEDED when exhausted (§10.5)', async () => {
    // 1st call (allowed)
    const call1 = await quotaService.checkAndIncrement(userId, 'planner');
    expect(call1.allowed).toBe(true);
    expect(call1.remaining).toBe(2);

    // 2nd call (allowed)
    const call2 = await quotaService.checkAndIncrement(userId, 'planner');
    expect(call2.allowed).toBe(true);
    expect(call2.remaining).toBe(1);

    // 3rd call (allowed, reaching limit)
    const call3 = await quotaService.checkAndIncrement(userId, 'coach');
    expect(call3.allowed).toBe(true);
    expect(call3.remaining).toBe(0);

    // 4th call (exhausted -> 429)
    await expect(quotaService.checkAndIncrement(userId, 'planner')).rejects.toMatchObject({
      status: 429,
      response: expect.objectContaining({
        code: 'AI_DAILY_QUOTA_EXCEEDED',
      }),
    });
  });

  it('2. CONCURRENCY RACE TEST: Simultaneous requests near budget boundary cannot both succeed', async () => {
    // Reset quota with limit 1
    const configService = new ConfigService({ AI_DAILY_QUOTA: 1 });
    const raceQuotaService = new AiQuotaService(configService);

    // Launch two simultaneous check-and-increment operations concurrently
    const results = await Promise.allSettled([
      raceQuotaService.checkAndIncrement(userId, 'planner'),
      raceQuotaService.checkAndIncrement(userId, 'coach'),
    ]);

    const fulfilled = results.filter((r) => r.status === 'fulfilled');
    const rejected = results.filter((r) => r.status === 'rejected');

    // Exactly 1 must succeed, and exactly 1 must be rejected with 429
    expect(fulfilled.length).toBe(1);
    expect(rejected.length).toBe(1);

    const firstRejected = rejected[0];
    if (firstRejected && firstRejected.status === 'rejected') {
      const err = firstRejected.reason as {
        status: number;
        response: { code: string };
      };
      expect(err.status).toBe(429);
      expect(err.response.code).toBe('AI_DAILY_QUOTA_EXCEEDED');
    }
  });

  it('3. Feature Flags Hook: Disables AI features with 403 FEATURE_DISABLED when flag is false', async () => {
    // Disable ai_planner_enabled for user
    quotaService.setFeatureFlag('ai_planner_enabled', false, userId);

    await expect(quotaService.checkAndIncrement(userId, 'planner')).rejects.toMatchObject({
      status: 403,
      response: expect.objectContaining({
        code: 'FEATURE_DISABLED',
      }),
    });

    // Coach remains enabled unless explicitly disabled
    const coachRes = await quotaService.checkAndIncrement(userId, 'coach');
    expect(coachRes.allowed).toBe(true);

    // Disable globally
    quotaService.setFeatureFlag('ai_coach_enabled', false, null);
    await expect(quotaService.checkAndIncrement(userId, 'coach')).rejects.toMatchObject({
      status: 403,
      response: expect.objectContaining({
        code: 'FEATURE_DISABLED',
      }),
    });
  });

  it('4. Offline handling: Returns 503 AI_OFFLINE_UNAVAILABLE when provider throws network failure', async () => {
    mockProvider.generateStructured = async () => {
      throw new Error('Network timeout reaching provider');
    };

    await expect(
      plannerService.generatePlan(userId, { goal: 'Test Offline Error' }),
    ).rejects.toMatchObject({
      status: 503,
      response: expect.objectContaining({
        code: 'AI_OFFLINE_UNAVAILABLE',
      }),
    });
  });
});
