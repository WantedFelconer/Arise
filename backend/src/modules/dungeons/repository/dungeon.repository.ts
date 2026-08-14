import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { memoryDb, StoredDungeon } from '../../../db/memory/memory-db';

@Injectable()
export class DungeonRepository {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findById(id: string, userId?: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.dungeon.findFirst({
        where: {
          id,
          ...(userId ? { userId } : {}),
        },
      });
    }

    const dungeon = memoryDb.dungeons.get(id);
    if (!dungeon) return null;
    if (userId && dungeon.userId !== userId) return null;
    return dungeon;
  }

  async findMany(userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.dungeon.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });
    }

    return Array.from(memoryDb.dungeons.values())
      .filter((d) => d.userId === userId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async create(data: { userId: string; title: string }) {
    const id = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.dungeon.create({
        data: {
          id,
          userId: data.userId,
          title: data.title,
          status: 'active',
        },
      });
    }

    const dungeon: StoredDungeon = {
      id,
      userId: data.userId,
      title: data.title,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    };
    memoryDb.dungeons.set(id, dungeon);
    return dungeon;
  }

  async update(id: string, userId: string, data: Partial<StoredDungeon>) {
    const now = new Date();
    if (this.isDbAvailable()) {
      return this.prisma!.dungeon.update({
        where: { id },
        data: {
          ...data,
          updatedAt: now,
        },
      });
    }

    const dungeon = memoryDb.dungeons.get(id);
    if (!dungeon || dungeon.userId !== userId) return null;
    const updated: StoredDungeon = {
      ...dungeon,
      ...data,
      updatedAt: now,
    };
    memoryDb.dungeons.set(id, updated);
    return updated;
  }

  async delete(id: string, userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.dungeon.deleteMany({
        where: { id, userId },
      });
    }

    const dungeon = memoryDb.dungeons.get(id);
    if (dungeon && dungeon.userId === userId) {
      memoryDb.dungeons.delete(id);
      return { count: 1 };
    }
    return { count: 0 };
  }
}
