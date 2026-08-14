import { AIPlanStructuredOutput } from '../validation/plan.schema';
import { QuestResponse } from '../../../quests/dto/quest.dto';

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
  createdQuests: QuestResponse[];
}
