import { z } from 'zod';

export const reminderSchema = z.object({
  id: z.string().uuid().optional(),
});
