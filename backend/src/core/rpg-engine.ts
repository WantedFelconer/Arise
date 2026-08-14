import rankThresholds from '../config/rank_thresholds.json';
import circadianCurves from '../config/circadian_curves.json';
import bossDamageTable from '../config/boss_damage_table.json';
import gateRewardsConfig from '../config/gate_rewards.json';
import questPenaltiesConfig from '../config/quest_penalties.json';
import screenTimeConfig from '../config/screen_time_modifiers.json';
import fitnessConfig from '../config/fitness_thresholds.json';

export interface CharacterStats {
  intelligence: number;
  discipline: number;
  fitness: number;
  creativity: number;
  coding: number;
  business: number;
  health: number;
}

export type StatKey = keyof CharacterStats;

export const DEFAULT_STATS: CharacterStats = {
  intelligence: 10,
  discipline: 10,
  fitness: 10,
  creativity: 10,
  coding: 10,
  business: 10,
  health: 10,
};

export interface CalculateXpOptions {
  baseXp: number;
  difficultyMultiplier?: number;
  streakBonus?: number;
  gateStabilityBonus?: number;
}

export interface RankThreshold {
  rank: string;
  minLevel: number;
  maxLevel: number;
}

export interface ScreenTimeSessionInput {
  appPackage: string;
  category?: string;
  durationS: number;
}

export interface FitnessRewardResult {
  xp: number;
  manaDelta: number;
  statKey: StatKey;
  thresholdReached: boolean;
  label?: string;
}

export class RpgEngine {
  /**
   * FR-CHAR-001: level = floor(0.1 * sqrt(total_xp)) + 1
   * Computes character level from total accumulated XP.
   */
  static calculateLevel(totalXp: number): number {
    const validXp = Math.max(0, Math.floor(totalXp || 0));
    return Math.floor(0.1 * Math.sqrt(validXp)) + 1;
  }

  /**
   * Computes the cumulative XP required to reach a specific level.
   * Inverse of calculateLevel: level = 0.1 * sqrt(xp) + 1 => sqrt(xp) = (level - 1) / 0.1 = 10*(level - 1)
   * => xp = 100 * (level - 1)^2
   */
  static xpForLevel(level: number): number {
    if (level <= 1) return 0;
    return 100 * Math.pow(level - 1, 2);
  }

  /**
   * FR-CHAR-003: Config-driven rank evaluation (E < 10, D < 25, C < 45, B < 70, A < 100, S >= 100)
   */
  static calculateRank(level: number): string {
    const thresholds: RankThreshold[] = rankThresholds as RankThreshold[];
    const match = thresholds.find((t) => level >= t.minLevel && level <= t.maxLevel);
    return match ? match.rank : 'E';
  }

  /**
   * FR-XP-002: XP award formula
   * XP = base_value * difficulty_multiplier * (1 + streak_bonus) * (1 + gate_stability_bonus)
   */
  static calculateQuestXp(options: CalculateXpOptions): number {
    const baseXp = Math.max(0, options.baseXp || 0);
    const difficultyMultiplier = Math.max(0, options.difficultyMultiplier ?? 1.0);
    const streakBonus = Math.max(0, options.streakBonus ?? 0.0);
    const gateStabilityBonus = Math.max(0, options.gateStabilityBonus ?? 0.0);

    const calculated = baseXp * difficultyMultiplier * (1 + streakBonus) * (1 + gateStabilityBonus);
    return Math.round(calculated);
  }

  /**
   * FR-BOSS-002: Config-driven boss damage calculation
   * Damage = base_damage(difficulty, priority) * focus_quality_multiplier
   */
  static calculateBossDamage(
    difficulty: string = 'medium',
    priority: string = 'medium',
    focusQualityMultiplier: number = 1.0,
  ): number {
    const diffKey = difficulty.toLowerCase() as keyof typeof bossDamageTable.baseDamage;
    const prioKey = priority.toLowerCase() as 'low' | 'medium' | 'high' | 'urgent';

    const diffMap = bossDamageTable.baseDamage[diffKey] || bossDamageTable.baseDamage.medium;
    const baseDamage = diffMap[prioKey] || diffMap.medium || 30;

    return Math.max(1, Math.round(baseDamage * Math.max(0.1, focusQualityMultiplier)));
  }

