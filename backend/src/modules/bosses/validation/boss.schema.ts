import { z } from 'zod';

export const createBossSchema = z.object({
  title: z.string().min(1).max(255),
  description: z.string().max(2000).optional(),
  hpMax: z.number().int().positive(),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).default('medium'),
  deadline: z.string().datetime({ offset: true }).optional().or(z.string().datetime()).nullable(),
  dungeonId: z.string().uuid().optional().nullable(),
});

export const updateBossSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  description: z.string().max(2000).optional().nullable(),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).optional(),
  deadline: z.string().datetime({ offset: true }).optional().or(z.string().datetime()).nullable(),
  dungeonId: z.string().uuid().optional().nullable(),
});

export type CreateBossInput = z.input<typeof createBossSchema>;
export type UpdateBossInput = z.input<typeof updateBossSchema>;
