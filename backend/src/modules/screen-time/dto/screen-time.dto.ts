export interface ScreenTimeSessionDto {
  appPackage: string;
  category?: string;
  durationS: number;
  occurredAt?: string | Date;
  // Anti-cheat verification: spoofed client fields must be discarded by backend
  manaDelta?: number;
  manaImpact?: number;
}

export interface IngestSessionsDto {
  sessions: ScreenTimeSessionDto[];
}

export interface IngestSessionsResponse {
  sessionsProcessed: number;
  totalDurationMinutes: number;
  totalManaImpact: number;
  categoryBreakdown: Record<string, { durationMinutes: number; manaImpact: number }>;
}

export interface ScreenTimeInsightResponse {
  totalDurationMinutes: number;
  netManaImpact: number;
  mostUsedApps: Array<{ appPackage: string; durationMinutes: number; category: string; manaImpact: number }>;
  categoryBreakdown: Record<string, { durationMinutes: number; manaImpact: number }>;
  peakDistractionHours: number[];
}

export interface SetAppCategoryDto {
  category: string;
  manaModifierPerMinute?: number;
}
