export interface LifetimeStatsResponse {
  quests: {
    total: number;
    completed: number;
    active: number;
    trashed: number;
    completionRatePct: number;
    totalEstimatedMinutes: number;
    totalActualMinutes: number;
  };
  focus: {
    totalSessions: number;
    completedSessions: number;
    collapsedSessions: number;
    totalFocusMinutes: number;
    successRatePct: number;
    averageStabilityPct: number;
  };
  bosses: {
    total: number;
    active: number;
    defeated: number;
  };
  dungeons: {
    total: number;
    active: number;
    completed: number;
  };
  progression: {
    level: number;
    rank: string;
    totalXp: number;
    currentMana: number;
    maxMana: number;
    currentStreak: number;
    longestStreak: number;
  };
  screenTime: {
    totalMinutes: number;
    manaDeltaNet: number;
  };
  fitness: {
    totalLogs: number;
    totalSteps: number;
    totalWorkoutMinutes: number;
  };
}
