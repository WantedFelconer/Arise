import { Envelope } from '../api/envelope.ts';
import { SyncService } from '../modules/sync/sync.service.ts';
import type { SyncBatchRequest } from '../types/database.ts';

export class SyncController {
  private static syncService = new SyncService();

  /**
   * POST /api/v1/sync/push
   */
  public static async pushSyncBatch(req: any, res: any) {
    try {
      const userId = req.user?.userId || 'user_demo';
      const batchRequest: SyncBatchRequest = req.body;

      if (!batchRequest || !Array.isArray(batchRequest.events)) {
        return res.status(400).json(Envelope.error('Invalid sync batch payload'));
      }

      const response = await SyncController.syncService.processSyncBatch(userId, batchRequest);
      return res.status(200).json(Envelope.success(response));
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Sync processing failed'));
    }
  }
}
