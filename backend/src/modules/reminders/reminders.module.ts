import { Module } from '@nestjs/common';
import { ReminderController } from './controller/reminder.controller';
import { ReminderService } from './service/reminder.service';
import { ReminderRepository } from './repository/reminder.repository';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [ReminderController],
  providers: [ReminderService, ReminderRepository],
  exports: [ReminderService, ReminderRepository],
})
export class RemindersModule {}
