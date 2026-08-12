// Centralized XP Engine (Design Constraint C-4 & FR-XP-1 to FR-XP-4)

export interface QuestXPCalculationInput {
  difficulty: number; // 1 (Easy) to 5 (Legendary)
  priority: number; // 1 (Low) to 4 (Urgent & Important)
  estimatedMinutes: number;
  streakDays?: number;
  gateStability?: number; // 0.0 to 1.0 (if completed within a Gate focus session)
}

export interface LevelProgressionResult {
  level: number;
  currentXP: number;
  totalXP: number;
  xpForNextLevel: number;
  leveledUp: boolean;
}

export class XPEngine {
  /**
   * Base XP table by difficulty level (1 to 5)
   */
  private static readonly BASE_XP_TABLE: Record<number, number> = {
    1: 25,  // Easy
    2: 50,  // Medium
    3: 100, // Hard
    4: 200, // Very Hard
    5: 400, // Legendary
  };

  /**
   * Calculate XP awarded for completing a Quest.
   */
  public static calculateQuestXP(input: QuestXPCalculationInput): number {
    const baseXP = this.BASE_XP_TABLE[input.difficulty] || 50;

    // Duration Multiplier: bonus for longer tasks (capped at 3.0x)
    const durationMultiplier = Math.min(3.0, Math.max(0.5, input.estimatedMinutes / 30));

    // Priority Multiplier: 1.0 to 1.5x
    const priorityMultiplier = 1.0 + (input.priority - 1) * 0.15;

    // Streak Multiplier: up to +25% bonus for streaks
    const streakBonus = input.streakDays ? Math.min(0.25, input.streakDays * 0.02) : 0;

    // Gate Focus Bonus: up to +30% bonus for high stability focus sessions
    const gateBonus = input.gateStability !== undefined ? input.gateStability * 0.3 : 0;

    const totalXP = Math.round(baseXP * durationMultiplier * priorityMultiplier * (1 + streakBonus + gateBonus));
    return Math.max(5, totalXP);
  }

  /**
   * Calculate XP required to reach a specific level.
   * Formula: XP_req(Level) = 100 * (Level ^ 1.5)
   */
  public static xpRequiredForLevel(level: number): number {
    if (level <= 1) return 0;
    return Math.floor(100 * Math.pow(level - 1, 1.5));
  }

  /**
   * Compute Character Level and remaining XP from accumulated Total XP.
   */
  public static computeLevelFromTotalXP(totalXP: number): LevelProgressionResult {
    let level = 1;
    while (totalXP >= this.xpRequiredForLevel(level + 1)) {
      level++;
    }

    const currentLevelXPThreshold = this.xpRequiredForLevel(level);
    const nextLevelXPThreshold = this.xpRequiredForLevel(level + 1);

    const currentXP = totalXP - currentLevelXPThreshold;
    const xpForNextLevel = nextLevelXPThreshold - currentLevelXPThreshold;

    return {
      level,
      currentXP,
      totalXP,
      xpForNextLevel,
      leveledUp: false, // caller compares against previous level
    };
  }

  /**
   * Calculate XP awarded for completing a Habit occurrence.
   */
  public static calculateHabitXP(streakDays: number): number {
    const baseHabitXP = 30;
    const streakMultiplier = 1.0 + Math.min(1.0, streakDays * 0.05); // Up to 2.0x at 20-day streak
    return Math.round(baseHabitXP * streakMultiplier);
  }
}
