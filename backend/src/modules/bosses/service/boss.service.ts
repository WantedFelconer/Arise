import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { BossRepository } from '../repository/boss.repository';
import { RpgEngine } from '../../../core/rpg-engine';
import { CreateBossInput, UpdateBossInput } from '../validation/boss.schema';
import { BossResponse, BossHistoryItem } from '../dto/boss.dto';
import { memoryDb } from '../../../db/memory/memory-db';

@Injectable()
export class BossService {
  constructor(@Inject(BossRepository) private bossRepository: BossRepository) {}

  async getBoss(userId: string, id: string): Promise<BossResponse> {
    const boss = await this.bossRepository.findById(id, userId);
    if (!boss) {
      throw new NotFoundException({
        code: 'BOSS_NOT_FOUND',
        message: 'Boss not found or access denied',
      });
    }

    return this.mapToResponse(boss);
  }

  async listBosses(
    userId: string,
    filters: { status?: string; dungeonId?: string } = {},
  ): Promise<BossResponse[]> {
    const bosses = await this.bossRepository.findMany(userId, filters);
    return bosses.map((b) => this.mapToResponse(b));
  }

  async createBoss(userId: string, input: CreateBossInput): Promise<BossResponse> {
    const deadline = input.deadline ? new Date(input.deadline) : null;
    const boss = await this.bossRepository.create({
      userId,
      title: input.title,
      description: input.description,
      hpMax: input.hpMax,
      hpCurrent: input.hpMax,
      difficulty: input.difficulty || 'medium',
      deadline,
      dungeonId: input.dungeonId || null,
    });

    return this.mapToResponse(boss);
  }

  async updateBoss(userId: string, id: string, input: UpdateBossInput): Promise<BossResponse> {
    const existing = await this.bossRepository.findById(id, userId);
    if (!existing) {
      throw new NotFoundException({
        code: 'BOSS_NOT_FOUND',
        message: 'Boss not found or access denied',
      });
    }

    if (existing.status === 'defeated') {
      throw new BadRequestException({
        code: 'BOSS_ALREADY_DEFEATED',
        message: 'Cannot modify a defeated boss',
      });
    }

    const updateData: Record<string, unknown> = {};
    if (input.title !== undefined) updateData.title = input.title;
    if (input.description !== undefined) updateData.description = input.description;
    if (input.difficulty !== undefined) updateData.difficulty = input.difficulty;
    if (input.deadline !== undefined) {
      updateData.deadline = input.deadline ? new Date(input.deadline) : null;
    }
    if (input.dungeonId !== undefined) updateData.dungeonId = input.dungeonId;

    const updated = await this.bossRepository.update(id, userId, updateData);
    return this.mapToResponse(updated!);
  }

  /**
   * Boss Lifecycle (§7.3): active -> abandoned
   */
  async abandonBoss(userId: string, id: string): Promise<BossResponse> {
    const boss = await this.bossRepository.findById(id, userId);
    if (!boss) {
      throw new NotFoundException({
        code: 'BOSS_NOT_FOUND',
        message: 'Boss not found or access denied',
      });
    }

    if (boss.status === 'defeated') {
      throw new BadRequestException({
        code: 'BOSS_ALREADY_DEFEATED',
        message: 'Cannot abandon a defeated boss',
      });
    }

    const updated = await this.bossRepository.update(id, userId, { status: 'abandoned' });
    return this.mapToResponse(updated!);
  }

  /**
   * Boss Lifecycle (§7.3): abandoned -> active
   */
  async reactivateBoss(userId: string, id: string): Promise<BossResponse> {
    const boss = await this.bossRepository.findById(id, userId);
    if (!boss) {
      throw new NotFoundException({
        code: 'BOSS_NOT_FOUND',
        message: 'Boss not found or access denied',
      });
    }

    if (boss.status !== 'abandoned') {
      throw new BadRequestException({
        code: 'INVALID_BOSS_STATE',
        message: 'Only abandoned bosses can be reactivated',
      });
    }

    const updated = await this.bossRepository.update(id, userId, { status: 'active' });
    return this.mapToResponse(updated!);
  }

