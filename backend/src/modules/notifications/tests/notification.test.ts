import { describe, it, expect, beforeEach } from 'vitest';
import { NotificationRepository } from '../repository/notification.repository';
import { NotificationService } from '../service/notification.service';
import { FcmService } from '../service/fcm.service';
import { ConfigService } from '@nestjs/config';
import { memoryDb } from '../../../db/memory/memory-db';

describe('NotificationService (FR-NOTIF-001 & FR-NOTIF-002)', () => {
  let repository: NotificationRepository;
  let service: NotificationService;
  let fcmService: FcmService;
  const userId = 'test-user-notif-1';

  beforeEach(() => {
    memoryDb.clear();
    const configService = new ConfigService();
    fcmService = new FcmService(configService);
    repository = new NotificationRepository();
    service = new NotificationService(repository, fcmService);
  });

  it('creates and retrieves notifications for a user', async () => {
    const created = await service.sendNotification({
      userId,
      title: 'Quest Deadline Approaching',
      message: 'Your OS Study Quest is due in 1 hour',
      type: 'deadline',
    });

    expect(created.id).toBeDefined();
    expect(created.read).toBe(false);

    const list = await service.listNotifications(userId);
    expect(list.total).toBe(1);
    expect(list.unreadCount).toBe(1);
    expect(list.items[0].title).toBe('Quest Deadline Approaching');
  });

  it('marks a single notification as read and computes unread count accurately', async () => {
    const n1 = await service.sendNotification({
      userId,
      title: 'Reminder 1',
      message: 'Drink water',
    });
    await service.sendNotification({
      userId,
      title: 'Reminder 2',
      message: 'Gate session starting',
    });

    let count = await service.getUnreadCount(userId);
    expect(count.unreadCount).toBe(2);

    await service.markAsRead(userId, n1.id);

    count = await service.getUnreadCount(userId);
    expect(count.unreadCount).toBe(1);

    const unreadList = await service.listNotifications(userId, { unreadOnly: true });
    expect(unreadList.items.length).toBe(1);
    expect(unreadList.items[0].title).toBe('Reminder 2');
  });

  it('marks all notifications as read in bulk', async () => {
    await service.sendNotification({ userId, title: 'N1', message: 'M1' });
    await service.sendNotification({ userId, title: 'N2', message: 'M2' });

    const result = await service.markAllAsRead(userId);
    expect(result.markedCount).toBe(2);

    const count = await service.getUnreadCount(userId);
    expect(count.unreadCount).toBe(0);
  });

  it('enforces multi-tenant isolation', async () => {
    const user2 = 'other-user';
    const n1 = await service.sendNotification({ userId, title: 'User1 Notif', message: 'Secret' });

    const user2List = await service.listNotifications(user2);
    expect(user2List.total).toBe(0);

    await expect(service.markAsRead(user2, n1.id)).rejects.toThrow();
  });
});
