import { BossResponse } from '../../bosses/dto/boss.dto';

export interface CreateDungeonDto {
  title: string;
}

export interface UpdateDungeonDto {
  title?: string;
}

export interface DungeonResponse {
  id: string;
  userId: string;
  title: string;
  status: 'active' | 'completed';
  totalBosses: number;
  defeatedBosses: number;
  progressPct: number;
  bosses?: BossResponse[];
  createdAt: Date;
  updatedAt: Date;
}
