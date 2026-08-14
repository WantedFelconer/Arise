import { Module } from '@nestjs/common';
import { AchievementController } from './controller/achievement.controller';
import { AchievementService } from './service/achievement.service';
import { AchievementRepository } from './repository/achievement.repository';
import { CharacterModule } from '../character/character.module';

@Module({
  imports: [CharacterModule],
  controllers: [AchievementController],
  providers: [AchievementService, AchievementRepository],
  exports: [AchievementService, AchievementRepository],
})
export class AchievementsModule {}
