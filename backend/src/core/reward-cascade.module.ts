import { Module, forwardRef } from '@nestjs/common';
import { RewardCascadeService } from './reward-cascade';
import { CharacterModule } from '../modules/character/character.module';
import { BossesModule } from '../modules/bosses/bosses.module';
import { AchievementsModule } from '../modules/achievements/achievements.module';
import { QuestsModule } from '../modules/quests/quests.module';

@Module({
  imports: [
    forwardRef(() => CharacterModule),
    forwardRef(() => BossesModule),
    forwardRef(() => AchievementsModule),
    forwardRef(() => QuestsModule),
  ],
  providers: [RewardCascadeService],
  exports: [RewardCascadeService],
})
export class RewardCascadeModule {}
