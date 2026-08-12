// Centralized Gate Focus Engine (FR-GATE-1 to FR-GATE-6)

export interface GateSessionOutcomeInput {
  plannedDurationSeconds: number;
  actualDurationSeconds: number;
  pauseCount: number;
  exitEarly: boolean;
}

export interface GateSessionOutcome {
  status: 'completed' | 'collapsed';
  stabilityFinal: number; // 0.00 to 100.00
  xpAwarded: number;
  manaDelta: number;
}

export class GateEngine {
  /**
   * Calculate final stability score and rewards/penalties for a Gate Focus Expedition.
   */
  public static calculateSessionOutcome(input: GateSessionOutcomeInput): GateSessionOutcome {
    const completionRatio = Math.min(1.0, input.actualDurationSeconds / Math.max(1, input.plannedDurationSeconds));

    // Stability calculation: degrades with pauses and early exit
    let stability = completionRatio * 100;
    stability -= input.pauseCount * 5; // -5% per pause
    if (input.exitEarly && completionRatio < 0.8) {
      stability -= 25; // early abort penalty
    }

    const stabilityFinal = Math.max(0, Math.min(100, Math.round(stability * 100) / 100));

    // Threshold for Gate completion vs collapse: 75% stability or 80% duration
    if (!input.exitEarly && completionRatio >= 0.8 && stabilityFinal >= 50) {
      const durationBonus = Math.round(input.plannedDurationSeconds / 60) * 2;
      return {
        status: 'completed',
        stabilityFinal,
        xpAwarded: 50 + durationBonus,
        manaDelta: 15,
      };
    } else {
      return {
        status: 'collapsed',
        stabilityFinal,
        xpAwarded: 0,
        manaDelta: -20,
      };
    }
  }
}
