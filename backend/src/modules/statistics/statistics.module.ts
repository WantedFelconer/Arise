import { Module } from '@nestjs/common';
import { StatisticsController } from './controller/statistics.controller';
import { StatisticsService } from './service/statistics.service';

@Module({
  controllers: [StatisticsController],
  providers: [StatisticsService],
  exports: [StatisticsService],
})
export class StatisticsModule {}
