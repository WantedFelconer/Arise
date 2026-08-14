import { z } from 'zod';

export const equipTitleSchema = z.object({
  titleId: z.string().nullable(),
});
