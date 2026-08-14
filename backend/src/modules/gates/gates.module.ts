import { Module, forwardRef } from '@nestjs/common';
import { GateController } from './controller/gate.controller';
import { GateService } from './service/gate.service';
import { GateRepository } from './repository/gate.repository';
import { QuestsModule } from '../quests/quests.module';
import { RewardCascadeModule } from '../../core/reward-cascade.module';

@Module({
  imports: [forwardRef(() => QuestsModule), forwardRef(() => RewardCascadeModule)],
  controllers: [GateController],
  providers: [GateService, GateRepository],
  exports: [GateService, GateRepository],
})
export class GatesModule {}
