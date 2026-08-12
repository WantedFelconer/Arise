import { AIFactory } from '../ai/ai.factory.ts';
import { Envelope } from '../api/envelope.ts';
import { QuestService } from '../modules/quests/quest.service.ts';
import type { QuestEntity } from '../types/database.ts';

export class QuestController {
  /**
   * POST /api/v1/quests/parse-nl (FR-NLI-1)
   */
  public static async parseNaturalLanguage(req: any, res: any) {
    try {
      const { text } = req.body || {};
      if (!text) {
        return res.status(400).json(Envelope.error('Free-text line required'));
      }

      const aiProvider = AIFactory.getProvider();
      const draft = await aiProvider.parseNaturalLanguageQuest(text);

      return res.status(200).json(Envelope.success(draft));
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Failed to parse natural language quest'));
    }
  }

  /**
   * POST /api/v1/quests/:id/complete (FR-QUEST-12)
   */
  public static async completeQuest(req: any, res: any) {
    try {
      const { id } = req.params;
      const { actualMinutes } = req.body || {};

      const mockQuest: QuestEntity = {
        id,
        user_id: req.user?.userId || 'user_demo',
        title: 'Complete Research Paper Draft',
        quest_type: 'main',
        priority: 3,
        difficulty: 3,
        estimated_minutes: 60,
        status: 'active',
        tags: ['research'],
        is_favorite: false,
        is_pinned: false,
        created_at: new Date(),
        updated_at: new Date(),
      };

      const result = QuestService.completeQuest(mockQuest, actualMinutes || 45);
      return res.status(200).json(Envelope.success(result));
    } catch (err: any) {
      return res.status(400).json(Envelope.error(err.message || 'Quest completion failed'));
    }
  }
}
