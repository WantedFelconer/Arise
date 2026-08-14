import { Injectable, Logger } from '@nestjs/common';
import { memoryDb } from '../db/memory/memory-db';

@Injectable()
export class AccountPurgeJob {
  private readonly logger = new Logger(AccountPurgeJob.name);
  private readonly purgeThresholdDays = 30;

  /**
   * BullMQ worker processor for 30-day PII account purge (NFR-009, NFR-010, FR-AUTH-009)
   */
  async execute(): Promise<{ purgedAccountsCount: number }> {
    this.logger.debug('Running 30-day account deletion PII purge worker...');
    const now = Date.now();
    const thresholdMs = this.purgeThresholdDays * 24 * 60 * 60 * 1000;
    const usersToPurge: string[] = [];

    for (const user of memoryDb.users.values()) {
      if (user.deletedAt && now - user.deletedAt.getTime() >= thresholdMs) {
        usersToPurge.push(user.id);
      }
    }

    let purgedCount = 0;
    for (const userId of usersToPurge) {
      // 1. Delete user profile & settings
      memoryDb.users.delete(userId);
      memoryDb.settings.delete(userId);
      memoryDb.characters.delete(userId);

      // 2. Delete tokens & devices
      for (const [id, token] of memoryDb.refreshTokens.entries()) {
        if (token.userId === userId) memoryDb.refreshTokens.delete(id);
      }

      // 3. Delete quests & bosses & dungeons & gates
      for (const [id, q] of memoryDb.quests.entries()) {
        if (q.userId === userId) memoryDb.quests.delete(id);
      }
      for (const [id, b] of memoryDb.bosses.entries()) {
        if (b.userId === userId) memoryDb.bosses.delete(id);
      }
      for (const [id, d] of memoryDb.dungeons.entries()) {
        if (d.userId === userId) memoryDb.dungeons.delete(id);
      }
      for (const [id, g] of memoryDb.gateSessions.entries()) {
        if (g.userId === userId) memoryDb.gateSessions.delete(id);
      }

      // 4. Delete supporting modules data (screen time, reminders, notes, fitness, notifications)
      memoryDb.screenTimeSessions = memoryDb.screenTimeSessions.filter((s) => s.userId !== userId);
      for (const [id, r] of memoryDb.reminders.entries()) {
        if (r.userId === userId) memoryDb.reminders.delete(id);
      }
      for (const [id, n] of memoryDb.notes.entries()) {
        if (n.userId === userId) memoryDb.notes.delete(id);
      }
      for (const [id, f] of memoryDb.noteFolders.entries()) {
        if (f.userId === userId) memoryDb.noteFolders.delete(id);
      }
      memoryDb.fitnessLogs = memoryDb.fitnessLogs.filter((f) => f.userId !== userId);
      memoryDb.notifications = memoryDb.notifications.filter((n) => n.userId !== userId);

      // 5. Delete AI plans & conversations
      for (const [id, p] of memoryDb.aiGeneratedPlans.entries()) {
        if (p.userId === userId) memoryDb.aiGeneratedPlans.delete(id);
      }
      for (const [id, c] of memoryDb.aiConversations.entries()) {
        if (c.userId === userId) memoryDb.aiConversations.delete(id);
      }

      // 6. Delete achievements & analytics
      for (const [k, ua] of memoryDb.userAchievements.entries()) {
        if (ua.userId === userId) memoryDb.userAchievements.delete(k);
      }
      for (const [k, snap] of memoryDb.analyticsSnapshots.entries()) {
        if (snap.userId === userId) memoryDb.analyticsSnapshots.delete(k);
      }

      purgedCount++;
      this.logger.log(`Account ${userId} permanently purged (PII erased).`);
    }

    return { purgedAccountsCount: purgedCount };
  }
}
