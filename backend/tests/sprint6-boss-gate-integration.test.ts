import { describe, it, expect, beforeEach } from 'vitest';
import { RewardCascadeService } from '../src/core/reward-cascade';
import { CharacterRepository } from '../src/modules/character/repository/character.repository';
import { CharacterService } from '../src/modules/character/service/character.service';
import { BossRepository } from '../src/modules/bosses/repository/boss.repository';
import { BossService } from '../src/modules/bosses/service/boss.service';
import { GateRepository } from '../src/modules/gates/repository/gate.repository';
import { GateService } from '../src/modules/gates/service/gate.service';
import { AchievementRepository } from '../src/modules/achievements/repository/achievement.repository';
import { AchievementService } from '../src/modules/achievements/service/achievement.service';
import { QuestRepository } from '../src/modules/quests/repository/quest.repository';
import { QuestService } from '../src/modules/quests/service/quest.service';
import { memoryDb } from '../src/db/memory/memory-db';

describe('Sprint A6 — Boss, Dungeon & Gate Integration Verification Suite', () => {
  let characterService: CharacterService;
  let bossService: BossService;
  let gateService: GateService;
  let questService: QuestService;
  let rewardCascadeService: RewardCascadeService;
  let questRepository: QuestRepository;
  let bossRepository: BossRepository;
  let gateRepository: GateRepository;
  const testUserId = 'user-sprint6-test-1';

  beforeEach(async () => {
    memoryDb.clear();

    const charRepo = new CharacterRepository();
    characterService = new CharacterService(charRepo);
    await charRepo.createCharacter({ userId: testUserId });

    bossRepository = new BossRepository();
    bossService = new BossService(bossRepository);

    const achRepo = new AchievementRepository();
    const achievementService = new AchievementService(achRepo, characterService);

    questRepository = new QuestRepository();
    gateRepository = new GateRepository();

    rewardCascadeService = new RewardCascadeService(
      characterService,
      bossService,
      achievementService,
      questRepository,
    );

    questService = new QuestService(
      questRepository,
      bossService,
      characterService,
      rewardCascadeService,
    );

    gateService = new GateService(
      gateRepository,
      questService,
      rewardCascadeService,
    );
  });

  describe('1. Quest Completion → Reward Cascade → Boss Damage & Defeat Flow', () => {
    it('damages Boss HP, awards XP/Mana, and updates character state upon quest completion', async () => {
      // 1. Create a Boss
      const boss = await bossService.createBoss(testUserId, {
        title: 'Midterm Exam Project',
        hpMax: 500,
        difficulty: 'hard',
      });
      expect(boss.hpCurrent).toBe(500);
      expect(boss.status).toBe('active');

      // 2. Create linked quest
      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Review Chapter 1-5',
        estimatedMinutes: 60,
        difficulty: 'hard',
        priority: 'high',
        bossId: boss.id,
        status: 'pending',
      });

      // 3. Complete quest via Reward Cascade
      const cascadeResult = await rewardCascadeService.executeQuestRewardCascade(
        testUserId,
        quest.id,
      );

      expect(cascadeResult.quest.status).toBe('completed');
      expect(cascadeResult.xpAwarded).toBe(90); // 60 * 1.5 multiplier
      expect(cascadeResult.manaDelta).toBe(5);
      expect(cascadeResult.bossDamage).toBeGreaterThan(0);

      // 4. Verify authoritative Boss HP reduction
      const updatedBoss = await bossService.getBoss(testUserId, boss.id);
      expect(updatedBoss.hpCurrent).toBe(500 - cascadeResult.bossDamage!);
      expect(updatedBoss.status).toBe('active');
    });

    it('marks Boss defeated, emits rewards, and triggers boss_defeat achievement when HP reaches 0', async () => {
      // Create Boss with small HP
      const boss = await bossService.createBoss(testUserId, {
        title: 'Mini Final Boss',
        hpMax: 10,
        difficulty: 'medium',
      });

      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Final Submission',
        estimatedMinutes: 60,
        difficulty: 'epic',
        priority: 'high',
        bossId: boss.id,
        status: 'pending',
      });

      const cascadeResult = await rewardCascadeService.executeQuestRewardCascade(
        testUserId,
        quest.id,
      );

      expect(cascadeResult.bossDefeated).toBe(true);
      expect(cascadeResult.bossRewards).toBeDefined();
      expect(cascadeResult.bossRewards!.xp).toBeGreaterThan(0);

      const defeatedBoss = await bossService.getBoss(testUserId, boss.id);
      expect(defeatedBoss.hpCurrent).toBe(0);
      expect(defeatedBoss.status).toBe('defeated');
      expect(defeatedBoss.defeatedAt).toBeDefined();

      // Defeated boss shows up in boss history
      const history = await bossService.getBossHistory(testUserId);
      expect(history.length).toBe(1);
      expect(history[0]!.title).toBe('Mini Final Boss');
    });
  });

  describe('2. Gate Expedition → Complete → Reward Cascade Flow', () => {
    it('awards Gate clear XP, restores Mana, and damages linked boss upon 100% stability clear', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Dungeon Master Boss',
        hpMax: 300,
        difficulty: 'medium',
      });

      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Deep Focus Coding',
        estimatedMinutes: 30,
        difficulty: 'medium',
        bossId: boss.id,
        status: 'pending',
      });

      // Start gate session linked to quest
      const session = await gateService.startSession(testUserId, {
        questId: quest.id,
        plannedDurationSeconds: 1500, // 25 mins
      });

      expect(session.id).toBeDefined();
      expect(session.status).toBe('active');
      expect(session.questId).toBe(quest.id);

      // Simulate completion via Gate Clear Reward Cascade
      const storedSession = (await gateRepository.findById(session.id, testUserId))!;
      const cascadeResult = await rewardCascadeService.executeGateClearRewardCascade(
        testUserId,
        storedSession,
        100,
      );

      expect(cascadeResult.xpDelta).toBeGreaterThan(0);
      expect(cascadeResult.manaDelta).toBeGreaterThan(0);
      expect(cascadeResult.bossDamage).toBeGreaterThan(0);

      // Check Boss damaged from Gate completion
      const updatedBoss = await bossService.getBoss(testUserId, boss.id);
      expect(updatedBoss.hpCurrent).toBe(300 - cascadeResult.bossDamage!);
    });
  });

  describe('3. Gate Collapse → Penalty Cascade & Hardcore Mode Recovery', () => {
    it('applies XP & Mana penalty in casual mode on collapse', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      const storedSession = (await gateRepository.findById(session.id, testUserId))!;
      const penaltyResult = await rewardCascadeService.executeGateCollapseRewardCascade(
        testUserId,
        storedSession,
        'casual',
      );

      expect(penaltyResult.xpDelta).toBeLessThan(0);
      expect(penaltyResult.manaDelta).toBeLessThan(0);
      expect(penaltyResult.bossRecovered).toBe(false);
    });

    it('triggers Boss HP recovery in Hardcore Mode when gate collapses on linked boss quest', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Hardcore Project',
        hpMax: 200,
        difficulty: 'hard',
      });

      // Apply initial damage to boss (down to 100 HP)
      await bossService.applyDamage(testUserId, boss.id, 100);
      const damagedBoss = await bossService.getBoss(testUserId, boss.id);
      expect(damagedBoss.hpCurrent).toBe(100);

      const quest = await questRepository.create({
        userId: testUserId,
        title: 'Hardcore Task',
        bossId: boss.id,
      });

      const session = await gateService.startSession(testUserId, {
        questId: quest.id,
        plannedDurationSeconds: 1500,
      });

      const storedSession = (await gateRepository.findById(session.id, testUserId))!;
      const penaltyResult = await rewardCascadeService.executeGateCollapseRewardCascade(
        testUserId,
        storedSession,
        'hardcore',
      );

      expect(penaltyResult.bossRecovered).toBe(true);

      // Boss recovered HP (100 + 15% of 200 = 130 HP)
      const recoveredBoss = await bossService.getBoss(testUserId, boss.id);
      expect(recoveredBoss.hpCurrent).toBe(130);
    });
  });

  describe('4. Gate Session Pause & Difficulty Constraints', () => {
    it('allows 1 pause in Casual mode and rejects subsequent pauses', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      const paused = await gateService.pauseSession(testUserId, session.id, 'casual');
      expect(paused.status).toBe('paused');
      expect(paused.pauseCount).toBe(1);

      const resumed = await gateService.resumeSession(testUserId, session.id);
      expect(resumed.status).toBe('active');

      // Second pause attempt in casual mode is rejected
      await expect(
        gateService.pauseSession(testUserId, session.id, 'casual'),
      ).rejects.toThrow(/Maximum of 1 pause/i);
    });

    it('strictly disallows pausing in Hardcore Mode', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      await expect(
        gateService.pauseSession(testUserId, session.id, 'hardcore'),
      ).rejects.toThrow(/Pausing is strictly disallowed in Hardcore Mode/i);
    });
  });
});
