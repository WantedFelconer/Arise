import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { SettingsRepository } from '../repository/settings.repository';
import { memoryDb } from '../../../db/memory/memory-db';
import {
  SetDifficultyModeDto,
  SettingsResponse,
  UpdateSettingsDto,
  UserDataExportResponse,
} from '../dto/settings.dto';

@Injectable()
export class SettingsService {
  constructor(@Inject(SettingsRepository) private settingsRepository: SettingsRepository) {}

  async getSettings(userId: string): Promise<SettingsResponse> {
    const user = memoryDb.users.get(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User account not found',
      });
    }

    const settings = await this.settingsRepository.getOrCreate(userId);

    return {
      userId,
      theme: settings.theme,
      soundEnabled: settings.soundEnabled,
      hapticsEnabled: settings.hapticsEnabled,
      language: settings.language,
      privacy: settings.privacy,
      dailyReminderTime: settings.dailyReminderTime,
      notificationPreferences: settings.notificationPreferences,
      difficultyMode: user.difficultyMode,
      deletedAt: user.deletedAt,
      createdAt: settings.createdAt,
      updatedAt: settings.updatedAt,
    };
  }

  async updateSettings(userId: string, dto: UpdateSettingsDto): Promise<SettingsResponse> {
    await this.settingsRepository.update(userId, dto);
    return this.getSettings(userId);
  }

  async setDifficultyMode(userId: string, dto: SetDifficultyModeDto): Promise<{ difficultyMode: string }> {
    const mode = await this.settingsRepository.setDifficultyMode(userId, dto.difficultyMode);
    return { difficultyMode: mode };
  }

  async getDifficultyMode(userId: string): Promise<{ difficultyMode: string }> {
    const user = memoryDb.users.get(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User account not found',
      });
    }
    return { difficultyMode: user.difficultyMode || 'casual' };
  }

  /**
   * FR-SET-002: Full Data Portability Export
   * Compiles JSON archive across all user-owned domain data.
   */
  async exportUserData(userId: string): Promise<UserDataExportResponse> {
    const user = memoryDb.users.get(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User account not found',
      });
    }

    const character = memoryDb.characters.get(userId) || null;
    const settings = (await this.settingsRepository.getOrCreate(userId)) as unknown as Record<string, unknown>;

    const xpTransactions = memoryDb.xpTransactions.filter((tx) => tx.characterId === userId);
    const manaTransactions = memoryDb.manaTransactions.filter((tx) => tx.characterId === userId);
    const quests = Array.from(memoryDb.quests.values()).filter((q) => q.userId === userId);
    const habits = Array.from(memoryDb.habits.values()).filter((h) => h.userId === userId);
    const bosses = Array.from(memoryDb.bosses.values()).filter((b) => b.userId === userId);
    const dungeons = Array.from(memoryDb.dungeons.values()).filter((d) => d.userId === userId);
    const gateSessions = Array.from(memoryDb.gateSessions.values()).filter((g) => g.userId === userId);
    const screenTimeSessions = memoryDb.screenTimeSessions.filter((s) => s.userId === userId);
    const appCategoryOverrides = Array.from(memoryDb.appCategories.values()).filter((c) => c.userId === userId);
    const reminders = Array.from(memoryDb.reminders.values()).filter((r) => r.userId === userId);
    const notes = Array.from(memoryDb.notes.values()).filter((n) => n.userId === userId);
    const noteFolders = Array.from(memoryDb.noteFolders.values()).filter((f) => f.userId === userId);
    const fitnessLogs = memoryDb.fitnessLogs.filter((f) => f.userId === userId);
    const notifications = memoryDb.notifications.filter((n) => n.userId === userId);
    const aiGeneratedPlans = Array.from(memoryDb.aiGeneratedPlans.values()).filter((p) => p.userId === userId);
    const aiConversations = Array.from(memoryDb.aiConversations.values()).filter((c) => c.userId === userId);
    const userAchievements = Array.from(memoryDb.userAchievements.values()).filter((ua) => ua.userId === userId);

    return {
      exportedAt: new Date().toISOString(),
      user: {
        id: user.id,
        email: user.email,
        difficultyMode: user.difficultyMode,
        createdAt: user.createdAt,
      },
      settings,
      character: character as unknown as Record<string, unknown> | null,
      xpTransactions,
      manaTransactions,
      quests,
      habits,
      bosses,
      dungeons,
      gateSessions,
      screenTimeSessions,
      appCategoryOverrides,
      reminders,
      notes,
      noteFolders,
      fitnessLogs,
      notifications,
      aiGeneratedPlans,
      aiConversations,
      userAchievements,
    };
  }

  /**
   * FR-SET-002 & FR-AUTH-009: Soft-delete account and schedule 30-day purge worker
   */
  async requestAccountDeletion(userId: string): Promise<{ deletedAt: Date; purgeScheduledDays: number }> {
    const deletedAt = await this.settingsRepository.softDeleteUser(userId);
    return {
      deletedAt,
      purgeScheduledDays: 30,
    };
  }

  async cancelAccountDeletion(userId: string): Promise<{ restored: boolean }> {
    const restored = await this.settingsRepository.cancelDeletion(userId);
    if (!restored) {
      throw new NotFoundException({
        code: 'NO_DELETION_PENDING',
        message: 'No pending deletion found for this account',
      });
    }
    return { restored: true };
  }
}
