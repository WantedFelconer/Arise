import { z } from 'zod';

export const createQuestSchema = z.object({
  title: z.string().min(1).max(255),
  description: z.string().max(4000).optional().nullable(),
  questType: z
    .enum(['daily', 'main', 'side', 'recurring', 'boss_quest', 'boss', 'ai_generated'])
    .default('daily'),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).default('medium'),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).default('medium'),
  deadline: z.string().datetime({ offset: true }).optional().or(z.string().datetime()).nullable(),
  estimatedMinutes: z.number().int().positive().default(30),
  tags: z.array(z.string()).default([]),
  bossId: z.string().uuid().optional().nullable(),
  parentQuestId: z.string().uuid().optional().nullable(),
  recurrenceRule: z.record(z.any()).optional().nullable(),
  statKey: z
    .enum(['intelligence', 'discipline', 'fitness', 'creativity', 'coding', 'business', 'health'])
    .optional()
    .nullable(),
  xpReward: z.number().int().nonnegative().optional(),
  manaReward: z.number().int().nonnegative().optional(),
  metadata: z.record(z.any()).optional().nullable(),
});

export const updateQuestSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  description: z.string().max(4000).optional().nullable(),
  questType: z
    .enum(['daily', 'main', 'side', 'recurring', 'boss_quest', 'boss', 'ai_generated'])
    .optional(),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).optional(),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).optional(),
  deadline: z.string().datetime({ offset: true }).optional().or(z.string().datetime()).nullable(),
  estimatedMinutes: z.number().int().positive().optional(),
  actualMinutes: z.number().int().nonnegative().optional().nullable(),
  tags: z.array(z.string()).optional(),
  bossId: z.string().uuid().optional().nullable(),
  parentQuestId: z.string().uuid().optional().nullable(),
  recurrenceRule: z.record(z.any()).optional().nullable(),
  isFavorite: z.boolean().optional(),
  isPinned: z.boolean().optional(),
  metadata: z.record(z.any()).optional().nullable(),
});

export const questListQuerySchema = z.object({
  status: z.string().optional(),
  priority: z.string().optional(),
  difficulty: z.string().optional(),
  tag: z.string().optional(),
  bossId: z.string().uuid().optional(),
  parentQuestId: z.string().uuid().optional(),
  search: z.string().optional(),
  deadlineFrom: z.string().optional(),
  deadlineTo: z.string().optional(),
  sortBy: z.enum(['deadline', 'priority', 'createdAt', 'title']).optional(),
  sortOrder: z.enum(['asc', 'desc']).optional(),
});

export type CreateQuestInput = z.input<typeof createQuestSchema>;
export type UpdateQuestInput = z.input<typeof updateQuestSchema>;
export type QuestListQueryInput = z.input<typeof questListQuerySchema>;
