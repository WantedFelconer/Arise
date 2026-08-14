export type AnalyticsPeriod = 'daily' | 'weekly' | 'monthly' | 'yearly';

export interface AnalyticsMetrics {
  totalXpGained: number;
  netManaChange: number;
  focusMinutes: number;
  gateSessionsCount: number;
  gateSuccessRatePct: number;
  questsCompleted: number;
  questsTotal: number;
  questCompletionRatePct: number;
  screenTimeMinutes: number;
  screenTimeManaImpact: number;
  fitnessSummary: {
    steps: number;
    workoutMinutes: number;
    waterMl: number;
  };
}

export interface AnalyticsSnapshotResponse {
  id: string;
  userId: string;
  period: AnalyticsPeriod;
  periodStart: Date;
  metrics: AnalyticsMetrics;
  aiSummary: string | null;
  createdAt: Date;
}

export interface GenerateSnapshotDto {
  period: AnalyticsPeriod;
  periodStart: string; // ISO or YYYY-MM-DD
}
