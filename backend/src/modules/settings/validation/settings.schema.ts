import { z } from 'zod';

export const updateSettingsSchema = z.object({
  theme: z.enum(['system_dark', 'dark', 'light']).optional(),
  soundEnabled: z.boolean().optional(),
  hapticsEnabled: z.boolean().optional(),
  language: z.string().min(2).max(10).optional(),
  privacy: z.record(z.unknown()).optional(),
  dailyReminderTime: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/).nullable().optional(),
  notificationPreferences: z.record(z.boolean()).optional(),
});

export const setDifficultyModeSchema = z.object({
  difficultyMode: z.enum(['casual', 'hardcore']),
});
