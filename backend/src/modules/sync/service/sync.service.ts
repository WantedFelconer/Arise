import { Injectable, BadRequestException, Inject } from '@nestjs/common';
import { IdempotencyService } from '../../../core/idempotency/idempotency.service';
import { CharacterService } from '../../character/service/character.service';

@Injectable()
export class SyncService {
  constructor(
    @Inject(IdempotencyService) private idempotencyService: IdempotencyService,
    @Inject(CharacterService) private characterService: CharacterService,
  ) {}

  async executeTestCommand(userId: string, idempotencyKey?: string, amount = 100) {
    if (!idempotencyKey) {
      throw new BadRequestException({
        code: 'MISSING_IDEMPOTENCY_KEY',
        message: 'Idempotency-Key header is required for progression-affecting operations',
      });
    }

    const result = await this.idempotencyService.executeIdempotent(
      userId,
      idempotencyKey,
      'TEST_REWARD_COMMAND',
      async () => {
        const rewardResult = await this.characterService.awardXp(userId, {
          amount,
          sourceType: 'test_sync',
          sourceId: idempotencyKey,
          reason: 'Idempotent sync validation test',
        });

        return {
          status: 200,
          body: {
            success: true,
            xpAwarded: rewardResult.xpAwarded,
            newLevel: rewardResult.newLevel,
            newRank: rewardResult.newRank,
            totalXp: rewardResult.character.totalXp,
          },
        };
      },
    );

    return result.body;
  }
}
