import { Controller, Get, Inject } from '@nestjs/common';
import { AiQuotaService } from './ai-quota.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';

@Controller('ai/quota')
export class AiQuotaController {
  constructor(@Inject(AiQuotaService) private readonly aiQuotaService: AiQuotaService) {}

  @Get()
  async getQuota(@CurrentUser('userId') userId: string) {
    const data = await this.aiQuotaService.getQuotaStatus(userId);
    return {
      data: {
        usedToday: data.usedToday,
        limit: data.dailyLimit,
        dailyLimit: data.dailyLimit,
        remaining: data.remaining,
        resetAt: data.resetAt,
      },
    };
  }
}
