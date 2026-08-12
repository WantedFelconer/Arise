// Centralized Boss Engine (FR-BOSS-1 to FR-BOSS-4)

export interface BossDamageInput {
  bossHpCurrent: number;
  bossHpMax: number;
  questDifficulty: number; // 1 to 5
  estimatedMinutes: number;
  isHardcoreMode?: boolean;
}

export interface BossDamageResult {
  hpRemaining: number;
  damageDealt: number;
  isDefeated: boolean;
}

export class BossEngine {
  /**
   * Calculate damage dealt to a Boss when a related Quest is completed.
   */
  public static calculateBossDamage(input: BossDamageInput): BossDamageResult {
    const baseDamage = 50 * input.questDifficulty;
    const durationBonus = Math.min(2.0, input.estimatedMinutes / 30);
    const damageDealt = Math.round(baseDamage * durationBonus);

    const hpRemaining = Math.max(0, input.bossHpCurrent - damageDealt);
    const isDefeated = hpRemaining === 0;

    return {
      hpRemaining,
      damageDealt,
      isDefeated,
    };
  }

  /**
   * Calculate Boss HP recovery (regression penalty) for Hardcore Mode on missed deadlines or collapsed Gates.
   */
  public static calculateHardcoreHpRecovery(hpCurrent: number, hpMax: number, penaltyFactor = 0.05): number {
    const recovery = Math.round(hpMax * penaltyFactor);
    return Math.min(hpMax, hpCurrent + recovery);
  }
}
