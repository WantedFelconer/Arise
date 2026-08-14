import { ToolDefinition } from '../../providers/ai-provider.interface';
import { QuestService } from '../../../quests/service/quest.service';
import { BossService } from '../../../bosses/service/boss.service';
import { CharacterService } from '../../../character/service/character.service';

/**
 * Authoritative tool definitions exposed to AI Coach per §10.4.
 * Note: `userId` is deliberately NOT present in tool parameters.
 */
export const coachToolDefinitions: ToolDefinition[] = [
  {
    name: 'get_recent_quests',
    description:
      "Fetches the user's recent quests, optionally filtered by status ('active', 'completed', 'in_progress', 'archived').",
    parameters: {
      type: 'object',
      properties: {
        status: {
          type: 'string',
          enum: ['active', 'in_progress', 'completed', 'archived'],
          description: 'Filter quests by status',
        },
        limit: {
          type: 'number',
          description: 'Max number of quests to return (default 10)',
        },
      },
    },
  },
  {
    name: 'get_xp_mana_trend',
    description:
      "Fetches the user's XP and Mana statistics and recent transaction activity over a given number of days.",
    parameters: {
      type: 'object',
      properties: {
        days: {
          type: 'number',
          description: 'Number of past days to analyze (default 7)',
        },
      },
    },
  },
  {
    name: 'get_screen_time_summary',
    description:
      "Fetches summary of app screen time and distraction metrics over a period ('today', 'week', 'month').",
    parameters: {
      type: 'object',
      properties: {
        period: {
          type: 'string',
          enum: ['today', 'week', 'month'],
          description: 'Time period for screen time summary',
        },
      },
    },
  },
  {
    name: 'get_active_bosses',
    description:
      'Fetches all currently active Boss projects, including current HP, max HP, and linked quests.',
    parameters: {
      type: 'object',
      properties: {},
    },
  },
];

export class CoachToolExecutor {
  constructor(
    private readonly questService: QuestService,
    private readonly bossService: BossService,
    private readonly characterService: CharacterService,
  ) {}

  /**
   * Executes a tool strictly scoped to authenticatedUserId.
   * Any model-supplied userId is stripped and ignored (§10.4 / Security requirement).
   */
  async executeTool(
    authenticatedUserId: string,
    toolName: string,
    rawArgs: Record<string, unknown>,
  ): Promise<string> {
    // Strip any spoofed or foreign userId argument
    const { userId: _ignored, ...args } = rawArgs;

    switch (toolName) {
      case 'get_recent_quests': {
        const status = typeof args.status === 'string' ? args.status : undefined;
        const limit = typeof args.limit === 'number' ? Math.min(args.limit, 50) : 10;
        let quests = await this.questService.listQuests(authenticatedUserId, {});
        if (status) {
          if (status === 'active') {
            quests = quests.filter(
              (q) =>
                (q.status as string) === 'active' ||
                q.status === 'pending' ||
                q.status === 'in_progress',
            );
          } else {
            quests = quests.filter((q) => (q.status as string) === status);
          }
        } else {
          quests = quests.filter((q) => q.status !== 'trashed' && q.status !== 'archived');
        }
        const sliced = quests.slice(0, limit).map((q) => ({
          id: q.id,
          title: q.title,
          status: q.status,
          priority: q.priority,
          difficulty: q.difficulty,
          estimatedMinutes: q.estimatedMinutes,
          deadline: q.deadline,
        }));
        return JSON.stringify({ count: quests.length, quests: sliced });
      }

      case 'get_xp_mana_trend': {
        const character = await this.characterService.getCharacter(authenticatedUserId);
        const stats = await this.characterService.getStats(authenticatedUserId);
        return JSON.stringify({
          level: character.level,
          totalXp: character.totalXp,
          currentMana: character.currentMana,
          maxMana: character.maxMana,
          rank: character.rank,
          stats: stats.stats,
        });
      }

      case 'get_screen_time_summary': {
        const period = typeof args.period === 'string' ? args.period : 'today';
        // Sprint 4 placeholder: return valid empty structure so Coach is forward-compatible
        return JSON.stringify({
          period,
          message: 'Screen time logging initialized (detailed tracking available in Sprint 4)',
          totalProductiveMinutes: 0,
          totalDistractionMinutes: 0,
          manaModifierApplied: 0,
          topApps: [],
        });
      }

      case 'get_active_bosses': {
        const bosses = await this.bossService.listBosses(authenticatedUserId, {
          status: 'active',
        });
        const summary = bosses.map((b) => ({
          id: b.id,
          title: b.title,
          hpCurrent: b.hpCurrent,
          hpMax: b.hpMax,
          difficulty: b.difficulty,
          deadline: b.deadline,
        }));
        return JSON.stringify({ count: bosses.length, activeBosses: summary });
      }

      default:
        return JSON.stringify({ error: `Unknown tool: ${toolName}` });
    }
  }
}
