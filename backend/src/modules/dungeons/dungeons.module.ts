import { Module } from '@nestjs/common';
import { DungeonController } from './controller/dungeon.controller';
import { DungeonService } from './service/dungeon.service';
import { DungeonRepository } from './repository/dungeon.repository';
import { BossesModule } from '../bosses/bosses.module';

@Module({
  imports: [BossesModule],
  controllers: [DungeonController],
  providers: [DungeonService, DungeonRepository],
  exports: [DungeonService, DungeonRepository],
})
export class DungeonsModule {}
