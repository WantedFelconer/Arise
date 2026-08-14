import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';
import { MockAIProvider } from '../src/modules/ai/providers/mock.adapter';
import { AI_PROVIDER_TOKEN } from '../src/modules/ai/providers/ai-provider.interface';

describe('Sprint 3 Intelligence Layer — End-to-End API Integration Suite', () => {
  let app: INestApplication;
  let mockProvider: MockAIProvider;
  let userTokenA: string;
  let userIdA: string;
  let userTokenB: string;
  let userIdB: string;

  beforeEach(async () => {
    memoryDb.clear();
    mockProvider = new MockAIProvider();

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(AI_PROVIDER_TOKEN)
      .useValue(mockProvider)
      .compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1', {
      exclude: ['health'],
    });
    await app.init();

    // Signup User A (Casual mode)
    const signupResA = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
      email: 'student_amara@arise.dev',
      password: 'Password123!@#',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });
    userTokenA = signupResA.body.data.tokens.accessToken;
    userIdA = signupResA.body.data.user.id;
    expect(userIdA).toBeDefined();

    // Signup User B (Hardcore mode)
    const signupResB = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
      email: 'engineer_rafi@arise.dev',
      password: 'Password123!@#',
      difficultyMode: 'hardcore',
      chronotype: 'night_owl',
    });
    userTokenB = signupResB.body.data.tokens.accessToken;
    userIdB = signupResB.body.data.user.id;
    expect(userIdB).toBeDefined();
  });

  describe('1. Literal §19 AC-AIP-003 & AC-AIP-005: AI Quest Planner Staging & Approval', () => {
    it('stages generated plan with zero quest rows, allows editing, and materializes nested quests on approval', async () => {
      // Step 1: Given a submitted planning context, POST /ai/plan returns a structured plan
      const planRes = await request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          goal: 'Master Operating Systems and Concurrency',
          deadline: '2026-10-01T00:00:00.000Z',
          availableTimeMinutesPerDay: 90,
          constraints: 'C/C++ only, no external libraries',
        });

      expect(planRes.status).toBe(201);
      const planData = planRes.body.data;
      expect(planData.id).toBeDefined();
      expect(planData.status).toBe('pending_approval');
      expect(planData.rawPlan.mainQuest.title).toBeDefined();
      expect(planData.rawPlan.mainQuest.subquests.length).toBeGreaterThanOrEqual(1);

      // LITERAL §19 AC-AIP-003: Then NO rows exist yet in quests for this plan
      const questsBeforeApproval = await request(app.getHttpServer())
        .get('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(questsBeforeApproval.status).toBe(200);
      expect(questsBeforeApproval.body.data.length).toBe(0);

      // Step 2: Edit staged plan (FR-AIP-004) -> status becomes 'edited'
      const editRes = await request(app.getHttpServer())
        .patch(`/api/v1/ai/plan/${planData.id}`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          mainQuestTitle: 'OS Concurrency & Process Synchronization',
        });

      expect(editRes.status).toBe(200);
      expect(editRes.body.data.status).toBe('edited');
      expect(editRes.body.data.rawPlan.mainQuest.title).toBe(
        'OS Concurrency & Process Synchronization',
      );

      // Step 3: LITERAL §19 AC-AIP-005: When user calls POST /ai/plan/{id}/approve
      const approveRes = await request(app.getHttpServer())
        .post(`/api/v1/ai/plan/${planData.id}/approve`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({});

      expect(approveRes.status).toBe(200);
      expect(approveRes.body.data.plan.status).toBe('approved');
      expect(approveRes.body.data.createdQuests.length).toBeGreaterThan(1);

      // Then all subquests are created as quests rows with correct parent_quest_id nesting in a single transaction
      const createdQuests = approveRes.body.data.createdQuests;
      const mainQuest = createdQuests[0];
      expect(mainQuest.parentQuestId).toBeNull();
      expect(mainQuest.title).toBe('OS Concurrency & Process Synchronization');

      const subquests = createdQuests.slice(1);
      for (const sub of subquests) {
        expect(sub.parentQuestId).toBe(mainQuest.id);
      }

      // Verify quests now exist when querying /quests
      const questsAfterApproval = await request(app.getHttpServer())
        .get('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(questsAfterApproval.status).toBe(200);
      expect(questsAfterApproval.body.data.length).toBe(createdQuests.length);

      // Step 4: Re-approving an already approved plan returns 409 Conflict
      const duplicateApprove = await request(app.getHttpServer())
        .post(`/api/v1/ai/plan/${planData.id}/approve`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({});

      expect(duplicateApprove.status).toBe(409);
      expect(duplicateApprove.body.error.code).toBe('AI_PLAN_ALREADY_APPROVED');
    });
  });

  describe('2. AI Coach Multi-Turn Conversation & Tool Calling (§6.13, §10.4)', () => {
    it('manages conversation sessions, executes tool calls, and returns grounded responses', async () => {
      // 1. Create a quest first so tool has data
      await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'Study Memory Management',
          estimatedMinutes: 60,
          difficulty: 'medium',
          priority: 'high',
        });

      // 2. Create an AI Coach conversation
      const convRes = await request(app.getHttpServer())
        .post('/api/v1/ai/coach/conversations')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'Morning Study Check-in',
          contextType: 'coach',
        });

      expect(convRes.status).toBe(201);
      const convId = convRes.body.data.id;
      expect(convId).toBeDefined();

      // 3. Send message that triggers tool calling
      const msgRes = await request(app.getHttpServer())
        .post(`/api/v1/ai/coach/conversations/${convId}/messages`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          content: 'What active quests do I have scheduled?',
        });

      expect(msgRes.status).toBe(201);
      expect(msgRes.body.data.message).toBeDefined();
      expect(msgRes.body.data.message.role).toBe('assistant');

      // 4. Test daily proposal endpoint
      const dailyRes = await request(app.getHttpServer())
        .post('/api/v1/ai/coach/daily')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          availableHours: 4,
          focusAreas: ['Operating Systems'],
        });

      expect(dailyRes.status).toBe(200);
      expect(dailyRes.body.data.proposal).toBeDefined();

      // 5. Test weekly review endpoint
      const weeklyRes = await request(app.getHttpServer())
        .post('/api/v1/ai/coach/weekly-review')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          wins: 'Completed 5 subquests',
          challenges: 'Late night sessions',
        });

      expect(weeklyRes.status).toBe(200);
      expect(weeklyRes.body.data.summary).toBeDefined();

      // 6. Test proactive nudges endpoint
      const nudgesRes = await request(app.getHttpServer())
        .get('/api/v1/ai/coach/nudges')
        .set('Authorization', `Bearer ${userTokenA}`);

      expect(nudgesRes.status).toBe(200);
      expect(Array.isArray(nudgesRes.body.data)).toBe(true);
    });
  });

  describe('3. AI Quota Enforcement (§10.5)', () => {
    it('tracks per-user daily quota and returns 429 when budget is exhausted', async () => {
      // Set small quota limit in memory for User B
      const key = `${userIdB}:${new Date().toISOString().split('T')[0]}`;
      memoryDb.dailyAiUsage.set(key, {
        key,
        userId: userIdB,
        date: new Date().toISOString().split('T')[0],
        count: 50, // default limit reached
      });

      const planRes = await request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({
          goal: 'Over-quota goal',
        });

      expect(planRes.status).toBe(429);
      expect(planRes.body.error.code).toBe('AI_DAILY_QUOTA_EXCEEDED');
    });
  });

  describe('4. Multi-Tenant Query-Level Isolation (§13.2)', () => {
    it('prevents User B from accessing, modifying, or approving User A AI plans and conversations', async () => {
      // 1. User A generates a plan
      const planResA = await request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          goal: 'User A Private Plan',
        });
      const planIdA = planResA.body.data.id;

      // 2. User A creates a conversation
      const convResA = await request(app.getHttpServer())
        .post('/api/v1/ai/coach/conversations')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'User A Private Coach',
        });
      const convIdA = convResA.body.data.id;

      // User B attempts to access User A's plan -> 404
      const getPlanB = await request(app.getHttpServer())
        .get(`/api/v1/ai/plan/${planIdA}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      expect(getPlanB.status).toBe(404);

      // User B attempts to approve User A's plan -> 404
      const approvePlanB = await request(app.getHttpServer())
        .post(`/api/v1/ai/plan/${planIdA}/approve`)
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({});
      expect(approvePlanB.status).toBe(404);

      // User B attempts to access User A's conversation -> 404
      const getConvB = await request(app.getHttpServer())
        .get(`/api/v1/ai/coach/conversations/${convIdA}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      expect(getConvB.status).toBe(404);

      // User B attempts to send message in User A's conversation -> 404
      const sendMsgB = await request(app.getHttpServer())
        .post(`/api/v1/ai/coach/conversations/${convIdA}/messages`)
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({
          content: 'Intruder message',
        });
      expect(sendMsgB.status).toBe(404);
    });
  });
});
