import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import {
  memoryDb,
  StoredScreenTimeSession,
  StoredAppCategory,
} from '../../../db/memory/memory-db';

@Injectable()
export class ScreenTimeRepository {
  async createSessions(
    userId: string,
    sessions: Array<{
      appPackage: string;
      category: string;
      durationS: number;
      occurredAt: Date;
      manaModifierApplied: number;
    }>,
  ): Promise<StoredScreenTimeSession[]> {
    const created: StoredScreenTimeSession[] = [];
    for (const s of sessions) {
      const stored: StoredScreenTimeSession = {
        id: uuidv4(),
        userId,
        appPackage: s.appPackage,
        category: s.category,
        durationS: s.durationS,
        occurredAt: s.occurredAt,
        manaModifierApplied: s.manaModifierApplied,
        createdAt: new Date(),
      };
      memoryDb.screenTimeSessions.push(stored);
      created.push(stored);
    }
    return created;
  }

  async findSessionsByUser(
    userId: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<StoredScreenTimeSession[]> {
    let items = memoryDb.screenTimeSessions.filter((s) => s.userId === userId);
    if (startDate) {
      items = items.filter((s) => s.occurredAt >= startDate);
    }
    if (endDate) {
      items = items.filter((s) => s.occurredAt <= endDate);
    }
    return items;
  }

  async getUserAppOverrides(userId: string): Promise<Map<string, StoredAppCategory>> {
    const overrides = new Map<string, StoredAppCategory>();
    for (const cat of memoryDb.appCategories.values()) {
      if (cat.userId === userId) {
        overrides.set(cat.appPackage, cat);
      }
    }
    return overrides;
  }

  async upsertAppCategory(
    userId: string,
    appPackage: string,
    category: string,
    manaModifierPerMinute?: number,
  ): Promise<StoredAppCategory> {
    const key = `${userId}:${appPackage}`;
    const existing = memoryDb.appCategories.get(key);
    const now = new Date();

    const stored: StoredAppCategory = {
      id: existing?.id || uuidv4(),
      userId,
      appPackage,
      category,
      manaModifierPerMinute,
      createdAt: existing?.createdAt || now,
      updatedAt: now,
    };

    memoryDb.appCategories.set(key, stored);
    return stored;
  }

  async deleteByUserId(userId: string): Promise<number> {
    const initLen = memoryDb.screenTimeSessions.length;
    memoryDb.screenTimeSessions = memoryDb.screenTimeSessions.filter((s) => s.userId !== userId);
    for (const [k, v] of memoryDb.appCategories.entries()) {
      if (v.userId === userId) {
        memoryDb.appCategories.delete(k);
      }
    }
    return initLen - memoryDb.screenTimeSessions.length;
  }
}
