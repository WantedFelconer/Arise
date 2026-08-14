import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { memoryDb, StoredGateSession } from '../../../db/memory/memory-db';

@Injectable()
export class GateRepository {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findById(id: string, userId?: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.gateSession.findFirst({
        where: {
          id,
          ...(userId ? { userId } : {}),
        },
      });
    }

    const session = memoryDb.gateSessions.get(id);
    if (!session) return null;
    if (userId && session.userId !== userId) return null;
    return session;
  }

  async findMany(userId: string, filters: { status?: string } = {}) {
    if (this.isDbAvailable()) {
      return this.prisma!.gateSession.findMany({
        where: {
          userId,
          ...(filters.status ? { status: filters.status } : {}),
        },
        orderBy: { startedAt: 'desc' },
      });
    }

    return Array.from(memoryDb.gateSessions.values())
      .filter((s) => {
        if (s.userId !== userId) return false;
        if (filters.status && s.status !== filters.status) return false;
        return true;
      })
      .sort((a, b) => b.startedAt.getTime() - a.startedAt.getTime());
  }

  async create(data: {
    userId: string;
    questId?: string | null;
    plannedDurationS: number;
    deviceId?: string | null;
    clientEventId?: string | null;
  }) {
    const id = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.gateSession.create({
        data: {
          id,
          userId: data.userId,
          questId: data.questId ?? null,
          plannedDurationS: data.plannedDurationS,
          status: 'active',
          startedAt: now,
          deviceId: data.deviceId ?? null,
          clientEventId: data.clientEventId ?? null,
        },
      });
    }

    const session: StoredGateSession = {
      id,
      userId: data.userId,
      questId: data.questId ?? null,
      plannedDurationS: data.plannedDurationS,
      actualDurationS: 0,
      pauseCount: 0,
      status: 'active',
      stabilityFinal: null,
      xpAwarded: null,
      manaDelta: null,
      exitReason: null,
      deviceId: data.deviceId ?? null,
      clientEventId: data.clientEventId ?? null,
      startedAt: now,
      pausedAt: null,
      totalPausedDurationS: 0,
      endedAt: null,
    };
    memoryDb.gateSessions.set(id, session);
    return session;
  }

  async update(id: string, userId: string, data: Partial<StoredGateSession>) {
    if (this.isDbAvailable()) {
      return this.prisma!.gateSession.update({
        where: { id },
        data: {
          ...(data.status ? { status: data.status } : {}),
          ...(data.actualDurationS !== undefined ? { actualDurationS: data.actualDurationS } : {}),
          ...(data.pauseCount !== undefined ? { pauseCount: data.pauseCount } : {}),
          ...(data.stabilityFinal !== undefined ? { stabilityFinal: data.stabilityFinal } : {}),
          ...(data.xpAwarded !== undefined ? { xpAwarded: data.xpAwarded } : {}),
          ...(data.manaDelta !== undefined ? { manaDelta: data.manaDelta } : {}),
          ...(data.exitReason !== undefined ? { exitReason: data.exitReason } : {}),
          ...(data.endedAt !== undefined ? { endedAt: data.endedAt } : {}),
        },
      });
    }

    const session = memoryDb.gateSessions.get(id);
    if (!session || session.userId !== userId) return null;
    const updated: StoredGateSession = {
      ...session,
      ...data,
    };
    memoryDb.gateSessions.set(id, updated);
    return updated;
  }
}
