// Centralized Mana Engine (FR-MANA-1 to FR-MANA-4)

export class ManaEngine {
  public static readonly MANA_FLOOR = 0;
  public static readonly MANA_CEILING = 100;

  // Replenishment gains
  public static readonly GAIN_QUEST_COMPLETE = 10;
  public static readonly GAIN_GATE_COMPLETE = 15;
  public static readonly GAIN_EXERCISE = 15;
  public static readonly GAIN_SLEEP_REST = 25;

  // Depletion penalties
  public static readonly PENALTY_GATE_COLLAPSE = 20;
  public static readonly PENALTY_MISSED_DEADLINE = 15;
  public static readonly PENALTY_DISTRACTION_HOUR = 8;

  /**
   * Apply a Mana change, strictly clamping between floor (0) and ceiling (100).
   */
  public static applyManaDelta(currentMana: number, delta: number): number {
    const newMana = currentMana + delta;
    return Math.min(this.MANA_CEILING, Math.max(this.MANA_FLOOR, newMana));
  }

  /**
   * Calculate Mana depletion penalty for high distraction screen time sessions.
   * @param durationSeconds Screen time duration in seconds
   * @param category App category ('High Distraction', 'Entertainment', etc.)
   */
  public static calculateScreenTimeManaModifier(durationSeconds: number, category: string): number {
    if (category !== 'High Distraction' && category !== 'Entertainment') {
      return 0;
    }

    const hours = durationSeconds / 3600;
    const ratePerHours = category === 'High Distraction' ? this.PENALTY_DISTRACTION_HOUR : 4;
    return -Math.round(hours * ratePerHours);
  }
}
