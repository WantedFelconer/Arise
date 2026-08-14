import { AIPlanStructuredOutput } from '../validation/plan.schema';

export interface AiGeneratedPlanResponse {
  id: string;
  userId: string;
  goal: string;
  context: Record<string, unknown>;
  rawPlan: AIPlanStructuredOutput;
  status: 'pending_approval' | 'edited' | 'approved' | 'rejected';
  approvedQuestIds: string[];
  createdAt: string;
  updatedAt: string;
}

export interface ApprovePlanResponse {
  plan: AiGeneratedPlanResponse;
  createdQuests: Array<{
    id: string;
    userId: string;
    parentQuestId: string | null;
    bossId: string | null;
    title: string;
    description: string | null;
    questType: string;
    priority: string;
    difficulty: string;
    estimatedMinutes: number;
    deadline: string | null;
    status: string;
  }>;
}
