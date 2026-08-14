export interface AdminBalancingConfigResponse {
  rankThresholds: unknown;
  circadianCurves: unknown;
  bossDamageTable: unknown;
  gateRewards: unknown;
  questPenalties: unknown;
  screenTimeModifiers: unknown;
  fitnessThresholds: unknown;
  difficultyModes: unknown;
}

export interface FeatureFlagResponse {
  id: string;
  flagKey: string;
  enabled: boolean;
  userId: string | null;
}
