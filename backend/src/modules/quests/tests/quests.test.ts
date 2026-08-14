import { describe, it, expect, beforeEach } from 'vitest';
import { QuestRepository } from '../repository/quest.repository';
import { QuestService } from '../service/quest.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { BossService } from '../../bosses/service/boss.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { CharacterService } from '../../character/service/character.service';
import { AchievementRepository } from '../../achievements/repository/achievement.repository';
import { AchievementService } from '../../achievements/service/achievement.service';
import { RewardCascadeService } from '../../../core/reward-cascade';
import { memoryDb } from '../../../db/memory/memory-db';

describe('Quests Module — Unit & State Machine Suite', () => {
  let questRepository: QuestRepository;
  let questService: QuestService;
  let bossService: BossService;
  let characterService: CharacterService;
  let achievementService: AchievementService;
  let rewardCascadeService: RewardCascadeService;

  const testUserId = 'user-quest-test-1';

  beforeEach(async () => {
    memoryDb.clear();

    const charRepo = new CharacterRepository();
    characterService = new CharacterService(charRepo);
    await charRepo.createCharacter({ userId: testUserId });

    const bossRepo = new BossRepository();
    bossService = new BossService(bossRepo);

    const achRepo = new AchievementRepository();
    achievementService = new AchievementService(achRepo, characterService);

    questRepository = new QuestRepository();
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
  });

  describe('1. Quest Creation and Fields (FR-QST-001, FR-QST-004)', () => {
    it('creates a quest with all fields and initial pending status', async () => {
      const deadline = new Date(Date.now() + 86400000).toISOString();
      const quest = await questService.createQuest(testUserId, {
        title: 'Complete Algorithms Homework',
        description: 'Binary search tree exercises',
        questType: 'main',
        priority: 'high',
        difficulty: 'hard',
        estimatedMinutes: 60,
        tags: ['coding', 'study'],
        deadline,
      });

      expect(quest.id).toBeDefined();
      expect(quest.title).toBe('Complete Algorithms Homework');
      expect(quest.status).toBe('pending');
      expect(quest.priority).toBe('high');
      expect(quest.difficulty).toBe('hard');
      expect(quest.estimatedMinutes).toBe(60);
      expect(quest.tags).toEqual(['coding', 'study']);
    });
  });

  describe('2. State Machine Transitions (§7.1)', () => {
    it('transitions pending -> in_progress -> completed', async () => {
      const quest = await questService.createQuest(testUserId, {
        title: 'Study Physics',
      });
      expect(quest.status).toBe('pending');

      const started = await questService.startQuest(testUserId, quest.id);
      expect(started.status).toBe('in_progress');

      const completeResult = await questService.completeQuest(testUserId, quest.id);
      expect(completeResult.quest.status).toBe('completed');
      expect(completeResult.quest.completedAt).toBeDefined();
    });

    it('transitions in_progress -> pending on pause', async () => {
      const quest = await questService.createQuest(testUserId, { title: 'Focus Task' });
      await questService.startQuest(testUserId, quest.id);
      const paused = await questService.pauseQuest(testUserId, quest.id);
      expect(paused.status).toBe('pending');
    });

    it('transitions completed -> archived -> pending (restore) (FR-QST-007)', async () => {
      const quest = await questService.createQuest(testUserId, { title: 'Archivable Task' });
      await questService.completeQuest(testUserId, quest.id);

      const archived = await questService.archiveQuest(testUserId, quest.id);
      expect(archived.status).toBe('archived');

      const restored = await questService.restoreQuest(testUserId, quest.id);
      expect(restored.status).toBe('pending');
    });

    it('rejects invalid state machine transitions', async () => {
      const quest = await questService.createQuest(testUserId, { title: 'Test Task' });
      // Cannot pause a pending quest
      await expect(questService.pauseQuest(testUserId, quest.id)).rejects.toThrow(
        /Cannot pause quest with status/i,
      );

      // Cannot start an archived quest
      await questService.archiveQuest(testUserId, quest.id);
      await expect(questService.startQuest(testUserId, quest.id)).rejects.toThrow(
        /Cannot start quest with status/i,
      );
    });
  });

  describe('3. Unlimited Nesting & Parent Auto-Complete (FR-QST-002, FR-QST-003)', () => {
    it('auto-completes parent quest when all child quests complete', async () => {
      const parent = await questService.createQuest(testUserId, {
        title: 'Term Project',
        questType: 'main',
      });

      const child1 = await questService.createQuest(testUserId, {
        title: 'Phase 1: Research',
        parentQuestId: parent.id,
      });

      const child2 = await questService.createQuest(testUserId, {
        title: 'Phase 2: Code',
        parentQuestId: parent.id,
      });

      // Complete child 1
      const res1 = await questService.completeQuest(testUserId, child1.id);
      expect(res1.parentAutoCompleted).toBe(false);

      // Parent should still be pending
      const parentMid = await questService.getQuest(testUserId, parent.id);
      expect(parentMid.status).toBe('pending');

      // Complete child 2 -> should trigger parent auto-complete
      const res2 = await questService.completeQuest(testUserId, child2.id);
      expect(res2.parentAutoCompleted).toBe(true);

      const parentFinal = await questService.getQuest(testUserId, parent.id);
      expect(parentFinal.status).toBe('completed');
    });
  });

  describe('4. RRULE Recurrence Spawning (FR-QST-005)', () => {
    it('spawns next recurring quest occurrence upon completion', async () => {
      const initialDeadline = new Date('2026-03-01T12:00:00Z');
      const quest = await questService.createQuest(testUserId, {
        title: 'Daily Workout',
        questType: 'recurring',
        recurrenceRule: { intervalDays: 1 },
        deadline: initialDeadline.toISOString(),
      });

      const result = await questService.completeQuest(testUserId, quest.id);
      expect(result.nextRecurringQuestId).toBeDefined();

      const nextQuest = await questService.getQuest(testUserId, result.nextRecurringQuestId!);
      expect(nextQuest.title).toBe('Daily Workout');
      expect(nextQuest.status).toBe('pending');
      expect(nextQuest.deadline?.getTime()).toBe(new Date('2026-03-02T12:00:00Z').getTime());
    });
  });

  describe('5. 10-Second Undo Window (FR-QST-018)', () => {
    it('undoes a completion within 10 seconds', async () => {
      const quest = await questService.createQuest(testUserId, { title: 'Mistake Task' });
      await questService.completeQuest(testUserId, quest.id);

      const undone = await questService.undo(testUserId, quest.id);
      expect(undone.status).toBe('pending');
    });

    it('undoes a soft deletion within 10 seconds', async () => {
      const quest = await questService.createQuest(testUserId, { title: 'Accidental Delete' });
      await questService.deleteQuest(testUserId, quest.id);

      const undone = await questService.undo(testUserId, quest.id);
      expect(undone.status).toBe('pending');
    });
  });

  describe('6. Hardcore Deadline Miss Penalty (FR-QST-013)', () => {
    it('applies Mana penalty in hardcore mode on failed quest deadline', async () => {
      const quest = await questService.createQuest(testUserId, {
        title: 'Hardcore Urgent Quest',
        priority: 'urgent',
      });

      const beforeChar = await characterService.getCharacter(testUserId);
      expect(beforeChar.currentMana).toBe(100);

      await questService.failQuest(testUserId, quest.id, 'hardcore');

      const failedQuest = await questService.getQuest(testUserId, quest.id);
      expect(failedQuest.status).toBe('failed');

      const afterChar = await characterService.getCharacter(testUserId);
      expect(afterChar.currentMana).toBe(85); // 100 - 15 penalty
    });
  });

  describe('7. Filtering, Sorting, and Search (FR-QST-008)', () => {
    it('filters quests by status, priority, and searches title', async () => {
      await questService.createQuest(testUserId, {
        title: 'Alpha Machine Learning Project',
        priority: 'high',
        difficulty: 'hard',
      });

      await questService.createQuest(testUserId, {
        title: 'Beta Grocery shopping',
        priority: 'low',
        difficulty: 'trivial',
      });

      const searchResults = await questService.listQuests(testUserId, {
        search: 'machine learning',
      });
      expect(searchResults.length).toBe(1);
      expect(searchResults[0]!.title).toContain('Machine Learning');

      const priorityResults = await questService.listQuests(testUserId, {
        priority: 'high',
      });
      expect(priorityResults.length).toBe(1);
      expect(priorityResults[0]!.priority).toBe('high');
    });
  });
});
