import { z } from 'zod';

export const createNotificationSchema = z.object({
  title: z.string().min(1, 'Title is required').max(200),
  message: z.string().min(1, 'Message is required').max(1000),
  type: z.string().default('general'),
  data: z.record(z.unknown()).optional(),
  sendPush: z.boolean().optional().default(false),
});

export const notificationFilterSchema = z.object({
  unreadOnly: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
  type: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).default(0),
});
