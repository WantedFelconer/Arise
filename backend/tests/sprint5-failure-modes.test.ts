import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';
import { AI_PROVIDER_TOKEN } from '../src/modules/ai/providers/ai-provider.interface';
import { MockAIProvider } from '../src/modules/ai/providers/mock.adapter';
import jwt from 'jsonwebtoken';

describe('Sprint 5 Failure-Mode & Resilience Audit Suite', () => {
  let app: INestApplication;
  let userToken: string;
  let userId: string;
  let mockAiProvider: MockAIProvider;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1', {
      exclude: ['health'],
    });
    await app.init();

    mockAiProvider = moduleFixture.get<MockAIProvider>(AI_PROVIDER_TOKEN);
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
        email: `failure_${nonce}@arise.test`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userToken = signupRes.body.data.tokens.accessToken;
    userId = signupRes.body.data.user.id;
  });

  it('1. Malformed Request Body -> Rejects with 400 VALIDATION_ERROR and structured error details', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/quests')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        title: '', // Invalid empty string
        estimatedMinutes: -5, // Invalid negative integer
      });

    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
    expect(res.body.error.details).toBeDefined();
  });

  it('2. Expired or Invalid JWT -> Rejects with 401 UNAUTHORIZED', async () => {
    // Malformed signature / fake token
    const fakeToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature';
    const res1 = await request(app.getHttpServer())
      .get('/api/v1/character')
      .set('Authorization', `Bearer ${fakeToken}`);

    expect(res1.status).toBe(401);
    expect(res1.body.error.code).toBe('UNAUTHORIZED');

    // Missing Bearer token
    const res2 = await request(app.getHttpServer()).get('/api/v1/character');
    expect(res2.status).toBe(401);
    expect(res2.body.error.code).toBe('UNAUTHORIZED');
  });

  it('3. AI Provider Network Failure / Timeout -> Returns 503 AI_OFFLINE_UNAVAILABLE gracefully', async () => {
    // Configure mock provider to throw an offline network error
    mockAiProvider.queueStructuredResponse(() => {
      throw new Error('Connection refused to AI backend (ECONNREFUSED)');
    });

    const res = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ goal: 'AI Plan with offline provider' });

    expect(res.status).toBe(503);
    expect(res.body.error.code).toBe('AI_OFFLINE_UNAVAILABLE');
  });

  it('4. Malformed AI Provider Output on both attempts -> Returns 422 AI_PLAN_INVALID with schema error details', async () => {
    // Queue two consecutive malformed schema responses (attempt 1 and retry attempt 2)
    mockAiProvider.queueStructuredResponse({
      invalidKey: 'completely malformed response lacking mainQuest and subquests',
    });
    mockAiProvider.queueStructuredResponse({
      invalidKey2: 'still malformed response on retry',
    });

    const res = await request(app.getHttpServer())
      .post('/api/v1/ai/plan')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ goal: 'AI Plan triggering schema retry failure' });

    expect(res.status).toBe(422);
    expect(res.body.error.code).toBe('AI_PLAN_INVALID');
    expect(res.body.error.details).toBeDefined();
  });

  it('5. Database Graceful Fallback / Resilience -> Returns structured responses without leaking internal stack traces', async () => {
    // Request a non-existent route or invalid entity ID
    const res = await request(app.getHttpServer())
      .get('/api/v1/dungeons/00000000-0000-0000-0000-000000000000')
      .set('Authorization', `Bearer ${userToken}`);

    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe('DUNGEON_NOT_FOUND');
    expect(res.body).not.toHaveProperty('stack');
  });
});
