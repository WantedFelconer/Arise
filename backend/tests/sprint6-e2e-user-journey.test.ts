import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 6 / Final MVP Audit — Complete User Journey E2E Test Suite', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1', {
      exclude: ['health'],
    });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(async () => {
    memoryDb.clear();
  });

  it('Executes the complete end-to-end user journey flawlessly', async () => {
    const nonce = Math.random().toString(36).substring(7);
    const testEmail = `solo_leveler_${nonce}@arise.app`;
    const testPassword = 'Password123!';

    // -------------------------------------------------------------------------
    // Step 1: Register Clean Test Account
    // -------------------------------------------------------------------------
    const signupRes = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: testEmail,
        password: testPassword,
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });

    expect(signupRes.status).toBe(201);
    expect(signupRes.body.data.user.email).toBe(testEmail);
    expect(signupRes.body.data.tokens.accessToken).toBeDefined();
    expect(signupRes.body.data.tokens.refreshToken).toBeDefined();

    const initialRefreshToken = signupRes.body.data.tokens.refreshToken;

    // -------------------------------------------------------------------------
    // Step 2: Login with Credentials
    // -------------------------------------------------------------------------
    const loginRes = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({
        email: testEmail,
        password: testPassword,
      });

    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data.tokens.accessToken).toBeDefined();
    const activeToken = loginRes.body.data.tokens.accessToken;
    const activeRefreshToken = loginRes.body.data.tokens.refreshToken;

    // -------------------------------------------------------------------------
    // Step 3 & 4: Restart App / Session Restored via Token Refresh
    // -------------------------------------------------------------------------
    const refreshRes = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({
        refreshToken: activeRefreshToken,
      });

    expect(refreshRes.status).toBe(200);
    expect(refreshRes.body.data.accessToken).toBeDefined();
    expect(refreshRes.body.data.refreshToken).toBeDefined();
    const restoredToken = refreshRes.body.data.accessToken;

    // -------------------------------------------------------------------------
    // Step 5: Load Character State
    // -------------------------------------------------------------------------
    const charRes = await request(app.getHttpServer())
      .get('/api/v1/character')
      .set('Authorization', `Bearer ${restoredToken}`);

    expect(charRes.status).toBe(200);
    expect(charRes.body.data.level).toBe(1);
    expect(charRes.body.data.totalXp).toBe(0);
    expect(charRes.body.data.rank).toBe('E');
    expect(charRes.body.data.currentMana).toBe(100);

    // -------------------------------------------------------------------------
    // Step 6 & 7: Create Project Boss & Quest
    // -------------------------------------------------------------------------
    const bossRes = await request(app.getHttpServer())
      .post('/api/v1/bosses')
      .set('Authorization', `Bearer ${restoredToken}`)
      .send({
        title: 'IGRIS THE BLOODRED COMMANDER',
        hpMax: 200,
        difficulty: 'hard',
      });
    expect(bossRes.status).toBe(201);
    const bossId = bossRes.body.data.id;
    expect(bossRes.body.data.hpCurrent).toBe(200);

    const questRes = await request(app.getHttpServer())
      .post('/api/v1/quests')
      .set('Authorization', `Bearer ${restoredToken}`)
      .send({
        title: 'Master TypeScript AST Parsing',
        description: 'Complete compiler pipeline exercises',
        difficulty: 'hard',
        priority: 'high',
        estimatedMinutes: 60,
        bossId: bossId,
        tags: ['coding', 'study'],
      });

    expect(questRes.status).toBe(201);
    const questId = questRes.body.data.id;
    expect(questRes.body.data.title).toBe('Master TypeScript AST Parsing');

    // -------------------------------------------------------------------------
    // Step 8 & 9: Close & Reopen (Query Quests List)
    // -------------------------------------------------------------------------
    const listRes = await request(app.getHttpServer())
      .get('/api/v1/quests')
      .set('Authorization', `Bearer ${restoredToken}`);

    expect(listRes.status).toBe(200);
    const questsList = Array.isArray(listRes.body.data) ? listRes.body.data : listRes.body.data.items;
    const foundQuest = questsList.find((q: any) => q.id === questId);
    expect(foundQuest).toBeDefined();
    expect(['pending', 'active']).toContain(foundQuest.status);

    // -------------------------------------------------------------------------
    // Step 10-16: Offline Simulation & Completion with Idempotency Key
    // -------------------------------------------------------------------------
    const idempotencyKey = `sync-e2e-quest-${questId}`;
    const completeRes = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${restoredToken}`)
      .set('idempotency-key', idempotencyKey)
      .send({});

    expect(completeRes.status).toBe(200);
    expect(completeRes.body.data.quest.id).toBe(questId);
    expect(completeRes.body.data.xpAwarded).toBeGreaterThan(0);

    // Replay same request with same idempotency key -> cached identical result
    const replayRes = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${restoredToken}`)
      .set('idempotency-key', idempotencyKey)
      .send({});

    expect(replayRes.status).toBe(200);
    expect(replayRes.body.data.quest.id).toBe(questId);

    // -------------------------------------------------------------------------
    // Step 17 & 18: Authoritative Reward Cascade (XP/Mana/Boss damage update)
    // -------------------------------------------------------------------------
    const updatedCharRes = await request(app.getHttpServer())
      .get('/api/v1/character')
      .set('Authorization', `Bearer ${restoredToken}`);

    expect(updatedCharRes.status).toBe(200);
    expect(updatedCharRes.body.data.totalXp).toBeGreaterThan(50);

    // Verify Boss took damage via reward cascade
    const updatedBossRes = await request(app.getHttpServer())
      .get(`/api/v1/bosses/${bossId}`)
      .set('Authorization', `Bearer ${restoredToken}`);

    expect(updatedBossRes.status).toBe(200);
    expect(updatedBossRes.body.data.hpCurrent).toBeLessThan(200);

    // -------------------------------------------------------------------------
    // Step 19-21: Enter Focus Gate
    // -------------------------------------------------------------------------
    const gateStartRes = await request(app.getHttpServer())
      .post('/api/v1/gates/sessions')
      .set('Authorization', `Bearer ${restoredToken}`)
      .send({
        plannedDurationSeconds: 1500,
        questId: questId,
      });

    expect(gateStartRes.status).toBe(201);
    expect(gateStartRes.body.data.status).toBe('active');

    // -------------------------------------------------------------------------
    // Step 22: Use AI in Online Mode (AI Planning & Triage)
    // -------------------------------------------------------------------------
    const aiPlanRes = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .set('Authorization', `Bearer ${restoredToken}`)
      .send({
        goal: 'Prepare for System Architecture Certification Exam',
        availableMinutes: 120,
      });

    expect(aiPlanRes.status).toBe(201);
    const planData = aiPlanRes.body.data;
    expect(planData.id).toBeDefined();
    expect(planData.status).toBe('pending_approval');
    expect(planData.rawPlan.mainQuest.title).toBeDefined();
    expect(planData.rawPlan.mainQuest.subquests.length).toBeGreaterThan(0);

    // Approve the plan to convert into actual quests (AI proposes, user commits)
    const approveRes = await request(app.getHttpServer())
      .post(`/api/v1/ai/plan/${planData.id}/approve`)
      .set('Authorization', `Bearer ${restoredToken}`)
      .send({});

    expect(approveRes.status).toBe(200);
    expect(approveRes.body.data.plan.status).toBe('approved');
    expect(approveRes.body.data.createdQuests.length).toBeGreaterThan(0);

    // Verify AI Quota deduction
    const quotaRes = await request(app.getHttpServer())
      .get('/api/v1/ai/quota')
      .set('Authorization', `Bearer ${restoredToken}`);

    expect(quotaRes.status).toBe(200);
    expect(quotaRes.body.data.remaining).toBeLessThan(quotaRes.body.data.limit);
  });
});
