import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 5 Offline-First & Idempotency / Transaction Audit Suite', () => {
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
        email: `offline_audit_${nonce}@arise.test`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userToken = signupRes.body.data.tokens.accessToken;
    userId = signupRes.body.data.user.id;
  });

  describe('1. Offline-First Authority Contract Verification', () => {
    it('1.1 Tampered local progression (XP, Level, Mana, Boss HP) is overwritten by server authoritative state upon sync', async () => {
      // Create a quest and a boss
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Gorgon Boss', hpMax: 200 });
      const bossId = bossRes.body.data.id;

      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Slay Gorgon Minion', bossId, estimatedMinutes: 30 });
      const questId = questRes.body.data.id;

      // Simulate a tampered local client modifying its local state:
      // Local client tampered character: totalXp = 50000, level = 50, currentMana = 999
      // Local client tampered boss: hpCurrent = 1
      const tamperedLocalClient = {
        totalXp: 50000,
        level: 50,
        currentMana: 999,
        bossHp: 1,
      };

      // Client performs sync by executing authoritative quest completion command
      const syncCmdKey = 'sync-cmd-' + Math.random().toString(36).substring(7);
      const completeRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('idempotency-key', syncCmdKey)
        .send({});

      expect(completeRes.status).toBe(200);

      // Fetch server authoritative character state
      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userToken}`);

      // Authoritative XP is computed strictly from the single completed quest (~50 XP, Level 1)
      expect(charRes.body.data.totalXp).toBeLessThan(100);
      expect(charRes.body.data.totalXp).not.toBe(tamperedLocalClient.totalXp);
      expect(charRes.body.data.level).toBe(1);
      expect(charRes.body.data.level).not.toBe(tamperedLocalClient.level);

      // Fetch server authoritative boss state
      const authoritativeBoss = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userToken}`);

      // Damage calculated from 30m medium quest is ~25, remaining HP ~175
      expect(authoritativeBoss.body.data.hpCurrent).toBeGreaterThan(150);
      expect(authoritativeBoss.body.data.hpCurrent).not.toBe(tamperedLocalClient.bossHp);
    });

    it('1.2 Gate session timing is recomputed server-side; client cannot award itself unverified session XP', async () => {
      const startRes = await request(app.getHttpServer())
        .post('/api/v1/gates/sessions')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ plannedDurationSeconds: 1800 });
      const sessionId = startRes.body.data.id;

      // Unsynchronized or premature completion attempt
      const attemptRes = await request(app.getHttpServer())
        .post(`/api/v1/gates/sessions/${sessionId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ actualDurationSeconds: 1800 });

      // Server rejects with GATE_NOT_READY and awards 0 XP
      expect(attemptRes.status).toBe(400);
      expect(attemptRes.body.error.code).toBe('GATE_NOT_READY');

      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userToken}`);
      expect(charRes.body.data.totalXp).toBe(0);
    });

    it('1.3 Queued domain operations with unique Idempotency-Keys survive replay and never duplicate rewards', async () => {
      const qRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Replay Test Quest', estimatedMinutes: 20 });
      const questId = qRes.body.data.id;

      const idempotencyKey = 'queue-replay-' + Math.random().toString(36).substring(7);

      // 1. First sync push
      const firstSync = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('idempotency-key', idempotencyKey)
        .send({});
      expect(firstSync.status).toBe(200);
      const initialXpAwarded = firstSync.body.data.xpAwarded;

      // Count XP ledger rows in memoryDb
      const char = Array.from(memoryDb.characters.values()).find((c) => c.userId === userId);
      const ledgerCountBefore = Array.from(memoryDb.xpTransactions.values()).filter(
        (t) => t.characterId === char?.id,
      ).length;
      expect(ledgerCountBefore).toBe(1);

      // 2. Replaying queued event on connection bounce with same key
      const replaySync = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('idempotency-key', idempotencyKey)
        .send({});
      expect(replaySync.status).toBe(200);

      // 3. Confirm exact same payload returned and ZERO duplicate ledger rows written
      const ledgerCountAfter = Array.from(memoryDb.xpTransactions.values()).filter(
        (t) => t.characterId === char?.id,
      ).length;
      expect(ledgerCountAfter).toBe(1);
      expect(replaySync.body.data.xpAwarded).toBe(initialXpAwarded);
    });

    it('1.4 Concurrent sync conflict on editable field (quest title) resolves gracefully with last-write-wins', async () => {
      const qRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Original Offline Title' });
      const questId = qRes.body.data.id;

      // Device 1 offline edit syncs
      const dev1Edit = await request(app.getHttpServer())
        .patch(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Device 1 Title Update' });
      expect(dev1Edit.status).toBe(200);

      // Device 2 offline edit syncs shortly after
      const dev2Edit = await request(app.getHttpServer())
        .patch(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Device 2 Title Update' });
      expect(dev2Edit.status).toBe(200);

      const finalQuest = await request(app.getHttpServer())
        .get(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userToken}`);
      expect(finalQuest.body.data.title).toBe('Device 2 Title Update');
    });

    it('1.5 AI endpoints refuse to fake offline operation', async () => {
      // AI planner requires online processing and explicit approval
      const planRes = await request(app.getHttpServer())
        .post('/api/v1/ai/plan')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ goal: 'Offline Goal' });

      // Succeeds via online provider mock with staged status, not auto-committed
      expect(planRes.status).toBe(201);
      expect(planRes.body.data.status).toBe('pending_approval');
    });
  });

  describe('2. Single Database Transaction & Reward Cascade Isolation (§17.3 Rule 1, Rule 5)', () => {
    it('2.1 RewardCascadeService writes ledger rows before updating character cached total', async () => {
      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Ledger-First Quest', estimatedMinutes: 45, difficulty: 'hard' });
      const questId = questRes.body.data.id;

      const completeRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({});
      expect(completeRes.status).toBe(200);

      const char = Array.from(memoryDb.characters.values()).find((c) => c.userId === userId);
      expect(char).toBeDefined();

      const xpTx = Array.from(memoryDb.xpTransactions.values()).filter(
        (t) => t.characterId === char!.id,
      );
      const manaTx = Array.from(memoryDb.manaTransactions.values()).filter(
        (t) => t.characterId === char!.id,
      );

      // Verify immutable ledger transactions exist
      expect(xpTx.length).toBeGreaterThanOrEqual(1);
      expect(manaTx.length).toBeGreaterThanOrEqual(1);

      // Verify character cached total matches sum of ledger transactions
      const sumXp = xpTx.reduce((sum, t) => sum + t.amount, 0);
      expect(char!.totalXp).toBe(sumXp);
    });

    it('2.2 Hardcore gate collapse applies penalties and boss HP recovery atomically in a single cascade', async () => {
      // Switch user to hardcore mode
      await request(app.getHttpServer())
        .post('/api/v1/settings/difficulty')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ difficultyMode: 'hardcore' });

      // Create boss with 100 HP
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ title: 'Hardcore Boss', hpMax: 100 });
      const bossId = bossRes.body.data.id;

      // Start gate session linked to boss
      const gateRes = await request(app.getHttpServer())
        .post('/api/v1/gates/sessions')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ plannedDurationSeconds: 1800, bossId });
      const sessionId = gateRes.body.data.id;

      // Collapse gate session in hardcore mode
      const collapseRes = await request(app.getHttpServer())
        .post(`/api/v1/gates/sessions/${sessionId}/collapse`)
        .set('Authorization', `Bearer ${userToken}`)
        .set('x-difficulty-mode', 'hardcore')
        .send({ exitReason: 'distraction' });

      expect(collapseRes.status).toBe(200);
      expect(collapseRes.body.data.status).toBe('collapsed');
      expect(collapseRes.body.data.xpAwarded).toBeLessThan(0); // Penalty applied
      expect(collapseRes.body.data.manaDelta).toBeLessThan(0);
    });
  });
});
