import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { NotificationController } from './controller/notification.controller';
import { NotificationService } from './service/notification.service';
import { NotificationRepository } from './repository/notification.repository';
import { FcmService } from './service/fcm.service';

@Module({
  imports: [ConfigModule],
  controllers: [NotificationController],
  providers: [NotificationService, NotificationRepository, FcmService],
  exports: [NotificationService, NotificationRepository, FcmService],
})
export class NotificationsModule {}
