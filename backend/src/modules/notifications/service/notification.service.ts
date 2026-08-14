import { Injectable, NotFoundException, Inject, Optional } from '@nestjs/common';
import { NotificationRepository } from '../repository/notification.repository';
import { FcmService } from './fcm.service';
import {
  CreateNotificationDto,
  NotificationFilterDto,
  NotificationResponse,
} from '../dto/notification.dto';

@Injectable()
export class NotificationService {
  constructor(
    @Inject(NotificationRepository) private notificationRepository: NotificationRepository,
    @Optional() @Inject(FcmService) private fcmService?: FcmService,
  ) {}

  /**
   * FR-NOTIF-001 & FR-NOTIF-002: Ingests notification into inbox and optionally sends push
   */
  async sendNotification(dto: CreateNotificationDto): Promise<NotificationResponse> {
    const record = await this.notificationRepository.create(dto);

    if (dto.sendPush) {
      await this.fcmService?.sendPush({
        userId: dto.userId,
        title: dto.title,
        body: dto.message,
        data: dto.data ? Object.fromEntries(Object.entries(dto.data).map(([k, v]) => [k, String(v)])) : undefined,
      });
    }

    return record;
  }

  async listNotifications(
    userId: string,
    filter?: NotificationFilterDto,
  ): Promise<{ items: NotificationResponse[]; total: number; unreadCount: number }> {
    const { items, total } = await this.notificationRepository.findByUser(userId, filter);
    const unreadCount = await this.notificationRepository.countUnread(userId);

    return {
      items,
      total,
      unreadCount,
    };
  }

  async getUnreadCount(userId: string): Promise<{ unreadCount: number }> {
    const count = await this.notificationRepository.countUnread(userId);
    return { unreadCount: count };
  }

  async markAsRead(userId: string, id: string): Promise<NotificationResponse> {
    const updated = await this.notificationRepository.markAsRead(id, userId);
    if (!updated) {
      throw new NotFoundException({
        code: 'NOTIFICATION_NOT_FOUND',
        message: 'Notification not found or access denied',
      });
    }
    return updated;
  }

  async markAllAsRead(userId: string): Promise<{ markedCount: number }> {
    const markedCount = await this.notificationRepository.markAllAsRead(userId);
    return { markedCount };
  }

  async deleteNotification(userId: string, id: string): Promise<void> {
    const deleted = await this.notificationRepository.delete(id, userId);
    if (!deleted) {
      throw new NotFoundException({
        code: 'NOTIFICATION_NOT_FOUND',
        message: 'Notification not found or access denied',
      });
    }
  }

  async deleteUserNotifications(userId: string): Promise<number> {
    return this.notificationRepository.deleteByUserId(userId);
  }
}
