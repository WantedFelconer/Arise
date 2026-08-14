import { Module, forwardRef } from '@nestjs/common';
import { AiProvidersModule } from './providers/ai-providers.module';
import { AiQuotaService } from './quota/ai-quota.service';
import { AiPlannerService } from './planner/service/ai-planner.service';
import { AiPlannerController } from './planner/controller/ai-planner.controller';
import { AiCoachService } from './coach/service/ai-coach.service';
import { AiCoachController } from './coach/controller/ai-coach.controller';
import { AiQuotaController } from './quota/ai-quota.controller';
import { QuestsModule } from '../quests/quests.module';
import { BossesModule } from '../bosses/bosses.module';
import { CharacterModule } from '../character/character.module';

@Module({
  imports: [
    AiProvidersModule,
    forwardRef(() => QuestsModule),
    forwardRef(() => BossesModule),
    forwardRef(() => CharacterModule),
  ],
  controllers: [AiPlannerController, AiCoachController, AiQuotaController],
  providers: [AiQuotaService, AiPlannerService, AiCoachService],
  exports: [AiQuotaService, AiPlannerService, AiCoachService],
})
export class AiModule {}
