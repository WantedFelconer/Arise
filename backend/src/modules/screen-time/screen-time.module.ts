import { Module } from '@nestjs/common';
import { ScreenTimeController } from './controller/screen-time.controller';
import { ScreenTimeService } from './service/screen-time.service';
import { ScreenTimeRepository } from './repository/screen-time.repository';
import { CharacterModule } from '../character/character.module';

@Module({
  imports: [CharacterModule],
  controllers: [ScreenTimeController],
  providers: [ScreenTimeService, ScreenTimeRepository],
  exports: [ScreenTimeService, ScreenTimeRepository],
})
export class ScreenTimeModule {}
