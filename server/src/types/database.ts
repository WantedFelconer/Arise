// TypeScript Schema Interfaces & Domain Event Types for ARISE Backend

export type DifficultyMode = 'casual' | 'hardcore';
export type QuestType = 'daily' | 'main' | 'side' | 'recurring' | 'boss' | 'ai_generated';
export type QuestStatus = 'active' | 'in_progress' | 'completed' | 'archived' | 'trashed';
export type BossStatus = 'active' | 'defeated';
export type DungeonStatus = 'active' | 'completed';
export type GateStatus = 'in_progress' | 'completed' | 'collapsed';
export type CaptureType = 'text' | 'voice' | 'photo' | 'screenshot';
export type InboxStatus = 'unsorted' | 'triaged' | 'converted';
export type ReminderType = 'quest' | 'habit' | 'deadline' | 'wellness' | 'behavioral';
export type PeriodType = 'daily' | 'weekly' | 'monthly' | 'yearly';
export type SyncStatus = 'pending' | 'syncing' | 'synced' | 'failed' | 'conflict' | 'cancelled';

export interface UserEntity {
  id: string;
  email: string;
  password_hash: string;
  difficulty_mode: DifficultyMode;
  created_at: Date;
  updated_at: Date;
}

export interface CharacterEntity {
  id: string;
  user_id: string;
  level: number;
  total_xp: number;
  mana: number;
  energy: number;
  coins: number;
  gems: number;
  active_title_id: string;
  rank: string;
  stats: {
    strength: number;
    agility: number;
    intelligence: number;
    vitality: number;
    perception: number;
  };
  updated_at: Date;
}

export interface QuestEntity {
  id: string;
  user_id: string;
  boss_id?: string | null;
  parent_quest_id?: string | null;
  title: string;
  description?: string | null;
  quest_type: QuestType;
  priority: number;
  difficulty: number;
  deadline?: Date | null;
  estimated_minutes: number;
  actual_minutes?: number | null;
  status: QuestStatus;
  eisenhower_quadrant?: number | null;
  recurrence_rule?: Record<string, any> | null;
  tags: string[];
  is_favorite: boolean;
  is_pinned: boolean;
  created_at: Date;
  updated_at: Date;
  completed_at?: Date | null;
}

export interface HabitEntity {
  id: string;
  user_id: string;
  title: string;
  frequency: {
    type: 'daily' | 'weekly' | 'custom';
    days: number[];
  };
  skip_allowance: number;
  current_streak: number;
  longest_streak: number;
  reminder_times: string[];
  created_at: Date;
}

export interface BossEntity {
  id: string;
  user_id: string;
  dungeon_id?: string | null;
  title: string;
  hp_max: number;
  hp_current: number;
  difficulty: number;
  deadline?: Date | null;
  status: BossStatus;
  created_at: Date;
}

export interface GateSessionEntity {
  id: string;
  user_id: string;
  quest_id?: string | null;
  started_at: Date;
  ended_at?: Date | null;
  planned_duration_s: number;
  actual_duration_s?: number | null;
  pause_count: number;
  exit_reason?: string | null;
  status: GateStatus;
  stability_final?: number | null;
  xp_awarded?: number | null;
  mana_delta?: number | null;
  device_id: string;
  client_event_id: string;
}

export interface SyncEventEntity {
  id: string;
  user_id: string;
  device_id: string;
  event_type: string;
  payload: Record<string, any>;
  occurred_at_client: Date;
  received_at_server: Date;
  sync_status: SyncStatus;
  retry_count: number;
  version: number;
}

// Domain Event Catalog Payload Schemas

export interface QuestCreatedPayload {
  questId: string;
  title: string;
  questType: QuestType;
  parentQuestId?: string;
  bossId?: string;
  priority: number;
  difficulty: number;
}

export interface QuestCompletedPayload {
  questId: string;
  difficulty: number;
  actualDurationMinutes: number;
  bossId?: string;
  tags?: string[];
  completedAt: string;
}

export interface HabitCompletedPayload {
  habitId: string;
  streakBefore: number;
  completedAt: string;
}

export interface GateCompletedPayload {
  sessionId: string;
  actualDurationSeconds: number;
  stabilityFinal: number;
  questId?: string;
}

export interface GateCollapsedPayload {
  sessionId: string;
  exitReason: string;
  durationFocusedSeconds: number;
}

export interface SyncBatchRequest {
  deviceId: string;
  events: Array<{
    eventId: string;
    eventType: string;
    payload: Record<string, any>;
    occurredAtClient: string;
    version: number;
  }>;
}

export interface SyncBatchResponse {
  processedEventIds: string[];
  failedEvents: Array<{
    eventId: string;
    error: string;
  }>;
  conflicts: Array<{
    eventId: string;
    strategy: 'server_wins' | 'field_merge' | 'manual_resolution';
    authoritativeState: Record<string, any>;
  }>;
  serverTimestamp: string;
}
