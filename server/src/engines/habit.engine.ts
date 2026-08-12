// Centralized Habit Engine (FR-HABIT-1 to FR-HABIT-5, AC-5)

export interface HabitStreakCalculationInput {
  currentStreak: number;
  longestStreak: number;
  skipAllowance: number;
  consecutiveMisses: number;
  action: 'completed' | 'skipped';
}

export interface HabitStreakResult {
  newCurrentStreak: number;
  newLongestStreak: number;
  streakBroken: boolean;
  skipUsed: boolean;
}

export class HabitEngine {
  /**
   * Compute new streak count for a habit occurrence, applying skip allowance rules.
   */
  public static calculateHabitStreak(input: HabitStreakCalculationInput): HabitStreakResult {
    if (input.action === 'completed') {
      const newCurrentStreak = input.currentStreak + 1;
      const newLongestStreak = Math.max(input.longestStreak, newCurrentStreak);
      return {
        newCurrentStreak,
        newLongestStreak,
        streakBroken: false,
        skipUsed: false,
      };
    } else {
      // Habit skipped
      if (input.consecutiveMisses <= input.skipAllowance) {
        // Streak preserved via skip allowance grace count
        return {
          newCurrentStreak: input.currentStreak,
          newLongestStreak: input.longestStreak,
          streakBroken: false,
          skipUsed: true,
        };
      } else {
        // Streak breaks
        return {
          newCurrentStreak: 0,
          newLongestStreak: input.longestStreak,
          streakBroken: true,
          skipUsed: false,
        };
      }
    }
  }
}
