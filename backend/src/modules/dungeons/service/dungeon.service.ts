import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { DungeonRepository } from '../repository/dungeon.repository';
import { BossService } from '../../bosses/service/boss.service';
import { CreateDungeonInput, UpdateDungeonInput } from '../validation/dungeon.schema';
import { DungeonResponse } from '../dto/dungeon.dto';

@Injectable()
export class DungeonService {
  constructor(
    @Inject(DungeonRepository) private dungeonRepository: DungeonRepository,
    @Inject(BossService) private bossService: BossService,
  ) {}

  async getDungeon(userId: string, id: string): Promise<DungeonResponse> {
    const dungeon = await this.dungeonRepository.findById(id, userId);
    if (!dungeon) {
      throw new NotFoundException({
        code: 'DUNGEON_NOT_FOUND',
        message: 'Dungeon not found or access denied',
      });
    }

    const bosses = await this.bossService.listBosses(userId, { dungeonId: id });
    const totalBosses = bosses.length;
    const defeatedBosses = bosses.filter((b) => b.status === 'defeated').length;
    const progressPct = totalBosses === 0 ? 0 : Math.round((defeatedBosses / totalBosses) * 100);

    // FR-DUNG-003: Auto-complete dungeon when all contained bosses are defeated
    let status = dungeon.status as 'active' | 'completed';
    if (totalBosses > 0 && defeatedBosses === totalBosses && dungeon.status !== 'completed') {
      await this.dungeonRepository.update(id, userId, { status: 'completed' });
      status = 'completed';
    } else if (totalBosses > 0 && defeatedBosses < totalBosses && dungeon.status === 'completed') {
      await this.dungeonRepository.update(id, userId, { status: 'active' });
      status = 'active';
    }

    return {
      id: dungeon.id,
      userId: dungeon.userId,
      title: dungeon.title,
      status,
      totalBosses,
      defeatedBosses,
      progressPct,
      bosses,
      createdAt: dungeon.createdAt,
      updatedAt: dungeon.updatedAt,
    };
  }

  async listDungeons(userId: string): Promise<DungeonResponse[]> {
    const dungeons = await this.dungeonRepository.findMany(userId);
    const allBosses = await this.bossService.listBosses(userId);

    return dungeons.map((dungeon) => {
      const dungeonBosses = allBosses.filter((b) => b.dungeonId === dungeon.id);
      const totalBosses = dungeonBosses.length;
      const defeatedBosses = dungeonBosses.filter((b) => b.status === 'defeated').length;
      const progressPct = totalBosses === 0 ? 0 : Math.round((defeatedBosses / totalBosses) * 100);

      const status =
        totalBosses > 0 && defeatedBosses === totalBosses
          ? 'completed'
          : (dungeon.status as 'active' | 'completed');

      return {
        id: dungeon.id,
        userId: dungeon.userId,
        title: dungeon.title,
        status,
        totalBosses,
        defeatedBosses,
        progressPct,
        bosses: dungeonBosses,
        createdAt: dungeon.createdAt,
        updatedAt: dungeon.updatedAt,
      };
    });
  }

  async createDungeon(userId: string, input: CreateDungeonInput): Promise<DungeonResponse> {
    const dungeon = await this.dungeonRepository.create({
      userId,
      title: input.title,
    });

    return {
      id: dungeon.id,
      userId: dungeon.userId,
      title: dungeon.title,
      status: 'active',
      totalBosses: 0,
      defeatedBosses: 0,
      progressPct: 0,
      bosses: [],
      createdAt: dungeon.createdAt,
      updatedAt: dungeon.updatedAt,
    };
  }

  async updateDungeon(
    userId: string,
    id: string,
    input: UpdateDungeonInput,
  ): Promise<DungeonResponse> {
    const existing = await this.dungeonRepository.findById(id, userId);
    if (!existing) {
      throw new NotFoundException({
        code: 'DUNGEON_NOT_FOUND',
        message: 'Dungeon not found or access denied',
      });
    }

    const updateData: Record<string, unknown> = {};
    if (input.title !== undefined) updateData.title = input.title;
    if (input.status !== undefined) updateData.status = input.status;

    await this.dungeonRepository.update(id, userId, updateData);
    return this.getDungeon(userId, id);
  }

  async deleteDungeon(userId: string, id: string): Promise<{ success: boolean }> {
    const existing = await this.dungeonRepository.findById(id, userId);
    if (!existing) {
      throw new NotFoundException({
        code: 'DUNGEON_NOT_FOUND',
        message: 'Dungeon not found or access denied',
      });
    }

    // Unlink any bosses currently in this dungeon
    const bosses = await this.bossService.listBosses(userId, { dungeonId: id });
    for (const boss of bosses) {
      await this.bossService.updateBoss(userId, boss.id, { dungeonId: null });
    }

    await this.dungeonRepository.delete(id, userId);
    return { success: true };
  }
}
