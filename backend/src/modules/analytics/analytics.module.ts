import { Module } from '@nestjs/common';
import { AnalyticsController } from './controller/analytics.controller';
import { AnalyticsService } from './service/analytics.service';
import { AnalyticsRepository } from './repository/analytics.repository';

@Module({
  controllers: [AnalyticsController],
  providers: [AnalyticsService, AnalyticsRepository],
  exports: [AnalyticsService, AnalyticsRepository],
})
export class AnalyticsModule {}
