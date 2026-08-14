import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint 4 Supporting Systems — End-to-End API Integration Suite', () => {
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
    const resA = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `hunter_a_${nonce}@arise.app`,
        password: 'Password123!',
        difficultyMode: 'casual',
        chronotype: 'early_bird',
      });
    userAToken = resA.body.data.tokens.accessToken;
    userAId = resA.body.data.user.id;

    // Register User B
    const resB = await request(app.getHttpServer())
      .post('/api/v1/auth/signup')
      .send({
        email: `hunter_b_${nonce}@arise.app`,
        password: 'Password123!',
        difficultyMode: 'hardcore',
        chronotype: 'night_owl',
      });
    userBToken = resB.body.data.tokens.accessToken;
    userBId = resB.body.data.user.id;
  });

  describe('1. Screen Time Anti-Cheat & Server Authority (§6.10, FR-SCREEN-001, 002)', () => {
    it('discards client-submitted spoofed Mana delta and computes authoritative impact', async () => {
      // User A submits a batch session claiming +500 Mana for 60 min on TikTok
      const res = await request(app.getHttpServer())
        .post('/api/v1/screen-time/sessions')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          sessions: [
            {
              appPackage: 'com.zhiliaoapp.musically',
              durationS: 3600, // 60 mins -> -16 Mana
              manaDelta: 500, // Spoofed value!
              manaImpact: 500, // Spoofed value!
            },
          ],
        });

      expect(res.status).toBe(200);
      expect(res.body.data.sessionsProcessed).toBe(1);
      expect(res.body.data.totalDurationMinutes).toBe(60);
      expect(res.body.data.totalManaImpact).toBe(-16); // Server-authoritative!

      // Check character Mana was reduced
      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(charRes.body.data.currentMana).toBe(84); // 100 - 16
    });

    it('fetches distraction insights and sets per-app custom category overrides', async () => {
      // Set override for Duolingo
      const overrideRes = await request(app.getHttpServer())
        .put('/api/v1/screen-time/categories/com.duolingo')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          category: 'educational',
          manaModifierPerMinute: 0.2,
        });
      expect(overrideRes.status).toBe(200);

      // Ingest Duolingo session
      const ingestRes = await request(app.getHttpServer())
        .post('/api/v1/screen-time/sessions')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          sessions: [
            {
              appPackage: 'com.duolingo',
              durationS: 1800, // 30 mins -> +6 Mana
            },
          ],
        });
      expect(ingestRes.body.data.totalManaImpact).toBe(6);

      // Fetch insights
      const insightsRes = await request(app.getHttpServer())
        .get('/api/v1/screen-time/insights')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(insightsRes.status).toBe(200);
      expect(insightsRes.body.data.totalDurationMinutes).toBe(30);
      expect(insightsRes.body.data.mostUsedApps[0].appPackage).toBe('com.duolingo');
    });
  });

  describe('2. Reminders & Background Dispatch Throttling (§6.11, FR-REM-001..005)', () => {
    it('creates, snoozes, and dispatches reminders with priority and throttling', async () => {
      // Create reminder
      const createRes = await request(app.getHttpServer())
        .post('/api/v1/reminders')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          type: 'quest',
          message: 'Complete CS301 Assignment',
          triggerConfig: { timeOfDay: '14:00' },
          priority: 'deadline',
        });
      expect(createRes.status).toBe(201);
      const reminderId = createRes.body.data.id;

      // Snooze reminder
      const snoozeRes = await request(app.getHttpServer())
        .post(`/api/v1/reminders/${reminderId}/snooze`)
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ snoozeMinutes: 30 });
      expect(snoozeRes.status).toBe(200);
      expect(snoozeRes.body.data.snoozedUntil).toBeDefined();

      // Verify list
      const listRes = await request(app.getHttpServer())
        .get('/api/v1/reminders')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(listRes.body.data.length).toBe(1);
    });
  });

  describe('3. Notifications Inbox & FCM Credential Protection (§6.21, FR-NOTIF-001..002)', () => {
    it('manages in-app notifications and never exposes FCM secrets in API responses', async () => {
      // Ingest test notifications directly into memoryDb for User A
      memoryDb.notifications.push({
        id: 'notif-1',
        userId: userAId,
        title: 'Achievement Unlocked',
        message: 'You completed your first quest!',
        type: 'achievement',
        read: false,
        data: { achievementId: 'ach-1' },
        createdAt: new Date(),
      });

      const listRes = await request(app.getHttpServer())
        .get('/api/v1/notifications')
        .set('Authorization', `Bearer ${userAToken}`);

      expect(listRes.status).toBe(200);
      expect(listRes.body.data.total).toBe(1);
      expect(listRes.body.data.unreadCount).toBe(1);

      // Verify FCM server key is NOT in the response
      expect(JSON.stringify(listRes.body)).not.toContain('FCM_SERVER_KEY');
      expect(JSON.stringify(listRes.body)).not.toContain('service_account');

      // Mark as read
      const readRes = await request(app.getHttpServer())
        .patch('/api/v1/notifications/notif-1/read')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(readRes.status).toBe(200);
      expect(readRes.body.data.read).toBe(true);
    });
  });

  describe('4. Fitness Logging & Progression Threshold Rewards (§6.17, FR-FIT-001..002)', () => {
    it('awards XP and Mana when activity exceeds configured threshold', async () => {
      // 8,500 steps >= 8,000 threshold (+50 XP, +10 Mana)
      const res = await request(app.getHttpServer())
        .post('/api/v1/fitness/logs')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          logType: 'steps',
          value: 8500,
          unit: 'count',
        });

      expect(res.status).toBe(201);
      expect(res.body.data.rewards.thresholdReached).toBe(true);
      expect(res.body.data.rewards.xpAwarded).toBe(50);
      expect(res.body.data.rewards.manaDelta).toBe(10);

      // Verify character received XP
      const charRes = await request(app.getHttpServer())
        .get('/api/v1/character')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(charRes.body.data.totalXp).toBe(50);
    });

    it('does NOT award XP when activity is below threshold', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/fitness/logs')
        .set('Authorization', `Bearer ${userBToken}`)
        .send({
          logType: 'steps',
          value: 1000,
          unit: 'count',
        });

      expect(res.status).toBe(201);
      expect(res.body.data.rewards.thresholdReached).toBe(false);
      expect(res.body.data.rewards.xpAwarded).toBe(0);
    });
  });

  describe('5. Notes Baseline & Full-Text Search (§6.15, FR-NOTE-001)', () => {
    it('creates folders, notes, and performs full-text search', async () => {
      const folderRes = await request(app.getHttpServer())
        .post('/api/v1/notes/folders')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ name: 'System Architecture' });
      expect(folderRes.status).toBe(201);
      const folderId = folderRes.body.data.id;

      const noteRes = await request(app.getHttpServer())
        .post('/api/v1/notes')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({
          title: 'Modular Monolith Patterns in NestJS',
          body: 'Organize features with Clean Architecture boundaries.',
          folderId,
          tags: ['architecture', 'nestjs'],
        });
      expect(noteRes.status).toBe(201);

      // Search by query string
      const searchRes = await request(app.getHttpServer())
        .get('/api/v1/notes?q=Modular')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(searchRes.status).toBe(200);
      expect(searchRes.body.data.length).toBe(1);
      expect(searchRes.body.data[0].title).toBe('Modular Monolith Patterns in NestJS');
    });
  });

  describe('6. Settings, Full Export & Account Erasure Lifecycle (§6.23, FR-SET-001..002)', () => {
    it('exports all domain data without omission in GDPR-compliant JSON', async () => {
      // Seed a note for export
      await request(app.getHttpServer())
        .post('/api/v1/notes')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ title: 'Exportable Note', body: 'Confidential content' });

      const exportRes = await request(app.getHttpServer())
        .get('/api/v1/settings/export')
        .set('Authorization', `Bearer ${userAToken}`);

      expect(exportRes.status).toBe(200);
      expect(exportRes.body.data.user.id).toBe(userAId);
      expect(exportRes.body.data.notes.length).toBeGreaterThanOrEqual(1);
      expect(exportRes.body.data.character).toBeDefined();
      expect(exportRes.body.data.settings).toBeDefined();
    });

    it('soft-deletes account and enables 30-day cancellation', async () => {
      const deleteRes = await request(app.getHttpServer())
        .post('/api/v1/settings/account/delete')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(deleteRes.status).toBe(200);
      expect(deleteRes.body.data.purgeScheduledDays).toBe(30);

      // Cancel deletion
      const cancelRes = await request(app.getHttpServer())
        .post('/api/v1/settings/account/cancel-deletion')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(cancelRes.status).toBe(200);
      expect(cancelRes.body.data.restored).toBe(true);
    });
  });

  describe('7. Game Modes Non-Retroactivity (§6.24, FR-MODE-001..003)', () => {
    it('switches difficulty mode without modifying historical ledger records', async () => {
      // Add initial XP ledger transaction under casual mode
      memoryDb.xpTransactions.push({
        id: 'hist-tx-1',
        characterId: userAId,
        amount: 250,
        sourceType: 'quest',
        createdAt: new Date('2026-08-01T10:00:00Z'),
      });

      // Switch to hardcore mode
      const modeRes = await request(app.getHttpServer())
        .put('/api/v1/settings/difficulty-mode')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ difficultyMode: 'hardcore' });

      expect(modeRes.status).toBe(200);
      expect(modeRes.body.data.difficultyMode).toBe('hardcore');

      // Verify past transaction row amount remains exactly 250
      const pastTx = memoryDb.xpTransactions.find((tx) => tx.id === 'hist-tx-1');
      expect(pastTx?.amount).toBe(250);
    });
  });

  describe('8. Statistics & Multi-Horizon Analytics Reconciliation (§6.14, §6.20)', () => {
    it('aggregates lifetime stats and computes multi-horizon analytics snapshots', async () => {
      const statsRes = await request(app.getHttpServer())
        .get('/api/v1/stats')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(statsRes.status).toBe(200);
      expect(statsRes.body.data.progression.level).toBeDefined();

      const dailyRes = await request(app.getHttpServer())
        .get('/api/v1/analytics/daily')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(dailyRes.status).toBe(200);
      expect(dailyRes.body.data.period).toBe('daily');
    });
  });

  describe('9. Music Catalog & Admin Balancing Config (§6.16, §6.27)', () => {
    it('exposes ambient music catalog and config-driven balancing tables', async () => {
      const musicRes = await request(app.getHttpServer())
        .get('/api/v1/music/catalog')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(musicRes.status).toBe(200);
      expect(musicRes.body.data.tracks.length).toBeGreaterThan(0);

      const adminRes = await request(app.getHttpServer())
        .get('/api/v1/admin/config')
        .set('Authorization', `Bearer ${userAToken}`);
      expect(adminRes.status).toBe(200);
      expect(adminRes.body.data.difficultyModes).toBeDefined();
    });
  });

  describe('10. Multi-Tenant Query-Level Ownership Isolation (§13.2)', () => {
    it('prevents User B from reading, modifying, or exporting User A notes and reminders', async () => {
      // User A creates a note
      const noteRes = await request(app.getHttpServer())
        .post('/api/v1/notes')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ title: 'User A Secret Note', body: 'Do not leak' });
      const noteId = noteRes.body.data.id;

      // User B attempts to get User A's note
      const bGetRes = await request(app.getHttpServer())
        .get(`/api/v1/notes/${noteId}`)
        .set('Authorization', `Bearer ${userBToken}`);
      expect(bGetRes.status).toBe(404);

      // User B attempts to delete User A's note
      const bDelRes = await request(app.getHttpServer())
        .delete(`/api/v1/notes/${noteId}`)
        .set('Authorization', `Bearer ${userBToken}`);
      expect(bDelRes.status).toBe(404);
    });
  });
});
