import { z } from 'zod';

export const dungeonSchema = z.object({
  id: z.string().uuid().optional(),
});
