import { Module } from '@nestjs/common';
import { SettingsController } from './controller/settings.controller';
import { SettingsService } from './service/settings.service';
import { SettingsRepository } from './repository/settings.repository';

@Module({
  controllers: [SettingsController],
  providers: [SettingsService, SettingsRepository],
  exports: [SettingsService, SettingsRepository],
})
export class SettingsModule {}
