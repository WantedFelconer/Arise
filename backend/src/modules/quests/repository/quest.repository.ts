import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { memoryDb, StoredQuest } from '../../../db/memory/memory-db';
import { QuestListQueryInput } from '../validation/quest.schema';
import { Prisma } from '@prisma/client';

@Injectable()
export class QuestRepository {
  // In-memory undo buffer for 10-second undo window: key = questId, value = { previousState, timestamp }
  private undoBuffer = new Map<string, { previousState: StoredQuest; timestamp: number }>();

  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findById(id: string, userId?: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.quest.findFirst({
        where: {
          id,
          ...(userId ? { userId } : {}),
        },
        include: {
          subQuests: true,
        },
      });
    }

    const quest = memoryDb.quests.get(id);
    if (!quest) return null;
    if (userId && quest.userId !== userId) return null;

    // Load subQuests if any
    const subQuests = Array.from(memoryDb.quests.values()).filter(
      (q) => q.parentQuestId === id && q.status !== 'trashed',
    );

    return {
      ...quest,
      subQuests,
    };
  }

  async findMany(userId: string, filters: QuestListQueryInput = {}) {
    if (this.isDbAvailable()) {
      const where: Prisma.QuestWhereInput = {
        userId,
        ...(filters.status ? { status: filters.status } : { status: { not: 'trashed' } }),
        ...(filters.priority ? { priority: filters.priority } : {}),
        ...(filters.difficulty ? { difficulty: filters.difficulty } : {}),
        ...(filters.bossId ? { bossId: filters.bossId } : {}),
        ...(filters.parentQuestId !== undefined ? { parentQuestId: filters.parentQuestId } : {}),
        ...(filters.tag ? { tags: { has: filters.tag } } : {}),
        ...(filters.search
          ? {
              OR: [
                { title: { contains: filters.search, mode: 'insensitive' } },
                { description: { contains: filters.search, mode: 'insensitive' } },
              ],
            }
          : {}),
      };

      const orderBy: Prisma.QuestOrderByWithRelationInput = filters.sortBy
        ? { [filters.sortBy]: filters.sortOrder || 'desc' }
        : { createdAt: 'desc' };

      return this.prisma!.quest.findMany({
        where,
        orderBy,
      });
    }

    let items = Array.from(memoryDb.quests.values()).filter((q) => q.userId === userId);

    if (filters.status) {
      items = items.filter((q) => q.status === filters.status);
    } else {
      items = items.filter((q) => q.status !== 'trashed');
    }

    if (filters.priority) {
      items = items.filter((q) => q.priority === filters.priority);
    }
    if (filters.difficulty) {
      items = items.filter((q) => q.difficulty === filters.difficulty);
    }
    if (filters.bossId) {
      items = items.filter((q) => q.bossId === filters.bossId);
    }
    if (filters.parentQuestId !== undefined) {
      items = items.filter((q) => q.parentQuestId === filters.parentQuestId);
    }
    if (filters.tag) {
      items = items.filter((q) => q.tags.includes(filters.tag!));
    }
    if (filters.search) {
      const term = filters.search.toLowerCase();
      items = items.filter(
        (q) =>
          q.title.toLowerCase().includes(term) ||
          (q.description && q.description.toLowerCase().includes(term)),
      );
    }

    if (filters.sortBy) {
      const field = filters.sortBy;
      const order = filters.sortOrder === 'asc' ? 1 : -1;
      items.sort((a, b) => {
        const valA = a[field as keyof StoredQuest];
        const valB = b[field as keyof StoredQuest];
        if (valA === valB) return 0;
        if (valA == null) return 1;
        if (valB == null) return -1;
        return valA > valB ? order : -order;
      });
    } else {
      items.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    }

    return items;
  }

  async findChildren(parentQuestId: string, userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.quest.findMany({
        where: { parentQuestId, userId, status: { not: 'trashed' } },
      });
    }

    return Array.from(memoryDb.quests.values()).filter(
      (q) => q.parentQuestId === parentQuestId && q.userId === userId && q.status !== 'trashed',
    );
  }

  async create(data: {
    id?: string;
    userId: string;
    title: string;
    description?: string | null;
    questType?: string;
    priority?: string;
    difficulty?: string;
    estimatedMinutes?: number;
    deadline?: Date | null;
    tags?: string[];
    bossId?: string | null;
    parentQuestId?: string | null;
    recurrenceRule?: Record<string, unknown> | null;
    metadata?: Record<string, unknown> | null;
    status?: string;
  }) {
    const id = data.id || crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.quest.create({
        data: {
          id,
          userId: data.userId,
          title: data.title,
          description: data.description ?? null,
          questType: data.questType ?? 'daily',
          priority: data.priority ?? 'medium',
          difficulty: data.difficulty ?? 'medium',
          status: data.status ?? 'pending',
          estimatedMinutes: data.estimatedMinutes ?? 30,
          deadline: data.deadline ?? null,
          tags: data.tags ?? [],
          bossId: data.bossId ?? null,
          parentQuestId: data.parentQuestId ?? null,
          recurrenceRule: data.recurrenceRule
            ? (data.recurrenceRule as Prisma.InputJsonValue)
            : Prisma.DbNull,
        },
      });
    }

    const quest: StoredQuest = {
      id,
      userId: data.userId,
      title: data.title,
      description: data.description ?? null,
      questType: data.questType ?? 'daily',
      priority: data.priority ?? 'medium',
      difficulty: data.difficulty ?? 'medium',
      status: data.status ?? 'pending',
      estimatedMinutes: data.estimatedMinutes ?? 30,
      actualMinutes: null,
      deadline: data.deadline ?? null,
      recurrenceRule: data.recurrenceRule ?? null,
      tags: data.tags ?? [],
      isFavorite: false,
      isPinned: false,
      eisenhowerQuadrant: null,
      metadata: data.metadata ?? null,
      bossId: data.bossId ?? null,
      parentQuestId: data.parentQuestId ?? null,
      completedAt: null,
      deletedAt: null,
      createdAt: now,
      updatedAt: now,
    };
    memoryDb.quests.set(id, quest);
    return quest;
  }

  async update(id: string, userId: string, data: Partial<StoredQuest>) {
    const now = new Date();
    if (this.isDbAvailable()) {
      const prismaData: Prisma.QuestUpdateInput = {
        ...(data.title ? { title: data.title } : {}),
        ...(data.description !== undefined ? { description: data.description } : {}),
        ...(data.status ? { status: data.status } : {}),
        ...(data.priority ? { priority: data.priority } : {}),
        ...(data.difficulty ? { difficulty: data.difficulty } : {}),
        ...(data.estimatedMinutes ? { estimatedMinutes: data.estimatedMinutes } : {}),
        ...(data.actualMinutes !== undefined ? { actualMinutes: data.actualMinutes } : {}),
        ...(data.deadline !== undefined ? { deadline: data.deadline } : {}),
        ...(data.tags ? { tags: data.tags } : {}),
        ...(data.bossId !== undefined
          ? { boss: data.bossId ? { connect: { id: data.bossId } } : { disconnect: true } }
          : {}),
        ...(data.parentQuestId !== undefined
          ? {
              parentQuest: data.parentQuestId
                ? { connect: { id: data.parentQuestId } }
                : { disconnect: true },
            }
          : {}),
        ...(data.completedAt !== undefined ? { completedAt: data.completedAt } : {}),
        ...(data.isFavorite !== undefined ? { isFavorite: data.isFavorite } : {}),
        ...(data.isPinned !== undefined ? { isPinned: data.isPinned } : {}),
        updatedAt: now,
      };

      return this.prisma!.quest.update({
        where: { id },
        data: prismaData,
      });
    }

    const quest = memoryDb.quests.get(id);
    if (!quest || quest.userId !== userId) return null;

    // Capture previous state for undo window if this is a completion or deletion
    if (data.status === 'completed' || data.status === 'trashed') {
      this.undoBuffer.set(id, {
        previousState: { ...quest },
        timestamp: Date.now(),
      });
    }

    const updated: StoredQuest = {
      ...quest,
      ...data,
      updatedAt: now,
    };
    memoryDb.quests.set(id, updated);
    return updated;
  }

  /**
   * FR-QST-018: Undo completion or deletion within a 10-second window
   */
  async undo(id: string, userId: string): Promise<{ success: boolean; quest?: StoredQuest }> {
    const entry = this.undoBuffer.get(id);
    if (!entry) {
      return { success: false };
    }

    const elapsedMs = Date.now() - entry.timestamp;
    if (elapsedMs > 10000) {
      // Expired 10-second window
      this.undoBuffer.delete(id);
      return { success: false };
    }

    const restoredState = entry.previousState;
    if (restoredState.userId !== userId) return { success: false };

    memoryDb.quests.set(id, {
      ...restoredState,
      updatedAt: new Date(),
    });
    this.undoBuffer.delete(id);

    return { success: true, quest: memoryDb.quests.get(id) };
  }

  async softDelete(id: string, userId: string) {
    return this.update(id, userId, {
      status: 'trashed',
      deletedAt: new Date(),
    });
  }

  async restore(id: string, userId: string) {
    return this.update(id, userId, {
      status: 'pending',
      deletedAt: null,
    });
  }
}
