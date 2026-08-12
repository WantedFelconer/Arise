import { AIFactory } from '../../ai/ai.factory.ts';
import type { AIPlanDraft, PlanningContext } from '../../ai/interfaces/AIProvider.ts';

export class AIPlannerService {
  private static planStore: Map<string, { draft: AIPlanDraft; userId: string }> = new Map();

  /**
   * Submit planning context and generate a draft plan as a background job.
   */
  public async createPlanJob(userId: string, context: PlanningContext): Promise<string> {
    const aiProvider = AIFactory.getProvider();
    const draft = await aiProvider.generatePlan({ ...context, userId });

    AIPlannerService.planStore.set(draft.jobId, { draft, userId });
    return draft.jobId;
  }

  /**
   * Retrieve a generated draft plan by jobId.
   */
  public getPlanDraft(jobId: string, userId: string): AIPlanDraft | null {
    const record = AIPlannerService.planStore.get(jobId);
    if (!record || record.userId !== userId) {
      return null;
    }
    return record.draft;
  }

  /**
   * Approve a draft plan and materialize real Quest entities (C-10 / FR-AIPLAN-4).
   */
  public approveAndMaterializePlan(jobId: string, userId: string): { materializedQuests: any[] } {
    const record = AIPlannerService.planStore.get(jobId);
    if (!record || record.userId !== userId) {
      throw new Error('Plan draft job not found or unauthorized');
    }

    if (record.draft.status === 'approved') {
      throw new Error('Plan job has already been approved');
    }

    record.draft.status = 'approved';

    // Map draft items to materialized Quest DTOs
    const materializedQuests = record.draft.items.map((item) => ({
      id: `q_${Math.random().toString(36).substr(2, 9)}`,
      userId,
      title: item.title,
      description: item.description,
      questType: item.questType,
      priority: item.priority,
      difficulty: item.difficulty,
      estimatedMinutes: item.estimatedMinutes,
      status: 'active',
      createdAt: new Date().toISOString(),
    }));

    return { materializedQuests };
  }
}
