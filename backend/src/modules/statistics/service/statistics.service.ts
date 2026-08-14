import { Injectable } from '@nestjs/common';
import { memoryDb } from '../../../db/memory/memory-db';
import { RpgEngine } from '../../../core/rpg-engine';
import { LifetimeStatsResponse } from '../dto/statistics.dto';

@Injectable()
export class StatisticsService {
  /**
   * FR-STAT-001: Aggregates lifetime stats across all historical tables for a user
   */
  async getLifetimeStats(userId: string): Promise<LifetimeStatsResponse> {
    // 1. Quests stats
    const userQuests = Array.from(memoryDb.quests.values()).filter((q) => q.userId === userId);
    const completedQuests = userQuests.filter((q) => q.status === 'completed');
    const activeQuests = userQuests.filter((q) => q.status === 'active' || q.status === 'in_progress');
    const trashedQuests = userQuests.filter((q) => q.status === 'trashed');

    const totalQuests = userQuests.length;
    const completionRatePct =
      totalQuests > 0 ? Math.round((completedQuests.length / totalQuests) * 100) : 0;

    const totalEstimatedMinutes = userQuests.reduce((acc, q) => acc + (q.estimatedMinutes || 0), 0);
    const totalActualMinutes = userQuests.reduce((acc, q) => acc + (q.actualMinutes || 0), 0);

    // 2. Focus / Gate stats
    const userGates = Array.from(memoryDb.gateSessions.values()).filter((g) => g.userId === userId);
    const completedGates = userGates.filter((g) => g.status === 'completed' || g.status === 'cleared');
    const collapsedGates = userGates.filter((g) => g.status === 'collapsed');

    const totalGateDurationS = userGates.reduce(
      (acc, g) => acc + (g.actualDurationS || g.plannedDurationS || 0),
      0,
    );
    const totalFocusMinutes = Math.round(totalGateDurationS / 60);

    const gateSuccessRatePct =
      userGates.length > 0 ? Math.round((completedGates.length / userGates.length) * 100) : 0;

    const stabilitySum = userGates.reduce((acc, g) => acc + (g.stabilityFinal || 100), 0);
    const averageStabilityPct =
      userGates.length > 0 ? Math.round(stabilitySum / userGates.length) : 100;

    // 3. Bosses & Dungeons
    const userBosses = Array.from(memoryDb.bosses.values()).filter((b) => b.userId === userId);
    const defeatedBosses = userBosses.filter((b) => b.status === 'defeated');
    const activeBosses = userBosses.filter((b) => b.status === 'active');

    const userDungeons = Array.from(memoryDb.dungeons.values()).filter((d) => d.userId === userId);
    const completedDungeons = userDungeons.filter((d) => d.status === 'completed');
    const activeDungeons = userDungeons.filter((d) => d.status === 'active');

    // 4. Progression & Streaks
    const character = memoryDb.characters.get(userId);
    const totalXp = character?.totalXp || 0;
    const level = character?.level || RpgEngine.calculateLevel(totalXp);
    const rank = character?.rank || RpgEngine.calculateRank(level);
    const currentMana = character?.currentMana ?? 100;
    const maxMana = character?.maxMana ?? 100;

    // Collect all completion dates (from completed quests, gates, and xp transactions)
    const completionDates: Date[] = [];
    for (const q of completedQuests) {
      if (q.completedAt) completionDates.push(q.completedAt);
    }
    for (const g of completedGates) {
      if (g.endedAt) completionDates.push(g.endedAt);
      else if (g.startedAt) completionDates.push(g.startedAt);
    }

    const { currentStreak, longestStreak } = RpgEngine.calculateStreakFromDates(completionDates);

    // 5. Screen Time
    const userScreenTime = memoryDb.screenTimeSessions.filter((s) => s.userId === userId);
    const totalScreenDurationS = userScreenTime.reduce((acc, s) => acc + s.durationS, 0);
    const screenTimeManaNet = userScreenTime.reduce((acc, s) => acc + (s.manaModifierApplied || 0), 0);

    // 6. Fitness
    const userFitness = memoryDb.fitnessLogs.filter((f) => f.userId === userId);
    const totalSteps = userFitness
      .filter((f) => f.logType === 'steps')
      .reduce((acc, f) => acc + f.value, 0);
    const totalWorkoutMinutes = userFitness
      .filter((f) => f.logType === 'workout' || f.logType === 'exercise')
      .reduce((acc, f) => acc + f.value, 0);

    return {
      quests: {
        total: totalQuests,
        completed: completedQuests.length,
        active: activeQuests.length,
        trashed: trashedQuests.length,
        completionRatePct,
        totalEstimatedMinutes,
        totalActualMinutes,
      },
      focus: {
        totalSessions: userGates.length,
        completedSessions: completedGates.length,
        collapsedSessions: collapsedGates.length,
        totalFocusMinutes,
        successRatePct: gateSuccessRatePct,
        averageStabilityPct,
      },
      bosses: {
        total: userBosses.length,
        active: activeBosses.length,
        defeated: defeatedBosses.length,
      },
      dungeons: {
        total: userDungeons.length,
        active: activeDungeons.length,
        completed: completedDungeons.length,
      },
      progression: {
        level,
        rank,
        totalXp,
        currentMana,
        maxMana,
        currentStreak,
        longestStreak,
      },
      screenTime: {
        totalMinutes: Math.round(totalScreenDurationS / 60),
        manaDeltaNet: screenTimeManaNet,
      },
      fitness: {
        totalLogs: userFitness.length,
        totalSteps,
        totalWorkoutMinutes,
      },
    };
  }
}
