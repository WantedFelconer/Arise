import { Injectable, Inject, Optional } from '@nestjs/common';
import { AchievementRepository } from '../repository/achievement.repository';
import { CharacterService } from '../../character/service/character.service';
import { AchievementResponse, AchievementTriggerEvent } from '../dto/achievement.dto';

@Injectable()
export class AchievementService {
  constructor(
    @Inject(AchievementRepository) private achievementRepository: AchievementRepository,
    @Optional() @Inject(CharacterService) private characterService?: CharacterService,
  ) {}

  async listAchievements(userId?: string): Promise<AchievementResponse[]> {
    const all = await this.achievementRepository.findAll();
    const userUnlocksMap = new Map<string, Date>();

    if (userId) {
      const userUnlocks = await this.achievementRepository.findUserUnlocks(userId);
      for (const u of userUnlocks) {
        userUnlocksMap.set(u.achievementId, u.unlockedAt);
      }
    }

    return all.map((ach) => ({
      id: ach.id,
      code: ach.code,
      title: ach.title,
      description: ach.description,
      category: ach.category,
      xpReward: ach.xpReward,
      badgeAssetUrl: ach.badgeAssetUrl,
      criteria:
        ((ach as unknown as Record<string, unknown>).criteria as Record<string, unknown>) || {},
      unlocked: userId ? userUnlocksMap.has(ach.id) : false,
      unlockedAt: userId ? userUnlocksMap.get(ach.id) || null : null,
    }));
  }

  async getUserAchievements(userId: string): Promise<AchievementResponse[]> {
    const userUnlocks = await this.achievementRepository.findUserUnlocks(userId);
    return userUnlocks.map((u) => ({
      id: u.achievement.id,
      code: u.achievement.code,
      title: u.achievement.title,
      description: u.achievement.description,
      category: u.achievement.category,
      xpReward: u.achievement.xpReward,
      badgeAssetUrl: u.achievement.badgeAssetUrl,
      criteria:
        ((u.achievement as unknown as Record<string, unknown>).criteria as Record<
          string,
          unknown
        >) || {},
      unlocked: true,
      unlockedAt: u.unlockedAt,
    }));
  }

  /**
   * FR-ACH-001 & FR-ACH-002:
   * Evaluate machine-evaluable rules on events (quest_complete, gate_clear, boss_defeat).
   * Unlocks matching achievements, generates notification record, awards XP.
   */
  async evaluateTriggers(
    userId: string,
    event: AchievementTriggerEvent,
  ): Promise<AchievementResponse[]> {
    const allAchievements = await this.achievementRepository.findAll();
    const unlocked: AchievementResponse[] = [];

    for (const ach of allAchievements) {
      const alreadyUnlocked = await this.achievementRepository.isUnlocked(userId, ach.id);
      if (alreadyUnlocked) continue;

      const criteria =
        ((ach as unknown as Record<string, unknown>).criteria as Record<string, unknown>) || {};
      const matches = this.evaluateCriteria(criteria, event);

      if (matches) {
        const unlockRecord = await this.achievementRepository.recordUnlock(userId, ach.id);

        // FR-ACH-002: Generate notifications row
        await this.achievementRepository.createNotification({
          userId,
          title: `Achievement Unlocked: ${ach.title}`,
          message: ach.description,
          type: 'achievement_unlock',
          data: {
            achievementId: ach.id,
            code: ach.code,
            xpReward: ach.xpReward,
          },
        });

        // Award achievement XP if configured
        if (ach.xpReward > 0 && this.characterService) {
          try {
            await this.characterService.awardXp(userId, {
              amount: ach.xpReward,
              sourceType: 'bonus',
              sourceId: ach.id,
              reason: `Achievement unlocked: ${ach.title}`,
            });
          } catch {
            // CharacterService error should not break the trigger evaluation
          }
        }

        unlocked.push({
          id: ach.id,
          code: ach.code,
          title: ach.title,
          description: ach.description,
          category: ach.category,
          xpReward: ach.xpReward,
          badgeAssetUrl: ach.badgeAssetUrl,
          criteria,
          unlocked: true,
          unlockedAt: unlockRecord.unlockedAt,
        });
      }
    }

    return unlocked;
  }

  private evaluateCriteria(
    criteria: Record<string, unknown>,
    event: AchievementTriggerEvent,
  ): boolean {
    if (!criteria || Object.keys(criteria).length === 0) return false;

    // Match event type if specified
    if (criteria.event && criteria.event !== event.eventType) {
      return false;
    }

    // Match minimum stability percentage for gate
    if (criteria.minStability !== undefined) {
      if (typeof event.payload?.stabilityPct !== 'number' || event.payload.stabilityPct < (criteria.minStability as number)) {
        return false;
      }
    }

    // Match minimum duration
    if (criteria.minDurationS !== undefined) {
      if (typeof event.payload?.durationS !== 'number' || event.payload.durationS < (criteria.minDurationS as number)) {
        return false;
      }
    }

    // Match minimum streak
    if (criteria.minStreak !== undefined) {
      if (typeof event.payload?.streak !== 'number' || event.payload.streak < (criteria.minStreak as number)) {
        return false;
      }
    }

    // Match minimum quests completed count
    if (criteria.minQuestsCompleted !== undefined) {
      if (typeof event.payload?.questsCompletedCount !== 'number' || event.payload.questsCompletedCount < (criteria.minQuestsCompleted as number)) {
        return false;
      }
    }

    // Match minimum gates cleared count
    if (criteria.minGatesCleared !== undefined) {
      if (typeof event.payload?.gatesClearedCount !== 'number' || event.payload.gatesClearedCount < (criteria.minGatesCleared as number)) {
        return false;
      }
    }

    // Match minimum bosses defeated count
    if (criteria.minBossesDefeated !== undefined) {
      if (typeof event.payload?.bossesDefeatedCount !== 'number' || event.payload.bossesDefeatedCount < (criteria.minBossesDefeated as number)) {
        return false;
      }
    }

    // Match minimum level
    if (criteria.minLevel !== undefined) {
      if (typeof event.payload?.level !== 'number' || event.payload.level < (criteria.minLevel as number)) {
        return false;
      }
    }

    return true;
  }
}

