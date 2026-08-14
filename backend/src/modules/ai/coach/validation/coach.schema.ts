import { z } from 'zod';

export const createConversationSchema = z.object({
  title: z.string().optional(),
  contextType: z.enum(['coach', 'daily', 'weekly_review', 'general']).optional().default('coach'),
});

export type CreateConversationInput = z.infer<typeof createConversationSchema>;

export const sendMessageSchema = z.object({
  content: z.string().min(1, 'Message content cannot be empty'),
});

export type SendMessageInput = z.infer<typeof sendMessageSchema>;

export const directChatSchema = z.object({
  message: z.string().min(1, 'Message cannot be empty'),
  conversationId: z.string().uuid().optional(),
});

export type DirectChatInput = z.infer<typeof directChatSchema>;

export const dailyPlanCoachSchema = z.object({
  availableHours: z.number().positive().optional(),
  focusAreas: z.array(z.string()).optional(),
  notes: z.string().optional(),
});

export type DailyPlanCoachInput = z.infer<typeof dailyPlanCoachSchema>;

export const weeklyReviewCoachSchema = z.object({
  wins: z.string().optional(),
  challenges: z.string().optional(),
  nextWeekGoals: z.string().optional(),
});

export type WeeklyReviewCoachInput = z.infer<typeof weeklyReviewCoachSchema>;
