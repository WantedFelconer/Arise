export interface StartGateSessionDto {
  questId?: string | null;
  plannedDurationSeconds: number;
  deviceId?: string | null;
  clientEventId?: string | null;
}

export interface GateSessionResponse {
  id: string;
  userId: string;
  questId: string | null;
  plannedDurationS: number;
  actualDurationS: number;
  pauseCount: number;
  status: 'active' | 'paused' | 'cleared' | 'collapsed';
  stabilityPct: number;
  stabilityFinal: number | null;
  xpAwarded: number | null;
  manaDelta: number | null;
  exitReason: string | null;
  startedAt: Date;
  endedAt: Date | null;
}

export interface GateStatsResponse {
  totalSessions: number;
  totalCleared: number;
  totalCollapsed: number;
  successRatePct: number;
  longestExpeditionSeconds: number;
  totalFocusTimeSeconds: number;
}
