export type FitnessLogType =
  | 'steps'
  | 'workout'
  | 'sleep'
  | 'water'
  | 'weight'
  | 'heart_rate'
  | 'calories';

export interface CreateFitnessLogDto {
  logType: FitnessLogType;
  value: number;
  unit: string;
  recordedAt?: string | Date;
  metadata?: Record<string, unknown>;
}

export interface FitnessLogResponse {
  id: string;
  userId: string;
  logType: FitnessLogType;
  value: number;
  unit: string;
  recordedAt: Date;
  metadata?: Record<string, unknown>;
  rewards?: {
    xpAwarded: number;
    manaDelta: number;
    statKey: string;
    thresholdReached: boolean;
    label?: string;
  };
  createdAt: Date;
}

export interface FitnessSummaryResponse {
  totalSteps: number;
  totalWorkoutMinutes: number;
  averageSleepHours: number;
  totalWaterMl: number;
  latestWeightKg?: number;
  averageHeartRateBpm?: number;
}
