export interface AchievementResponse {
  id: string;
  code: string;
  title: string;
  description: string;
  category: string;
  xpReward: number;
  badgeAssetUrl: string | null;
  criteria: Record<string, unknown>;
  unlocked?: boolean;
  unlockedAt?: Date | null;
}

export interface AchievementTriggerEvent {
  eventType: 'quest_complete' | 'gate_clear' | 'boss_defeat' | 'habit_streak';
  userId: string;
  payload?: {
    questId?: string;
    bossId?: string;
    gateSessionId?: string;
    stabilityPct?: number;
    durationS?: number;
    difficultyMode?: string;
    [key: string]: unknown;
  };
}
