export interface CreateQuestDto {
  title: string;
  description?: string;
  questType?: 'daily' | 'main' | 'side' | 'recurring' | 'boss_quest' | 'boss' | 'ai_generated';
  priority?: 'low' | 'medium' | 'high' | 'urgent';
  difficulty?: 'trivial' | 'easy' | 'medium' | 'hard' | 'epic';
  deadline?: string | null;
  estimatedMinutes?: number;
  tags?: string[];
  bossId?: string | null;
  parentQuestId?: string | null;
  recurrenceRule?: Record<string, unknown> | null;
  statKey?:
    | 'intelligence'
    | 'discipline'
    | 'fitness'
    | 'creativity'
    | 'coding'
    | 'business'
    | 'health'
    | null;
  xpReward?: number;
  manaReward?: number;
  metadata?: Record<string, unknown> | null;
}

export interface UpdateQuestDto {
  title?: string;
  description?: string | null;
  questType?: 'daily' | 'main' | 'side' | 'recurring' | 'boss_quest' | 'boss' | 'ai_generated';
  priority?: 'low' | 'medium' | 'high' | 'urgent';
  difficulty?: 'trivial' | 'easy' | 'medium' | 'hard' | 'epic';
  deadline?: string | null;
  estimatedMinutes?: number;
  actualMinutes?: number | null;
  tags?: string[];
  bossId?: string | null;
  parentQuestId?: string | null;
  recurrenceRule?: Record<string, unknown> | null;
  isFavorite?: boolean;
  isPinned?: boolean;
  metadata?: Record<string, unknown> | null;
}

export interface QuestResponse {
  id: string;
  userId: string;
  bossId: string | null;
  parentQuestId: string | null;
  title: string;
  description: string | null;
  questType: string;
  priority: string;
  difficulty: string;
  status: 'pending' | 'in_progress' | 'completed' | 'archived' | 'failed' | 'trashed';
  estimatedMinutes: number;
  actualMinutes: number | null;
  deadline: Date | null;
  recurrenceRule: Record<string, unknown> | null;
  tags: string[];
  isFavorite: boolean;
  isPinned: boolean;
  eisenhowerQuadrant: string | null;
  metadata?: Record<string, unknown> | null;
  subQuests?: QuestResponse[];
  completedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface QuestListQueryDto {
  status?: string;
  priority?: string;
  difficulty?: string;
  tag?: string;
  bossId?: string;
  parentQuestId?: string;
  search?: string;
  deadlineFrom?: string;
  deadlineTo?: string;
  sortBy?: 'deadline' | 'priority' | 'createdAt' | 'title';
  sortOrder?: 'asc' | 'desc';
}
