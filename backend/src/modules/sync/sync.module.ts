import { Module } from '@nestjs/common';
import { SyncController } from './controller/sync.controller';
import { SyncService } from './service/sync.service';
import { CharacterModule } from '../character/character.module';

@Module({
  imports: [CharacterModule],
  controllers: [SyncController],
  providers: [SyncService],
  exports: [SyncService],
})
export class SyncModule {}
