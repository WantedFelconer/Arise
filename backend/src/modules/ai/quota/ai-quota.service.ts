import {
  Injectable,
  Optional,
  HttpException,
  HttpStatus,
  ForbiddenException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { memoryDb } from '../../../db/memory/memory-db';

@Injectable()
export class AiQuotaService {
  private readonly defaultDailyQuota: number;
  private readonly userLocks = new Map<string, Promise<void>>();

  constructor(@Optional() private readonly configService?: ConfigService) {
    this.defaultDailyQuota = 50;
  }

  private getLimit(): number {
    if (this.configService) {
      const internal = (this.configService as any)?.internalConfig?.AI_DAILY_QUOTA;
      if (internal !== undefined) return Number(internal);
    }
    if (process.env.AI_DAILY_QUOTA) {
      return parseInt(process.env.AI_DAILY_QUOTA, 10);
    }
    return this.defaultDailyQuota;
  }

  private getTodayKey(userId: string): string {
    const today = new Date().toISOString().split('T')[0];
    return `${userId}:${today}`;
  }

  private getNextUtcMidnight(): Date {
    const tomorrow = new Date();
    tomorrow.setUTCHours(24, 0, 0, 0);
    return tomorrow;
  }

  /**
   * Acquire a per-user async mutex to ensure concurrency-safe atomic operations.
   */
  private async acquireLock(userId: string): Promise<() => void> {
    while (this.userLocks.has(userId)) {
      await this.userLocks.get(userId);
    }
    let resolveLock!: () => void;
    const lockPromise = new Promise<void>((resolve) => {
      resolveLock = resolve;
    });
    this.userLocks.set(userId, lockPromise);

    return () => {
      this.userLocks.delete(userId);
      resolveLock();
    };
  }

  /**
   * Check if a feature flag is enabled for the user or globally.
   * Forward-compatible non-billing scaffolding per §10.5 / ADR 0001.
   */
  async checkFeatureFlag(userId: string, feature: 'planner' | 'coach'): Promise<void> {
    const specificKey = `ai_${feature}_enabled`;
    const globalKey = 'ai_enabled';

    // 1. Check user-specific flag
    for (const flag of memoryDb.featureFlags.values()) {
      if (flag.userId === userId && flag.flagKey === specificKey && !flag.enabled) {
        throw new ForbiddenException({
          statusCode: HttpStatus.FORBIDDEN,
          error: 'Forbidden',
          message: `AI ${feature} feature is disabled for your account`,
          code: 'FEATURE_DISABLED',
        });
      }
      if (flag.userId === userId && flag.flagKey === globalKey && !flag.enabled) {
        throw new ForbiddenException({
          statusCode: HttpStatus.FORBIDDEN,
          error: 'Forbidden',
          message: 'AI features are currently disabled for your account',
          code: 'FEATURE_DISABLED',
        });
      }
    }

    // 2. Check global system flag
    for (const flag of memoryDb.featureFlags.values()) {
      if (flag.userId === null && flag.flagKey === specificKey && !flag.enabled) {
        throw new ForbiddenException({
          statusCode: HttpStatus.FORBIDDEN,
          error: 'Forbidden',
          message: `AI ${feature} feature is temporarily disabled globally`,
          code: 'FEATURE_DISABLED',
        });
      }
      if (flag.userId === null && flag.flagKey === globalKey && !flag.enabled) {
        throw new ForbiddenException({
          statusCode: HttpStatus.FORBIDDEN,
          error: 'Forbidden',
          message: 'AI features are temporarily disabled globally',
          code: 'FEATURE_DISABLED',
        });
      }
    }
  }

  /**
   * Check and atomically increment the user's daily AI quota.
   * Throws 429 AI_DAILY_QUOTA_EXCEEDED if quota limit is reached.
   */
  async checkAndIncrement(
    userId: string,
    feature: 'planner' | 'coach',
  ): Promise<{ allowed: boolean; remaining: number; resetAt: Date }> {
    // 1. Check feature flags first
    await this.checkFeatureFlag(userId, feature);

    // 2. Acquire user lock for atomic check-and-increment
    const releaseLock = await this.acquireLock(userId);

    try {
      const key = this.getTodayKey(userId);
      const today = new Date().toISOString().split('T')[0] || '';
      const limit = this.getLimit();

      let record = memoryDb.dailyAiUsage.get(key);
      if (!record) {
        record = {
          key,
          userId,
          date: today,
          count: 0,
        };
        memoryDb.dailyAiUsage.set(key, record);
      }

      const activeRecord = record;
      if (activeRecord.count >= limit) {
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            error: 'Too Many Requests',
            message: `Daily AI quota limit of ${limit} requests reached. Quota resets at UTC midnight.`,
            code: 'AI_DAILY_QUOTA_EXCEEDED',
            resetAt: this.getNextUtcMidnight().toISOString(),
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      // Atomically increment counter
      activeRecord.count += 1;
      const remaining = Math.max(0, limit - activeRecord.count);

      return {
        allowed: true,
        remaining,
        resetAt: this.getNextUtcMidnight(),
      };
    } finally {
      releaseLock();
    }
  }

  /**
   * Retrieve current quota status without incrementing.
   */
  async getQuotaStatus(userId: string): Promise<{
    usedToday: number;
    dailyLimit: number;
    remaining: number;
    resetAt: Date;
  }> {
    const key = this.getTodayKey(userId);
    const limit = this.getLimit();
    const record = memoryDb.dailyAiUsage.get(key);
    const usedToday = record ? record.count : 0;

    return {
      usedToday,
      dailyLimit: limit,
      remaining: Math.max(0, limit - usedToday),
      resetAt: this.getNextUtcMidnight(),
    };
  }

  /**
   * Set or update a feature flag (for testing or admin controls).
   */
  setFeatureFlag(flagKey: string, enabled: boolean, userId: string | null = null): void {
    const id = `${userId || 'global'}_${flagKey}`;
    memoryDb.featureFlags.set(id, {
      id,
      userId,
      flagKey,
      enabled,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  }

  /**
   * Reset quota counter for a user (for testing).
   */
  resetQuota(userId: string): void {
    const key = this.getTodayKey(userId);
    memoryDb.dailyAiUsage.delete(key);
  }
}
