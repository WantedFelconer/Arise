import { z } from 'zod';

export const triggerConfigSchema = z.object({
  timestamp: z.string().datetime().optional(),
  rrule: z.string().optional(),
  timeOfDay: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/).optional(),
  daysOfWeek: z.array(z.number().int().min(0).max(6)).optional(),
  triggerPhrase: z.string().optional(),
  interventionMessage: z.string().optional(),
  delayMinutes: z.number().int().min(1).max(120).optional(),
});

export const createReminderSchema = z.object({
  type: z.enum([
    'quest',
    'deadline',
    'hydration',
    'medication',
    'sleep',
    'prayer',
    'behavioral',
    'custom',
  ]),
  message: z.string().min(1, 'Message is required').max(1000),
  triggerConfig: triggerConfigSchema,
  priority: z.enum(['deadline', 'urgent', 'high', 'medium', 'low', 'custom']).optional().default('custom'),
  active: z.boolean().optional().default(true),
});

export const updateReminderSchema = createReminderSchema.partial();

export const snoozeReminderSchema = z.object({
  snoozeMinutes: z.number().int().min(1).max(1440).default(15),
});
