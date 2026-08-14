import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 5 Security & Anti-Cheat Audit — 16 Attack Scenarios', () => {
  let app: INestApplication;
  let userTokenA: string;
  let userTokenB: string;
  let userIdA: string;
  let userIdB: string;

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
    const nonce = Math.random().toString(36).substring(7);

    // Register User A
    const signupResA = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `sec_a_${nonce}@arise.test`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userTokenA = signupResA.body.data.tokens.accessToken;
    userIdA = signupResA.body.data.user.id;

    // Register User B
    const signupResB = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `sec_b_${nonce}@arise.test`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'night_owl',
      });
    userTokenB = signupResB.body.data.tokens.accessToken;
    userIdB = signupResB.body.data.user.id;
  });

  it('Attack 1: Client submits { xp: 999999999 } to any endpoint -> Ignored/rejected', async () => {
    // Attempt to inject arbitrary XP via quest creation
    const res = await request(app.getHttpServer())
      .post('/api/v1/quests')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        title: 'Cheat Quest',
        xp: 999999999,
        totalXp: 999999999,
        xpReward: 999999999,
      });

    expect(res.status).toBe(201);
    const questId = res.body.data.id;

    // Verify character XP has NOT jumped to 999999999
    const charRes = await request(app.getHttpServer())
      .get('/api/v1/character')
      .set('Authorization', `Bearer ${userTokenA}`);
    expect(charRes.body.data.totalXp).toBe(0);

    // Complete the quest -> reward must be computed by RpgEngine, not raw 999999999
    const completeRes = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({});
    expect(completeRes.status).toBe(200);
    // Calculated standard quest XP for 30min medium difficulty is around 50
    expect(completeRes.body.data.xpAwarded).toBeLessThan(1000);
  });

  it('Attack 2: Client submits { level: 999 } -> Ignored/rejected', async () => {
    const res = await request(app.getHttpServer())
      .patch('/api/v1/character/title')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        level: 999,
        titleId: 'novice',
      });

    // Level must remain 1
    const charRes = await request(app.getHttpServer())
      .get('/api/v1/character')
      .set('Authorization', `Bearer ${userTokenA}`);
    expect(charRes.body.data.level).toBe(1);
  });

  it('Attack 3: Client submits { mana: 999999 } or a fake Mana delta on Screen Time ingestion -> Server recomputes from raw data', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/screen-time/sessions')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        sessions: [
          {
            appPackage: 'com.instagram.android',
            durationSeconds: 1800,
            manaDelta: 999999,
            manaImpact: 999999,
          },
        ],
      });

    expect(res.status).toBe(200);
    // Standard mana impact for Instagram (entertainment/distraction 30m) is negative (-8)
    expect(res.body.data.totalManaImpact).toBeLessThanOrEqual(0);
    expect(res.body.data.totalManaImpact).toBe(-8);
  });

  it('Attack 4: Client submits { currentHp: 0 } directly on a boss -> No such endpoint / HP only changes via reward cascade', async () => {
    const bossRes = await request(app.getHttpServer())
      .post('/api/v1/bosses')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        title: 'Undefeated Dragon',
        hpMax: 500,
        difficulty: 'epic',
      });
    expect(bossRes.status).toBe(201);
    const bossId = bossRes.body.data.id;

    // Attempt to PATCH boss currentHp
    const patchRes = await request(app.getHttpServer())
      .patch(`/api/v1/bosses/${bossId}`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        hpCurrent: 0,
        currentHp: 0,
        status: 'defeated',
      });

    // Boss should still have 500 HP and status 'active'
    const getBossRes = await request(app.getHttpServer())
      .get(`/api/v1/bosses/${bossId}`)
      .set('Authorization', `Bearer ${userTokenA}`);
    expect(getBossRes.body.data.hpCurrent).toBe(500);
    expect(getBossRes.body.data.status).toBe('active');
  });

  it('Attack 5: Client fabricates a streak/achievement unlock -> Evaluated server-side from ledger data only', async () => {
    const fakeUnlockRes = await request(app.getHttpServer())
      .post('/api/v1/achievements/unlock')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        achievementId: 'grandmaster',
        code: 'ALL_BOSSES_DEFEATED',
      });

    // Endpoint does not exist or rejects client-triggered unlocks
    expect([404, 405]).toContain(fakeUnlockRes.status);
  });

  it('Attack 6: Client calls POST /quests/{id}/complete twice (or replays an idempotency key)', async () => {
    const questRes = await request(app.getHttpServer())
      .post('/api/v1/quests')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        title: 'Idempotency Target Quest',
        estimatedMinutes: 25,
      });
    expect(questRes.status).toBe(201);
    const questId = questRes.body.data.id;

    const key = 'idem-attack-6-' + Math.random().toString(36).substring(7);

    // Call 1
    const call1 = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .set('idempotency-key', key)
      .send({});
    expect(call1.status).toBe(200);

    // Call 2 with same idempotency key -> identical cached response, zero duplicate mutations
    const call2 = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .set('idempotency-key', key)
      .send({});
    expect(call2.status).toBe(200);
    expect(call2.body.data.quest.id).toBe(questId);

    // Call 3 without idempotency key -> 409 Conflict (QUEST_ALREADY_COMPLETED)
    const call3 = await request(app.getHttpServer())
      .post(`/api/v1/quests/${questId}/complete`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({});
    expect(call3.status).toBe(409);
    expect(call3.body.error.code).toBe('QUEST_ALREADY_COMPLETED');
  });

  it('Attack 7: Client submits a Gate session with a manipulated client-side elapsed time -> Server computes elapsed time from started_at + planned_duration', async () => {
    // Start gate session
    const startRes = await request(app.getHttpServer())
      .post('/api/v1/gates/sessions')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        plannedDurationSeconds: 1500,
      });
    expect(startRes.status).toBe(201);
    const sessionId = startRes.body.data.id;

    // Immediately try to complete with manipulated elapsed time = 1500 seconds
    const completeRes = await request(app.getHttpServer())
      .post(`/api/v1/gates/sessions/${sessionId}/complete`)
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        actualDurationSeconds: 1500,
        stabilityFinal: 1.0,
      });

    // Backend calculates actual elapsed time from started_at to now (~0-1 second)
    // Server computes stability at 0% and refuses to clear an uncompleted gate (FR-GATE-008)
    expect(completeRes.status).toBe(400);
    expect(completeRes.body.error.code).toBe('GATE_NOT_READY');
  });

  it('Attack 8: Client submits { premium: true } or attempts to flip an AI feature_flags gate -> No client-writable path', async () => {
    const res = await request(app.getHttpServer())
      .patch('/api/v1/settings')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        premium: true,
        feature_flags: { ai_enabled: true, bypass_quota: true },
        aiDailyQuota: 999999,
      });

    expect(res.status).toBe(200);
    // Verify feature flags and quota remain untouched
    const quotaRes = await request(app.getHttpServer())
      .get('/api/v1/ai/quota')
      .set('Authorization', `Bearer ${userTokenA}`);
    expect(quotaRes.body.data.limit).toBe(50);
  });

  it('Attack 9: Client exceeds the daily AI budget by firing concurrent requests -> Atomic mutex lock prevents race condition', async () => {
    process.env.AI_DAILY_QUOTA = '2';

    const nonce = Math.random().toString(36).substring(7);
    const userRes = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `quota_${nonce}@arise.test`,
        password: 'Password123!',
      });
    const quotaUserToken = userRes.body.data.tokens.accessToken;

    // Fire 3 simultaneous AI planner requests
    const promises = [1, 2, 3].map((i) =>
      request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${quotaUserToken}`)
        .send({
          goal: `Concurrent Plan ${i}`,
        }),
    );

    const results = await Promise.all(promises);
    const statuses = results.map((r) => r.status);

    // Exactly 2 requests must succeed (201) and exactly 1 must be rejected (429)
    const successCount = statuses.filter((s) => s === 201).length;
    const rateLimitedCount = statuses.filter((s) => s === 429).length;

    expect(successCount).toBe(2);
    expect(rateLimitedCount).toBe(1);

    delete process.env.AI_DAILY_QUOTA;
  });

  it('Attack 10: Client calls AI endpoints without authentication -> 401 Unauthorized', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .send({
        goal: 'Unauthenticated plan attempt',
      });

    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('Attack 11: Responses never leak AI provider API keys, FCM credentials, or JWT signing keys', async () => {
    const endpoints = [
      '/api/v1/character',
      '/api/v1/admin/config',
      '/api/v1/settings',
      '/api/v1/notifications',
      '/api/v1/music/catalog',
    ];

    for (const ep of endpoints) {
      const res = await request(app.getHttpServer())
        .get(ep)
        .set('Authorization', `Bearer ${userTokenA}`);

      const bodyStr = JSON.stringify(res.body);
      expect(bodyStr).not.toContain('AI_API_KEY');
      expect(bodyStr).not.toContain('GEMINI_API_KEY');
      expect(bodyStr).not.toContain('OPENAI_API_KEY');
      expect(bodyStr).not.toContain('CLAUDE_API_KEY');
      expect(bodyStr).not.toContain('FCM_SERVER_KEY');
      expect(bodyStr).not.toContain('JWT_PRIVATE_KEY');
      expect(bodyStr).not.toContain('PRIVATE KEY');
    }
  });

  it('Attack 12: User B cannot access User A resources by ID (Multi-Tenant Isolation across all entities)', async () => {
    // 1. Quests
    const qA = await request(app.getHttpServer())
      .post('/api/v1/quests')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({ title: 'User A Secret Quest' });
    const questId = qA.body.data.id;

    const bGetQuest = await request(app.getHttpServer())
      .get(`/api/v1/quests/${questId}`)
      .set('Authorization', `Bearer ${userTokenB}`);
    expect(bGetQuest.status).toBe(404);

    // 2. Bosses
    const bA = await request(app.getHttpServer())
      .post('/api/v1/bosses')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({ title: 'User A Boss', hpMax: 100 });
    const bossId = bA.body.data.id;

    const bGetBoss = await request(app.getHttpServer())
      .get(`/api/v1/bosses/${bossId}`)
      .set('Authorization', `Bearer ${userTokenB}`);
    expect(bGetBoss.status).toBe(404);

    // 3. Notes
    const nA = await request(app.getHttpServer())
      .post('/api/v1/notes')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({ title: 'User A Secret Notes', body: 'Sensitive info' });
    const noteId = nA.body.data.id;

    const bGetNote = await request(app.getHttpServer())
      .get(`/api/v1/notes/${noteId}`)
      .set('Authorization', `Bearer ${userTokenB}`);
    expect(bGetNote.status).toBe(404);

    // 4. Reminders
    const rA = await request(app.getHttpServer())
      .post('/api/v1/reminders')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({
        type: 'custom',
        message: 'User A Private Reminder',
        triggerConfig: { timestamp: new Date(Date.now() + 60000).toISOString() },
      });
    const reminderId = rA.body.data.id;

    const bGetReminder = await request(app.getHttpServer())
      .get(`/api/v1/reminders/${reminderId}`)
      .set('Authorization', `Bearer ${userTokenB}`);
    expect(bGetReminder.status).toBe(404);

    // 5. AI Plans
    const pA = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send({ goal: 'User A Plan' });
    const planId = pA.body.data.id;

    const bGetPlan = await request(app.getHttpServer())
      .get(`/api/v1/ai/plan/${planId}`)
      .set('Authorization', `Bearer ${userTokenB}`);
    expect(bGetPlan.status).toBe(404);
  });

  it('Attack 13: Rotated (already-used) refresh token replay revokes all user sessions (AC-AUTH-004)', async () => {
    const nonce = Math.random().toString(36).substring(7);
    // 1. Signup fresh user
    const regRes = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `token_reuse_${nonce}@arise.test`,
        password: 'Password123!',
      });
    const { accessToken, refreshToken: token1 } = regRes.body.data.tokens;

    // 2. First refresh -> rotates token1 and returns token2
    const ref1 = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: token1 });
    expect(ref1.status).toBe(200);
    const token2 = ref1.body.data.refreshToken;

    // 3. Replay already-used token1 -> Must return 401 TOKEN_REUSE_DETECTED and revoke ALL user sessions
    const replayRes = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: token1 });
    expect(replayRes.status).toBe(401);
    expect(replayRes.body.error.code).toBe('TOKEN_REUSE_DETECTED');

    // 4. Verify token2 was also revoked by the reuse defense
    const token2Attempt = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: token2 });
    expect(token2Attempt.status).toBe(401);
  });

  it('Attack 14: A revoked session / soft-deleted account token is rejected', async () => {
    const nonce = Math.random().toString(36).substring(7);
    // Create and then soft-delete user
    const victimRes = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `deleted_${nonce}@arise.test`,
        password: 'Password123!',
      });
    const victimToken = victimRes.body.data.tokens.accessToken;

    // Soft delete account
    const deleteRes = await request(app.getHttpServer())
      .delete('/api/v1/auth/account')
      .set('Authorization', `Bearer ${victimToken}`);
    expect(deleteRes.status).toBe(200);

    // Refresh attempt on deleted user must fail
    const refDeleted = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: victimRes.body.data.tokens.refreshToken });
    expect(refDeleted.status).toBe(401);
  });

  it('Attack 15: Rate limits on /auth/* and AI endpoints are enforced against abusive spam', async () => {
    const spamEmail = `spam_${Math.random().toString(36).substring(7)}@arise.test`;
    // Generate rapid requests to password reset endpoint
    const resetRequests = Array.from({ length: 15 }).map(() =>
      request(app.getHttpServer())
        .post('/api/v1/auth/password-reset/request')
        .send({ email: spamEmail }),
    );

    const responses = await Promise.all(resetRequests);
    const tooManyRequests = responses.filter((r) => r.status === 429);
    // Rate limit of 10 requests per window kicks in
    expect(tooManyRequests.length).toBeGreaterThan(0);
  });

  it('Attack 16: AI-generated quest title/description containing script tags is sanitized against Stored XSS', async () => {
    const xssPayload = {
      goal: '<script>alert("pwned")</script> Master Quantum Physics <img src=x onerror=alert(1)>',
      constraints: '<iframe src="javascript:alert(2)"></iframe> 2 hours per day',
    };

    const planRes = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .set('Authorization', `Bearer ${userTokenA}`)
      .send(xssPayload);

    expect(planRes.status).toBe(201);
    const plan = planRes.body.data;

    // Verify all malicious HTML/script tags were completely stripped
    expect(plan.goal).not.toContain('<script>');
    expect(plan.goal).not.toContain('alert("pwned")');
    expect(plan.goal).not.toContain('<img');
    expect(plan.goal).not.toContain('onerror=');
    expect(plan.goal).toContain('Master Quantum Physics');
  });
});
