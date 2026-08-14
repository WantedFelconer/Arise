import { Module } from '@nestjs/common';
import { BossController } from './controller/boss.controller';
import { BossService } from './service/boss.service';
import { BossRepository } from './repository/boss.repository';

@Module({
  controllers: [BossController],
  providers: [BossService, BossRepository],
  exports: [BossService, BossRepository],
})
export class BossesModule {}
