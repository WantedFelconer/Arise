import { z } from 'zod';

export const gateSchema = z.object({
  id: z.string().uuid().optional(),
});
