import { Injectable, Inject } from '@nestjs/common';
import { AnalyticsRepository } from '../repository/analytics.repository';
import { memoryDb } from '../../../db/memory/memory-db';
import {
  AnalyticsMetrics,
  AnalyticsPeriod,
  AnalyticsSnapshotResponse,
  GenerateSnapshotDto,
} from '../dto/analytics.dto';

@Injectable()
export class AnalyticsService {
  constructor(@Inject(AnalyticsRepository) private analyticsRepository: AnalyticsRepository) {}

  /**
   * Computes metrics for an arbitrary time interval by querying transaction ledgers
   */
  computeMetrics(userId: string, startDate: Date, endDate: Date): AnalyticsMetrics {
    const startTime = startDate.getTime();
    const endTime = endDate.getTime();

    // 1. XP Transactions
    const userXp = memoryDb.xpTransactions.filter(
      (tx) => tx.characterId === userId && tx.createdAt.getTime() >= startTime && tx.createdAt.getTime() <= endTime,
    );
    const totalXpGained = userXp.reduce((acc, tx) => acc + (tx.amount || 0), 0);

    // 2. Mana Transactions
    const userMana = memoryDb.manaTransactions.filter(
      (tx) => tx.characterId === userId && tx.createdAt.getTime() >= startTime && tx.createdAt.getTime() <= endTime,
    );
    const netManaChange = userMana.reduce((acc, tx) => acc + (tx.delta || 0), 0);

    // 3. Quests
    const userQuests = Array.from(memoryDb.quests.values()).filter(
      (q) => q.userId === userId && q.createdAt.getTime() <= endTime,
    );
    const completedInRange = userQuests.filter(
      (q) => q.status === 'completed' && q.completedAt && q.completedAt.getTime() >= startTime && q.completedAt.getTime() <= endTime,
    );
    const questsTotal = userQuests.length;
    const questsCompleted = completedInRange.length;
    const questCompletionRatePct = questsTotal > 0 ? Math.round((questsCompleted / questsTotal) * 100) : 0;

    // 4. Focus / Gate sessions
    const userGates = Array.from(memoryDb.gateSessions.values()).filter(
      (g) => g.userId === userId && g.startedAt.getTime() >= startTime && g.startedAt.getTime() <= endTime,
    );
    const completedGates = userGates.filter((g) => g.status === 'completed' || g.status === 'cleared');
    const totalDurationS = userGates.reduce((acc, g) => acc + (g.actualDurationS || g.plannedDurationS || 0), 0);
    const focusMinutes = Math.round(totalDurationS / 60);
    const gateSuccessRatePct = userGates.length > 0 ? Math.round((completedGates.length / userGates.length) * 100) : 0;

    // 5. Screen Time
    const userScreen = memoryDb.screenTimeSessions.filter(
      (s) => s.userId === userId && s.occurredAt.getTime() >= startTime && s.occurredAt.getTime() <= endTime,
    );
    const totalScreenS = userScreen.reduce((acc, s) => acc + s.durationS, 0);
    const screenTimeMinutes = Math.round(totalScreenS / 60);
    const screenTimeManaImpact = userScreen.reduce((acc, s) => acc + (s.manaModifierApplied || 0), 0);

    // 6. Fitness
    const userFitness = memoryDb.fitnessLogs.filter(
      (f) => f.userId === userId && f.recordedAt.getTime() >= startTime && f.recordedAt.getTime() <= endTime,
    );
    const steps = userFitness.filter((f) => f.logType === 'steps').reduce((acc, f) => acc + f.value, 0);
    const workoutMinutes = userFitness
      .filter((f) => f.logType === 'workout' || f.logType === 'exercise')
      .reduce((acc, f) => acc + f.value, 0);
    const waterMl = userFitness.filter((f) => f.logType === 'water').reduce((acc, f) => acc + f.value, 0);

    return {
      totalXpGained,
      netManaChange,
      focusMinutes,
      gateSessionsCount: userGates.length,
      gateSuccessRatePct,
      questsCompleted,
      questsTotal,
      questCompletionRatePct,
      screenTimeMinutes,
      screenTimeManaImpact,
      fitnessSummary: {
        steps,
        workoutMinutes,
        waterMl,
      },
    };
  }

