import { describe, it, expect, beforeEach } from 'vitest';
import { AnalyticsRepository } from '../repository/analytics.repository';
import { AnalyticsService } from '../service/analytics.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('AnalyticsService (FR-ANLY-001 & FR-ANLY-004)', () => {
  let repository: AnalyticsRepository;
  let service: AnalyticsService;
  const userId = 'analytics-test-user-1';

  beforeEach(() => {
    memoryDb.clear();
    repository = new AnalyticsRepository();
    service = new AnalyticsService(repository);

    const now = new Date();

    // 1. XP transactions
    memoryDb.xpTransactions.push(
      {
        id: 'xp-1',
        characterId: userId,
        amount: 150,
        sourceType: 'quest',
        createdAt: now,
      },
      {
        id: 'xp-2',
        characterId: userId,
        amount: 50,
        sourceType: 'gate',
        createdAt: now,
      },
    );

    // 2. Mana transactions
    memoryDb.manaTransactions.push(
      {
        id: 'mana-1',
        characterId: userId,
        delta: 10,
        sourceType: 'quest',
        createdAt: now,
      },
      {
        id: 'mana-2',
        characterId: userId,
        delta: -8,
        sourceType: 'screen_time',
        createdAt: now,
      },
    );

    // 3. Quests
    memoryDb.quests.set('q-1', {
      id: 'q-1',
      userId,
      bossId: null,
      parentQuestId: null,
      title: 'Analytics Quest',
      description: null,
      questType: 'daily',
      priority: 'medium',
      difficulty: 'medium',
      status: 'completed',
      estimatedMinutes: 30,
      actualMinutes: 30,
      deadline: null,
      recurrenceRule: null,
      tags: [],
      isFavorite: false,
      isPinned: false,
      eisenhowerQuadrant: null,
      completedAt: now,
      createdAt: now,
      updatedAt: now,
    });

    // 4. Focus
    memoryDb.gateSessions.set('g-1', {
      id: 'g-1',
      userId,
      questId: 'q-1',
      plannedDurationS: 1800,
      actualDurationS: 1800,
      pauseCount: 0,
      status: 'completed',
      stabilityFinal: 100,
      startedAt: now,
      endedAt: now,
    });

    // 5. Screen time
    memoryDb.screenTimeSessions.push({
      id: 'st-1',
      userId,
      appPackage: 'com.instagram.android',
      category: 'high_distraction',
      durationS: 1800,
      occurredAt: now,
      manaModifierApplied: -8,
      createdAt: now,
    });

    // 6. Fitness
    memoryDb.fitnessLogs.push({
      id: 'fit-1',
      userId,
      logType: 'steps',
      value: 8000,
      unit: 'count',
      recordedAt: now,
      createdAt: now,
    });
  });

  it('reconciles daily metrics against the underlying transaction tables', async () => {
    const report = await service.getDailyReport(userId);

    expect(report.period).toBe('daily');
    expect(report.metrics.totalXpGained).toBe(200); // 150 + 50
    expect(report.metrics.netManaChange).toBe(2); // 10 - 8
    expect(report.metrics.questsCompleted).toBe(1);
    expect(report.metrics.focusMinutes).toBe(30);
    expect(report.metrics.screenTimeMinutes).toBe(30);
    expect(report.metrics.screenTimeManaImpact).toBe(-8);
    expect(report.metrics.fitnessSummary.steps).toBe(8000);
  });

  it('generates and persists monthly snapshots permanently (FR-ANLY-004)', async () => {
    const monthly = await service.getMonthlyReport(userId);
    expect(monthly.period).toBe('monthly');
    expect(monthly.metrics.totalXpGained).toBe(200);

    const snapshots = await service.listSnapshots(userId, 'monthly');
    expect(snapshots.length).toBe(1);
    expect(snapshots[0].id).toBe(monthly.id);
  });
});
