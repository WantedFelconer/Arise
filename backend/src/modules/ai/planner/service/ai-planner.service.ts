import {
  Injectable,
  Inject,
  NotFoundException,
  ConflictException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { AIProvider, AI_PROVIDER_TOKEN } from '../../providers/ai-provider.interface';
import { AiQuotaService } from '../../quota/ai-quota.service';
import { QuestService } from '../../../quests/service/quest.service';
import { CharacterService } from '../../../character/service/character.service';
import { memoryDb, StoredAiGeneratedPlan } from '../../../../db/memory/memory-db';
import {
  aiPlanJsonSchema,
  aiPlanSchema,
  AIPlanStructuredOutput,
  GeneratePlanInput,
  EditPlanInput,
  RegeneratePlanInput,
  ApprovePlanInput,
} from '../validation/plan.schema';
import { AiGeneratedPlanResponse, ApprovePlanResponse } from '../dto/ai-planner.dto';
import { QuestResponse } from '../../../quests/dto/quest.dto';
import { sanitizeObject, sanitizeText } from '../../utils/sanitizer.util';

type QuestDifficulty = 'trivial' | 'easy' | 'medium' | 'hard' | 'epic';

@Injectable()
export class AiPlannerService {
  constructor(
    @Inject(AI_PROVIDER_TOKEN) private readonly aiProvider: AIProvider,
    @Inject(AiQuotaService) private readonly aiQuotaService: AiQuotaService,
    @Inject(QuestService) private readonly questService: QuestService,
    @Inject(CharacterService) private readonly characterService: CharacterService,
  ) {}

  /**
   * Constructs the authoritative system prompt per §10.2.
   */
  private buildSystemPrompt(): string {
    return (
      'You are the ARISE AI Quest Planning Engine. Your role is to decompose high-level user goals ' +
      'into structured, actionable RPG quests and subquests with precise time estimates, priorities, ' +
      'and schedules. You must output ONLY valid JSON conforming to the requested schema. ' +
      'Never output markdown prose, conversational filler, code blocks, or text outside the JSON object. ' +
      'Respect all stated user constraints and deadlines. Never fabricate resources or facts not implied by the user input.'
    );
  }

  /**
   * Constructs user prompt with context and server-side character hints per §10.2.
   */
  private async buildUserPrompt(userId: string, input: GeneratePlanInput): Promise<string> {
    const user = memoryDb.users.get(userId);
    const difficultyMode = user?.difficultyMode || 'casual';

    let characterInfo = 'Level: 1, Mana: 100/100';
    try {
      const character = await this.characterService.getCharacter(userId);
      characterInfo = `Level: ${character.level}, Mana: ${character.currentMana}/${character.maxMana}, Rank: ${character.rank}`;
    } catch {
      // Fallback if character not yet initialized
    }

    let prompt = `User Goal: ${input.goal}\n`;
    if (input.deadline) prompt += `Target Deadline: ${input.deadline}\n`;
    if (input.availableTimeMinutesPerDay)
      prompt += `Available Time Per Day: ${input.availableTimeMinutesPerDay} minutes\n`;
    if (input.constraints) prompt += `User Constraints: ${input.constraints}\n`;
    if (input.resources) prompt += `Available Resources: ${input.resources}\n`;
    if (input.difficulty) prompt += `Desired Difficulty: ${input.difficulty}\n`;

    prompt += `\n[Server Progression Context]\n`;
    prompt += `Difficulty Mode: ${difficultyMode}\n`;
    prompt += `Current Character Status: ${characterInfo}\n`;
    prompt += `Generate a main quest and actionable subquests conforming to the JSON schema.`;

    return prompt;
  }

  /**
   * Validate and perform 1 automatic retry on failure per §10.3.
   */
  private async callProviderWithRetry(
    systemPrompt: string,
    userPrompt: string,
  ): Promise<AIPlanStructuredOutput> {
    // Attempt 1
    let rawOutput: unknown;
    try {
      rawOutput = await this.aiProvider.generateStructured<unknown>({
        systemPrompt,
        userPrompt,
        jsonSchema: aiPlanJsonSchema,
      });
    } catch (err: unknown) {
      throw new HttpException(
        {
          statusCode: HttpStatus.SERVICE_UNAVAILABLE,
          error: 'Service Unavailable',
          message: `AI Provider is currently unavailable: ${err instanceof Error ? err.message : String(err)}`,
          code: 'AI_OFFLINE_UNAVAILABLE',
        },
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    const firstParse = aiPlanSchema.safeParse(rawOutput);
    if (firstParse.success) {
      return firstParse.data;
    }

    // Auto-retry once with error correction instruction appended (§10.3)
    const errorDetails = JSON.stringify(firstParse.error.format());
    const retryUserPrompt =
      `${userPrompt}\n\n[SYSTEM ERROR CORRECTION INSTRUCTION]\n` +
      `Your previous output failed validation with the following schema error:\n${errorDetails}\n` +
      `Please correct these issues and return strictly valid JSON conforming to the schema.`;

    try {
      rawOutput = await this.aiProvider.generateStructured<unknown>({
        systemPrompt,
        userPrompt: retryUserPrompt,
        jsonSchema: aiPlanJsonSchema,
      });
    } catch (err: unknown) {
      throw new HttpException(
        {
          statusCode: HttpStatus.SERVICE_UNAVAILABLE,
          error: 'Service Unavailable',
          message: `AI Provider failed during retry: ${err instanceof Error ? err.message : String(err)}`,
          code: 'AI_OFFLINE_UNAVAILABLE',
        },
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    const secondParse = aiPlanSchema.safeParse(rawOutput);
    if (secondParse.success) {
      return secondParse.data;
    }

    // If still non-conforming, fail with 422 AI_PLAN_INVALID
    throw new HttpException(
      {
        statusCode: HttpStatus.UNPROCESSABLE_ENTITY,
        error: 'Unprocessable Entity',
        message: 'AI plan generation failed schema validation after retry',
        code: 'AI_PLAN_INVALID',
        details: secondParse.error.format(),
      },
      HttpStatus.UNPROCESSABLE_ENTITY,
    );
  }

  /**
   * Generate an AI Quest Plan and stage it in ai_generated_plans (FR-AIP-001, FR-AIP-002, FR-AIP-003).
   * ZERO rows are created in `quests` at this stage.
   */
  async generatePlan(userId: string, input: GeneratePlanInput): Promise<AiGeneratedPlanResponse> {
    // 1. Quota & Feature flag check
    await this.aiQuotaService.checkAndIncrement(userId, 'planner');

    // 2. Build prompts
    const systemPrompt = this.buildSystemPrompt();
    const userPrompt = await this.buildUserPrompt(userId, input);

    // 3. Call AI provider with schema validation and auto-retry
    const structuredPlan = await this.callProviderWithRetry(systemPrompt, userPrompt);

    // 4. Sanitize plan text against stored XSS (§10.5, §13.4)
    const sanitizedPlan = sanitizeObject(structuredPlan);

    // 5. Stage in ai_generated_plans table with status = pending_approval
    const planId = uuidv4();
    const now = new Date();
    const stagedPlan: StoredAiGeneratedPlan = {
      id: planId,
      userId,
      goal: sanitizeText(input.goal),
      context: {
        deadline: input.deadline,
        availableTimeMinutesPerDay: input.availableTimeMinutesPerDay,
        constraints: sanitizeText(input.constraints),
        resources: sanitizeText(input.resources),
        difficulty: input.difficulty,
        bossId: input.bossId,
      },
      rawPlan: sanitizedPlan as Record<string, unknown>,
      status: 'pending_approval',
      approvedQuestIds: [],
      createdAt: now,
      updatedAt: now,
    };

    memoryDb.aiGeneratedPlans.set(planId, stagedPlan);

    return this.mapToResponse(stagedPlan);
  }

  /**
   * Get a staged plan by ID.
   */
  async getPlan(userId: string, planId: string): Promise<AiGeneratedPlanResponse> {
    const plan = memoryDb.aiGeneratedPlans.get(planId);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'AI plan not found or access denied',
        code: 'AI_PLAN_NOT_FOUND',
      });
    }
    return this.mapToResponse(plan);
  }

  /**
   * Edit a staged plan before approval (FR-AIP-004).
   * Transitions status to 'edited' per §7.4.
   */
  async editPlan(
    userId: string,
    planId: string,
    input: EditPlanInput,
  ): Promise<AiGeneratedPlanResponse> {
    const plan = memoryDb.aiGeneratedPlans.get(planId);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'AI plan not found or access denied',
        code: 'AI_PLAN_NOT_FOUND',
      });
    }

    if (plan.status === 'approved') {
      throw new ConflictException({
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: 'Cannot edit an already approved plan',
        code: 'AI_PLAN_ALREADY_APPROVED',
      });
    }

    const currentRawPlan = plan.rawPlan as unknown as AIPlanStructuredOutput;

    if (input.goal) {
      plan.goal = sanitizeText(input.goal);
    }

    if (input.mainQuestTitle) {
      currentRawPlan.mainQuest.title = sanitizeText(input.mainQuestTitle);
    }

    if (input.mainQuestDescription !== undefined) {
      currentRawPlan.mainQuest.description = sanitizeText(input.mainQuestDescription);
    }

    if (input.subquests) {
      currentRawPlan.mainQuest.subquests = sanitizeObject(input.subquests);
    }

    if (input.rawPlan) {
      plan.rawPlan = sanitizeObject({ ...currentRawPlan, ...input.rawPlan });
    }

    plan.status = 'edited';
    plan.updatedAt = new Date();

    return this.mapToResponse(plan);
  }

  /**
   * Regenerate a staged plan with additional context (FR-AIP-006).
   * Replaces staged plan content.
   */
  async regeneratePlan(
    userId: string,
    planId: string,
    input: RegeneratePlanInput,
  ): Promise<AiGeneratedPlanResponse> {
    const plan = memoryDb.aiGeneratedPlans.get(planId);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'AI plan not found or access denied',
        code: 'AI_PLAN_NOT_FOUND',
      });
    }

    if (plan.status === 'approved') {
      throw new ConflictException({
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: 'Cannot regenerate an already approved plan',
        code: 'AI_PLAN_ALREADY_APPROVED',
      });
    }

    // Quota check
    await this.aiQuotaService.checkAndIncrement(userId, 'planner');

    const goal = input.updatedGoal || plan.goal;
    const constraints = [
      plan.context.constraints as string,
      input.updatedConstraints,
      input.additionalContext,
    ]
      .filter(Boolean)
      .join('; ');

    const systemPrompt = this.buildSystemPrompt();
    const userPrompt = await this.buildUserPrompt(userId, {
      goal,
      constraints,
      deadline: plan.context.deadline as string,
      availableTimeMinutesPerDay: plan.context.availableTimeMinutesPerDay as number,
      difficulty: plan.context.difficulty as QuestDifficulty,
    });

    const structuredPlan = await this.callProviderWithRetry(systemPrompt, userPrompt);
    const sanitizedPlan = sanitizeObject(structuredPlan);

    plan.goal = sanitizeText(goal);
    plan.rawPlan = sanitizedPlan as Record<string, unknown>;
    plan.status = 'pending_approval';
    plan.updatedAt = new Date();

    return this.mapToResponse(plan);
  }

  /**
   * Discard / Reject a staged plan.
   */
  async rejectPlan(userId: string, planId: string): Promise<AiGeneratedPlanResponse> {
    const plan = memoryDb.aiGeneratedPlans.get(planId);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'AI plan not found or access denied',
        code: 'AI_PLAN_NOT_FOUND',
      });
    }

    if (plan.status === 'approved') {
      throw new ConflictException({
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: 'Cannot reject an already approved plan',
        code: 'AI_PLAN_ALREADY_APPROVED',
      });
    }

    plan.status = 'rejected';
    plan.updatedAt = new Date();

    return this.mapToResponse(plan);
  }

  /**
   * Materialize approved plan into real quests (FR-AIP-005 / Literal §19 AC).
   * In a single transactional flow, creates main quest and all subquests preserving parent_quest_id.
   */
  async approvePlan(
    userId: string,
    planId: string,
    input?: ApprovePlanInput,
  ): Promise<ApprovePlanResponse> {
    const plan = memoryDb.aiGeneratedPlans.get(planId);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException({
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: 'AI plan not found or access denied',
        code: 'AI_PLAN_NOT_FOUND',
      });
    }

    if (plan.status === 'approved') {
      throw new ConflictException({
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: 'This AI plan has already been approved',
        code: 'AI_PLAN_ALREADY_APPROVED',
      });
    }

    const structuredPlan = plan.rawPlan as unknown as AIPlanStructuredOutput;
    const mainQuestData = structuredPlan.mainQuest;
    const bossId = input?.bossId || (plan.context.bossId as string) || undefined;
    const deadline = input?.deadline || mainQuestData.deadline || undefined;
    const tags = input?.tags || ['ai-generated', 'planned'];

    const createdQuests: QuestResponse[] = [];
    const approvedQuestIds: string[] = [];

    // 1. Create Main Quest (parent_quest_id = null)
    const mainQuest = await this.questService.createQuest(userId, {
      title: mainQuestData.title,
      description: mainQuestData.description,
      questType: 'main',
      priority: 'high',
      difficulty: (mainQuestData.difficulty as QuestDifficulty) || 'medium',
      deadline,
      bossId,
      tags,
    });

    createdQuests.push(mainQuest);
    approvedQuestIds.push(mainQuest.id);

    // 2. Create Subquests with parent_quest_id = mainQuest.id
    for (const sub of mainQuestData.subquests) {
      const subQuest = await this.questService.createQuest(userId, {
        title: sub.title,
        description: sub.description,
        questType: 'side',
        parentQuestId: mainQuest.id,
        priority: sub.priority,
        difficulty: (sub.difficulty as QuestDifficulty) || 'medium',
        estimatedMinutes: sub.estimatedMinutes,
        bossId,
        tags,
      });

      createdQuests.push(subQuest);
      approvedQuestIds.push(subQuest.id);
    }

    // 3. Transition staged plan status to approved
    plan.status = 'approved';
    plan.approvedQuestIds = approvedQuestIds;
    plan.updatedAt = new Date();

    return {
      plan: this.mapToResponse(plan),
      createdQuests,
    };
  }

  private mapToResponse(plan: StoredAiGeneratedPlan): AiGeneratedPlanResponse {
    return {
      id: plan.id,
      userId: plan.userId,
      goal: plan.goal,
      context: plan.context,
      rawPlan: plan.rawPlan as AIPlanStructuredOutput,
      status: plan.status,
      approvedQuestIds: plan.approvedQuestIds || [],
      createdAt: plan.createdAt.toISOString(),
      updatedAt: plan.updatedAt.toISOString(),
    };
  }
}
