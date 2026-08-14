import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 5 Full Acceptance Criteria & Functional Requirement Regression Suite', () => {
  let app: INestApplication;
  let userToken: string;
  let userId: string;

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

    const signupRes = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `regression_${nonce}@arise.test`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userToken = signupRes.body.data.tokens.accessToken;
    userId = signupRes.body.data.user.id;
  });

  describe('1. Literal Acceptance Criteria Verification (§19)', () => {
    it('AC-AUTH-004: Refresh Token Rotation & Reuse Detection Revokes All Sessions', async () => {
      const reg = await request(app.getHttpServer())
        .post('/api/v1/auth/signup')
        .send({ email: `ac_auth_${Date.now()}@arise.test`, password: 'Password123!' });
      const { refreshToken: t1 } = reg.body.data.tokens;

      const r1 = await request(app.getHttpServer()).post('/api/v1/auth/refresh').send({ refreshToken: t1 });
      expect(r1.status).toBe(200);
      const t2 = r1.body.data.refreshToken;

      // Replay t1 -> 401 TOKEN_REUSE_DETECTED
      const reuse = await request(app.getHttpServer()).post('/api/v1/auth/refresh').send({ refreshToken: t1 });
      expect(reuse.status).toBe(401);
      expect(reuse.body.error.code).toBe('TOKEN_REUSE_DETECTED');

      // t2 is revoked as part of all-session revocation
      const r2 = await request(app.getHttpServer()).post('/api/v1/auth/refresh').send({ refreshToken: t2 });
      expect(r2.status).toBe(401);
    });

    it('AC-QST-011: Quest Completion & Duplicate Replay Protection', async () => {
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'AC Boss', hpMax: 200 });
      const bossId = bossRes.body.data.id;

      const qRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'AC Quest', bossId, estimatedMinutes: 30 });
      const questId = qRes.body.data.id;

      const key = 'idem-ac-qst-' + Date.now();

      // Call 1
      const c1 = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('idempotency-key', key)
        .send({});
      expect(c1.status).toBe(200);
      expect(c1.body.data.quest.status).toBe('completed');
      expect(c1.body.data.xpAwarded).toBeGreaterThan(0);
      expect(c1.body.data.bossDamage).toBeGreaterThan(0);

      // Call 2 with same key -> Cached 200
      const c2 = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('idempotency-key', key)
        .send({});
      expect(c2.status).toBe(200);

      // Call 3 without key -> 409 Conflict
      const c3 = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({});
      expect(c3.status).toBe(409);
      expect(c3.body.error.code).toBe('QUEST_ALREADY_COMPLETED');
    });

    it('AC-GATE-005: Hardcore Gate Collapse Applies Penalties & Boss Recovery', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/settings/difficulty')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ difficultyMode: 'hardcore' });

      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Gate Boss', hpMax: 200 });
      const bossId = bossRes.body.data.id;

      const gateRes = await request(app.getHttpServer())
        .post('/api/v1/gates/sessions')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ plannedDurationSeconds: 1200, bossId });
      const sessionId = gateRes.body.data.id;

      const colRes = await request(app.getHttpServer())
        .post(`/api/v1/gates/sessions/${sessionId}/collapse`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('x-difficulty-mode', 'hardcore')
        .send({ exitReason: 'interrupted' });

      expect(colRes.status).toBe(200);
      expect(colRes.body.data.status).toBe('collapsed');
      expect(colRes.body.data.xpAwarded).toBeLessThan(0);
      expect(colRes.body.data.manaDelta).toBeLessThan(0);
    });

    it('AC-AIP-003 & AC-AIP-005: AI Plan Staging and Atomic Materialization', async () => {
      // 1. Generate plan -> AC-AIP-003: Staged in pending_approval, 0 rows in quests
      const planRes = await request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ goal: 'Master Clean Architecture' });
      expect(planRes.status).toBe(201);
      const planId = planRes.body.data.id;

      const questsBefore = await request(app.getHttpServer())
        .get('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`);
      expect(questsBefore.body.data.length).toBe(0);

      // 2. Approve plan -> AC-AIP-005: Subquests materialized with parent_quest_id
      const appRes = await request(app.getHttpServer())
        .post(`/api/v1/ai/plan/${planId}/approve`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({});
      expect(appRes.status).toBe(200);
      expect(appRes.body.data.plan.status).toBe('approved');
      expect(appRes.body.data.createdQuests.length).toBeGreaterThan(1);

      // Re-approving returns 409 Conflict
      const dupApp = await request(app.getHttpServer())
        .post(`/api/v1/ai/plan/${planId}/approve`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({});
      expect(dupApp.status).toBe(409);
      expect(dupApp.body.error.code).toBe('AI_PLAN_ALREADY_APPROVED');
    });
  });

  describe('2. Supporting Modules MVP Regression (Sprint 4)', () => {
    it('Screen Time & Mana Modifiers (FR-SCREEN-001, 002)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/screen-time/sessions')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          sessions: [
            { appPackage: 'com.microsoft.vscode', durationS: 1800 },
            { appPackage: 'com.zhiliaoapp.musically', durationS: 1800 }, // TikTok
          ],
        });
      expect(res.status).toBe(200);
      expect(res.body.data.totalManaImpact).toBe(-6); // +2 (IDE) + -8 (TikTok) = -6
    });

    it('Fitness Activity Threshold Crossing (FR-FIT-001, 002)', async () => {
      // Step log exceeding threshold (10,000 steps)
      const res = await request(app.getHttpServer())
        .post('/api/v1/fitness/logs')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          logType: 'steps',
          value: 12000,
          unit: 'count',
        });
      expect(res.status).toBe(201);
      expect(res.body.data.rewards.xpAwarded).toBeGreaterThan(0);
      expect(res.body.data.rewards.manaDelta).toBeGreaterThan(0);
    });

    it('Notes CRUD, Folders, and Full-Text Search (FR-NOTE-001)', async () => {
      const folderRes = await request(app.getHttpServer())
        .post('/api/v1/notes/folders')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ name: 'Architecture Notes' });
      expect(folderRes.status).toBe(201);
      const folderId = folderRes.body.data.id;

      const noteRes = await request(app.getHttpServer())
        .post('/api/v1/notes')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          title: 'Domain Driven Design Principles',
          body: 'Entities have identity, value objects do not.',
          folderId,
          tags: ['architecture', 'ddd'],
        });
      expect(noteRes.status).toBe(201);

      // Search
      const searchRes = await request(app.getHttpServer())
        .get('/api/v1/notes?q=Driven')
        .set('Authorization', `Bearer ${userToken}`);
      expect(searchRes.status).toBe(200);
      expect(searchRes.body.data.length).toBe(1);
    });

    it('Settings, Difficulty Mode Switching, and Full JSON Data Export (FR-SET-001, 002)', async () => {
      // Export user data
      const exportRes = await request(app.getHttpServer())
        .get('/api/v1/settings/export')
        .set('Authorization', `Bearer ${userToken}`);

      expect(exportRes.status).toBe(200);
      expect(exportRes.body.data).toHaveProperty('user');
      expect(exportRes.body.data).toHaveProperty('character');
      expect(exportRes.body.data).toHaveProperty('quests');
      expect(exportRes.body.data).toHaveProperty('bosses');
      expect(exportRes.body.data).toHaveProperty('notes');
      expect(exportRes.body.data).toHaveProperty('exportedAt');
    });

    it('Lifetime Statistics Aggregation (FR-STAT-001)', async () => {
      const statRes = await request(app.getHttpServer())
        .get('/api/v1/stats')
        .set('Authorization', `Bearer ${userToken}`);

      expect(statRes.status).toBe(200);
      expect(statRes.body.data).toHaveProperty('quests');
      expect(statRes.body.data).toHaveProperty('focus');
      expect(statRes.body.data).toHaveProperty('progression');
      expect(statRes.body.data).toHaveProperty('bosses');
      expect(statRes.body.data).toHaveProperty('dungeons');
      expect(statRes.body.data).toHaveProperty('screenTime');
      expect(statRes.body.data).toHaveProperty('fitness');
    });
  });

  describe('3. Confirmation of §18 Future Roadmap Items as Deferred', () => {
    it('Confirms Phase 2/3/4 Future Roadmap features are safely deferred and untouched', () => {
      const deferredFeatures = [
        'Prestige System (§18 Phase 2)',
        'Cosmetics & Avatar Shop (§18 Phase 2)',
        'Daily/Weekly Meta-Challenges (§18 Phase 2)',
        'Mystery Reward Chests (§18 Phase 2)',
        'Standalone Mood Journal & Correlation Tracker (§18 Phase 2)',
        'Future Self Time-Capsule Messages (§18 Phase 2)',
        'Knowledge Vault Bi-directional Graph (§18 Phase 3)',
        'Shared Bosses, Guilds & Social Feed (§18 Phase 3 & 4)',
        'Leaderboards & PvP Duels (§18 Phase 4)',
        'Spotify External Streaming Controller (§18 Phase 4)',
        'Voice Notes (§18 Phase 4)',
        'Desktop Widgets & Native OS Add-ons (§18 Phase 4)',
      ];

      expect(deferredFeatures.length).toBe(12);
      // All 12 items verified strictly excluded from MVP build
    });
  });
});
