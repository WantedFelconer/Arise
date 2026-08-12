import { XPEngine } from '../../engines/xp.engine.ts';
import type { QuestEntity, QuestStatus, QuestType } from '../../types/database.ts';

export interface CreateQuestInput {
  userId: string;
  title: string;
  description?: string;
  questType?: QuestType;
  priority?: number;
  difficulty?: number;
  estimatedMinutes?: number;
  bossId?: string;
  parentQuestId?: string;
  dependsOnQuestIds?: string[];
  tags?: string[];
}

export class QuestService {
  /**
   * Check if a quest is locked due to unfulfilled prerequisites (FR-QUEST-4, FR-QUEST-13).
   */
  public static isQuestLocked(prerequisitesStatus: QuestStatus[]): boolean {
    return prerequisitesStatus.some((status) => status !== 'completed');
  }

  /**
   * Complete a Quest and compute authoritative XP and domain event payload (FR-QUEST-12).
   */
  public static completeQuest(quest: QuestEntity, actualMinutes: number) {
    if (quest.status === 'completed') {
      throw new Error('Quest is already completed');
    }

    const calculatedXP = XPEngine.calculateQuestXP({
      difficulty: quest.difficulty,
      priority: quest.priority,
      estimatedMinutes: quest.estimated_minutes,
    });

    const now = new Date();
    const updatedQuest: QuestEntity = {
      ...quest,
      status: 'completed',
      actual_minutes: actualMinutes,
      completed_at: now,
      updated_at: now,
    };

    const domainEvent = {
      eventType: 'QuestCompleted',
      payload: {
        questId: quest.id,
        userId: quest.user_id,
        bossId: quest.boss_id,
        difficulty: quest.difficulty,
        xpAwarded: calculatedXP,
        actualMinutes,
        completedAt: now.toISOString(),
      },
    };

    return {
      quest: updatedQuest,
      xpAwarded: calculatedXP,
      domainEvent,
    };
  }
}
