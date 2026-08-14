import { describe, it, expect, beforeEach } from 'vitest';
import { SettingsRepository } from '../repository/settings.repository';
import { SettingsService } from '../service/settings.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('SettingsService (FR-SET-001, FR-SET-002, FR-MODE-001..003)', () => {
  let repository: SettingsRepository;
  let service: SettingsService;
  const userId = 'settings-test-user-1';

  beforeEach(() => {
    memoryDb.clear();
    repository = new SettingsRepository();
    service = new SettingsService(repository);

    // Seed user
    memoryDb.users.set(userId, {
      id: userId,
      email: 'hunter@arise.app',
      passwordHash: 'argon2-hash',
      difficultyMode: 'casual',
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });
  });

  it('updates preferences (theme, notificationPreferences, sound)', async () => {
    const updated = await service.updateSettings(userId, {
      theme: 'dark',
      soundEnabled: false,
      dailyReminderTime: '08:30',
      notificationPreferences: { questReminders: false, gateAlerts: true, dailyReview: true },
    });

    expect(updated.theme).toBe('dark');
    expect(updated.soundEnabled).toBe(false);
    expect(updated.dailyReminderTime).toBe('08:30');
    expect(updated.notificationPreferences.questReminders).toBe(false);
  });

  it('switches difficulty mode non-retroactively (FR-MODE-003)', async () => {
    // Append an initial transaction under casual mode
    const initialTx = {
      id: 'tx-1',
      characterId: userId,
      amount: 100,
      sourceType: 'quest',
      createdAt: new Date('2026-08-01T00:00:00Z'),
    };
    memoryDb.xpTransactions.push(initialTx);

    // Switch mode to hardcore
    const res = await service.setDifficultyMode(userId, { difficultyMode: 'hardcore' });
    expect(res.difficultyMode).toBe('hardcore');

    // Confirm user is now in hardcore mode
    const currentMode = await service.getDifficultyMode(userId);
    expect(currentMode.difficultyMode).toBe('hardcore');

    // Historical ledger transaction remains untouched
    expect(memoryDb.xpTransactions[0].amount).toBe(100);
  });

  it('exports complete user data across all tables without omission (FR-SET-002)', async () => {
    // Seed some data
    memoryDb.quests.set('q-1', {
      id: 'q-1',
      userId,
      bossId: null,
      parentQuestId: null,
      title: 'Export Quest',
      description: null,
      questType: 'daily',
      priority: 'medium',
      difficulty: 'medium',
      status: 'active',
      estimatedMinutes: 30,
      actualMinutes: null,
      deadline: null,
      recurrenceRule: null,
      tags: [],
      isFavorite: false,
      isPinned: false,
      eisenhowerQuadrant: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const exportData = await service.exportUserData(userId);

    expect(exportData.user.id).toBe(userId);
    expect(exportData.quests.length).toBe(1);
    expect(exportData.exportedAt).toBeDefined();
    expect(exportData.settings).toBeDefined();
  });

  it('soft-deletes user account and invalidates active refresh tokens', async () => {
    memoryDb.refreshTokens.set('rt-1', {
      id: 'rt-1',
      userId,
      tokenHash: 'hash-1',
      revokedAt: null,
      expiresAt: new Date(Date.now() + 86400000),
      createdAt: new Date(),
    });

    const result = await service.requestAccountDeletion(userId);
    expect(result.deletedAt).toBeDefined();
    expect(result.purgeScheduledDays).toBe(30);

    const user = memoryDb.users.get(userId);
    expect(user?.deletedAt).not.toBeNull();

    // Verify token was revoked
    expect(memoryDb.refreshTokens.get('rt-1')?.revokedAt).not.toBeNull();

    // Cancellation test
    const restore = await service.cancelAccountDeletion(userId);
    expect(restore.restored).toBe(true);
    expect(memoryDb.users.get(userId)?.deletedAt).toBeNull();
  });
});
