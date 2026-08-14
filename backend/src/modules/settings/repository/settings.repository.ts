import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { memoryDb, StoredSettings } from '../../../db/memory/memory-db';
import { UpdateSettingsDto } from '../dto/settings.dto';

const DEFAULT_SETTINGS: Omit<StoredSettings, 'id' | 'userId' | 'createdAt' | 'updatedAt'> = {
  theme: 'system_dark',
  soundEnabled: true,
  hapticsEnabled: true,
  language: 'en',
  privacy: { analyticsSharing: false, crashReports: true },
  dailyReminderTime: '09:00',
  notificationPreferences: {
    questReminders: true,
    gateAlerts: true,
    dailyReview: true,
  },
};

@Injectable()
export class SettingsRepository {
  async getOrCreate(userId: string): Promise<StoredSettings> {
    const existing = memoryDb.settings.get(userId);
    if (existing) return existing;

    const now = new Date();
    const created: StoredSettings = {
      id: uuidv4(),
      userId,
      ...DEFAULT_SETTINGS,
      createdAt: now,
      updatedAt: now,
    };

    memoryDb.settings.set(userId, created);
    return created;
  }

  async update(userId: string, dto: UpdateSettingsDto): Promise<StoredSettings> {
    const settings = await this.getOrCreate(userId);

    if (dto.theme !== undefined) settings.theme = dto.theme;
    if (dto.soundEnabled !== undefined) settings.soundEnabled = dto.soundEnabled;
    if (dto.hapticsEnabled !== undefined) settings.hapticsEnabled = dto.hapticsEnabled;
    if (dto.language !== undefined) settings.language = dto.language;
    if (dto.privacy !== undefined) settings.privacy = dto.privacy;
    if (dto.dailyReminderTime !== undefined) settings.dailyReminderTime = dto.dailyReminderTime;
    if (dto.notificationPreferences !== undefined) settings.notificationPreferences = dto.notificationPreferences;
    settings.updatedAt = new Date();

    memoryDb.settings.set(userId, settings);
    return settings;
  }

  async setDifficultyMode(userId: string, mode: 'casual' | 'hardcore'): Promise<string> {
    const user = memoryDb.users.get(userId);
    if (user) {
      user.difficultyMode = mode;
      user.updatedAt = new Date();
      memoryDb.users.set(userId, user);
    }
    return mode;
  }

  async softDeleteUser(userId: string): Promise<Date> {
    const user = memoryDb.users.get(userId);
    const now = new Date();
    if (user) {
      user.deletedAt = now;
      user.updatedAt = now;
      memoryDb.users.set(userId, user);
    }
    // Invalidate refresh tokens
    for (const [id, token] of memoryDb.refreshTokens.entries()) {
      if (token.userId === userId) {
        token.revokedAt = now;
        memoryDb.refreshTokens.set(id, token);
      }
    }
    return now;
  }

  async cancelDeletion(userId: string): Promise<boolean> {
    const user = memoryDb.users.get(userId);
    if (user && user.deletedAt) {
      user.deletedAt = null;
      user.updatedAt = new Date();
      memoryDb.users.set(userId, user);
      return true;
    }
    return false;
  }
}
