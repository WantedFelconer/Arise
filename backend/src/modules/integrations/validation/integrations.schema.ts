import { z } from 'zod';

export const integrationSchema = z.object({
  id: z.string().uuid().optional(),
});
