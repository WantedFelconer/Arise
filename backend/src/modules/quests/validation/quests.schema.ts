import { z } from 'zod';

export const questSchema = z.object({
  id: z.string().uuid().optional(),
});
