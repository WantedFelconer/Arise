import { Controller, Get, Inject } from '@nestjs/common';
import { AchievementService } from '../service/achievement.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';

@Controller('achievements')
export class AchievementController {
  constructor(@Inject(AchievementService) private achievementService: AchievementService) {}

  @Get()
  async list(@CurrentUser('userId') userId: string) {
    const data = await this.achievementService.listAchievements(userId);
    return { data };
  }

  @Get('unlocked')
  async listUnlocked(@CurrentUser('userId') userId: string) {
    const data = await this.achievementService.getUserAchievements(userId);
    return { data };
  }
}