  /**
   * FR-BOSS-002 & FR-BOSS-003:
   * Apply computed damage to Boss HP. If HP <= 0, mark as defeated.
   */
  async applyDamage(
    userId: string,
    bossId: string,
    damage: number,
  ): Promise<{
    boss: BossResponse;
    defeated: boolean;
    rewards?: { xp: number; coins: number };
    damageDealt: number;
  }> {
    const boss = await this.bossRepository.findById(bossId, userId);
    if (!boss) {
      throw new NotFoundException({
        code: 'BOSS_NOT_FOUND',
        message: 'Boss not found or access denied',
      });
    }

    if (boss.status === 'defeated') {
      return {
        boss: this.mapToResponse(boss),
        defeated: true,
        damageDealt: 0,
      };
    }

    const newHp = Math.max(0, boss.hpCurrent - damage);
    const defeated = newHp === 0;
    const now = new Date();

    const updated = await this.bossRepository.update(bossId, userId, {
      hpCurrent: newHp,
      status: defeated ? 'defeated' : 'active',
      defeatedAt: defeated ? now : null,
    });

    let rewards;
    if (defeated) {
      rewards = RpgEngine.getBossDefeatRewards(boss.difficulty);
    }

    return {
      boss: this.mapToResponse(updated!),
      defeated,
      rewards,
      damageDealt: damage,
    };
  }

  /**
   * Hardcore Mode Failure / Gate Collapse: Boss HP recovery (FR-BOSS-004 / FR-GATE-005)
   */
  async applyHpRecovery(
    userId: string,
    bossId: string,
    recoveryRate: number = 0.15,
  ): Promise<BossResponse> {
    const boss = await this.bossRepository.findById(bossId, userId);
    if (!boss || boss.status === 'defeated') {
      return this.mapToResponse(boss!);
    }

    const hpGain = Math.round(boss.hpMax * recoveryRate);
    const newHp = Math.min(boss.hpMax, boss.hpCurrent + hpGain);

    const updated = await this.bossRepository.update(bossId, userId, {
      hpCurrent: newHp,
    });

    return this.mapToResponse(updated!);
  }

  /**
   * FR-BOSS-005: Boss history: defeated bosses, time-to-defeat, quest count
   */
  async getBossHistory(userId: string): Promise<BossHistoryItem[]> {
    const bosses = await this.bossRepository.findMany(userId, { status: 'defeated' });
    return bosses.map((b) => {
      const defeatedAt = (b as unknown as { defeatedAt?: Date }).defeatedAt || b.updatedAt;
      const timeToDefeatMs = Math.max(0, defeatedAt.getTime() - b.createdAt.getTime());

      // Count completed quests linked to this boss
      const linkedQuests = Array.from(memoryDb.quests.values()).filter(
        (q) => q.bossId === b.id && q.status === 'completed',
      );

      return {
        id: b.id,
        title: b.title,
        difficulty: b.difficulty,
        hpMax: b.hpMax,
        defeatedAt,
        createdAt: b.createdAt,
        timeToDefeatMs,
        questsCompletedCount: linkedQuests.length,
      };
    });
  }

  private mapToResponse(boss: {
    id: string;
    userId: string;
    dungeonId: string | null;
    title: string;
    description: string | null;
    hpMax: number;
    hpCurrent: number;
    difficulty: string;
    status: string;
    deadline: Date | null;
    defeatedAt?: Date | null;
    createdAt: Date;
    updatedAt: Date;
  }): BossResponse {
    return {
      id: boss.id,
      userId: boss.userId,
      dungeonId: boss.dungeonId,
      title: boss.title,
      description: boss.description,
      hpMax: boss.hpMax,
      hpCurrent: boss.hpCurrent,
      difficulty: boss.difficulty,
      status: boss.status as 'active' | 'defeated' | 'abandoned',
      deadline: boss.deadline,
      defeatedAt: boss.defeatedAt || null,
      createdAt: boss.createdAt,
      updatedAt: boss.updatedAt,
    };
  }
}
