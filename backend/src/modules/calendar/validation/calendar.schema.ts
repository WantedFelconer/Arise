import { z } from 'zod';

export const calendarSchema = z.object({
  id: z.string().uuid().optional(),
});
