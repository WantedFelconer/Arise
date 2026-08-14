import { Injectable, Inject, NotFoundException, HttpException, HttpStatus } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { AIProvider, AI_PROVIDER_TOKEN } from '../../providers/ai-provider.interface';
import { AiQuotaService } from '../../quota/ai-quota.service';
import { QuestService } from '../../../quests/service/quest.service';
import { BossService } from '../../../bosses/service/boss.service';
import { CharacterService } from '../../../character/service/character.service';
import { memoryDb, StoredAiConversation, StoredAiMessage } from '../../../../db/memory/memory-db';
import { coachToolDefinitions, CoachToolExecutor } from '../tools/ai-coach.tools';
import {
  CreateConversationInput,
  SendMessageInput,
  DailyPlanCoachInput,
  WeeklyReviewCoachInput,
} from '../validation/coach.schema';
import {
  AiConversationResponse,
  AiMessageResponse,
  ChatResponse,
  NudgeItem,
} from '../dto/ai-coach.dto';
import { sanitizeText } from '../../utils/sanitizer.util';

@Injectable()
export class AiCoachService {
  private readonly toolExecutor: CoachToolExecutor;

  constructor(
    @Inject(AI_PROVIDER_TOKEN) private readonly aiProvider: AIProvider,
    @Inject(AiQuotaService) private readonly aiQuotaService: AiQuotaService,
    @Inject(QuestService) private readonly questService: QuestService,
    @Inject(BossService) private readonly bossService: BossService,
    @Inject(CharacterService) private readonly characterService: CharacterService,
  ) {
    this.toolExecutor = new CoachToolExecutor(
      this.questService,
      this.bossService,
      this.characterService,
    );
  }

  /**
   * Builds the fixed system prompt with explicit medical/legal/financial exclusion per §10.5.
   */
  getSystemPrompt(): string {
    return (
      'You are the ARISE AI Coach, a supportive, strategic Life-OS guide helping the user turn real-world goals ' +
      'into sustainable productivity and gamified RPG progression.\n' +
      'Guidelines:\n' +
      '1. Be direct, encouraging, pragmatic, and action-oriented.\n' +
      '2. Ground your advice in real user data using available tools (recent quests, xp/mana trends, active bosses) rather than guessing.\n' +
      '3. Do not provide medical, legal, or financial advice. If asked for medical, legal, or financial advice, advise the user to consult a qualified professional.\n' +
      '4. Keep responses concise and focused on actionable next steps.'
    );
  }

  /**
   * Create a new persistent conversation.
   */
  async createConversation(
    userId: string,
    input: CreateConversationInput,
  ): Promise<AiConversationResponse> {
    const id = uuidv4();
    const now = new Date();
    const title = input.title ? sanitizeText(input.title) : 'Coach Session';

    const conv: StoredAiConversation = {
      id,
      userId,
      title,
      contextType: input.contextType || 'coach',
      createdAt: now,
      updatedAt: now,
    };

    memoryDb.aiConversations.set(id, conv);
    return this.mapConversationToResponse(conv);
  }

  /**
   * List all conversations for the user.
   */
  async listConversations(userId: string): Promise<AiConversationResponse[]> {
    const list: StoredAiConversation[] = [];
    for (const conv of memoryDb.aiConversations.values()) {
      if (conv.userId === userId) {
        list.push(conv);
      }
    }
    list.sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    return list.map((c) => this.mapConversationToResponse(c));
  }

