import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UsePipes,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { AiCoachService } from '../service/ai-coach.service';
import { CurrentUser } from '../../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../../core/pipes/zod-validation.pipe';
import {
  createConversationSchema,
  sendMessageSchema,
  directChatSchema,
  dailyPlanCoachSchema,
  weeklyReviewCoachSchema,
  CreateConversationInput,
  SendMessageInput,
  DirectChatInput,
  DailyPlanCoachInput,
  WeeklyReviewCoachInput,
} from '../validation/coach.schema';

@Controller('ai/coach')
export class AiCoachController {
  constructor(@Inject(AiCoachService) private readonly coachService: AiCoachService) {}

  @Post('conversations')
  @UsePipes(new ZodValidationPipe(createConversationSchema))
  async createConversation(
    @CurrentUser('userId') userId: string,
    @Body() body: CreateConversationInput,
  ) {
    const data = await this.coachService.createConversation(userId, body);
    return { data };
  }

  @Get('conversations')
  async listConversations(@CurrentUser('userId') userId: string) {
    const data = await this.coachService.listConversations(userId);
    return { data };
  }

  @Get('conversations/:id')
  async getConversation(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.coachService.getConversation(userId, id);
    return { data };
  }

  @Post('conversations/:id/messages')
  @UsePipes(new ZodValidationPipe(sendMessageSchema))
  async sendMessage(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: SendMessageInput,
  ) {
    const data = await this.coachService.sendMessage(userId, id, body);
    return { data };
  }

  @Post('chat')
  @UsePipes(new ZodValidationPipe(directChatSchema))
  async directChat(@CurrentUser('userId') userId: string, @Body() body: DirectChatInput) {
    const data = await this.coachService.directChat(userId, body.message, body.conversationId);
    return { data };
  }

  @Post('daily')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(dailyPlanCoachSchema))
  async getDailyProposal(@CurrentUser('userId') userId: string, @Body() body: DailyPlanCoachInput) {
    const data = await this.coachService.getDailyProposal(userId, body);
    return { data };
  }

  @Post('weekly-review')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(weeklyReviewCoachSchema))
  async getWeeklyReview(
    @CurrentUser('userId') userId: string,
    @Body() body: WeeklyReviewCoachInput,
  ) {
    const data = await this.coachService.getWeeklyReview(userId, body);
    return { data };
  }

  @Get('nudges')
  async getNudges(@CurrentUser('userId') userId: string) {
    const data = await this.coachService.getNudges(userId);
    return { data };
  }
}
