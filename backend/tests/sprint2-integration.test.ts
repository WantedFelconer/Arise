import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 2 Core Productivity Loop — End-to-End API Integration Suite', () => {
  let app: INestApplication;
  let userTokenA: string;
  let userIdA: string;
  let userTokenB: string;
  let userIdB: string;

  beforeEach(async () => {
    memoryDb.clear();

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1', {
      exclude: ['health'],
    });
    await app.init();

    // Signup User A (Casual mode)
    const signupResA = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
      email: 'tenanta@arise.dev',
      password: 'Password123!@#',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });
    userTokenA = signupResA.body.data.tokens.accessToken;
    userIdA = signupResA.body.data.user.id;
    expect(userIdA).toBeDefined();

    // Signup User B (Hardcore mode)
    const signupResB = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
      email: 'tenantb@arise.dev',
      password: 'Password123!@#',
      difficultyMode: 'hardcore',
      chronotype: 'night_owl',
    });
    userTokenB = signupResB.body.data.tokens.accessToken;
    userIdB = signupResB.body.data.user.id;
    expect(userIdB).toBeDefined();
  });

  describe('1. Literal §19 AC-QST-011: Quest Completion & Duplicate Replay Protection', () => {
    it('executes atomic reward cascade on quest complete and rejects duplicate completion with 409', async () => {
      // 1. Create an active Boss at hp_current = 200
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'Algorithm Final Boss',
          hpMax: 200,
          difficulty: 'medium',
        });
      expect(bossRes.status).toBe(201);
      const bossId = bossRes.body.data.id;
      expect(bossRes.body.data.hpCurrent).toBe(200);

      // 2. Create a pending quest with estimatedMinutes=50, linked to the Boss
      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'Solve Graph Traversal Questions',
          estimatedMinutes: 50,
          difficulty: 'medium',
          priority: 'medium',
          bossId,
          tags: ['coding'],
        });
      expect(questRes.status).toBe(201);
      const questId = questRes.body.data.id;
      expect(questRes.body.data.status).toBe('pending');

      // 3. Complete the quest
      const completeRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({});

      expect(completeRes.status).toBe(200);
      expect(completeRes.body.data.quest.status).toBe('completed');
      expect(completeRes.body.data.xpAwarded).toBe(50);
      expect(completeRes.body.data.manaDelta).toBe(5);
      expect(completeRes.body.data.bossDamage).toBeGreaterThan(0);

      // Verify Boss HP reduced
      const bossCheck = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(bossCheck.body.data.hpCurrent).toBeLessThan(200);

      // Verify Ledger Rows in Character History
      const historyRes = await request(app.getHttpServer())
        .get('/api/v1/character/history')
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(historyRes.status).toBe(200);
      const xpTxs = historyRes.body.data.xpTransactions;
      const manaTxs = historyRes.body.data.manaTransactions;
      expect(
        xpTxs.some(
          (t: { amount: number; sourceId?: string }) => t.amount === 50 && t.sourceId === questId,
        ),
      ).toBe(true);
      expect(
        manaTxs.some(
          (t: { delta: number; sourceId?: string }) => t.delta === 5 && t.sourceId === questId,
        ),
      ).toBe(true);

      const xpTxsCountBefore = xpTxs.length;
      const manaTxsCountBefore = manaTxs.length;

      // 4. Calling the same complete endpoint again MUST return 409 Conflict and create NO duplicate ledger rows
      const duplicateRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({});

      expect(duplicateRes.status).toBe(409);

      // Verify no duplicate transactions were created
      const historyAfter = await request(app.getHttpServer())
        .get('/api/v1/character/history')
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(historyAfter.body.data.xpTransactions.length).toBe(xpTxsCountBefore);
      expect(historyAfter.body.data.manaTransactions.length).toBe(manaTxsCountBefore);
    });

    it('replaying with Idempotency-Key returns original cached response with zero duplicate mutations', async () => {
      const idempotencyKey = 'idemp-quest-complete-999';

      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({
          title: 'Idempotent Quest',
          estimatedMinutes: 40,
        });
      const questId = questRes.body.data.id;

      // First call with Idempotency-Key
      const res1 = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .set('idempotency-key', idempotencyKey)
        .send({});
      expect(res1.status).toBe(200);

      // Second call with same Idempotency-Key returns cached 200 OK
      const res2 = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`)
        .set('idempotency-key', idempotencyKey)
        .send({});
      expect(res2.status).toBe(200);
      expect(res2.body.data.xpAwarded).toBe(res1.body.data.xpAwarded);

      // Verify only 1 XP transaction row exists for this quest
      const historyRes = await request(app.getHttpServer())
        .get('/api/v1/character/history')
        .set('Authorization', `Bearer ${userTokenA}`);
      const matchingTxs = historyRes.body.data.xpTransactions.filter(
        (t: { sourceId?: string }) => t.sourceId === questId,
      );
      expect(matchingTxs.length).toBe(1);
    });
  });

  describe('2. Literal §19 AC-GATE-005: Hardcore Gate Collapse Penalty & Boss HP Recovery', () => {
    it('applies negative XP and Mana transactions and recovers boss HP on collapse in hardcore mode', async () => {
      // 1. Create a Boss for User B (Hardcore user)
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({
          title: 'Hardcore Project Boss',
          hpMax: 100,
        });
      const bossId = bossRes.body.data.id;

      // Damage boss first so it has lost HP
      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({
          title: 'Damaging Quest',
          estimatedMinutes: 60,
          bossId,
        });
      await request(app.getHttpServer())
        .post(`/api/v1/quests/${questRes.body.data.id}/complete`)
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({});

      const damagedBoss = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      const hpBeforeCollapse = damagedBoss.body.data.hpCurrent;
      expect(hpBeforeCollapse).toBeLessThan(100);

      // 2. Start a Gate Session linked to that boss-linked quest
      const sessionRes = await request(app.getHttpServer())
        .post('/api/v1/gates/sessions')
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({
          questId: questRes.body.data.id,
          plannedDurationSeconds: 1500,
        });
      expect(sessionRes.status).toBe(201);
      const sessionId = sessionRes.body.data.id;

      // 3. Call POST /api/v1/gates/:id/collapse in hardcore mode
      const collapseRes = await request(app.getHttpServer())
        .post(`/api/v1/gates/${sessionId}/collapse`)
        .set('Authorization', `Bearer ${userTokenB}`)
        .set('x-difficulty-mode', 'hardcore')
        .send({
          exitReason: 'aborted_early',
        });

      expect(collapseRes.status).toBe(200);
      expect(collapseRes.body.data.status).toBe('collapsed');

      // 4. Verify negative XP transaction and negative Mana transaction exist
      const historyRes = await request(app.getHttpServer())
        .get('/api/v1/character/history')
        .set('Authorization', `Bearer ${userTokenB}`);
      const xpTxs = historyRes.body.data.xpTransactions;
      const manaTxs = historyRes.body.data.manaTransactions;

      const penaltyXpTx = xpTxs.find(
        (t: { sourceId?: string; amount?: number }) => t.sourceId === sessionId,
      );
      const penaltyManaTx = manaTxs.find(
        (t: { sourceId?: string; delta?: number }) => t.sourceId === sessionId,
      );

      expect(penaltyXpTx).toBeDefined();
      expect(penaltyXpTx.amount).toBeLessThan(0); // Negative XP transaction
      expect(penaltyManaTx).toBeDefined();
      expect(penaltyManaTx.delta).toBeLessThan(0); // Negative Mana transaction

      // 5. Verify Boss HP recovery was applied per hardcore recovery rate
      const recoveredBoss = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      expect(recoveredBoss.body.data.hpCurrent).toBeGreaterThan(hpBeforeCollapse);
    });
  });

  describe('3. Dungeons Progression & Boss Grouping (FR-DUNG-001..003)', () => {
    it('calculates dungeon progress and transitions to completed when all bosses are defeated', async () => {
      const dungeonRes = await request(app.getHttpServer())
        .post('/api/v1/dungeons')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Full Stack Track' });
      const dungeonId = dungeonRes.body.data.id;

      const boss1 = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Frontend Boss', hpMax: 30, dungeonId });

      const boss2 = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Backend Boss', hpMax: 30, dungeonId });

      // Defeat boss 1
      const q1 = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Q1', bossId: boss1.body.data.id, estimatedMinutes: 100 });
      await request(app.getHttpServer())
        .post(`/api/v1/quests/${q1.body.data.id}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`);

      const d1 = await request(app.getHttpServer())
        .get(`/api/v1/dungeons/${dungeonId}`)
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(d1.body.data.progressPct).toBe(50);
      expect(d1.body.data.status).toBe('active');

      // Defeat boss 2
      const q2 = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Q2', bossId: boss2.body.data.id, estimatedMinutes: 100 });
      await request(app.getHttpServer())
        .post(`/api/v1/quests/${q2.body.data.id}/complete`)
        .set('Authorization', `Bearer ${userTokenA}`);

      const d2 = await request(app.getHttpServer())
        .get(`/api/v1/dungeons/${dungeonId}`)
        .set('Authorization', `Bearer ${userTokenA}`);
      expect(d2.body.data.progressPct).toBe(100);
      expect(d2.body.data.status).toBe('completed');
    });
  });

  describe('4. Multi-Tenant Query-Level Isolation (§13.2)', () => {
    it('prevents User B from accessing, modifying, or completing User A quests and bosses', async () => {
      // User A creates quest and boss
      const bossA = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Secret Project', hpMax: 100 });

      const questA = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userTokenA}`)
        .send({ title: 'Confidential Task', bossId: bossA.body.data.id });

      // User B tries to read User A quest -> 404 NOT_FOUND
      const getRes = await request(app.getHttpServer())
        .get(`/api/v1/quests/${questA.body.data.id}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      expect(getRes.status).toBe(404);

      // User B tries to complete User A quest -> 404 NOT_FOUND
      const compRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questA.body.data.id}/complete`)
        .set('Authorization', `Bearer ${userTokenB}`)
        .send({});
      expect(compRes.status).toBe(404);

      // User B tries to read User A boss -> 404 NOT_FOUND
      const bossGetRes = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossA.body.data.id}`)
        .set('Authorization', `Bearer ${userTokenB}`);
      expect(bossGetRes.status).toBe(404);
    });
  });
});
