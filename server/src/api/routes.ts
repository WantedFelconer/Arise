import { AIPlannerController } from '../controllers/ai_planner.controller.ts';
import { AuthController } from '../controllers/auth.controller.ts';
import { QuestController } from '../controllers/quest.controller.ts';
import { SyncController } from '../controllers/sync.controller.ts';
import { authMiddleware } from '../middleware/auth.middleware.ts';
import { rateLimitMiddleware } from '../middleware/ratelimit.middleware.ts';
import { securityHeadersMiddleware } from '../middleware/security.middleware.ts';

export function createMasterRouter(): any {
  let Router: any;
  try {
    Router = require('express').Router;
  } catch (e) {
    // Browser mock router
    Router = () => ({
      use: () => {},
      post: () => {},
      get: () => {},
      patch: () => {},
      delete: () => {},
    });
  }

  const router = Router();


  // Apply security headers & global rate limiting
  router.use(securityHeadersMiddleware);
  router.use(rateLimitMiddleware(100, 60000));

  // 1. Auth Endpoints (Public)
  router.post('/auth/signup', AuthController.signup);
  router.post('/auth/login', AuthController.login);
  router.post('/auth/refresh', AuthController.refresh);

  // 2. Protected Routes (Bearer Token Required)
  const protectedRouter = Router();
  protectedRouter.use(authMiddleware);

  // Quests
  protectedRouter.post('/quests/parse-nl', QuestController.parseNaturalLanguage);
  protectedRouter.post('/quests/:id/complete', QuestController.completeQuest);

  // Sync
  protectedRouter.post('/sync/push', SyncController.pushSyncBatch);

  // AI Planner (Flagship)
  protectedRouter.post('/ai/plan', AIPlannerController.createPlanJob);
  protectedRouter.get('/ai/plan/:jobId', AIPlannerController.getPlanDraft);
  protectedRouter.post('/ai/plan/:jobId/approve', AIPlannerController.approvePlan);

  router.use(protectedRouter);

  return router;
}
