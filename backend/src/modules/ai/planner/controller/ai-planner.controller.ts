import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  UsePipes,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { AiPlannerService } from '../service/ai-planner.service';
import { CurrentUser } from '../../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../../core/pipes/zod-validation.pipe';
import {
  generatePlanInputSchema,
  editPlanInputSchema,
  regeneratePlanInputSchema,
  approvePlanInputSchema,
  GeneratePlanInput,
  EditPlanInput,
  RegeneratePlanInput,
  ApprovePlanInput,
} from '../validation/plan.schema';

@Controller('ai/plan')
export class AiPlannerController {
  constructor(@Inject(AiPlannerService) private readonly plannerService: AiPlannerService) {}

  @Post()
  @UsePipes(new ZodValidationPipe(generatePlanInputSchema))
  async generatePlan(@CurrentUser('userId') userId: string, @Body() body: GeneratePlanInput) {
    const data = await this.plannerService.generatePlan(userId, body);
    return { data };
  }

  @Get(':id')
  async getPlan(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.plannerService.getPlan(userId, id);
    return { data };
  }

  @Patch(':id')
  @UsePipes(new ZodValidationPipe(editPlanInputSchema))
  async editPlan(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: EditPlanInput,
  ) {
    const data = await this.plannerService.editPlan(userId, id, body);
    return { data };
  }

  @Post(':id/approve')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(approvePlanInputSchema))
  async approvePlan(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body?: ApprovePlanInput,
  ) {
    const data = await this.plannerService.approvePlan(userId, id, body);
    return { data };
  }

  @Post(':id/reject')
  @HttpCode(HttpStatus.OK)
  async rejectPlan(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.plannerService.rejectPlan(userId, id);
    return { data };
  }

  @Post(':id/regenerate')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(regeneratePlanInputSchema))
  async regeneratePlan(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: RegeneratePlanInput,
  ) {
    const data = await this.plannerService.regeneratePlan(userId, id, body);
    return { data };
  }
}