  /**
   * FR-BOSS-003: Config-driven boss defeat rewards
   */
  static getBossDefeatRewards(difficulty: string = 'medium'): { xp: number; coins: number } {
    const diffKey = difficulty.toLowerCase() as keyof typeof bossDamageTable.bossRewards;
    const reward = bossDamageTable.bossRewards[diffKey] || bossDamageTable.bossRewards.medium;
    return { ...reward };
  }

  /**
   * FR-GATE-004: Config-driven Gate completion XP calculation
   * XP = duration_minutes * xp_per_minute(difficulty) * (stability_pct / 100)
   */
  static calculateGateXp(
    durationSeconds: number,
    difficulty: string = 'medium',
    stabilityPct: number = 100,
  ): number {
    const diffKey = difficulty.toLowerCase() as keyof typeof gateRewardsConfig.xpPerMinute;
    const xpPerMin = gateRewardsConfig.xpPerMinute[diffKey] ?? gateRewardsConfig.xpPerMinute.medium;
    const durationMinutes = Math.max(1, Math.round(durationSeconds / 60));
    const stabilityMultiplier = Math.max(0, Math.min(100, stabilityPct)) / 100;

    return Math.max(1, Math.round(durationMinutes * xpPerMin * stabilityMultiplier));
  }

  /**
   * FR-GATE-004: Mana reward for cleared Gate session
   */
  static getGateClearManaReward(): number {
    return gateRewardsConfig.manaRewardOnClear || 10;
  }

  /**
   * FR-GATE-005 & §19 AC-GATE-005: Gate collapse penalty
   */
  static getGateCollapsePenalty(difficultyMode: string = 'casual') {
    if (difficultyMode === 'hardcore') {
      return { ...gateRewardsConfig.hardcorePenalty };
    }
    return { ...gateRewardsConfig.casualPenalty };
  }

  /**
   * FR-QST-013: Deadline miss mana penalty (Hardcore mode)
   */
  static getDeadlineMissPenalty(difficultyMode: string = 'casual') {
    const modeKey = difficultyMode === 'hardcore' ? 'hardcore' : 'casual';
    return { ...questPenaltiesConfig.deadlineMissPenalty[modeKey] };
  }

  /**
   * FR-MANA-001: Clamps current mana between 0 and max_mana
   */
  static clampMana(mana: number, maxMana: number): number {
    const validMax = Math.max(1, maxMana || 100);
    return Math.max(0, Math.min(validMax, mana));
  }

  /**
   * FR-ENERGY-001: Computes hourly energy curve from circadian profile (0..23)
   */
  static calculateHourlyEnergy(profileType: string, hour: number): number {
    const validHour = Math.max(0, Math.min(23, Math.floor(hour || 0)));
    const curves = circadianCurves as Record<string, Record<string, number>>;
    const profile = curves[profileType] ?? curves['early_bird'] ?? curves['custom'];
    if (!profile) return 75;
    return profile[validHour.toString()] ?? 75;
  }

  /**
   * FR-SCREEN-001 & FR-SCREEN-002: Server-authoritative Screen Time Mana calculation
   * Matches app package to category, evaluates rate per minute, returns integer Mana delta.
   */
  static calculateScreenTimeManaImpact(
    session: ScreenTimeSessionInput,
    userCategoryOverrides?: Map<string, { category: string; manaModifierPerMinute?: number }>,
  ): { category: string; manaDelta: number } {
    const durationMinutes = Math.max(0, session.durationS / 60);
    let category = session.category;
    let customModifierPerMin: number | undefined;

    // Check user override for appPackage
    if (userCategoryOverrides && userCategoryOverrides.has(session.appPackage)) {
      const override = userCategoryOverrides.get(session.appPackage)!;
      category = override.category || category;
      customModifierPerMin = override.manaModifierPerMinute;
    }

    // Infer category from default package maps if not provided
    if (!category) {
      const cats = screenTimeConfig.categories as Record<
        string,
        { defaultApps?: string[]; manaModifierPerMinute: number }
      >;
      for (const [catKey, catVal] of Object.entries(cats)) {
        if (catVal.defaultApps && catVal.defaultApps.includes(session.appPackage)) {
          category = catKey;
          break;
        }
      }
    }

    const finalCategory = category || screenTimeConfig.defaultCategory || 'communication';
    const catConfig =
      (
        screenTimeConfig.categories as Record<
          string,
          { manaModifierPerMinute: number; manaModifierPer30Min: number }
        >
      )[finalCategory] || screenTimeConfig.categories.communication;

    const ratePerMin =
      typeof customModifierPerMin === 'number'
        ? customModifierPerMin
        : (catConfig.manaModifierPer30Min ? catConfig.manaModifierPer30Min / 30 : catConfig.manaModifierPerMinute);

    const calculatedDelta = ratePerMin * durationMinutes;
    const manaDelta = Math.round(calculatedDelta);

    return {
      category: finalCategory,
      manaDelta,
    };
  }

