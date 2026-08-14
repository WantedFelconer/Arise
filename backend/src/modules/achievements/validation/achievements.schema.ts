import { z } from 'zod';

export const achievementSchema = z.object({
  id: z.string().uuid().optional(),
});
