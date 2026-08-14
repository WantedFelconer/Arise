export interface CreateBossDto {
  title: string;
  description?: string;
  hpMax: number;
  difficulty?: 'trivial' | 'easy' | 'medium' | 'hard' | 'epic';
  deadline?: string;
  dungeonId?: string;
}

export interface UpdateBossDto {
  title?: string;
  description?: string;
  difficulty?: 'trivial' | 'easy' | 'medium' | 'hard' | 'epic';
  deadline?: string | null;
  dungeonId?: string | null;
}

export interface BossResponse {
  id: string;
  userId: string;
  dungeonId: string | null;
  title: string;
  description: string | null;
  hpMax: number;
  hpCurrent: number;
  difficulty: string;
  status: 'active' | 'defeated' | 'abandoned';
  deadline: Date | null;
  defeatedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
  linkedQuestsCount?: number;
}

export interface BossHistoryItem {
  id: string;
  title: string;
  difficulty: string;
  hpMax: number;
  defeatedAt: Date;
  createdAt: Date;
  timeToDefeatMs: number;
  questsCompletedCount: number;
}
