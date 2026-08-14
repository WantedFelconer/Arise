import { z } from 'zod';

/**
 * Authoritative §10.3 JSON Schema for structured plan generation.
 */
export const aiPlanJsonSchema = {
  type: 'object',
  required: ['mainQuest'],
  properties: {
    mainQuest: {
      type: 'object',
      required: ['title', 'subquests'],
      properties: {
        title: { type: 'string' },
        description: { type: 'string' },
        deadline: { type: 'string' },
        difficulty: {
          type: 'string',
          enum: ['trivial', 'easy', 'medium', 'hard', 'epic'],
        },
        xpReward: { type: 'number' },
        subquests: {
          type: 'array',
          items: {
            type: 'object',
            required: ['title', 'estimatedMinutes', 'priority'],
            properties: {
              title: { type: 'string' },
              description: { type: 'string' },
              estimatedMinutes: { type: 'number' },
              priority: {
                type: 'string',
                enum: ['low', 'medium', 'high', 'urgent'],
              },
              difficulty: {
                type: 'string',
                enum: ['trivial', 'easy', 'medium', 'hard', 'epic'],
              },
              xpReward: { type: 'number' },
              dependsOnIndex: {
                oneOf: [{ type: 'number' }, { type: 'array', items: { type: 'number' } }],
              },
            },
          },
        },
      },
    },
    suggestedSchedule: {
      type: 'array',
      items: {
        type: 'object',
        required: ['date', 'questIndex'],
        properties: {
          date: { type: 'string' },
          questIndex: { type: 'number' },
          notes: { type: 'string' },
        },
      },
    },
  },
};

/**
 * Zod validation schema matching §10.3.
 */
export const aiSubquestSchema = z.object({
  title: z.string().min(1, 'Subquest title is required'),
  description: z.string().optional(),
  estimatedMinutes: z.number().int().positive('Estimated minutes must be positive'),
  priority: z.enum(['low', 'medium', 'high', 'urgent']),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).default('medium'),
  xpReward: z.number().int().nonnegative().optional(),
  dependsOnIndex: z
    .union([z.number().int().nonnegative(), z.array(z.number().int().nonnegative())])
    .optional(),
});

export const aiMainQuestSchema = z.object({
  title: z.string().min(1, 'Main quest title is required'),
  description: z.string().optional(),
  deadline: z.string().optional(),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).default('medium'),
  xpReward: z.number().int().nonnegative().optional(),
  subquests: z.array(aiSubquestSchema).min(1, 'At least one subquest is required'),
});

export const aiSuggestedScheduleItemSchema = z.object({
  date: z.string(),
  questIndex: z.number().int().nonnegative(),
  notes: z.string().optional(),
});

export const aiPlanSchema = z.object({
  mainQuest: aiMainQuestSchema,
  suggestedSchedule: z.array(aiSuggestedScheduleItemSchema).optional(),
});

export type AIPlanStructuredOutput = z.infer<typeof aiPlanSchema>;
export type AISubquestOutput = z.infer<typeof aiSubquestSchema>;

/**
 * User Request validation schemas.
 */
export const generatePlanInputSchema = z.object({
  goal: z.string().min(1, 'Goal is required'),
  deadline: z.string().optional(),
  availableTimeMinutesPerDay: z.number().int().positive().optional(),
  constraints: z.string().optional(),
  resources: z.string().optional(),
  difficulty: z.enum(['trivial', 'easy', 'medium', 'hard', 'epic']).optional(),
  bossId: z.string().uuid().optional(),
});

export type GeneratePlanInput = z.infer<typeof generatePlanInputSchema>;

export const editPlanInputSchema = z.object({
  goal: z.string().optional(),
  rawPlan: aiPlanSchema.partial().optional(),
  mainQuestTitle: z.string().optional(),
  mainQuestDescription: z.string().optional(),
  subquests: z.array(aiSubquestSchema).optional(),
});

export type EditPlanInput = z.infer<typeof editPlanInputSchema>;

export const regeneratePlanInputSchema = z.object({
  additionalContext: z.string().optional(),
  updatedGoal: z.string().optional(),
  updatedConstraints: z.string().optional(),
});

export type RegeneratePlanInput = z.infer<typeof regeneratePlanInputSchema>;

export const approvePlanInputSchema = z.object({
  bossId: z.string().uuid().optional(),
  deadline: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

export type ApprovePlanInput = z.infer<typeof approvePlanInputSchema>;