  async getDailyReport(userId: string, dateStr?: string): Promise<AnalyticsSnapshotResponse> {
    const targetDate = dateStr ? new Date(dateStr) : new Date();
    const startOfDay = new Date(Date.UTC(targetDate.getUTCFullYear(), targetDate.getUTCMonth(), targetDate.getUTCDate(), 0, 0, 0));
    const endOfDay = new Date(Date.UTC(targetDate.getUTCFullYear(), targetDate.getUTCMonth(), targetDate.getUTCDate(), 23, 59, 59, 999));

    const metrics = this.computeMetrics(userId, startOfDay, endOfDay);
    const snapshot = await this.analyticsRepository.saveSnapshot(userId, 'daily', startOfDay, metrics);

    return {
      id: snapshot.id,
      userId: snapshot.userId,
      period: 'daily',
      periodStart: snapshot.periodStart,
      metrics: snapshot.metrics as unknown as AnalyticsMetrics,
      aiSummary: snapshot.aiSummary,
      createdAt: snapshot.createdAt,
    };
  }

  async getWeeklyReport(userId: string, startDateStr?: string): Promise<AnalyticsSnapshotResponse> {
    const targetDate = startDateStr ? new Date(startDateStr) : new Date();
    const startOfWeek = new Date(Date.UTC(targetDate.getUTCFullYear(), targetDate.getUTCMonth(), targetDate.getUTCDate(), 0, 0, 0));
    const endOfWeek = new Date(startOfWeek.getTime() + 7 * 24 * 60 * 60 * 1000 - 1);

    const metrics = this.computeMetrics(userId, startOfWeek, endOfWeek);
    const snapshot = await this.analyticsRepository.saveSnapshot(userId, 'weekly', startOfWeek, metrics);

    return {
      id: snapshot.id,
      userId: snapshot.userId,
      period: 'weekly',
      periodStart: snapshot.periodStart,
      metrics: snapshot.metrics as unknown as AnalyticsMetrics,
      aiSummary: snapshot.aiSummary,
      createdAt: snapshot.createdAt,
    };
  }

  async getMonthlyReport(userId: string, yearStr?: string, monthStr?: string): Promise<AnalyticsSnapshotResponse> {
    const now = new Date();
    const year = yearStr ? parseInt(yearStr, 10) : now.getUTCFullYear();
    const month = monthStr ? parseInt(monthStr, 10) - 1 : now.getUTCMonth();

    const startOfMonth = new Date(Date.UTC(year, month, 1, 0, 0, 0));
    const endOfMonth = new Date(Date.UTC(year, month + 1, 0, 23, 59, 59, 999));

    const metrics = this.computeMetrics(userId, startOfMonth, endOfMonth);
    const snapshot = await this.analyticsRepository.saveSnapshot(userId, 'monthly', startOfMonth, metrics);

    return {
      id: snapshot.id,
      userId: snapshot.userId,
      period: 'monthly',
      periodStart: snapshot.periodStart,
      metrics: snapshot.metrics as unknown as AnalyticsMetrics,
      aiSummary: snapshot.aiSummary,
      createdAt: snapshot.createdAt,
    };
  }

  async getYearlyReport(userId: string, yearStr?: string): Promise<AnalyticsSnapshotResponse> {
    const now = new Date();
    const year = yearStr ? parseInt(yearStr, 10) : now.getUTCFullYear();

    const startOfYear = new Date(Date.UTC(year, 0, 1, 0, 0, 0));
    const endOfYear = new Date(Date.UTC(year, 11, 31, 23, 59, 59, 999));

    const metrics = this.computeMetrics(userId, startOfYear, endOfYear);
    const snapshot = await this.analyticsRepository.saveSnapshot(userId, 'yearly', startOfYear, metrics);

    return {
      id: snapshot.id,
      userId: snapshot.userId,
      period: 'yearly',
      periodStart: snapshot.periodStart,
      metrics: snapshot.metrics as unknown as AnalyticsMetrics,
      aiSummary: snapshot.aiSummary,
      createdAt: snapshot.createdAt,
    };
  }

  async generateSnapshot(userId: string, dto: GenerateSnapshotDto): Promise<AnalyticsSnapshotResponse> {
    if (dto.period === 'daily') return this.getDailyReport(userId, dto.periodStart);
    if (dto.period === 'weekly') return this.getWeeklyReport(userId, dto.periodStart);
    if (dto.period === 'monthly') {
      const d = new Date(dto.periodStart);
      return this.getMonthlyReport(userId, String(d.getUTCFullYear()), String(d.getUTCMonth() + 1));
    }
    return this.getYearlyReport(userId, dto.periodStart.slice(0, 4));
  }

  async listSnapshots(userId: string, period?: AnalyticsPeriod): Promise<AnalyticsSnapshotResponse[]> {
    const snapshots = await this.analyticsRepository.listSnapshots(userId, period);
    return snapshots.map((s) => ({
      id: s.id,
      userId: s.userId,
      period: s.period as AnalyticsPeriod,
      periodStart: s.periodStart,
      metrics: s.metrics as unknown as AnalyticsMetrics,
      aiSummary: s.aiSummary,
      createdAt: s.createdAt,
    }));
  }
}
