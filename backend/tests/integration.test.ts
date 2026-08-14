import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../src/app.module';

describe('Sprint 1 Secure Foundation — End-to-End API Integration Suite', () => {
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

  describe('1. Full Authentication Lifecycle Flow', () => {
    let accessToken: string;
    let refreshToken: string;

    it('POST /api/v1/auth/signup registers account, character, and returns RS256 token pair', async () => {
      const res = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
        email: 'e2e_user@arise.io',
        password: 'Password123!@#',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });

      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('user');
      expect(res.body.data.user.email).toBe('e2e_user@arise.io');
      expect(res.body.data).toHaveProperty('character');
      expect(res.body.data.character.level).toBe(1);
      expect(res.body.data.character.totalXp).toBe(0);
      expect(res.body.data.character.rank).toBe('E');
      expect(res.body.data).toHaveProperty('tokens');
      expect(res.body.data.tokens).toHaveProperty('accessToken');
      expect(res.body.data.tokens).toHaveProperty('refreshToken');

      accessToken = res.body.data.tokens.accessToken;
      refreshToken = res.body.data.tokens.refreshToken;
    });

    it('POST /api/v1/auth/login authenticates with valid credentials', async () => {
      const res = await request(app.getHttpServer()).post('/api/v1/auth/login').send({
        email: 'e2e_user@arise.io',
        password: 'Password123!@#',
      });

      expect(res.status).toBe(200);
      expect(res.body.data.user.email).toBe('e2e_user@arise.io');
      expect(res.body.data.tokens.accessToken).toBeDefined();
    });

    it('POST /api/v1/auth/refresh rotates single-use refresh token', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken });

      expect(res.status).toBe(200);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.refreshToken).not.toBe(refreshToken);

      // Update tokens for subsequent steps
      accessToken = res.body.data.accessToken;
      refreshToken = res.body.data.refreshToken;
    });

    it('POST /api/v1/auth/logout invalidates session', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ refreshToken });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('Logged out successfully');
    });
  });

  describe('2. AC-AUTH-004 End-to-End: Token Reuse Detection & Revocation', () => {
    it('rejects reused refresh token with 401 and revokes all active user sessions', async () => {
      // 1. Register User
      const signupRes = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
        email: 'reuse_victim@arise.io',
        password: 'Password123!',
        difficultyMode: 'casual',
      });

      const token1 = signupRes.body.data.tokens.refreshToken;

      // 2. Legitimate rotation: Token 1 -> Token 2
      const rotateRes = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: token1 });

      expect(rotateRes.status).toBe(200);
      const token2 = rotateRes.body.data.refreshToken;

      // 3. Attacker resubmits used Token 1
      const attackRes = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: token1 });

      expect(attackRes.status).toBe(401);
      expect(attackRes.body.error.code).toBe('TOKEN_REUSE_DETECTED');

      // 4. Verify all active sessions were revoked: Token 2 is now rejected
      const followUpRes = await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: token2 });

      expect(followUpRes.status).toBe(401);
    });
  });

  describe('3. Multi-Tenant Authorization & Query-Level Isolation (§13.2)', () => {
    let tokenUserA: string;
    let tokenUserB: string;
    let userIdA: string;
    let userIdB: string;

    beforeAll(async () => {
      const resA = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
        email: 'tenant_a@arise.io',
        password: 'PasswordA123!',
      });
      tokenUserA = resA.body.data.tokens.accessToken;
      userIdA = resA.body.data.user.id;

      const resB = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
        email: 'tenant_b@arise.io',
        password: 'PasswordB123!',
      });
      tokenUserB = resB.body.data.tokens.accessToken;
      userIdB = resB.body.data.user.id;
    });

    it('strictly isolates tenant character data based on verified JWT identity', async () => {
      // User A requests their character
      const resA = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${tokenUserA}`);

      expect(resA.status).toBe(200);
      expect(resA.body.data.userId).toBe(userIdA);

      // User B requests their character
      const resB = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${tokenUserB}`);

      expect(resB.status).toBe(200);
      expect(resB.body.data.userId).toBe(userIdB);
      expect(resB.body.data.userId).not.toBe(userIdA);
    });

    it('rejects unauthenticated requests to protected endpoints', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/character');
      expect(res.status).toBe(401);
      expect(res.body.error.code).toBe('UNAUTHORIZED');
    });

    it('rejects tampered or malformed JWT tokens', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', 'Bearer invalid.tampered.token');

      expect(res.status).toBe(401);
      expect(res.body.error.code).toBe('UNAUTHORIZED');
    });
  });

  describe('4. Sync Idempotency Replay End-to-End (NFR-008, Rule 6)', () => {
    let tokenUser: string;

    beforeAll(async () => {
      const signupRes = await request(app.getHttpServer()).post('/api/v1/auth/signup').send({
        email: 'idempotent_user@arise.io',
        password: 'Password123!',
      });
      tokenUser = signupRes.body.data.tokens.accessToken;
    });

    it('replaying an idempotency key returns exact same response without duplicate XP reward', async () => {
      const idempotencyKey = 'offline-cmd-uuid-999';

      // First execution: awards 100 XP
      const res1 = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${tokenUser}`)
        .set('Idempotency-Key', idempotencyKey)
        .send({ amount: 100 });

      expect(res1.status).toBe(200);
      expect(res1.body.data.success).toBe(true);
      expect(res1.body.data.xpAwarded).toBe(100);
      expect(res1.body.data.totalXp).toBe(100);

      // Replay identical command with same Idempotency-Key
      const res2 = await request(app.getHttpServer())
        .post('/api/v1/sync/idempotency-test')
        .set('Authorization', `Bearer ${tokenUser}`)
        .set('Idempotency-Key', idempotencyKey)
        .send({ amount: 100 });

      expect(res2.status).toBe(200);
      expect(res2.body).toEqual(res1.body);

      // Verify character total XP is STILL 100 (never 200!)
      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${tokenUser}`);

      expect(charRes.body.data.totalXp).toBe(100);
    });
  });
});
