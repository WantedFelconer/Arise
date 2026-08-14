import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { QuestRepository } from '../repository/quest.repository';
import { BossService } from '../../bosses/service/boss.service';
import { CharacterService } from '../../character/service/character.service';
import { RewardCascadeService } from '../../../core/reward-cascade';
import { RpgEngine } from '../../../core/rpg-engine';
import {
  CreateQuestInput,
  UpdateQuestInput,
  QuestListQueryInput,
} from '../validation/quest.schema';
import { QuestResponse } from '../dto/quest.dto';

@Injectable()
export class QuestService {
  constructor(
    @Inject(QuestRepository) private questRepository: QuestRepository,
    @Inject(forwardRef(() => BossService)) private bossService: BossService,
    @Inject(forwardRef(() => CharacterService)) private characterService: CharacterService,
    @Inject(forwardRef(() => RewardCascadeService))
    private rewardCascadeService: RewardCascadeService,
  ) {}

  async getQuest(userId: string, id: string): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    return this.mapToResponse(quest);
  }

  async listQuests(userId: string, filters: QuestListQueryInput = {}): Promise<QuestResponse[]> {
    const quests = await this.questRepository.findMany(userId, filters);
    return quests.map((q) => this.mapToResponse(q));
  }

  async createQuest(userId: string, input: CreateQuestInput): Promise<QuestResponse> {
    // Validate boss ownership if bossId is provided
    if (input.bossId) {
      await this.bossService.getBoss(userId, input.bossId);
    }

    // Validate parent quest ownership if parentQuestId is provided
    if (input.parentQuestId) {
      await this.getQuest(userId, input.parentQuestId);
    }

    const deadline = input.deadline ? new Date(input.deadline) : null;

    const quest = await this.questRepository.create({
      id: input.id,
      userId,
      title: input.title,
      description: input.description,
      questType: input.questType || 'daily',
      priority: input.priority || 'medium',
      difficulty: input.difficulty || 'medium',
      estimatedMinutes: input.estimatedMinutes || 30,
      deadline,
      tags: input.tags || [],
      bossId: input.bossId || null,
      parentQuestId: input.parentQuestId || null,
      recurrenceRule: input.recurrenceRule || null,
      metadata: input.metadata || null,
      status: 'pending',
    });

    return this.mapToResponse(quest);
  }

  async updateQuest(userId: string, id: string, input: UpdateQuestInput): Promise<QuestResponse> {
    const existing = await this.questRepository.findById(id, userId);
    if (!existing) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (existing.status === 'completed' || existing.status === 'trashed') {
      throw new BadRequestException({
        code: 'INVALID_QUEST_STATE',
        message: `Cannot edit a ${existing.status} quest`,
      });
    }

    if (input.bossId) {
      await this.bossService.getBoss(userId, input.bossId);
    }
    if (input.parentQuestId && input.parentQuestId !== id) {
      await this.getQuest(userId, input.parentQuestId);
    }

    const updateData: Record<string, unknown> = {};
    if (input.title !== undefined) updateData.title = input.title;
    if (input.description !== undefined) updateData.description = input.description;
    if (input.questType !== undefined) updateData.questType = input.questType;
    if (input.priority !== undefined) updateData.priority = input.priority;
    if (input.difficulty !== undefined) updateData.difficulty = input.difficulty;
    if (input.estimatedMinutes !== undefined) updateData.estimatedMinutes = input.estimatedMinutes;
    if (input.actualMinutes !== undefined) updateData.actualMinutes = input.actualMinutes;
    if (input.deadline !== undefined) {
      updateData.deadline = input.deadline ? new Date(input.deadline) : null;
    }
    if (input.tags !== undefined) updateData.tags = input.tags;
    if (input.bossId !== undefined) updateData.bossId = input.bossId;
    if (input.parentQuestId !== undefined) updateData.parentQuestId = input.parentQuestId;
    if (input.recurrenceRule !== undefined) updateData.recurrenceRule = input.recurrenceRule;
    if (input.isFavorite !== undefined) updateData.isFavorite = input.isFavorite;
    if (input.isPinned !== undefined) updateData.isPinned = input.isPinned;
    if (input.metadata !== undefined) updateData.metadata = input.metadata;

    const updated = await this.questRepository.update(id, userId, updateData);
    return this.mapToResponse(updated!);
  }

  /**
   * Quest Lifecycle State Machine: pending -> in_progress
   */
  async startQuest(userId: string, id: string): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (quest.status !== 'pending') {
      throw new BadRequestException({
        code: 'INVALID_TRANSITION',
        message: `Cannot start quest with status '${quest.status}'. Expected 'pending'`,
      });
    }

    const updated = await this.questRepository.update(id, userId, { status: 'in_progress' });
    return this.mapToResponse(updated!);
  }

  /**
   * Quest Lifecycle State Machine: in_progress -> pending (pause/collapse)
   */
  async pauseQuest(userId: string, id: string): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (quest.status !== 'in_progress') {
      throw new BadRequestException({
        code: 'INVALID_TRANSITION',
        message: `Cannot pause quest with status '${quest.status}'. Expected 'in_progress'`,
      });
    }

    const updated = await this.questRepository.update(id, userId, { status: 'pending' });
    return this.mapToResponse(updated!);
  }

  /**
   * Quest Lifecycle State Machine: complete (via Centralized Reward Cascade)
   */
  async completeQuest(userId: string, id: string, options?: { focusQualityMultiplier?: number }) {
    return this.rewardCascadeService.executeQuestRewardCascade(userId, id, options);
  }

  /**
   * Quest Lifecycle State Machine: {completed, pending, failed} -> archived (FR-QST-007)
   */
  async archiveQuest(userId: string, id: string): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (quest.status === 'trashed' || quest.status === 'archived') {
      throw new BadRequestException({
        code: 'INVALID_TRANSITION',
        message: `Cannot archive quest with status '${quest.status}'`,
      });
    }

    const updated = await this.questRepository.update(id, userId, { status: 'archived' });
    return this.mapToResponse(updated!);
  }

  /**
   * Quest Lifecycle State Machine: archived/trashed -> pending (restore)
   */
  async restoreQuest(userId: string, id: string): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (quest.status !== 'archived' && quest.status !== 'trashed') {
      throw new BadRequestException({
        code: 'INVALID_TRANSITION',
        message: `Cannot restore quest with status '${quest.status}'. Expected 'archived' or 'trashed'`,
      });
    }

    const updated = await this.questRepository.restore(id, userId);
    return this.mapToResponse(updated!);
  }

  /**
   * FR-QST-013: Hardcore mode deadline miss penalty -> status = failed
   */
  async failQuest(
    userId: string,
    id: string,
    userDifficultyMode: string = 'casual',
  ): Promise<QuestResponse> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    if (quest.status !== 'pending' && quest.status !== 'in_progress') {
      throw new BadRequestException({
        code: 'INVALID_TRANSITION',
        message: `Cannot fail quest with status '${quest.status}'`,
      });
    }

    // Apply hardcore penalty if applicable
    if (userDifficultyMode === 'hardcore') {
      const penalty = RpgEngine.getDeadlineMissPenalty('hardcore');
      if (penalty.manaPenalty > 0) {
        await this.characterService.modifyMana(userId, {
          delta: -penalty.manaPenalty,
          sourceType: 'quest',
          sourceId: id,
          reason: `Hardcore deadline miss penalty for quest: ${quest.title}`,
        });
      }
    }

    const updated = await this.questRepository.update(id, userId, { status: 'failed' });
    return this.mapToResponse(updated!);
  }

  /**
   * FR-QST-018: Soft-delete (trashed)
   */
  async deleteQuest(userId: string, id: string): Promise<{ success: boolean }> {
    const quest = await this.questRepository.findById(id, userId);
    if (!quest) {
      throw new NotFoundException({
        code: 'QUEST_NOT_FOUND',
        message: 'Quest not found or access denied',
      });
    }

    await this.questRepository.softDelete(id, userId);
    return { success: true };
  }

  /**
   * FR-QST-018: Undo delete/complete within 10 seconds
   */
  async undo(userId: string, id: string): Promise<QuestResponse> {
    const result = await this.questRepository.undo(id, userId);
    if (!result.success || !result.quest) {
      throw new BadRequestException({
        code: 'UNDO_EXPIRED_OR_INVALID',
        message: 'Undo window expired (10-second limit) or no action available to undo',
      });
    }

    return this.mapToResponse(result.quest);
  }

  private mapToResponse(quest: unknown): QuestResponse {
    const q = quest as Record<string, unknown>;
    const subQuests = q.subQuests as unknown[] | undefined;

    return {
      id: q.id as string,
      userId: q.userId as string,
      bossId: (q.bossId as string) ?? null,
      parentQuestId: (q.parentQuestId as string) ?? null,
      title: q.title as string,
      description: (q.description as string) ?? null,
      questType: q.questType as string,
      priority: q.priority as string,
      difficulty: q.difficulty as string,
      status: q.status as
        'pending' | 'in_progress' | 'completed' | 'archived' | 'failed' | 'trashed',
      estimatedMinutes: Number(q.estimatedMinutes),
      actualMinutes: (q.actualMinutes as number) ?? null,
      deadline: (q.deadline as Date) ?? null,
      recurrenceRule: (q.recurrenceRule as Record<string, unknown>) ?? null,
      tags: (q.tags as string[]) || [],
      isFavorite: Boolean(q.isFavorite),
      isPinned: Boolean(q.isPinned),
      eisenhowerQuadrant: (q.eisenhowerQuadrant as string) ?? null,
      metadata: (q.metadata as Record<string, unknown>) ?? null,
      subQuests: subQuests ? subQuests.map((s) => this.mapToResponse(s)) : undefined,
      completedAt: (q.completedAt as Date) ?? null,
      createdAt: q.createdAt as Date,
      updatedAt: q.updatedAt as Date,
    };
  }
}
