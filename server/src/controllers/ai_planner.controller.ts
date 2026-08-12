import { Envelope } from '../api/envelope.ts';
import { AIPlannerService } from '../modules/ai_planner/ai_planner.service.ts';

export class AIPlannerController {
  private static service = new AIPlannerService();

  /**
   * POST /api/v1/ai/plan
   */
  public static async createPlanJob(req: any, res: any) {
    try {
      const userId = req.user?.userId || 'user_demo';
      const context = req.body || {};

      if (!context.goal) {
        return res.status(400).json(Envelope.error('Goal context is required'));
      }

      const jobId = await AIPlannerController.service.createPlanJob(userId, context);
      return res.status(202).json(Envelope.success({ jobId, status: 'pending_approval' }));
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Plan generation failed'));
    }
  }

  /**
   * GET /api/v1/ai/plan/:jobId
   */
  public static async getPlanDraft(req: any, res: any) {
    try {
      const userId = req.user?.userId || 'user_demo';
      const { jobId } = req.params;

      const draft = AIPlannerController.service.getPlanDraft(jobId, userId);
      if (!draft) {
        return res.status(404).json(Envelope.error('Plan draft not found'));
      }

      return res.status(200).json(Envelope.success(draft));
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Failed to retrieve plan draft'));
    }
  }

  /**
   * POST /api/v1/ai/plan/:jobId/approve (C-10 / FR-AIPLAN-4)
   */
  public static async approvePlan(req: any, res: any) {
    try {
      const userId = req.user?.userId || 'user_demo';
      const { jobId } = req.params;

      const result = AIPlannerController.service.approveAndMaterializePlan(jobId, userId);
      return res.status(200).json(Envelope.success(result));
    } catch (err: any) {
      return res.status(400).json(Envelope.error(err.message || 'Plan approval failed'));
    }
  }
}
