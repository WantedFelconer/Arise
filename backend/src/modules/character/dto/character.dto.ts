import { z } from 'zod';
import { equipTitleSchema } from '../validation/character.schema';
import { CharacterStats, StatKey } from '../../../core/rpg-engine';

export type EquipTitleDto = z.infer<typeof equipTitleSchema>;

export interface CharacterResponse {
  id: string;
  userId: string;
  level: number;
  totalXp: number;
  xpToNextLevel: number;
  currentMana: number;
  maxMana: number;
  coins: number;
  gems: number;
  rank: string;
  activeTitleId: string | null;
  stats: CharacterStats;
}

export interface AwardXpInput {
  amount: number;
  sourceType: string;
  sourceId?: string;
  statKey?: StatKey;
  reason?: string;
}

export interface ModifyManaInput {
  delta: number;
  sourceType: string;
  sourceId?: string;
  reason?: string;
}

export interface XpAggregationSummary {
  today: number;
  thisWeek: number;
  thisMonth: number;
  lifetime: number;
}