  /**
   * Get a conversation with message history.
   */
  async getConversation(userId: string, conversationId: string): Promise<AiConversationResponse> {
    const conv = memoryDb.aiConversations.get(conversationId);
    if (!conv || conv.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'Conversation not found or access denied',
        code: 'CONVERSATION_NOT_FOUND',
      });
    }

    const messages = this.getMessagesForConversation(conversationId);
    return this.mapConversationToResponse(conv, messages);
  }

  /**
   * Send message in a conversation, executing tool calls server-side with strict user scoping (§10.4).
   */
  async sendMessage(
    userId: string,
    conversationId: string,
    input: SendMessageInput,
  ): Promise<ChatResponse> {
    const conv = memoryDb.aiConversations.get(conversationId);
    if (!conv || conv.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'Conversation not found or access denied',
        code: 'CONVERSATION_NOT_FOUND',
      });
    }

    // 1. Quota check
    await this.aiQuotaService.checkAndIncrement(userId, 'coach');

    // 2. Persist user message
    const userMsgId = uuidv4();
    const userMsg: StoredAiMessage = {
      id: userMsgId,
      conversationId,
      userId,
      role: 'user',
      content: sanitizeText(input.content),
      createdAt: new Date(),
    };
    memoryDb.aiMessages.set(userMsgId, userMsg);

    // 3. Assemble message history
    const history = this.getMessagesForConversation(conversationId);
    const conversationPayload: Array<{
      role: 'user' | 'assistant' | 'system' | 'tool';
      content: string;
    }> = [
      { role: 'system', content: this.getSystemPrompt() },
      ...history.map((m) => ({
        role: m.role,
        content: m.content,
      })),
    ];

    // 4. Invoke AI provider with tools
    let aiResponse: {
      content: string;
      toolCalls?: Array<{ id: string; name: string; arguments: Record<string, unknown> }>;
    };
    try {
      aiResponse = await this.aiProvider.chat({
        conversation: conversationPayload,
        tools: coachToolDefinitions,
      });
    } catch (err: unknown) {
      throw new HttpException(
        {
          statusCode: HttpStatus.SERVICE_UNAVAILABLE,
          error: 'Service Unavailable',
          message: `AI Coach is currently offline: ${err instanceof Error ? err.message : String(err)}`,
          code: 'AI_OFFLINE_UNAVAILABLE',
        },
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    const toolExecutions: Array<{
      toolName: string;
      arguments: Record<string, unknown>;
      result: string;
    }> = [];

    // 5. Execute tool calls if requested by the model
    if (aiResponse.toolCalls && aiResponse.toolCalls.length > 0) {
      // Save assistant message requesting tools
      const toolCallAssistantMsgId = uuidv4();
      memoryDb.aiMessages.set(toolCallAssistantMsgId, {
        id: toolCallAssistantMsgId,
        conversationId,
        userId,
        role: 'assistant',
        content: aiResponse.content || '',
        toolCalls: aiResponse.toolCalls,
        createdAt: new Date(),
      });

      // Execute each tool call strictly scoped to authenticated user
      for (const call of aiResponse.toolCalls) {
        const toolResultString = await this.toolExecutor.executeTool(
          userId,
          call.name,
          call.arguments,
        );

        toolExecutions.push({
          toolName: call.name,
          arguments: call.arguments,
          result: toolResultString,
        });

        // Save tool result message
        const toolMsgId = uuidv4();
        const toolMsg: StoredAiMessage = {
          id: toolMsgId,
          conversationId,
          userId,
          role: 'tool',
          content: toolResultString,
          toolCallId: call.id,
          createdAt: new Date(),
        };
        memoryDb.aiMessages.set(toolMsgId, toolMsg);

        // Append to prompt payload
        conversationPayload.push({
          role: 'tool',
          content: toolResultString,
        });
      }

      // Re-invoke AI provider with tool results
      try {
        aiResponse = await this.aiProvider.chat({
          conversation: conversationPayload,
        });
      } catch (err: unknown) {
        throw new HttpException(
          {
            statusCode: HttpStatus.SERVICE_UNAVAILABLE,
            error: 'Service Unavailable',
            message: `AI Coach failed during tool response synthesis: ${err instanceof Error ? err.message : String(err)}`,
            code: 'AI_OFFLINE_UNAVAILABLE',
          },
          HttpStatus.SERVICE_UNAVAILABLE,
        );
      }
    }

    // 6. Save final assistant response
    const finalAssistantMsgId = uuidv4();
    const finalContent = sanitizeText(aiResponse.content);
    const finalAssistantMsg: StoredAiMessage = {
      id: finalAssistantMsgId,
      conversationId,
      userId,
      role: 'assistant',
      content: finalContent,
      createdAt: new Date(),
    };
    memoryDb.aiMessages.set(finalAssistantMsgId, finalAssistantMsg);

    // Update conversation timestamp
    conv.updatedAt = new Date();

    return {
      conversationId,
      message: this.mapMessageToResponse(finalAssistantMsg),
      toolExecutions: toolExecutions.length > 0 ? toolExecutions : undefined,
    };
  }

  /**
   * Direct chat convenience method (auto-creates or reuses a default conversation).
   */
  async directChat(
    userId: string,
    message: string,
    conversationId?: string,
  ): Promise<ChatResponse> {
    let targetConvId = conversationId;
    if (!targetConvId) {
      const conv = await this.createConversation(userId, {
        title: 'Daily AI Coaching',
        contextType: 'coach',
      });
      targetConvId = conv.id;
    }
    return this.sendMessage(userId, targetConvId, { content: message });
  }

  /**
   * Proposes daily plan schedule based on active quests and energy status (§8.6).
   */
  async getDailyProposal(
    userId: string,
    input: DailyPlanCoachInput,
  ): Promise<{ proposal: string; questsSuggested: Record<string, unknown>[] }> {
    await this.aiQuotaService.checkAndIncrement(userId, 'coach');

    const allQuests = await this.questService.listQuests(userId, {});
    const quests = allQuests.filter((q) => q.status === 'pending' || q.status === 'in_progress');
    let characterInfo = 'Level: 1, Mana: 100/100';
    try {
      const char = await this.characterService.getCharacter(userId);
      characterInfo = `Level: ${char.level}, Mana: ${char.currentMana}/${char.maxMana}`;
    } catch {
      // Fallback
    }

    const questSummary = quests.slice(0, 10).map((q) => ({
      title: q.title,
      priority: q.priority,
      difficulty: q.difficulty,
      estimatedMinutes: q.estimatedMinutes,
      deadline: q.deadline,
    }));

    const systemPrompt = this.getSystemPrompt();
    const userPrompt =
      `Generate a daily schedule proposal for today based on my active quests:\n` +
      `Available Time: ${input.availableHours || 4} hours\n` +
      `Focus Areas: ${(input.focusAreas || []).join(', ') || 'Core Priorities'}\n` +
      `Additional Notes: ${input.notes || 'None'}\n` +
      `Character Status: ${characterInfo}\n` +
      `Active Quests: ${JSON.stringify(questSummary)}\n` +
      `Please provide an ordered time-blocked suggestion.`;

    const aiResponse = await this.aiProvider.chat({
      conversation: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
      ],
    });

    return {
      proposal: sanitizeText(aiResponse.content),
      questsSuggested: questSummary as Record<string, unknown>[],
    };
  }

  /**
   * Generates weekly review summary (§8.6).
   */
  async getWeeklyReview(
    userId: string,
    input: WeeklyReviewCoachInput,
  ): Promise<{ summary: string; statsSnapshot: Record<string, unknown> }> {
    await this.aiQuotaService.checkAndIncrement(userId, 'coach');

    const completedQuests = await this.questService.listQuests(userId, {
      status: 'completed',
    });
    let stats: Record<string, unknown> = {};
    try {
      stats = (await this.characterService.getStats(userId)) as unknown as Record<string, unknown>;
    } catch {
      // Fallback
    }

    const systemPrompt = this.getSystemPrompt();
    const userPrompt =
      `Synthesize my weekly productivity review:\n` +
      `User Stated Wins: ${input.wins || 'Completed key milestones'}\n` +
      `User Stated Challenges: ${input.challenges || 'Time management and distractions'}\n` +
      `Next Week Goals: ${input.nextWeekGoals || 'Maintain consistency'}\n` +
      `Total Completed Quests: ${completedQuests.length}\n` +
      `Current Stats: ${JSON.stringify(stats)}\n` +
      `Provide a brief, motivating reflection and 2 concrete suggestions for next week.`;

    const aiResponse = await this.aiProvider.chat({
      conversation: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
      ],
    });

    return {
      summary: sanitizeText(aiResponse.content),
      statsSnapshot: stats,
    };
  }

  /**
   * Calculates proactive nudges for overload or procrastination (§8.6).
   */
  async getNudges(userId: string): Promise<NudgeItem[]> {
    const nudges: NudgeItem[] = [];
    const allQuests = await this.questService.listQuests(userId, {});
    const activeQuests = allQuests.filter(
      (q) => q.status === 'pending' || q.status === 'in_progress',
    );
    const bosses = await this.bossService.listBosses(userId, { status: 'active' });

    // 1. Check for Workload Overload (> 480 minutes estimated)
    const totalMinutes = activeQuests.reduce((acc, q) => acc + (q.estimatedMinutes || 30), 0);
    if (totalMinutes > 480) {
      nudges.push({
        id: uuidv4(),
        type: 'overload',
        title: 'Workload Capacity Warning',
        message: `You have ${Math.round(totalMinutes / 60)} hours of active work planned. This exceeds a realistic daily focus window.`,
        actionableSuggestion:
          'Consider deferring low-priority quests or breaking larger quests into smaller milestones.',
      });
    }

    // 2. Check for Procrastination / Overdue Tasks
    const now = new Date();
    const overdueQuests = activeQuests.filter((q) => q.deadline && new Date(q.deadline) < now);
    if (overdueQuests.length > 0 && overdueQuests[0]) {
      const target = overdueQuests[0];
      nudges.push({
        id: uuidv4(),
        type: 'procrastination',
        title: `Overdue Quest: "${target.title}"`,
        message:
          'This quest has passed its target deadline. Procrastination is often a sign the task is too vague or energy is low.',
        actionableSuggestion:
          'Ask the AI Coach to break this quest down or reschedule it for a high-energy time window.',
        relatedQuestId: target.id,
      });
    }

    // 3. Active Boss Momentum Nudge
    if (bosses.length > 0 && bosses[0]) {
      const topBoss = bosses[0];
      nudges.push({
        id: uuidv4(),
        type: 'boss_momentum',
        title: `Boss Battle: ${topBoss.title}`,
        message: `Boss HP is at ${topBoss.hpCurrent}/${topBoss.hpMax}. Completing related quests deals direct damage.`,
        actionableSuggestion:
          'Enter a Gate focus session on a quest linked to this boss to accelerate defeat.',
        relatedBossId: topBoss.id,
      });
    }

    return nudges;
  }

  private getMessagesForConversation(conversationId: string): StoredAiMessage[] {
    const list: StoredAiMessage[] = [];
    for (const msg of memoryDb.aiMessages.values()) {
      if (msg.conversationId === conversationId) {
        list.push(msg);
      }
    }
    list.sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
    return list;
  }

  private mapConversationToResponse(
    conv: StoredAiConversation,
    messages?: StoredAiMessage[],
  ): AiConversationResponse {
    return {
      id: conv.id,
      userId: conv.userId,
      title: conv.title,
      contextType: conv.contextType,
      messages: messages ? messages.map((m) => this.mapMessageToResponse(m)) : undefined,
      createdAt: conv.createdAt.toISOString(),
      updatedAt: conv.updatedAt.toISOString(),
    };
  }

  private mapMessageToResponse(msg: StoredAiMessage): AiMessageResponse {
    return {
      id: msg.id,
      conversationId: msg.conversationId,
      role: msg.role,
      content: msg.content,
      toolCalls: msg.toolCalls,
      toolCallId: msg.toolCallId,
      createdAt: msg.createdAt.toISOString(),
    };
  }
}
