import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { memoryDb, StoredAnalyticsSnapshot } from '../../../db/memory/memory-db';
import { AnalyticsMetrics, AnalyticsPeriod } from '../dto/analytics.dto';

@Injectable()
export class AnalyticsRepository {
  async saveSnapshot(
    userId: string,
    period: AnalyticsPeriod,
    periodStart: Date,
    metrics: AnalyticsMetrics,
    aiSummary: string | null = null,
  ): Promise<StoredAnalyticsSnapshot> {
    const key = `${userId}:${period}:${periodStart.toISOString().split('T')[0]}`;
    const existing = memoryDb.analyticsSnapshots.get(key);

    const snapshot: StoredAnalyticsSnapshot = {
      id: existing?.id || uuidv4(),
      userId,
      period,
      periodStart,
      metrics: metrics as unknown as Record<string, unknown>,
      aiSummary: aiSummary ?? existing?.aiSummary ?? null,
      createdAt: existing?.createdAt || new Date(),
    };

    memoryDb.analyticsSnapshots.set(key, snapshot);
    return snapshot;
  }

  async findSnapshot(
    userId: string,
    period: AnalyticsPeriod,
    periodStart: Date,
  ): Promise<StoredAnalyticsSnapshot | null> {
    const key = `${userId}:${period}:${periodStart.toISOString().split('T')[0]}`;
    return memoryDb.analyticsSnapshots.get(key) || null;
  }

  async listSnapshots(userId: string, period?: AnalyticsPeriod): Promise<StoredAnalyticsSnapshot[]> {
    let items = Array.from(memoryDb.analyticsSnapshots.values()).filter((s) => s.userId === userId);
    if (period) {
      items = items.filter((s) => s.period === period);
    }
    items.sort((a, b) => b.periodStart.getTime() - a.periodStart.getTime());
    return items;
  }

  async deleteByUserId(userId: string): Promise<number> {
    let count = 0;
    for (const [k, v] of memoryDb.analyticsSnapshots.entries()) {
      if (v.userId === userId) {
        memoryDb.analyticsSnapshots.delete(k);
        count++;
      }
    }
    return count;
  }
}
