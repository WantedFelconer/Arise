import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { memoryDb, StoredBoss } from '../../../db/memory/memory-db';

@Injectable()
export class BossRepository {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findById(id: string, userId?: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.boss.findFirst({
        where: {
          id,
          ...(userId ? { userId } : {}),
        },
      });
    }

    const boss = memoryDb.bosses.get(id);
    if (!boss) return null;
    if (userId && boss.userId !== userId) return null;
    return boss;
  }

  async findMany(userId: string, filters: { status?: string; dungeonId?: string } = {}) {
    if (this.isDbAvailable()) {
      return this.prisma!.boss.findMany({
        where: {
          userId,
          ...(filters.status ? { status: filters.status } : {}),
          ...(filters.dungeonId !== undefined ? { dungeonId: filters.dungeonId } : {}),
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    return Array.from(memoryDb.bosses.values())
      .filter((b) => {
        if (b.userId !== userId) return false;
        if (filters.status && b.status !== filters.status) return false;
        if (filters.dungeonId !== undefined && b.dungeonId !== filters.dungeonId) return false;
        return true;
      })
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async create(data: {
    userId: string;
    title: string;
    description?: string | null;
    hpMax: number;
    hpCurrent?: number;
    difficulty?: string;
    deadline?: Date | null;
    dungeonId?: string | null;
  }) {
    const id = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.boss.create({
        data: {
          id,
          userId: data.userId,
          title: data.title,
          description: data.description ?? null,
          hpMax: data.hpMax,
          hpCurrent: data.hpCurrent ?? data.hpMax,
          difficulty: data.difficulty ?? 'medium',
          status: 'active',
          deadline: data.deadline ?? null,
          dungeonId: data.dungeonId ?? null,
        },
      });
    }

    const boss: StoredBoss = {
      id,
      userId: data.userId,
      title: data.title,
      description: data.description ?? null,
      hpMax: data.hpMax,
      hpCurrent: data.hpCurrent ?? data.hpMax,
      difficulty: data.difficulty ?? 'medium',
      status: 'active',
      deadline: data.deadline ?? null,
      defeatedAt: null,
      dungeonId: data.dungeonId ?? null,
      createdAt: now,
      updatedAt: now,
    };
    memoryDb.bosses.set(id, boss);
    return boss;
  }

  async update(id: string, userId: string, data: Partial<StoredBoss>) {
    const now = new Date();
    if (this.isDbAvailable()) {
      return this.prisma!.boss.update({
        where: { id },
        data: {
          ...data,
          updatedAt: now,
        },
      });
    }

    const boss = memoryDb.bosses.get(id);
    if (!boss || boss.userId !== userId) return null;
    const updated: StoredBoss = {
      ...boss,
      ...data,
      updatedAt: now,
    };
    memoryDb.bosses.set(id, updated);
    return updated;
  }

  async delete(id: string, userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.boss.deleteMany({
        where: { id, userId },
      });
    }

    const boss = memoryDb.bosses.get(id);
    if (boss && boss.userId === userId) {
      memoryDb.bosses.delete(id);
      return { count: 1 };
    }
    return { count: 0 };
  }
}
