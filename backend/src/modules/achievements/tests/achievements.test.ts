import { describe, it, expect, beforeEach } from 'vitest';
import { AchievementRepository } from '../repository/achievement.repository';
import { AchievementService } from '../service/achievement.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { CharacterService } from '../../character/service/character.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('Achievements Module — Unit & Trigger Suite', () => {
  let achievementRepository: AchievementRepository;
  let achievementService: AchievementService;
  let characterService: CharacterService;
  const testUserId = 'user-ach-test-1';

  beforeEach(async () => {
    memoryDb.clear();
    const charRepo = new CharacterRepository();
    characterService = new CharacterService(charRepo);
    await charRepo.createCharacter({ userId: testUserId });

    achievementRepository = new AchievementRepository();
    achievementService = new AchievementService(achievementRepository, characterService);
  });

  describe('1. Achievement Listing (FR-ACH-001)', () => {
    it('lists available achievements with unlock status', async () => {
      const all = await achievementService.listAchievements(testUserId);
      expect(all.length).toBeGreaterThanOrEqual(3);
      expect(all.every((a) => a.unlocked === false)).toBe(true);
    });
  });

  describe('2. Trigger Evaluation & Unlock Notifications (FR-ACH-001, FR-ACH-002)', () => {
    it('unlocks first quest achievement on quest_complete event and creates notification row', async () => {
      const unlocked = await achievementService.evaluateTriggers(testUserId, {
        eventType: 'quest_complete',
        userId: testUserId,
        payload: { questId: 'q-1' },
      });

      expect(unlocked.length).toBeGreaterThanOrEqual(1);
      expect(unlocked.some((u) => u.code === 'first_quest_completed')).toBe(true);

      // Check user achievements
      const userUnlocks = await achievementService.getUserAchievements(testUserId);
      expect(userUnlocks.length).toBe(1);
      expect(userUnlocks[0]!.code).toBe('first_quest_completed');

      // Check notification created
      const notifications = memoryDb.notifications.filter((n) => n.userId === testUserId);
      expect(notifications.length).toBe(1);
      expect(notifications[0]!.type).toBe('achievement_unlock');

      // Second trigger should NOT duplicate unlock
      const secondTrigger = await achievementService.evaluateTriggers(testUserId, {
        eventType: 'quest_complete',
        userId: testUserId,
        payload: { questId: 'q-2' },
      });
      expect(secondTrigger.length).toBe(0);
    });
  });
});
