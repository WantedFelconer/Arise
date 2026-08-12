import crypto from 'crypto';
import type {
  AIPlanDraft,
  AIPlanDraftItem,
  AIProvider,
  ParsedQuestDraft,
  PlanningContext,
  TriageSuggestion,
} from '../interfaces/AIProvider.ts';

export class MockAIProvider implements AIProvider {
  /**
   * Generate structured study / project plan draft from user goal context.
   */
  public async generatePlan(context: PlanningContext): Promise<AIPlanDraft> {
    const jobId = `job_${crypto.randomBytes(8).toString('hex')}`;
    const goalTitle = context.goal || 'Master Target Goal';

    const items: AIPlanDraftItem[] = [
      {
        id: 'temp_1',
        title: `Phase 1: Core Fundamentals for ${goalTitle}`,
        description: 'Read primary documentation and complete initial setup',
        estimatedMinutes: 45,
        priority: 3,
        difficulty: 2,
        questType: 'main',
      },
      {
        id: 'temp_2',
        title: `Phase 1.1: Hands-on Laboratory Exercise`,
        description: 'Implement a minimal prototype reproducing core concept',
        estimatedMinutes: 60,
        priority: 2,
        difficulty: 3,
        questType: 'main',
        parentTempId: 'temp_1',
        dependsOnTempIds: ['temp_1'],
      },
      {
        id: 'temp_3',
        title: `Phase 2: Comprehensive Review & Boss Dungeon Preparation`,
        description: 'Consolidate learnings and complete mock test / project submission',
        estimatedMinutes: 90,
        priority: 4,
        difficulty: 4,
        questType: 'boss',
        dependsOnTempIds: ['temp_2'],
      },
    ];

    return {
      jobId,
      goal: goalTitle,
      items,
      status: 'pending_approval',
      createdAt: new Date().toISOString(),
    };
  }

  /**
   * AI Triage for raw inbox items (FR-INBOX-3).
   */
  public async triageInboxItem(inboxItemId: string, rawContent: string): Promise<TriageSuggestion> {
    const isNote = rawContent.toLowerCase().includes('idea') || rawContent.toLowerCase().includes('note');
    const isBoss = rawContent.toLowerCase().includes('project') || rawContent.toLowerCase().includes('thesis');

    if (isNote) {
      return {
        inboxItemId,
        suggestedDestination: 'note',
        title: rawContent.slice(0, 50),
        description: rawContent,
      };
    } else if (isBoss) {
      return {
        inboxItemId,
        suggestedDestination: 'boss_subtask',
        title: rawContent.slice(0, 50),
        description: rawContent,
        estimatedMinutes: 60,
      };
    } else {
      return {
        inboxItemId,
        suggestedDestination: 'quest',
        title: rawContent.slice(0, 50),
        description: rawContent,
        estimatedMinutes: 30,
        suggestedDate: new Date(Date.now() + 86400000).toISOString(),
      };
    }
  }

  /**
   * Parse single free-text line into structured Quest draft (FR-NLI-1).
   * Example: "Study OS tomorrow 8pm for 2 hours"
   */
  public async parseNaturalLanguageQuest(text: string): Promise<ParsedQuestDraft> {
    const lower = text.toLowerCase();

    // Duration extraction
    let estimatedMinutes = 30;
    const hourMatch = lower.match(/(\d+)\s*(hour|hr|hours|hrs)/);
    const minMatch = lower.match(/(\d+)\s*(min|mins|minute|minutes)/);

    if (hourMatch) {
      estimatedMinutes = parseInt(hourMatch[1], 10) * 60;
    } else if (minMatch) {
      estimatedMinutes = parseInt(minMatch[1], 10);
    }

    // Priority extraction
    let priority = 2; // Default Medium
    if (lower.includes('urgent') || lower.includes('asap') || lower.includes('important')) {
      priority = 4;
    } else if (lower.includes('low') || lower.includes('maybe')) {
      priority = 1;
    }

    // Deadline estimation
    let deadline: string | undefined = undefined;
    if (lower.includes('tomorrow')) {
      const tomorrow = new Date(Date.now() + 86400000);
      tomorrow.setHours(20, 0, 0, 0);
      deadline = tomorrow.toISOString();
    } else if (lower.includes('tonight') || lower.includes('today')) {
      const today = new Date();
      today.setHours(22, 0, 0, 0);
      deadline = today.toISOString();
    }

    // Title cleaning
    const title = text
      .replace(/(tomorrow|tonight|today|\d+\s*(hour|hr|hours|hrs|\d+\s*min|mins|minutes|for))/gi, '')
      .trim() || text;

    return {
      title: title.charAt(0).toUpperCase() + title.slice(1),
      estimatedMinutes,
      priority,
      difficulty: estimatedMinutes >= 60 ? 3 : 2,
      deadline,
      tags: ['ai_parsed'],
    };
  }

  /**
   * Summarize weekly/monthly reflective reviews.
   */
  public async summarizeReflection(context: { period: string; logs: any[] }): Promise<string> {
    return `Summary for ${context.period}: Maintained high consistency across core quests. Focus stability averaged 85%. Recommendation: Schedule high-difficulty tasks during morning energy peak.`;
  }
}
