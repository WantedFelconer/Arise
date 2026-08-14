import { z } from 'zod';

export const bossSchema = z.object({
  id: z.string().uuid().optional(),
});
