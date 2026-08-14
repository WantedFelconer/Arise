import { z } from 'zod';

export const createDungeonSchema = z.object({
  title: z.string().min(1).max(255),
});

export const updateDungeonSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  status: z.enum(['active', 'completed']).optional(),
});

export type CreateDungeonInput = z.input<typeof createDungeonSchema>;
export type UpdateDungeonInput = z.input<typeof updateDungeonSchema>;
