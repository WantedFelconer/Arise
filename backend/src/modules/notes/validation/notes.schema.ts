import { z } from 'zod';

export const noteSchema = z.object({
  id: z.string().uuid().optional(),
});
