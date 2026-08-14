import { Module, forwardRef } from '@nestjs/common';
import { QuestController } from './controller/quest.controller';
import { QuestService } from './service/quest.service';
import { QuestRepository } from './repository/quest.repository';
import { BossesModule } from '../bosses/bosses.module';
import { CharacterModule } from '../character/character.module';
import { RewardCascadeModule } from '../../core/reward-cascade.module';

@Module({
  imports: [
    forwardRef(() => BossesModule),
    forwardRef(() => CharacterModule),
    forwardRef(() => RewardCascadeModule),
  ],
  controllers: [QuestController],
  providers: [QuestService, QuestRepository],
  exports: [QuestService, QuestRepository],
})
export class QuestsModule {}
