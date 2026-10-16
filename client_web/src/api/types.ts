export interface User {
  id: string
  email: string
  difficultyMode: 'casual' | 'hardcore' | string
  chronotype?: 'early_bird' | 'night_owl' | 'custom' | string
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
}

export interface CharacterStats {
  intelligence: number
  discipline: number
  fitness: number
  creativity: number
  coding: number
  business: number
  health: number
}

export interface CharacterResponse {
  id: string
  userId: string
  level: number
  totalXp: number
  xpToNextLevel: number
  currentMana: number
  maxMana: number
  coins: number
  gems: number
  rank: string
  activeTitleId: string | null
  stats: CharacterStats
}

export interface AuthResponse {
  user: User
  character?: CharacterResponse
  tokens: AuthTokens
}

export interface Quest {
  id: string
  userId: string
  bossId: string | null
  parentQuestId: string | null
  title: string
  description: string | null
  questType: 'daily' | 'main' | 'side' | 'recurring' | 'boss_quest' | 'boss' | 'ai_generated' | string
  priority: 'low' | 'medium' | 'high' | 'urgent' | string
  difficulty: 'trivial' | 'easy' | 'medium' | 'hard' | 'epic' | string
  status: 'pending' | 'in_progress' | 'completed' | 'failed' | 'archived' | string
  estimatedMinutes: number
  actualMinutes: number | null
  deadline: string | null
  recurrenceRule: Record<string, unknown> | null
  tags: string[]
  isFavorite: boolean
  isPinned: boolean
  completedAt: string | null
  createdAt: string
  updatedAt: string
}

export interface CreateQuestInput {
  title: string
  description?: string | null
  questType?: string
  priority?: string
  difficulty?: string
  deadline?: string | null
  estimatedMinutes?: number
  tags?: string[]
  bossId?: string | null
  statKey?: keyof CharacterStats
}

export interface UpdateQuestInput {
  title?: string
  description?: string | null
  questType?: string
  priority?: string
  difficulty?: string
  deadline?: string | null
  estimatedMinutes?: number
  tags?: string[]
  isFavorite?: boolean
  isPinned?: boolean
}

export interface CompleteQuestResult {
  quest: Quest
  xpAwarded: number
  manaDelta: number
  parentAutoCompleted?: boolean
  unlockedAchievements?: string[]
}

export interface Boss {
  id: string
  userId: string
  title: string
  description: string | null
  currentHp: number
  maxHp: number
  status: 'active' | 'defeated' | 'abandoned' | string
  deadline: string | null
  rank: string
  expReward: number
  goldReward: number
  dungeonId: string | null
  quests?: Quest[]
  createdAt: string
  updatedAt: string
}

export interface BossDamageHistory {
  id: string
  bossId: string
  damage: number
  action: string
  rank?: string
  createdAt: string
}

export interface Dungeon {
  id: string
  userId: string
  title: string
  description: string | null
  rank: string
  status: string
  bosses?: Boss[]
  createdAt: string
}

export interface GateSession {
  id: string
  userId: string
  questId: string | null
  plannedDurationSeconds: number
  actualDurationSeconds: number | null
  status: 'in_progress' | 'completed' | 'paused' | 'collapsed' | string
  startedAt: string
  completedAt: string | null
  exitReason?: string | null
}

export interface GateStats {
  totalSessions: number
  completedSessions: number
  collapsedSessions: number
  totalMinutes: number
  completionRate: number
}

export interface AiQuotaStatus {
  usedToday: number
  limit: number
  dailyLimit: number
  remaining: number
  resetAt: string
}

export interface AiPlanItem {
  id?: string
  title: string
  rank?: string
  time?: string
  days?: string
  exp?: number
  questType?: string
  difficulty?: string
}

export interface AiPlanProposal {
  id: string
  userId: string
  goal: string
  status: 'draft' | 'approved' | 'rejected'
  planData: {
    items?: AiPlanItem[]
    summary?: string
  }
  createdAt: string
}

export interface Achievement {
  id: string
  name: string
  description: string
  category: string
  tier: string
  rarity?: string
  unlocked: boolean
  progress?: number
  requiredCount?: number
  icon?: string
}

export interface Reminder {
  id: string
  userId: string
  title: string
  scheduleTime: string
  reminderType: string
  repeatInterval?: string | null
  daysOfWeek?: string[]
  isActive: boolean
  snoozedUntil?: string | null
  createdAt: string
}

export interface NotificationItem {
  id: string
  userId: string
  title: string
  message: string
  category: string
  isRead: boolean
  createdAt: string
}

export interface UserSettings {
  userId: string
  difficultyMode: 'casual' | 'hardcore'
  chronotype?: string
  soundEnabled?: boolean
  hapticsEnabled?: boolean
  theme?: string
  language?: string
  dailyReminderTime?: string | null
  notificationPreferences?: Record<string, boolean>
}

export interface Note {
  id: string
  userId: string
  folderId?: string | null
  title: string
  content: string
  tags: string[]
  isPinned: boolean
  isArchived: boolean
  createdAt: string
  updatedAt: string
}

export interface NoteFolder {
  id: string
  userId: string
  name: string
  color?: string
}

export interface LifetimeStats {
  totalQuestsCompleted: number
  totalGatesCompleted: number
  totalFocusMinutes: number
  currentStreak: number
  longestStreak: number
  totalXpEarned: number
}

export interface ScreenTimeInsights {
  totalUsageMinutes: number
  manaImpact: number
  appUsageBreakdown: Array<{
    appPackage: string
    category: string
    durationMinutes: number
    manaDrain: number
  }>
}
