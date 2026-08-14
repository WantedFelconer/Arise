import { describe, it, expect, beforeEach } from 'vitest';
import { ConfigService } from '@nestjs/config';
import { AiPlannerService } from '../planner/service/ai-planner.service';
import { MockAIProvider } from '../providers/mock.adapter';
import { AiQuotaService } from '../quota/ai-quota.service';
import { QuestService } from '../../quests/service/quest.service';
import { QuestRepository } from '../../quests/repository/quest.repository';
import { RewardCascadeService } from '../../../core/reward-cascade.service';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { BossService } from '../../bosses/service/boss.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { memoryDb } from '../../../db/memory/memory-db';

describe('AI Quest Planner Suite (§6.12, §10.2, §10.3, §19 AC)', () => {
  let plannerService: AiPlannerService;
  let mockProvider: MockAIProvider;
  let quotaService: AiQuotaService;
  let questService: QuestService;
  let characterService: CharacterService;
  const userId = 'user-ai-planner-test-123';

  beforeEach(() => {
    memoryDb.clear();

    // Create user & character in memory
    memoryDb.users.set(userId, {
      id: userId,
      email: 'planner@example.com',
      passwordHash: 'hash',
      difficultyMode: 'casual',
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });

    memoryDb.characters.set(userId, {
      id: 'char-123',
      userId,
      level: 2,
      totalXp: 550,
      currentMana: 80,
      maxMana: 100,
      coins: 20,
      gems: 0,
      rank: 'E',
      activeTitleId: null,
      stats: {
        intelligence: 12,
        discipline: 10,
        fitness: 10,
        creativity: 10,
        coding: 14,
        business: 10,
        health: 10,
      },
      updatedAt: new Date(),
    });

    const configService = new ConfigService({ AI_DAILY_QUOTA: 50 });
    mockProvider = new MockAIProvider();
    quotaService = new AiQuotaService(configService);

    const characterRepo = new CharacterRepository();
    characterService = new CharacterService(characterRepo);

    const bossRepo = new BossRepository();
    const bossService = new BossService(bossRepo);

    const questRepo = new QuestRepository();
    questService = new QuestService(
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

  it('1. Generates structured plan adhering to §10.3 schema and system prompt §10.2', async () => {
    const res = await plannerService.generatePlan(userId, {
      goal: 'Learn Docker and Kubernetes for Backend Deployment',
      deadline: '2026-09-01T00:00:00.000Z',
      availableTimeMinutesPerDay: 120,
      constraints: 'Mac environment only',
    });

    expect(res.id).toBeDefined();
    expect(res.userId).toBe(userId);
    expect(res.status).toBe('pending_approval');
    expect(res.rawPlan.mainQuest.title).toBeDefined();
    expect(res.rawPlan.mainQuest.subquests.length).toBeGreaterThan(0);

    // Verify §10.2 system prompt guidelines were passed
    expect(mockProvider.lastSystemPrompt?.toLowerCase()).toContain('planning engine');
    expect(mockProvider.lastSystemPrompt).toContain('JSON');
    expect(mockProvider.lastUserPrompt).toContain('Docker and Kubernetes');
    expect(mockProvider.lastUserPrompt).toContain('Level: 2');
  });

  it('2. Schema validation failure triggers 1 automatic retry; succeeds if retry is valid (§10.3)', async () => {
    // Attempt 1: Invalid payload missing required subquests
    const invalidPlan = {
      mainQuest: {
        title: 'Broken Plan without subquests',
      },
    };

    // Attempt 2: Valid payload
    const validPlan = {
      mainQuest: {
        title: 'Fixed Plan',
        subquests: [
          {
            title: 'Subtask 1',
            estimatedMinutes: 30,
            priority: 'medium',
          },
        ],
      },
    };

    mockProvider.queueStructuredResponse(invalidPlan);
    mockProvider.queueStructuredResponse(validPlan);

    const res = await plannerService.generatePlan(userId, {
      goal: 'Test Auto-Retry Success',
    });

    expect(mockProvider.generateCallCount).toBe(2);
    expect(res.rawPlan.mainQuest.title).toBe('Fixed Plan');
    expect(res.status).toBe('pending_approval');
  });

  it('3. Schema validation failure triggers retry-then-422 AI_PLAN_INVALID if still non-conforming (§10.3)', async () => {
    const invalidPlan1 = { mainQuest: { title: 'Invalid 1' } };
    const invalidPlan2 = { mainQuest: { title: 'Invalid 2' } };

    mockProvider.queueStructuredResponse(invalidPlan1);
    mockProvider.queueStructuredResponse(invalidPlan2);

    await expect(
      plannerService.generatePlan(userId, { goal: 'Will Fail Twice' }),
    ).rejects.toMatchObject({
      status: 422,
      response: expect.objectContaining({
        code: 'AI_PLAN_INVALID',
      }),
    });

    expect(mockProvider.generateCallCount).toBe(2);
  });

  it('4. LITERAL §19 AC-AIP-003: Staging produces ZERO rows in `quests`', async () => {
    const countBefore = memoryDb.quests.size;
    expect(countBefore).toBe(0);

    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Build Flutter Clean Architecture Feature',
      availableTimeMinutesPerDay: 60,
    });

    expect(stagedPlan.status).toBe('pending_approval');

    // Confirm NO rows exist yet in quests table for this plan
    const countAfter = memoryDb.quests.size;
    expect(countAfter).toBe(0);

    const userQuests = await questService.listQuests(userId, {});
    expect(userQuests.length).toBe(0);
  });

  it('5. LITERAL §19 AC-AIP-005: Approving staged plan materializes nested quests in single transaction', async () => {
    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Master Database Optimization',
    });

    expect(memoryDb.quests.size).toBe(0);

    const approvalResult = await plannerService.approvePlan(userId, stagedPlan.id);

    expect(approvalResult.plan.status).toBe('approved');
    expect(approvalResult.createdQuests.length).toBe(4); // 1 main quest + 3 subquests

    // Check main quest
    const mainQuest = approvalResult.createdQuests[0]!;
    expect(mainQuest.parentQuestId).toBeNull();
    expect(mainQuest.questType).toBe('main');

    // Check all subquests have parentQuestId pointing to mainQuest.id
    const subQuests = approvalResult.createdQuests.slice(1);
    expect(subQuests.length).toBe(3);
    for (const sub of subQuests) {
      expect(sub.parentQuestId).toBe(mainQuest.id);
      expect(sub.questType).toBe('side');
    }

    // Verify stored in DB
    expect(memoryDb.quests.size).toBe(4);

    // Verify plan in store has status 'approved'
    const storedPlan = memoryDb.aiGeneratedPlans.get(stagedPlan.id);
    expect(storedPlan?.status).toBe('approved');
    expect(storedPlan?.approvedQuestIds).toEqual([mainQuest.id, ...subQuests.map((q) => q.id)]);
  });

  it('6. Double approval is rejected with 409 Conflict', async () => {
    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Single Approval Only',
    });

    await plannerService.approvePlan(userId, stagedPlan.id);

    await expect(plannerService.approvePlan(userId, stagedPlan.id)).rejects.toMatchObject({
      status: 409,
      response: expect.objectContaining({
        code: 'AI_PLAN_ALREADY_APPROVED',
      }),
    });
  });

  it('7. Staged plan can be edited before approval (§7.4 status: pending_approval -> edited)', async () => {
    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Initial Plan',
    });

    expect(stagedPlan.status).toBe('pending_approval');

    const editedPlan = await plannerService.editPlan(userId, stagedPlan.id, {
      mainQuestTitle: 'Custom Edited Main Quest Title',
      subquests: [
        {
          title: 'Custom Edited Subquest 1',
          estimatedMinutes: 45,
          priority: 'urgent',
          difficulty: 'hard',
        },
      ],
    });

    expect(editedPlan.status).toBe('edited');
    expect(editedPlan.rawPlan.mainQuest.title).toBe('Custom Edited Main Quest Title');
    expect(editedPlan.rawPlan.mainQuest.subquests[0]?.title).toBe('Custom Edited Subquest 1');

    // Approve the edited plan and verify it creates the edited quests
    const approved = await plannerService.approvePlan(userId, stagedPlan.id);
    expect(approved.createdQuests[0]?.title).toBe('Custom Edited Main Quest Title');
    expect(approved.createdQuests[1]?.title).toBe('Custom Edited Subquest 1');
  });

  it('8. Staged plan can be rejected/discarded (§7.4 status: rejected)', async () => {
    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Plan to Discard',
    });

    const rejected = await plannerService.rejectPlan(userId, stagedPlan.id);
    expect(rejected.status).toBe('rejected');

    // Cannot approve a rejected plan if status is locked
    const fetched = await plannerService.getPlan(userId, stagedPlan.id);
    expect(fetched.status).toBe('rejected');
  });

  it('9. Staged plan regeneration replaces plan content and resets to pending_approval (FR-AIP-006)', async () => {
    const stagedPlan = await plannerService.generatePlan(userId, {
      goal: 'Version 1',
    });

    const newMockPlan = {
      mainQuest: {
        title: 'Regenerated V2 Plan',
        subquests: [
          {
            title: 'V2 Subtask',
            estimatedMinutes: 20,
            priority: 'low',
          },
        ],
      },
    };
    mockProvider.queueStructuredResponse(newMockPlan);

    const regenerated = await plannerService.regeneratePlan(userId, stagedPlan.id, {
      additionalContext: 'Make it much shorter and simpler',
    });

    expect(regenerated.rawPlan.mainQuest.title).toBe('Regenerated V2 Plan');
    expect(regenerated.status).toBe('pending_approval');
  });

  it('10. Sanitizes user input and AI output to prevent Stored XSS (§10.5, §13.4)', async () => {
    const xssPayloadPlan = {
      mainQuest: {
        title: '<script>alert("pwned")</script>Secure Title',
        description: '<img src=x onerror=alert(1)>Clean Description',
        subquests: [
          {
            title: '<iframe src="javascript:alert(2)"></iframe>Safe Subtask',
            estimatedMinutes: 30,
            priority: 'medium',
          },
        ],
      },
    };

    mockProvider.queueStructuredResponse(xssPayloadPlan);

    const res = await plannerService.generatePlan(userId, {
      goal: '<script>evil()</script>Learn Security',
    });

    expect(res.goal).toBe('Learn Security');
    expect(res.rawPlan.mainQuest.title).toBe('Secure Title');
    expect(res.rawPlan.mainQuest.description).toBe('Clean Description');
    expect(res.rawPlan.mainQuest.subquests[0]?.title).toBe('Safe Subtask');

    const approved = await plannerService.approvePlan(userId, res.id);
    expect(approved.createdQuests[0]?.title).toBe('Secure Title');
    expect(approved.createdQuests[1]?.title).toBe('Safe Subtask');
  });
});
