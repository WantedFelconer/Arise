import { CharacterStats } from '../../core/rpg-engine';

export interface StoredUser {
  id: string;
  email: string;
  passwordHash: string;
  difficultyMode: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

export interface StoredCharacter {
  id: string;
  userId: string;
  level: number;
  totalXp: number;
  currentMana: number;
  maxMana: number;
  coins: number;
  gems: number;
  rank: string;
  activeTitleId: string | null;
  stats: CharacterStats;
  updatedAt: Date;
}

export interface StoredRefreshToken {
  id: string;
  userId: string;
  tokenHash: string;
  revokedAt: Date | null;
  expiresAt: Date;
  createdAt: Date;
}

export interface StoredXpTransaction {
  id: string;
  characterId: string;
  amount: number;
  sourceType: string;
  sourceId?: string | null;
  statKey?: string | null;
  reason?: string | null;
  createdAt: Date;
}

export interface StoredManaTransaction {
  id: string;
  characterId: string;
  delta: number;
  sourceType: string;
  sourceId?: string | null;
  reason?: string | null;
  createdAt: Date;
}

export interface StoredIdempotencyRecord {
  id: string;
  userId: string;
  idempotencyKey: string;
  operationType: string;
  responseStatus: number;
  responseBody: unknown;
  createdAt: Date;
}

export interface StoredQuest {
  id: string;
  userId: string;
  bossId: string | null;
  parentQuestId: string | null;
  title: string;
  description: string | null;
  questType: string;
  priority: string;
  difficulty: string;
  status: string; // pending | in_progress | completed | archived | failed | trashed
  estimatedMinutes: number;
  actualMinutes: number | null;
  deadline: Date | null;
  recurrenceRule: Record<string, unknown> | null;
  tags: string[];
  isFavorite: boolean;
  isPinned: boolean;
  eisenhowerQuadrant: string | null;
  metadata?: Record<string, unknown> | null;
  completedAt?: Date | null;
  deletedAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredBoss {
  id: string;
  userId: string;
  dungeonId: string | null;
  title: string;
  description: string | null;
  hpMax: number;
  hpCurrent: number;
  difficulty: string;
  status: string; // active | defeated | abandoned
  deadline: Date | null;
  defeatedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredDungeon {
  id: string;
  userId: string;
  title: string;
  status: string; // active | completed
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredGateSession {
  id: string;
  userId: string;
  questId: string | null;
  plannedDurationS: number;
  actualDurationS?: number | null;
  pauseCount: number;
  status: string; // active | paused | cleared | collapsed
  stabilityFinal?: number | null;
  xpAwarded?: number | null;
  manaDelta?: number | null;
  exitReason?: string | null;
  deviceId?: string | null;
  clientEventId?: string | null;
  startedAt: Date;
  pausedAt?: Date | null;
  totalPausedDurationS?: number;
  endedAt?: Date | null;
}

export interface StoredAchievement {
  id: string;
  code: string;
  title: string;
  description: string;
  category: string;
  xpReward: number;
  badgeAssetUrl: string | null;
  criteria: Record<string, unknown>;
  createdAt: Date;
}

export interface StoredUserAchievement {
  id: string;
  userId: string;
  achievementId: string;
  unlockedAt: Date;
}

export interface StoredNotification {
  id: string;
  userId: string;
  title: string;
  message: string;
  type: string;
  read: boolean;
  data: Record<string, unknown> | null;
  createdAt: Date;
}

export interface StoredScreenTimeSession {
  id: string;
  userId: string;
  appPackage: string;
  category: string;
  durationS: number;
  occurredAt: Date;
  manaModifierApplied: number;
  createdAt: Date;
}

export interface StoredAppCategory {
  id: string;
  userId: string | null; // null = system default
  appPackage: string;
  category: string;
  manaModifierPerMinute?: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredReminder {
  id: string;
  userId: string;
  type: string; // quest | deadline | hydration | medication | sleep | prayer | behavioral | custom
  message: string;
  triggerConfig: Record<string, unknown>;
  priority: string; // urgent | deadline | high | medium | low | custom
  active: boolean;
  snoozedUntil?: Date | null;
  lastTriggeredAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredNoteFolder {
  id: string;
  userId: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredNote {
  id: string;
  userId: string;
  folderId: string | null;
  questId: string | null;
  title: string;
  body: string;
  tags: string[];
  notionPageId: string | null;
  syncStatus: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredFitnessLog {
  id: string;
  userId: string;
  logType: string; // steps | workout | sleep | water | weight | heart_rate | calories
  value: number;
  unit: string;
  recordedAt: Date;
  metadata?: Record<string, unknown>;
  createdAt: Date;
}

export interface StoredAnalyticsSnapshot {
  id: string;
  userId: string;
  period: string; // daily | weekly | monthly | yearly
  periodStart: Date;
  metrics: Record<string, unknown>;
  aiSummary: string | null;
  createdAt: Date;
}

export interface StoredSettings {
  id: string;
  userId: string;
  theme: string;
  soundEnabled: boolean;
  hapticsEnabled: boolean;
  language: string;
  privacy: Record<string, unknown>;
  dailyReminderTime: string | null;
  notificationPreferences: Record<string, boolean>;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredAiGeneratedPlan {
  id: string;
  userId: string;
  goal: string;
  context: Record<string, unknown>;
  rawPlan: Record<string, unknown>;
  status: 'pending_approval' | 'edited' | 'approved' | 'rejected';
  approvedQuestIds: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredAiConversation {
  id: string;
  userId: string;
  title: string;
  contextType: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredAiMessage {
  id: string;
  conversationId: string;
  userId: string;
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  toolCalls?: Array<{ id: string; name: string; arguments: Record<string, unknown> }>;
  toolCallId?: string;
  createdAt: Date;
}

export interface StoredFeatureFlag {
  id: string;
  userId: string | null; // null = global
  flagKey: string;
  enabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface StoredDailyAiUsage {
  key: string; // userId:YYYY-MM-DD
  userId: string;
  date: string; // YYYY-MM-DD
  count: number;
}

class MemoryDbStore {
  users = new Map<string, StoredUser>();
  characters = new Map<string, StoredCharacter>();
  refreshTokens = new Map<string, StoredRefreshToken>();
  xpTransactions: StoredXpTransaction[] = [];
  manaTransactions: StoredManaTransaction[] = [];
  idempotencyRecords = new Map<string, StoredIdempotencyRecord>();
  settings = new Map<string, StoredSettings>();
  circadianProfiles = new Map<string, unknown>();

  // Sprint 2 stores
  quests = new Map<string, StoredQuest>();
  habits = new Map<string, unknown>();
  bosses = new Map<string, StoredBoss>();
  dungeons = new Map<string, StoredDungeon>();
  gateSessions = new Map<string, StoredGateSession>();
  achievements = new Map<string, StoredAchievement>();
  userAchievements = new Map<string, StoredUserAchievement>();
  notifications: StoredNotification[] = [];

  // Sprint 3 stores (AI Intelligence Layer)
  aiGeneratedPlans = new Map<string, StoredAiGeneratedPlan>();
  aiConversations = new Map<string, StoredAiConversation>();
  aiMessages = new Map<string, StoredAiMessage>();
  featureFlags = new Map<string, StoredFeatureFlag>();
  dailyAiUsage = new Map<string, StoredDailyAiUsage>();

  // Sprint 4 stores (Supporting Systems)
  screenTimeSessions: StoredScreenTimeSession[] = [];
  appCategories = new Map<string, StoredAppCategory>();
  reminders = new Map<string, StoredReminder>();
  notes = new Map<string, StoredNote>();
  noteFolders = new Map<string, StoredNoteFolder>();
  fitnessLogs: StoredFitnessLog[] = [];
  analyticsSnapshots = new Map<string, StoredAnalyticsSnapshot>();

  clear() {
    this.users.clear();
    this.characters.clear();
    this.refreshTokens.clear();
    this.xpTransactions = [];
    this.manaTransactions = [];
    this.idempotencyRecords.clear();
    this.settings.clear();
    this.circadianProfiles.clear();
    this.quests.clear();
    this.habits.clear();
    this.bosses.clear();
    this.dungeons.clear();
    this.gateSessions.clear();
    this.achievements.clear();
    this.userAchievements.clear();
    this.notifications = [];
    this.aiGeneratedPlans.clear();
    this.aiConversations.clear();
    this.aiMessages.clear();
    this.featureFlags.clear();
    this.dailyAiUsage.clear();
    this.screenTimeSessions = [];
    this.appCategories.clear();
    this.reminders.clear();
    this.notes.clear();
    this.noteFolders.clear();
    this.fitnessLogs = [];
    this.analyticsSnapshots.clear();
  }
}

export const memoryDb = new MemoryDbStore();

