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
import { AnalyticsService } from '../service/analytics.service';
import {
  analyticsQuerySchema,
  generateSnapshotSchema,
} from '../validation/analytics.schema';
import { AnalyticsPeriod, GenerateSnapshotDto } from '../dto/analytics.dto';

@Controller('analytics')
export class AnalyticsController {
  constructor(@Inject(AnalyticsService) private readonly analyticsService: AnalyticsService) {}

  @Get('daily')
  async getDaily(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(analyticsQuerySchema)) query: { date?: string },
  ) {
    const data = await this.analyticsService.getDailyReport(userId, query.date);
    return { data };
  }

  @Get('weekly')
  async getWeekly(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(analyticsQuerySchema)) query: { startDate?: string },
  ) {
    const data = await this.analyticsService.getWeeklyReport(userId, query.startDate);
    return { data };
  }

  @Get('monthly')
  async getMonthly(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(analyticsQuerySchema)) query: { year?: string; month?: string },
  ) {
    const data = await this.analyticsService.getMonthlyReport(userId, query.year, query.month);
    return { data };
  }

  @Get('yearly')
  async getYearly(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(analyticsQuerySchema)) query: { year?: string },
  ) {
    const data = await this.analyticsService.getYearlyReport(userId, query.year);
    return { data };
  }

  @Get('snapshots')
  async listSnapshots(
    @CurrentUser('userId') userId: string,
    @Query('period') period?: AnalyticsPeriod,
  ) {
    const data = await this.analyticsService.listSnapshots(userId, period);
    return { data };
  }

  @Post('snapshots/generate')
  @HttpCode(HttpStatus.OK)
  async generateSnapshot(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(generateSnapshotSchema)) dto: GenerateSnapshotDto,
  ) {
    const data = await this.analyticsService.generateSnapshot(userId, dto);
    return { data };
  }
}
