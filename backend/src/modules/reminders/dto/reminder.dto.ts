export type ReminderType =
  | 'quest'
  | 'deadline'
  | 'hydration'
  | 'medication'
  | 'sleep'
  | 'prayer'
  | 'behavioral'
  | 'custom';

export type ReminderPriority = 'deadline' | 'urgent' | 'high' | 'medium' | 'low' | 'custom';

export interface TriggerConfig {
  timestamp?: string; // One-off ISO timestamp
  rrule?: string; // RFC 5545 RRULE or cron expression
  timeOfDay?: string; // HH:mm
  daysOfWeek?: number[]; // 0-6 (Sun-Sat)
  triggerPhrase?: string; // For behavioral reminders
  interventionMessage?: string;
  delayMinutes?: number;
}

export interface CreateReminderDto {
  type: ReminderType;
  message: string;
  triggerConfig: TriggerConfig;
  priority?: ReminderPriority;
  active?: boolean;
}

export interface UpdateReminderDto {
  type?: ReminderType;
  message?: string;
  triggerConfig?: TriggerConfig;
  priority?: ReminderPriority;
  active?: boolean;
}

export interface SnoozeReminderDto {
  snoozeMinutes: number;
}

export interface ReminderResponse {
  id: string;
  userId: string;
  type: ReminderType;
  message: string;
  triggerConfig: TriggerConfig;
  priority: ReminderPriority;
  active: boolean;
  snoozedUntil?: Date | null;
  lastTriggeredAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}
