import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint A5 — Sync Engine, Reconciliation & Anti-Cheat Hardening Test Suite', () => {
  let app: INestApplication;
  let userAToken: string;
  let userAId: string;
  let userBToken: string;
  let userBId: string;

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
    const signupA = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `usera_${nonce}@arise.sys`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userAToken = signupA.body.data.tokens.accessToken;
    userAId = signupA.body.data.user.id;

    // Register User B
    const signupB = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `userb_${nonce}@arise.sys`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'night_owl',
      });
    userBToken = signupB.body.data.tokens.accessToken;
    userBId = signupB.body.data.user.id;
  });

  // ===========================================================================
  // 1. OWNERSHIP SECURITY (Never trust client-supplied userId/accountId/ownerId)
  // ===========================================================================
  describe('1. Ownership Security & Multi-Tenant Isolation', () => {
    it('1.1 User A cannot read, update, complete, or delete User B quest (returns 404/403)', async () => {
      // User B creates a quest
      const questRes = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userBToken}`)
        .send({
          title: "User B's Private Quest",
          description: 'Secret objective',
          estimatedMinutes: 45,
          difficulty: 'hard',
        });
      const questId = questRes.body.data.id;

      // User A attempts to GET User B's quest
      const getRes = await request(app.getHttpServer())
        .get(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userAToken}`);
      expect(getRes.status).toBe(404);

      // User A attempts to PATCH User B's quest
      const patchRes = await request(app.getHttpServer())
        .patch(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ title: 'Hacked Quest Title' });
      expect(patchRes.status).toBe(404);

      // User A attempts to COMPLETE User B's quest
      const completeRes = await request(app.getHttpServer())
        .post(`/api/v1/quests/${questId}/complete`)
        .set('Authorization', `Bearer ${userAToken}`)
        .send({});
      expect(completeRes.status).toBe(404);

      // User A attempts to DELETE User B's quest
      const deleteRes = await request(app.getHttpServer())
        .delete(`/api/v1/quests/${questId}`)
        .set('Authorization', `Bearer ${userAToken}`);
      expect(deleteRes.status).toBe(404);
    });

    it('1.2 Client-supplied userId in request body is ignored; server derives ownership strictly from token', async () => {
      // User A attempts to create a quest on behalf of User B by injecting userId: userBId in the body
      const spoofCreate = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          userId: userBId,
          title: 'Spoofed Ownership Quest',
          description: 'Attempting to inject into User B ledger',
          estimatedMinutes: 30,
        });

      expect(spoofCreate.status).toBe(201);
      const createdQuest = spoofCreate.body.data;

      // Ownership MUST belong to User A (the authenticated principal), NOT User B
      expect(createdQuest.userId).toBe(userAId);

      // User B should NOT see this quest in their list
      const userBList = await request(app.getHttpServer())
        .get('/api/v1/quests')
        .set('Authorization', `Bearer ${userBToken}`);
      const questFound = userBList.body.data.some((q: any) => q.id === createdQuest.id);
      expect(questFound).toBe(false);
    });
  });

  // ===========================================================================
  // 2. IDEMPOTENCY & REPLAY PROTECTION
  // ===========================================================================
  describe('2. Idempotency & Replay Protection', () => {
    it('2.1 Same command + same idempotency key + multiple submissions = 1 logical mutation with 0 duplicate ledger rows', async () => {
      const idempotencyKey = 'idem-key-' + Math.random().toString(36).substring(7);

      // 1st submission
      const res1 = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${userAToken}`)
        .set('idempotency-key', idempotencyKey)
        .send({ amount: 150 });

      expect(res1.status).toBe(200);
      expect(res1.body.data.xpAwarded).toBe(150);
      expect(res1.body.data.totalXp).toBe(150);

      // 2nd submission (Replay / Network retry)
      const res2 = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${userAToken}`)
        .set('idempotency-key', idempotencyKey)
        .send({ amount: 150 });

      expect(res2.status).toBe(200);
      expect(res2.body.data.totalXp).toBe(150); // Total XP has NOT doubled

      // 3rd submission
      const res3 = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${userAToken}`)
        .set('idempotency-key', idempotencyKey)
        .send({ amount: 150 });

      expect(res3.status).toBe(200);
      expect(res3.body).toEqual(res1.body);

      // Verify character ledger in server state
      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(charRes.body.data.totalXp).toBe(150);

      // Exactly 1 XP transaction recorded in memoryDb for this idempotencyKey
      const matchingLedgerRows = Array.from(memoryDb.xpTransactions.values()).filter(
        (t) => t.sourceId === idempotencyKey,
      );
      expect(matchingLedgerRows.length).toBe(1);
    });

    it('2.2 Idempotency keys are scoped strictly to the authenticated user; User B cannot reuse User A key', async () => {
      const sharedKey = 'cross-user-key-' + Math.random().toString(36).substring(7);

      // User A submits mutation with sharedKey
      const resA = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${userAToken}`)
        .set('idempotency-key', sharedKey)
        .send({ amount: 100 });
      expect(resA.status).toBe(200);
      expect(resA.body.data.totalXp).toBe(100);

      // User B submits mutation with the SAME sharedKey
      const resB = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${userBToken}`)
        .set('idempotency-key', sharedKey)
        .send({ amount: 200 });
      expect(resB.status).toBe(200);
      // User B executes independently; total XP is 200, NOT User A's cached 100
      expect(resB.body.data.totalXp).toBe(200);

      // Verify User A remains unaffected
      const charA = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(charA.body.data.totalXp).toBe(100);

      // Verify User B remains unaffected
      const charB = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userBToken}`);
      expect(charB.body.data.totalXp).toBe(200);
    });
  });

  // ===========================================================================
  // 3. ADVERSARIAL TAMPER TESTS (Anti-Cheat Validation)
  // ===========================================================================
  describe('3. Adversarial Progression Tamper Tests', () => {
    it('3.1 Attempting to set XP, Level, Mana, or Energy directly via client payloads fails', async () => {
      // 1. Attempt to inject { xp: 999999, level: 100 } on quest creation
      const spoofQuest = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          title: 'Hacked Quest',
          estimatedMinutes: 30,
          xp: 999999,
          level: 100,
          mana: 999999,
          energy: 999999,
        });
      expect(spoofQuest.status).toBe(201);

      // Character must still be Level 1, 0 XP
      const char1 = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(char1.body.data.level).toBe(1);
      expect(char1.body.data.totalXp).toBe(0);

      // 2. Attempt to inject fake Mana deltas on Screen Time ingestion
      const spoofScreenTime = await request(app.getHttpServer())
        .post('/api/v1/screen-time/sessions')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          sessions: [
            {
              appPackage: 'com.instagram.android',
              durationSeconds: 3600,
              manaDelta: +999999, // Client trying to claim Instagram restored 999k Mana
            },
          ],
        });
      expect(spoofScreenTime.status).toBe(200);

      // Authoritative Mana impact must be negative for Instagram (-16), NOT +999999
      expect(spoofScreenTime.body.data.totalManaImpact).toBeLessThan(0);
    });

    it('3.2 Attempting to set Boss HP to 0 directly is rejected; Boss HP only changes via verified quest completions', async () => {
      const bossRes = await request(app.getHttpServer())
        .post('/api/v1/bosses')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ title: 'Immortal Wyrm', hpMax: 500 });
      const bossId = bossRes.body.data.id;

      // Attempt to PATCH Boss HP directly to 0
      const spoofPatch = await request(app.getHttpServer())
        .patch(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ hpCurrent: 0 });

      // If PATCH is supported, hpCurrent is stripped/ignored; boss remains at max HP
      const bossCheck = await request(app.getHttpServer())
        .get(`/api/v1/bosses/${bossId}`)
        .set('Authorization', `Bearer ${userAToken}`);
      expect(bossCheck.body.data.hpCurrent).toBe(500);
      expect(bossCheck.body.data.status).toBe('active');
    });
  });

  // ===========================================================================
  // 4. TOKEN SECURITY & REPLAY ATTACK DETECTION
  // ===========================================================================
  describe('4. Token Security & Replay Attack Detection', () => {
    it('4.1 Reusing an already-consumed refresh token triggers reuse detection and revokes all user sessions (AC-AUTH-004)', async () => {
      const nonce = Math.random().toString(36).substring(7);
      const signupRes = await request(app.getHttpServer())
        .post('/api/v1/auth/signup')
        .send({
          email: `reuse_victim_${nonce}@arise.sys`,
          password: 'Password123!',
          difficultyMode: 'casual',
          chronotype: 'early_bird',
        });
      const initialRefreshToken = signupRes.body.data.tokens.refreshToken;

      // Step 1: Legitimate client uses refresh token to get new tokens
      const refresh1 = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: initialRefreshToken });
      expect(refresh1.status).toBe(200);
      const newAccessToken = refresh1.body.data.accessToken;

      // Step 2: Attacker replays the INITIAL refresh token
      const replayAttack = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: initialRefreshToken });

      expect(replayAttack.status).toBe(401);
      expect(replayAttack.body.error.code).toBe('TOKEN_REUSE_DETECTED');

      // Step 3: All active sessions revoked — subsequent requests with active tokens fail
      const subsequentReq = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: refresh1.body.data.refreshToken });
      expect(subsequentReq.status).toBe(401);
    });

    it('4.2 Malformed payloads are rejected with 400/422 by Zod validation pipes', async () => {
      const invalidQuest = await request(app.getHttpServer())
        .post('/api/v1/quests')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          title: '', // Title too short
          difficulty: 'super_saiyan', // Invalid enum
        });
      expect(invalidQuest.status).toBe(400);
      expect(invalidQuest.body.error.code).toBe('VALIDATION_ERROR');
    });
  });
});
