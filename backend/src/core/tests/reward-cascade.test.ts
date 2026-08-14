import { describe, it, expect, beforeEach } from 'vitest';
import { RewardCascadeService } from '../reward-cascade';
import { CharacterRepository } from '../../modules/character/repository/character.repository';
import { CharacterService } from '../../modules/character/service/character.service';
import { BossRepository } from '../../modules/bosses/repository/boss.repository';
import { BossService } from '../../modules/bosses/service/boss.service';
import { AchievementRepository } from '../../modules/achievements/repository/achievement.repository';
import { AchievementService } from '../../modules/achievements/service/achievement.service';
import { QuestRepository } from '../../modules/quests/repository/quest.repository';
import { memoryDb } from '../../db/memory/memory-db';

describe('Centralized Reward Cascade — Unit Suite (§8.4, NFR-005, §17.3 Rule 5)', () => {
  let rewardCascadeService: RewardCascadeService;
  let characterService: CharacterService;
  let bossService: BossService;
  let questRepository: QuestRepository;
  const testUserId = 'user-cascade-test-1';

  beforeEach(async () => {
    memoryDb.clear();

    const charRepo = new CharacterRepository();
    characterService = new CharacterService(charRepo);
    await charRepo.createCharacter({ userId: testUserId });

    const bossRepo = new BossRepository();
    bossService = new BossService(bossRepo);

    const achRepo = new AchievementRepository();
    const achievementService = new AchievementService(achRepo, characterService);

    questRepository = new QuestRepository();
    rewardCascadeService = new RewardCascadeService(
      characterService,
      bossService,
      achievementService,
      questRepository,
    );
  });

  describe('1. Quest Reward Cascade Execution', () => {
    it('applies XP, Mana, Boss Damage, and marks quest completed in a single flow', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Midterm Boss',
        hpMax: 200,
        difficulty: 'medium',
      });

      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Study Chapter 1',
        estimatedMinutes: 50,
        difficulty: 'medium',
        priority: 'medium',
        bossId: boss.id,
      });

      const result = await rewardCascadeService.executeQuestRewardCascade(testUserId, quest.id);

      expect(result.quest.status).toBe('completed');
      expect(result.xpAwarded).toBe(50);
      expect(result.manaDelta).toBe(5);
      expect(result.bossDamage).toBeGreaterThan(0);

      // Check Boss HP reduced
      const updatedBoss = await bossService.getBoss(testUserId, boss.id);
      expect(updatedBoss.hpCurrent).toBe(200 - result.bossDamage!);

      // Check Character state (50 quest XP + 50 first_quest_completed achievement bonus)
      const char = await characterService.getCharacter(testUserId);
      expect(char.totalXp).toBe(100);
      expect(char.currentMana).toBe(100); // 100 max clamped
    });

    it('rejects duplicate completion with 409 Conflict (§17.3 Rule 5)', async () => {
      const quest = await questRepository.create({
        userId: testUserId,
        title: 'One-time Task',
      });

      await rewardCascadeService.executeQuestRewardCascade(testUserId, quest.id);

      // Duplicate attempt
      await expect(
        rewardCascadeService.executeQuestRewardCascade(testUserId, quest.id),
      ).rejects.toThrow(/already been completed/i);
    });
  });

  describe('2. Gate Clear & Collapse Cascade Execution', () => {
    it('executes gate clear with XP award and achievement triggers', async () => {
      const session = {
        id: 'gate-sess-1',
        userId: testUserId,
        questId: null,
        plannedDurationS: 1500,
        actualDurationS: 1500,
        pauseCount: 0,
        status: 'active',
        stabilityFinal: null,
        xpAwarded: null,
        manaDelta: null,
        exitReason: null,
        deviceId: null,
        clientEventId: null,
        startedAt: new Date(Date.now() - 1500000),
        pausedAt: null,
        totalPausedDurationS: 0,
        endedAt: null,
      };

      const result = await rewardCascadeService.executeGateClearRewardCascade(
        testUserId,
        session,
        100,
      );

      expect(result.xpDelta).toBeGreaterThan(0);
      expect(result.manaDelta).toBe(10);
    });

    it('executes gate collapse applying negative XP and Mana ledger entries in hardcore mode', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Project Alpha',
        hpMax: 100,
      });
      // Damage boss first so it can recover
      await bossService.applyDamage(testUserId, boss.id, 50);

      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Linked Quest',
        bossId: boss.id,
      });

      const session = {
        id: 'gate-sess-2',
        userId: testUserId,
        questId: quest.id,
        plannedDurationS: 1500,
        actualDurationS: 600,
        pauseCount: 0,
        status: 'active',
        stabilityFinal: null,
        xpAwarded: null,
        manaDelta: null,
        exitReason: null,
        deviceId: null,
        clientEventId: null,
        startedAt: new Date(),
        pausedAt: null,
        totalPausedDurationS: 0,
        endedAt: null,
      };

      const result = await rewardCascadeService.executeGateCollapseRewardCascade(
        testUserId,
        session,
        'hardcore',
      );

      expect(result.xpDelta).toBeLessThan(0);
      expect(result.manaDelta).toBeLessThan(0);
      expect(result.bossRecovered).toBe(true);

      // Check Boss HP recovered
      const bossAfter = await bossService.getBoss(testUserId, boss.id);
      expect(bossAfter.hpCurrent).toBeGreaterThan(50);
    });
  });
});
