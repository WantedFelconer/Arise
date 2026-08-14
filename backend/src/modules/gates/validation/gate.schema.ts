import { z } from 'zod';

export const startGateSessionSchema = z.object({
  questId: z.string().uuid().optional().nullable(),
  plannedDurationSeconds: z.number().int().min(60).max(14400), // 1 min to 4 hours
  deviceId: z.string().optional().nullable(),
  clientEventId: z.string().optional().nullable(),
});

export const collapseGateSessionSchema = z.object({
  exitReason: z.string().max(255).optional(),
});

export type StartGateSessionInput = z.input<typeof startGateSessionSchema>;
export type CollapseGateSessionInput = z.input<typeof collapseGateSessionSchema>;
