import { Injectable, Logger } from '@nestjs/common';
import { AnalyticsService } from '../modules/analytics/service/analytics.service';
import { memoryDb } from '../db/memory/memory-db';

@Injectable()
export class AnalyticsRollupJob {
  private readonly logger = new Logger(AnalyticsRollupJob.name);

  constructor(private analyticsService: AnalyticsService) {}

  /**
   * BullMQ scheduled worker for daily/monthly analytics rollups
   */
  async execute(): Promise<{ processedUsersCount: number }> {
    this.logger.debug('Running scheduled analytics snapshot rollups...');
    const users = Array.from(memoryDb.users.values()).filter((u) => !u.deletedAt);

    for (const user of users) {
      try {
        await this.analyticsService.getDailyReport(user.id);
        await this.analyticsService.getMonthlyReport(user.id);
      } catch (err) {
        this.logger.error(`Analytics rollup failed for user ${user.id}: ${(err as Error).message}`);
      }
    }

    this.logger.log(`Analytics rollups completed for ${users.length} users.`);
    return { processedUsersCount: users.length };
  }
}
