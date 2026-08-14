export interface SettingsResponse {
  userId: string;
  theme: string;
  soundEnabled: boolean;
  hapticsEnabled: boolean;
  language: string;
  privacy: Record<string, unknown>;
  dailyReminderTime: string | null;
  notificationPreferences: Record<string, boolean>;
  difficultyMode: string;
  deletedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateSettingsDto {
  theme?: string;
  soundEnabled?: boolean;
  hapticsEnabled?: boolean;
  language?: string;
  privacy?: Record<string, unknown>;
  dailyReminderTime?: string | null;
  notificationPreferences?: Record<string, boolean>;
}

export interface SetDifficultyModeDto {
  difficultyMode: 'casual' | 'hardcore';
}

export interface UserDataExportResponse {
  exportedAt: string;
  user: {
    id: string;
    email: string;
    difficultyMode: string;
    createdAt: Date;
  };
  settings: Record<string, unknown>;
  character: Record<string, unknown> | null;
  xpTransactions: unknown[];
  manaTransactions: unknown[];
  quests: unknown[];
  habits: unknown[];
  bosses: unknown[];
  dungeons: unknown[];
  gateSessions: unknown[];
  screenTimeSessions: unknown[];
  appCategoryOverrides: unknown[];
  reminders: unknown[];
  notes: unknown[];
  noteFolders: unknown[];
  fitnessLogs: unknown[];
  notifications: unknown[];
  aiGeneratedPlans: unknown[];
  aiConversations: unknown[];
  userAchievements: unknown[];
}
