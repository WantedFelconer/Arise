import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  Headers,
  UsePipes,
  Inject,
  Optional,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { QuestService } from '../service/quest.service';
import { IdempotencyService } from '../../../core/idempotency/idempotency.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import {
  createQuestSchema,
  updateQuestSchema,
  questListQuerySchema,
  CreateQuestInput,
  UpdateQuestInput,
  QuestListQueryInput,
} from '../validation/quest.schema';

@Controller('quests')
export class QuestController {
  constructor(
    @Inject(QuestService) private questService: QuestService,
    @Optional() @Inject(IdempotencyService) private idempotencyService?: IdempotencyService,
  ) {}

  @Get()
  @UsePipes(new ZodValidationPipe(questListQuerySchema))
  async list(@CurrentUser('userId') userId: string, @Query() query: QuestListQueryInput) {
    const data = await this.questService.listQuests(userId, query);
    return { data };
  }

  @Get(':id')
  async get(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.getQuest(userId, id);
    return { data };
  }

  @Post()
  @UsePipes(new ZodValidationPipe(createQuestSchema))
  async create(
    @CurrentUser('userId') userId: string,
    @Body() body: CreateQuestInput,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    if (idempotencyKey && this.idempotencyService) {
      const result = await this.idempotencyService.executeIdempotent(
        userId,
        idempotencyKey,
        'CREATE_QUEST',
        async () => {
          const data = await this.questService.createQuest(userId, body);
          return { status: 201, body: data };
        },
      );
      return { data: result.body };
    }

    const data = await this.questService.createQuest(userId, body);
    return { data };
  }

  @Patch(':id')
  @UsePipes(new ZodValidationPipe(updateQuestSchema))
  async update(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: UpdateQuestInput,
  ) {
    const data = await this.questService.updateQuest(userId, id, body);
    return { data };
  }

  @Post(':id/start')
  @HttpCode(HttpStatus.OK)
  async start(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.startQuest(userId, id);
    return { data };
  }

  @Post(':id/pause')
  @HttpCode(HttpStatus.OK)
  async pause(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.pauseQuest(userId, id);
    return { data };
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  async complete(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    if (idempotencyKey && this.idempotencyService) {
      const result = await this.idempotencyService.executeIdempotent(
        userId,
        idempotencyKey,
        'COMPLETE_QUEST',
        async () => {
          const data = await this.questService.completeQuest(userId, id);
          return { status: 200, body: data };
        },
      );
      return { data: result.body };
    }

    const data = await this.questService.completeQuest(userId, id);
    return { data };
  }

  @Post(':id/archive')
  @HttpCode(HttpStatus.OK)
  async archive(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.archiveQuest(userId, id);
    return { data };
  }

  @Post(':id/restore')
  @HttpCode(HttpStatus.OK)
  async restore(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.restoreQuest(userId, id);
    return { data };
  }

  @Post(':id/undo')
  @HttpCode(HttpStatus.OK)
  async undo(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.undo(userId, id);
    return { data };
  }

  @Post(':id/fail')
  @HttpCode(HttpStatus.OK)
  async fail(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.failQuest(userId, id);
    return { data };
  }

  @Delete(':id')
  async delete(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.questService.deleteQuest(userId, id);
    return { data };
  }
}
