import { z } from 'zod';

export const screenTimeSessionItemSchema = z
  .object({
    appPackage: z.string().min(1, 'appPackage is required').max(200),
    category: z.string().optional(),
    durationS: z.number().int().min(1, 'durationS must be positive').max(86400).optional(),
    durationSeconds: z.number().int().min(1, 'durationSeconds must be positive').max(86400).optional(),
    occurredAt: z.string().datetime().or(z.date()).optional(),
    manaDelta: z.number().optional(), // Client may attempt to send spoofed delta; schema permits input so service can explicitly test discarding it
    manaImpact: z.number().optional(),
  })
  .transform((val) => ({
    ...val,
    durationS: val.durationS ?? val.durationSeconds ?? 60,
  }));

export const ingestSessionsSchema = z.object({
  sessions: z.array(screenTimeSessionItemSchema).min(1, 'At least one session is required').max(500),
});

export const setAppCategorySchema = z.object({
  category: z.enum(['productive', 'educational', 'communication', 'entertainment', 'high_distraction']),
  manaModifierPerMinute: z.number().min(-2).max(2).optional(),
});
