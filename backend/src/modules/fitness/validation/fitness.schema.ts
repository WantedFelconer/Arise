import { z } from 'zod';

export const createFitnessLogSchema = z.object({
  logType: z.enum(['steps', 'workout', 'sleep', 'water', 'weight', 'heart_rate', 'calories']),
  value: z.number().min(0, 'Value must be positive'),
  unit: z.string().min(1, 'Unit is required').max(20),
  recordedAt: z.string().datetime().or(z.date()).optional(),
  metadata: z.record(z.unknown()).optional(),
});

export const fitnessFilterSchema = z.object({
  logType: z.enum(['steps', 'workout', 'sleep', 'water', 'weight', 'heart_rate', 'calories']).optional(),
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().optional(),
  limit: z.coerce.number().int().min(1).max(200).default(50),
  offset: z.coerce.number().int().min(0).default(0),
});