  /**
   * FR-FIT-002: Activity threshold-based XP and Mana progression
   */
  static calculateFitnessRewards(
    logType: string,
    value: number,
    _unit?: string,
  ): FitnessRewardResult {
    const thresholds = (fitnessConfig.thresholds as Record<
      string,
      Array<{ min: number; xp: number; mana: number; statKey: string; label?: string }>
    >)[logType.toLowerCase()];

    if (!thresholds || thresholds.length === 0) {
      return {
        xp: 0,
        manaDelta: 0,
        statKey: 'fitness',
        thresholdReached: false,
      };
    }

    // Find highest threshold achieved
    let highestMatch:
      | { min: number; xp: number; mana: number; statKey: string; label?: string }
      | undefined;
    for (const t of thresholds) {
      if (value >= t.min) {
        if (!highestMatch || t.min > highestMatch.min) {
          highestMatch = t;
        }
      }
    }

    if (!highestMatch) {
      return {
        xp: 0,
        manaDelta: 0,
        statKey: (thresholds[0]?.statKey as StatKey) || 'fitness',
        thresholdReached: false,
      };
    }

    return {
      xp: highestMatch.xp,
      manaDelta: highestMatch.mana,
      statKey: highestMatch.statKey as StatKey,
      thresholdReached: true,
      label: highestMatch.label,
    };
  }

  /**
   * FR-STAT-001 & FR-ACH: Computes consecutive day streaks from completion date list
   */
  static calculateStreakFromDates(dates: Date[]): { currentStreak: number; longestStreak: number } {
    if (!dates || dates.length === 0) {
      return { currentStreak: 0, longestStreak: 0 };
    }

    // Convert dates to sorted unique YYYY-MM-DD set
    const uniqueDays = Array.from(
      new Set(
        dates.map((d) => {
          const dateObj = typeof d === 'string' ? new Date(d) : d;
          return dateObj.toISOString().split('T')[0];
        }),
      ),
    ).filter((d): d is string => typeof d === 'string' && d.length > 0).sort();

    if (uniqueDays.length === 0) {
      return { currentStreak: 0, longestStreak: 0 };
    }

    let longest = 0;
    let current = 0;

    const dayTimestamps = uniqueDays.map((d) => new Date(d).getTime());
    const MS_PER_DAY = 24 * 60 * 60 * 1000;

    let tempStreak = 1;
    for (let i = 1; i < dayTimestamps.length; i++) {
      const currentTs = dayTimestamps[i] ?? 0;
      const prevTs = dayTimestamps[i - 1] ?? 0;
      const diffDays = Math.round((currentTs - prevTs) / MS_PER_DAY);
      if (diffDays === 1) {
        tempStreak++;
      } else {
        longest = Math.max(longest, tempStreak);
        tempStreak = 1;
      }
    }
    longest = Math.max(longest, tempStreak);

    // Check if current day or yesterday is in the set for active currentStreak
    const todayStr = new Date().toISOString().split('T')[0];
    const yesterdayStr = new Date(Date.now() - MS_PER_DAY).toISOString().split('T')[0];

    const lastDay = uniqueDays[uniqueDays.length - 1];
    if (lastDay === todayStr || lastDay === yesterdayStr) {
      // Calculate backwards from last day
      let runningStreak = 1;
      for (let i = uniqueDays.length - 1; i > 0; i--) {
        const currentTs = dayTimestamps[i] ?? 0;
        const prevTs = dayTimestamps[i - 1] ?? 0;
        const diff = Math.round((currentTs - prevTs) / MS_PER_DAY);
        if (diff === 1) {
          runningStreak++;
        } else {
          break;
        }
      }
      current = runningStreak;
    } else {
      current = 0;
    }

    return {
      currentStreak: current,
      longestStreak: Math.max(longest, current),
    };
  }
}

