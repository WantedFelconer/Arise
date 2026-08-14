import { Controller, Get, Inject } from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { StatisticsService } from '../service/statistics.service';

@Controller('stats')
export class StatisticsController {
  constructor(@Inject(StatisticsService) private readonly statisticsService: StatisticsService) {}

  @Get()
  async getStats(@CurrentUser('userId') userId: string) {
    const data = await this.statisticsService.getLifetimeStats(userId);
    return { data };
  }
}
