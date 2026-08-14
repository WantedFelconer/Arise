import { describe, it, expect, beforeEach } from 'vitest';
import { ConfigService } from '@nestjs/config';
import { AiCoachService } from '../coach/service/ai-coach.service';
import { MockAIProvider } from '../providers/mock.adapter';
import { AiQuotaService } from '../quota/ai-quota.service';
import { QuestService } from '../../quests/service/quest.service';
import { QuestRepository } from '../../quests/repository/quest.repository';
import { RewardCascadeService } from '../../../core/reward-cascade.service';
import { BossService } from '../../bosses/service/boss.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { CoachToolExecutor } from '../coach/tools/ai-coach.tools';
import { memoryDb } from '../../../db/memory/memory-db';

describe('AI Coach Suite (§6.13, §10.4, §10.5)', () => {
  let coachService: AiCoachService;
  let mockProvider: MockAIProvider;
  let quotaService: AiQuotaService;
  let questService: QuestService;
  let bossService: BossService;
  let characterService: CharacterService;
  let toolExecutor: CoachToolExecutor;

  const userA = 'user-a-coach-123';
  const userB = 'user-b-coach-456';

  beforeEach(() => {
    memoryDb.clear();

    // Create User A
    memoryDb.users.set(userA, {
      id: userA,
      email: 'usera@example.com',
      passwordHash: 'hash',
      difficultyMode: 'casual',
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });

    memoryDb.characters.set(userA, {
      id: 'char-a',
      userId: userA,
      level: 3,
      totalXp: 1500,
      currentMana: 90,
      maxMana: 100,
      coins: 50,
      gems: 5,
      rank: 'D',
      activeTitleId: null,
      stats: {
        intelligence: 15,
        discipline: 12,
        fitness: 10,
        creativity: 14,
        coding: 18,
        business: 10,
        health: 12,
      },
      updatedAt: new Date(),
    });

    // Create User B
    memoryDb.users.set(userB, {
      id: userB,
      email: 'userb@example.com',
      passwordHash: 'hash',
      difficultyMode: 'hardcore',
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });

    memoryDb.characters.set(userB, {
      id: 'char-b',
      userId: userB,
      level: 10,
      totalXp: 25000,
      currentMana: 50,
      maxMana: 150,
      coins: 500,
      gems: 50,
      rank: 'A',
      activeTitleId: null,
      stats: {
        intelligence: 30,
        discipline: 30,
        fitness: 30,
        creativity: 30,
        coding: 30,
        business: 30,
        health: 30,
      },
      updatedAt: new Date(),
    });

    const configService = new ConfigService({ AI_DAILY_QUOTA: 50 });
    mockProvider = new MockAIProvider();
    quotaService = new AiQuotaService(configService);

    const characterRepo = new CharacterRepository();
    characterService = new CharacterService(characterRepo);

    const bossRepo = new BossRepository();
    bossService = new BossService(bossRepo);

    const questRepo = new QuestRepository();
    questService = new QuestService(
      questRepo,
      bossService,
      characterService,
      undefined as unknown as RewardCascadeService,
    );
    toolExecutor = new CoachToolExecutor(questService, bossService, characterService);

    coachService = new AiCoachService(
      mockProvider,
      quotaService,
      questService,
      bossService,
      characterService,
    );
  });

  it('1. System prompt strictly contains §10.5 medical/legal/financial exclusion clause', () => {
    const prompt = coachService.getSystemPrompt();
    expect(prompt).toContain('medical');
    expect(prompt).toContain('legal');
    expect(prompt).toContain('financial');
    expect(prompt).toContain('consult a qualified professional');
  });

  it('2. Persistent multi-turn chat backed by ai_conversations and ai_messages (FR-COACH-001)', async () => {
    const conv = await coachService.createConversation(userA, {
      title: 'Weekly Productivity Review',
      contextType: 'coach',
    });

    expect(conv.id).toBeDefined();
    expect(conv.userId).toBe(userA);
    expect(conv.title).toBe('Weekly Productivity Review');

    // Send turn 1
    const res1 = await coachService.sendMessage(userA, conv.id, {
      content: 'How should I structure my study session today?',
    });

    expect(res1.message.role).toBe('assistant');
    expect(res1.message.content).toBeDefined();

    // Verify messages stored in memoryDb
    let messages = await coachService.getConversation(userA, conv.id);
    expect(messages.messages?.length).toBe(2); // user turn 1 + assistant turn 1

    // Send turn 2
    mockProvider.queueChatResponse({
      content: 'Great question! Focus on deep work for 90 minutes first.',
    });

    const res2 = await coachService.sendMessage(userA, conv.id, {
      content: 'What about distractions?',
    });

    expect(res2.message.content).toBe('Great question! Focus on deep work for 90 minutes first.');

    messages = await coachService.getConversation(userA, conv.id);
    expect(messages.messages?.length).toBe(4); // 2 user + 2 assistant
  });

  it('3. Tool calling integration: Executes tools and feeds results back to AI model (FR-COACH-003)', async () => {
    // Add sample quests and boss for User A
    await questService.createQuest(userA, {
      title: 'Active Task 1',
      difficulty: 'medium',
      priority: 'high',
    });

    const conv = await coachService.createConversation(userA, {
      title: 'Tool Test',
      contextType: 'coach',
    });

    // Mock AI asking for get_recent_quests tool call
    mockProvider.queueChatResponse({
      content: '',
      toolCalls: [
        {
          id: 'call_1',
          name: 'get_recent_quests',
          arguments: { status: 'active', limit: 5 },
        },
      ],
    });

    // Mock second AI response after tool execution
    mockProvider.queueChatResponse({
      content: 'I see you have 1 active quest: "Active Task 1". Ready to begin?',
    });

    const res = await coachService.sendMessage(userA, conv.id, {
      content: 'What quests do I have right now?',
    });

    expect(res.toolExecutions?.length).toBe(1);
    expect(res.toolExecutions?.[0]?.toolName).toBe('get_recent_quests');
    expect(res.toolExecutions?.[0]?.result).toContain('Active Task 1');
    expect(res.message.content).toBe(
      'I see you have 1 active quest: "Active Task 1". Ready to begin?',
    );

    // Verify tool execution message stored
    const convWithMsgs = await coachService.getConversation(userA, conv.id);
    const toolMsg = convWithMsgs.messages?.find((m) => m.role === 'tool');
    expect(toolMsg).toBeDefined();
    expect(toolMsg?.content).toContain('Active Task 1');
  });

  it('4. ANTI-SPOOFING SECURITY TEST: Tool calling ignores foreign/spoofed userId in arguments (§10.4)', async () => {
    // Create secret quests for User B
    await questService.createQuest(userB, {
      title: 'Top Secret User B Project',
      difficulty: 'epic',
      priority: 'urgent',
    });

    // Create User A quest
    await questService.createQuest(userA, {
      title: 'User A Public Quest',
      difficulty: 'easy',
      priority: 'low',
    });

    // Attempt tool execution where model passes spoofed userId for User B
    const toolResult = await toolExecutor.executeTool(userA, 'get_recent_quests', {
      userId: userB, // Attacker or hallucinating model attempts to access User B data
      status: 'active',
    });

    const parsed = JSON.parse(toolResult);
    expect(parsed.count).toBe(1);
    expect(parsed.quests[0].title).toBe('User A Public Quest');
    expect(toolResult).not.toContain('Top Secret User B Project');

    // Attempt get_xp_mana_trend tool spoofing
    const trendResult = await toolExecutor.executeTool(userA, 'get_xp_mana_trend', {
      userId: userB,
    });
    const parsedTrend = JSON.parse(trendResult);
    expect(parsedTrend.level).toBe(3); // User A's level, NOT User B's level 10
    expect(parsedTrend.rank).toBe('D');
  });

  it('5. Evaluates all 4 read-only tool definitions (§10.4)', async () => {
    // 1. get_recent_quests
    const qRes = await toolExecutor.executeTool(userA, 'get_recent_quests', {});
    expect(JSON.parse(qRes)).toHaveProperty('quests');

    // 2. get_xp_mana_trend
    const tRes = await toolExecutor.executeTool(userA, 'get_xp_mana_trend', { days: 7 });
    expect(JSON.parse(tRes)).toHaveProperty('currentMana');

    // 3. get_screen_time_summary (Sprint 4 placeholder stub)
    const sRes = await toolExecutor.executeTool(userA, 'get_screen_time_summary', {
      period: 'today',
    });
    const sParsed = JSON.parse(sRes);
    expect(sParsed.period).toBe('today');
    expect(sParsed.message).toContain('Sprint 4');

    // 4. get_active_bosses
    await bossService.createBoss(userA, {
      title: 'Boss Dragon',
      hpMax: 500,
      difficulty: 'hard',
    });
    const bRes = await toolExecutor.executeTool(userA, 'get_active_bosses', {});
    const bParsed = JSON.parse(bRes);
    expect(bParsed.count).toBe(1);
    expect(bParsed.activeBosses[0].title).toBe('Boss Dragon');
  });

  it('6. Computes proactive nudges for overload, procrastination, and boss momentum (§8.6)', async () => {
    // 1. Trigger overload nudge by adding > 480 minutes of work
    await questService.createQuest(userA, {
      title: 'Massive Project Task',
      estimatedMinutes: 500,
    });

    // 2. Trigger procrastination nudge by adding past-deadline quest
    const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    await questService.createQuest(userA, {
      title: 'Overdue Assignment',
      deadline: pastDate,
    });

    // 3. Add active boss
    await bossService.createBoss(userA, {
      title: 'Final Exam Boss',
      hpMax: 200,
      difficulty: 'medium',
    });

    const nudges = await coachService.getNudges(userA);

    expect(nudges.some((n) => n.type === 'overload')).toBe(true);
    expect(nudges.some((n) => n.type === 'procrastination')).toBe(true);
    expect(nudges.some((n) => n.type === 'boss_momentum')).toBe(true);
  });

  it('7. Daily planning and weekly review endpoints (§8.6)', async () => {
    mockProvider.queueChatResponse({
      content: 'Here is your daily schedule: 9am-11am Deep Focus on Core Quests.',
    });

    const daily = await coachService.getDailyProposal(userA, {
      availableHours: 4,
      focusAreas: ['Coding', 'Architecture'],
    });

    expect(daily.proposal).toContain('daily schedule');

    mockProvider.queueChatResponse({
      content: 'Weekly Review: Excellent consistency on coding quests. Focus on recovery.',
    });

    const weekly = await coachService.getWeeklyReview(userA, {
      wins: 'Finished Sprint 3',
      challenges: 'Sleep schedule',
    });

    expect(weekly.summary).toContain('Weekly Review');
  });
});
