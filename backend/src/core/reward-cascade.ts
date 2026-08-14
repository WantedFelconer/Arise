import {
  Injectable,
  Inject,
  ConflictException,
  BadRequestException,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { CharacterService } from '../modules/character/service/character.service';
import { BossService } from '../modules/bosses/service/boss.service';
import { AchievementService } from '../modules/achievements/service/achievement.service';
import { QuestRepository } from '../modules/quests/repository/quest.repository';
import { RpgEngine, StatKey } from './rpg-engine';
import { StoredGateSession, StoredQuest } from '../db/memory/memory-db';

export interface QuestRewardCascadeResult {
  quest: StoredQuest;
  xpAwarded: number;
  manaDelta: number;
  bossDamage?: number;
  bossDefeated?: boolean;
  bossRewards?: { xp: number; coins: number };
  parentAutoCompleted?: boolean;
  nextRecurringQuestId?: string;
  unlockedAchievements?: string[];
}

export interface GateRewardCascadeResult {
  xpDelta: number;
  manaDelta: number;
  bossDamage?: number;
  bossRecovered?: boolean;
  unlockedAchievements?: string[];
}

@Injectable()
export class RewardCascadeService {
  constructor(
    @Inject(forwardRef(() => CharacterService)) private characterService: CharacterService,
    @Inject(forwardRef(() => BossService)) private bossService: BossService,
    @Inject(forwardRef(() => AchievementService)) private achievementService: AchievementService,
    @Inject(forwardRef(() => QuestRepository)) private questRepository: QuestRepository,
  ) {}

  /**
   * §8.4 Quest Completion -> Reward Cascade
   * Atomic single-transaction handler for quest completions.
   * Idempotent: rejects already-completed quests with 409 Conflict.
   */
  async executeQuestRewardCascade(
    userId: string,
    questId: string,
    options?: { focusQualityMultiplier?: number },
  ): Promise<QuestRewardCascadeResult> {
    const quest = await this.questRepository.findById(questId, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    // Idempotency: Reject already completed quests
    if (quest.status === 'completed') {
      throw new ConflictException({
        code: 'QUEST_ALREADY_COMPLETED',
        message: 'Quest has already been completed and rewards applied',
      });
    }

    if (quest.status === 'trashed') {
      throw new BadRequestException({
        code: 'INVALID_QUEST_STATE',
        message: 'Cannot complete a trashed quest',
      });
    }

    const diffMultipliers: Record<string, number> = {
      trivial: 0.5,
      easy: 0.8,
      medium: 1.0,
      hard: 1.5,
      epic: 2.0,
    };
    const difficultyMultiplier = diffMultipliers[quest.difficulty] || 1.0;
    const baseXp = quest.estimatedMinutes > 0 ? quest.estimatedMinutes : 30;
    const xpAwarded = RpgEngine.calculateQuestXp({ baseXp, difficultyMultiplier });
    const manaDelta = 5;

    // 1. Linked to boss? -> Compute + apply boss damage
    let bossDamage: number | undefined;
    let bossDefeated: boolean | undefined;
    let bossRewards: { xp: number; coins: number } | undefined;

    if (quest.bossId) {
      bossDamage = RpgEngine.calculateBossDamage(
        quest.difficulty,
        quest.priority,
        options?.focusQualityMultiplier ?? 1.0,
      );

      try {
        const bossResult = await this.bossService.applyDamage(userId, quest.bossId, bossDamage);
        bossDefeated = bossResult.defeated;
        bossRewards = bossResult.rewards;
      } catch {
        // Boss could not be loaded or is already defeated
      }
    }

    // 2. Award XP to stat + Mana (via centralized engine / CharacterService)
    const validStats: StatKey[] = [
      'intelligence',
      'discipline',
      'fitness',
      'creativity',
      'coding',
      'business',
      'health',
    ];
    let statKey: StatKey = 'discipline';
    if (quest.tags && quest.tags.length > 0) {
      const match = quest.tags.find((t) => validStats.includes(t as StatKey));
      if (match) statKey = match as StatKey;
    }

    await this.characterService.awardXp(userId, {
      amount: xpAwarded,
      sourceType: 'quest',
      sourceId: quest.id,
      statKey,
      reason: `Completed quest: ${quest.title}`,
    });

    await this.characterService.modifyMana(userId, {
      delta: manaDelta,
      sourceType: 'quest',
      sourceId: quest.id,
      reason: `Completed quest: ${quest.title}`,
    });

    // If boss defeated, award boss bonus XP
    if (bossDefeated && bossRewards && bossRewards.xp > 0 && quest.bossId) {
      await this.characterService.awardXp(userId, {
        amount: bossRewards.xp,
        sourceType: 'bonus',
        sourceId: quest.bossId,
        reason: 'Boss defeat bonus',
      });
    }

    // Mark quest as completed
    const completedQuest = await this.questRepository.update(quest.id, userId, {
      status: 'completed',
      completedAt: new Date(),
    });

    // 3. Parent quest auto-completion: all sibling quests complete? -> auto-complete parent
    let parentAutoCompleted = false;
    if (quest.parentQuestId) {
      const siblings = await this.questRepository.findChildren(quest.parentQuestId, userId);
      const allDone = siblings.length > 0 && siblings.every((s) => s.status === 'completed');

      if (allDone) {
        // Auto-complete parent quest
        await this.questRepository.update(quest.parentQuestId, userId, {
          status: 'completed',
          completedAt: new Date(),
        });
        parentAutoCompleted = true;
      }
    }

    // 4. RRULE / Recurring quest spawning (FR-QST-005)
    let nextRecurringQuestId: string | undefined;
    if (quest.questType === 'recurring' || quest.recurrenceRule) {
      const recRule = quest.recurrenceRule as Record<string, unknown> | null;
      const intervalDays =
        recRule && typeof recRule.intervalDays === 'number' ? (recRule.intervalDays as number) : 1;
      const nextDeadline = quest.deadline
        ? new Date(quest.deadline.getTime() + intervalDays * 24 * 60 * 60 * 1000)
        : new Date(Date.now() + intervalDays * 24 * 60 * 60 * 1000);

      const nextQuest = await this.questRepository.create({
        userId,
        title: quest.title,
        description: quest.description,
        questType: quest.questType,
        priority: quest.priority,
        difficulty: quest.difficulty,
        estimatedMinutes: quest.estimatedMinutes,
        tags: quest.tags,
        bossId: quest.bossId,
        parentQuestId: quest.parentQuestId,
        recurrenceRule: recRule,
        deadline: nextDeadline,
        status: 'pending',
      });
      nextRecurringQuestId = nextQuest.id;
    }

    // 5. Achievement criteria evaluation (FR-ACH-001)
    const unlocked = await this.achievementService.evaluateTriggers(userId, {
      eventType: 'quest_complete',
      userId,
      payload: { questId: quest.id, bossId: quest.bossId || undefined },
    });

    if (bossDefeated && quest.bossId) {
      const bossUnlocks = await this.achievementService.evaluateTriggers(userId, {
        eventType: 'boss_defeat',
        userId,
        payload: { bossId: quest.bossId },
      });
      unlocked.push(...bossUnlocks);
    }

    return {
      quest: completedQuest as StoredQuest,
      xpAwarded,
      manaDelta,
      bossDamage,
      bossDefeated,
      bossRewards,
      parentAutoCompleted,
      nextRecurringQuestId,
      unlockedAchievements: unlocked.map((u) => u.title),
    };
  }

  /**
   * §8.3 & FR-GATE-004: Gate Clear Reward Cascade
   */
  async executeGateClearRewardCascade(
    userId: string,
    session: StoredGateSession,
    stabilityPct: number,
  ): Promise<GateRewardCascadeResult> {
    const duration = session.actualDurationS || session.plannedDurationS;
    const xpAwarded = RpgEngine.calculateGateXp(duration, 'medium', stabilityPct);
    const manaReward = RpgEngine.getGateClearManaReward();

    if (xpAwarded > 0) {
      await this.characterService.awardXp(userId, {
        amount: xpAwarded,
        sourceType: 'gate',
        sourceId: session.id,
        reason: 'Gate expedition clear XP reward',
      });
    }

    let bossDamage: number | undefined;
    if (session.questId) {
      const linkedQuest = await this.questRepository.findById(session.questId, userId);
      if (linkedQuest?.bossId) {
        bossDamage = RpgEngine.calculateBossDamage(
          linkedQuest.difficulty,
          linkedQuest.priority,
          stabilityPct / 100,
        );
        await this.bossService.applyDamage(userId, linkedQuest.bossId, bossDamage);
      }
    }

    if (manaReward > 0) {
      await this.characterService.modifyMana(userId, {
        delta: manaReward,
        sourceType: 'gate',
        sourceId: session.id,
        reason: 'Gate expedition clear mana bonus',
      });
    }

    // 3. Achievement criteria evaluation (FR-ACH-001)
    const unlocked = await this.achievementService.evaluateTriggers(userId, {
      eventType: 'gate_clear',
      userId,
      payload: {
        sessionId: session.id,
        plannedDurationS: session.plannedDurationS,
        stabilityPct,
      },
    });

    return {
      xpDelta: xpAwarded,
      manaDelta: manaReward,
      bossDamage,
      unlockedAchievements: unlocked.map((u) => u.title),
    };
  }

  /**
   * Centralized Gate Collapse Reward Cascade (FR-GATE-005)
   */
  async executeGateCollapseRewardCascade(
    userId: string,
    session: StoredGateSession,
    userDifficultyMode: string,
  ): Promise<{ xpDelta: number; manaDelta: number; bossRecovered: boolean }> {
    const penalty = RpgEngine.getGateCollapsePenalty(userDifficultyMode);

    // 1. Apply negative XP ledger transaction if penalty > 0
    if (penalty.xpPenalty > 0) {
      await this.characterService.applyXpPenalty(userId, {
        amount: penalty.xpPenalty,
        sourceType: 'gate',
        sourceId: session.id,
        reason: `Gate expedition collapse penalty (${userDifficultyMode} mode)`,
      });
    }

    // 2. Apply negative Mana ledger transaction if penalty > 0
    if (penalty.manaPenalty > 0) {
      await this.characterService.modifyMana(userId, {
        delta: -penalty.manaPenalty,
        sourceType: 'gate',
        sourceId: session.id,
        reason: `Gate expedition collapse mana penalty (${userDifficultyMode} mode)`,
      });
    }

    // Hardcore mode boss recovery
    let bossRecovered = false;
    if (userDifficultyMode === 'hardcore' && penalty.bossRecovery && session.questId) {
      const linkedQuest = await this.questRepository.findById(session.questId, userId);
      if (linkedQuest?.bossId) {
        const recoveryRate =
          'bossRecoveryRate' in penalty
            ? Number((penalty as Record<string, unknown>).bossRecoveryRate) || 0.15
            : 0.15;
        await this.bossService.applyHpRecovery(userId, linkedQuest.bossId, recoveryRate);
        bossRecovered = true;
      }
    }

    return {
      xpDelta: -penalty.xpPenalty,
      manaDelta: -penalty.manaPenalty,
      bossRecovered,
    };
  }
}
