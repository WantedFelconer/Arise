import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { FitnessService } from '../service/fitness.service';
import {
  createFitnessLogSchema,
  fitnessFilterSchema,
} from '../validation/fitness.schema';
import { CreateFitnessLogDto } from '../dto/fitness.dto';

@Controller('fitness')
export class FitnessController {
  constructor(@Inject(FitnessService) private readonly fitnessService: FitnessService) {}

  @Post('logs')
  @HttpCode(HttpStatus.CREATED)
  async logActivity(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(createFitnessLogSchema)) dto: CreateFitnessLogDto,
  ) {
    const data = await this.fitnessService.logActivity(userId, dto);
    return { data };
  }

  @Get('logs')
  async listLogs(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(fitnessFilterSchema)) filter: any,
  ) {
    const data = await this.fitnessService.listLogs(userId, filter);
    return { data };
  }

  @Get('summary')
  async getSummary(@CurrentUser('userId') userId: string) {
    const data = await this.fitnessService.getSummary(userId);
    return { data };
  }
}
