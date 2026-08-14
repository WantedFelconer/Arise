import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import {
  memoryDb,
  StoredAchievement,
  StoredUserAchievement,
  StoredNotification,
} from '../../../db/memory/memory-db';

import achievementsCatalog from '../../../config/achievements_catalog.json';

@Injectable()
export class AchievementRepository {
  constructor(@Optional() private prisma?: PrismaService) {
    // Seed default in-memory achievements if empty
    if (memoryDb.achievements.size === 0) {
      for (const ach of achievementsCatalog as unknown as StoredAchievement[]) {
        memoryDb.achievements.set(ach.id, {
          ...ach,
          createdAt: new Date('2026-01-01T00:00:00Z'),
        });
      }
    }
  }

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findAll() {
    if (this.isDbAvailable()) {
      const items = await this.prisma!.achievement.findMany();
      if (items.length > 0) return items;
    }
    return Array.from(memoryDb.achievements.values());
  }

  async findByCode(code: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.achievement.findUnique({
        where: { code },
      });
    }

    return Array.from(memoryDb.achievements.values()).find((a) => a.code === code) || null;
  }

  async findUserUnlocks(userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.userAchievement.findMany({
        where: { userId },
        include: { achievement: true },
      });
    }

    return Array.from(memoryDb.userAchievements.values())
      .filter((ua) => ua.userId === userId)
      .map((ua) => ({
        ...ua,
        achievement: memoryDb.achievements.get(ua.achievementId)!,
      }));
  }

  async isUnlocked(userId: string, achievementId: string): Promise<boolean> {
    if (this.isDbAvailable()) {
      const found = await this.prisma!.userAchievement.findUnique({
        where: {
          userId_achievementId: { userId, achievementId },
        },
      });
      return Boolean(found);
    }

    const key = `${userId}:${achievementId}`;
    return memoryDb.userAchievements.has(key);
  }

  async recordUnlock(userId: string, achievementId: string): Promise<StoredUserAchievement> {
    const id = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      const res = await this.prisma!.userAchievement.create({
        data: {
          id,
          userId,
          achievementId,
          unlockedAt: now,
        },
      });
      return {
        id: res.id,
        userId: res.userId,
        achievementId: res.achievementId,
        unlockedAt: res.unlockedAt,
      };
    }

    const key = `${userId}:${achievementId}`;
    const userAch: StoredUserAchievement = {
      id,
      userId,
      achievementId,
      unlockedAt: now,
    };
    memoryDb.userAchievements.set(key, userAch);
    return userAch;
  }

  async createNotification(data: {
    userId: string;
    title: string;
    message: string;
    type: string;
    data?: Record<string, unknown>;
  }) {
    const notification: StoredNotification = {
      id: crypto.randomUUID(),
      userId: data.userId,
      title: data.title,
      message: data.message,
      type: data.type,
      read: false,
      data: data.data || null,
      createdAt: new Date(),
    };
    memoryDb.notifications.push(notification);
    return notification;
  }
}
