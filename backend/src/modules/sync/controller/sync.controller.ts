import { Controller, Post, Headers, Body, HttpCode, HttpStatus, Inject } from '@nestjs/common';
import { SyncService } from '../service/sync.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';

@Controller('sync')
export class SyncController {
  constructor(@Inject(SyncService) private syncService: SyncService) {}

  @Post('idempotency-test')
  @HttpCode(HttpStatus.OK)
  async testIdempotency(
    @CurrentUser('userId') userId: string,
    @Headers('idempotency-key') idempotencyKey?: string,
    @Body('amount') amount?: number,
  ) {
    const data = await this.syncService.executeTestCommand(userId, idempotencyKey, amount);
    return { data };
  }
}
