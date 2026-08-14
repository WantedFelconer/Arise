import { z } from 'zod';

export const generateSnapshotSchema = z.object({
  period: z.enum(['daily', 'weekly', 'monthly', 'yearly']),
  periodStart: z.string().min(4, 'periodStart is required'),
});

export const analyticsQuerySchema = z.object({
  date: z.string().optional(),
  startDate: z.string().optional(),
  year: z.string().optional(),
  month: z.string().optional(),
  period: z.enum(['daily', 'weekly', 'monthly', 'yearly']).optional(),
});
