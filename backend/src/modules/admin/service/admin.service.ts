import { Injectable } from '@nestjs/common';
import { memoryDb } from '../../../db/memory/memory-db';
import rankThresholds from '../../../config/rank_thresholds.json';
import circadianCurves from '../../../config/circadian_curves.json';
import bossDamageTable from '../../../config/boss_damage_table.json';
import gateRewards from '../../../config/gate_rewards.json';
import questPenalties from '../../../config/quest_penalties.json';
import screenTimeModifiers from '../../../config/screen_time_modifiers.json';
import fitnessThresholds from '../../../config/fitness_thresholds.json';
import difficultyModes from '../../../config/difficulty_modes.json';
import { AdminBalancingConfigResponse, FeatureFlagResponse } from '../dto/admin.dto';

@Injectable()
export class AdminService {
  /**
   * FR-ADMIN-002: Exposes balancing configuration constants tunable without redeploy
   */
  getBalancingConfig(): AdminBalancingConfigResponse {
    return {
      rankThresholds,
      circadianCurves,
      bossDamageTable,
      gateRewards,
      questPenalties,
      screenTimeModifiers,
      fitnessThresholds,
      difficultyModes,
    };
  }

  getFeatureFlags(userId?: string): FeatureFlagResponse[] {
    const flags = Array.from(memoryDb.featureFlags.values());
    if (userId) {
      return flags.filter((f) => f.userId === null || f.userId === userId);
    }
    return flags;
  }
}
