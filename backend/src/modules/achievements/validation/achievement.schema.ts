import { z } from 'zod';

export const createAchievementSchema = z.object({
  code: z.string().min(1).max(100),
  title: z.string().min(1).max(255),
  description: z.string().max(1000),
  category: z.string().default('general'),
  xpReward: z.number().int().nonnegative().default(0),
  badgeAssetUrl: z.string().url().optional().nullable(),
  criteria: z.record(z.any()),
});

export type CreateAchievementInput = z.input<typeof createAchievementSchema>;
