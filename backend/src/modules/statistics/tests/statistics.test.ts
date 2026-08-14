import { describe, it, expect, beforeEach } from 'vitest';
import { StatisticsService } from '../service/statistics.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('StatisticsService (FR-STAT-001)', () => {
  let service: StatisticsService;
  const userId = 'stats-user-1';

  beforeEach(() => {
    memoryDb.clear();
    service = new StatisticsService();
  });

  it('aggregates lifetime metrics across quests, gates, bosses, and character progression', async () => {
    // Populate character
    memoryDb.characters.set(userId, {
      id: 'char-1',
      userId,
      level: 3,
      totalXp: 1500,
      currentMana: 85,
      maxMana: 100,
      coins: 50,
      gems: 5,
      rank: 'E',
      activeTitleId: null,
      stats: {
        intelligence: 15,
        discipline: 14,
        fitness: 10,
        creativity: 10,
        coding: 12,
        business: 10,
        health: 10,
      },
      updatedAt: new Date(),
    });

    // Populate quests
    memoryDb.quests.set('q1', {
      id: 'q1',
      userId,
      bossId: null,
      parentQuestId: null,
      title: 'Quest 1',
      description: null,
      questType: 'daily',
      priority: 'medium',
      difficulty: 'medium',
      status: 'completed',
      estimatedMinutes: 30,
      actualMinutes: 25,
      deadline: null,
      recurrenceRule: null,
      tags: [],
      isFavorite: false,
      isPinned: false,
      eisenhowerQuadrant: null,
      completedAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    memoryDb.quests.set('q2', {
      id: 'q2',
      userId,
      bossId: null,
      parentQuestId: null,
      title: 'Quest 2',
      description: null,
      questType: 'main',
      priority: 'high',
      difficulty: 'hard',
      status: 'active',
      estimatedMinutes: 60,
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

    // Populate gates
    memoryDb.gateSessions.set('g1', {
      id: 'g1',
      userId,
      questId: 'q1',
      plannedDurationS: 1800,
      actualDurationS: 1800,
      pauseCount: 0,
      status: 'completed',
      stabilityFinal: 95,
      startedAt: new Date(),
      endedAt: new Date(),
    });

    // Populate screen time
    memoryDb.screenTimeSessions.push({
      id: 'st-1',
      userId,
      appPackage: 'com.instagram.android',
      category: 'high_distraction',
      durationS: 1800, // 30 mins
      occurredAt: new Date(),
      manaModifierApplied: -8,
      createdAt: new Date(),
    });

    const stats = await service.getLifetimeStats(userId);

    expect(stats.quests.total).toBe(2);
    expect(stats.quests.completed).toBe(1);
    expect(stats.quests.completionRatePct).toBe(50);
    expect(stats.quests.totalEstimatedMinutes).toBe(90);

    expect(stats.focus.totalSessions).toBe(1);
    expect(stats.focus.completedSessions).toBe(1);
    expect(stats.focus.totalFocusMinutes).toBe(30);
    expect(stats.focus.successRatePct).toBe(100);

    expect(stats.progression.totalXp).toBe(1500);
    expect(stats.progression.currentMana).toBe(85);

    expect(stats.screenTime.totalMinutes).toBe(30);
    expect(stats.screenTime.manaDeltaNet).toBe(-8);
  });
});
