import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { memoryDb, StoredNotification } from '../../../db/memory/memory-db';
import { CreateNotificationDto, NotificationFilterDto } from '../dto/notification.dto';

@Injectable()
export class NotificationRepository {
  async create(dto: CreateNotificationDto): Promise<StoredNotification> {
    const notification: StoredNotification = {
      id: uuidv4(),
      userId: dto.userId,
      title: dto.title,
      message: dto.message,
      type: dto.type || 'general',
      read: false,
      data: dto.data || null,
      createdAt: new Date(),
    };

    memoryDb.notifications.push(notification);
    return notification;
  }

  async findById(id: string, userId: string): Promise<StoredNotification | null> {
    const found = memoryDb.notifications.find((n) => n.id === id && n.userId === userId);
    return found || null;
  }

  async findByUser(userId: string, filter?: NotificationFilterDto): Promise<{ items: StoredNotification[]; total: number }> {
    let items = memoryDb.notifications.filter((n) => n.userId === userId);

    if (filter?.unreadOnly) {
      items = items.filter((n) => !n.read);
    }
    if (filter?.type) {
      items = items.filter((n) => n.type === filter.type);
    }

    // Stable sort descending by creation date, preserving insertion order on ties
    const mapped = items.map((item, idx) => ({ item, idx }));
    mapped.sort((a, b) => {
      const timeDiff = b.item.createdAt.getTime() - a.item.createdAt.getTime();
      if (timeDiff !== 0) return timeDiff;
      return a.idx - b.idx;
    });
    items = mapped.map((m) => m.item);

    const total = items.length;
    const offset = filter?.offset || 0;
    const limit = filter?.limit || 50;
    const paged = items.slice(offset, offset + limit);

    return { items: paged, total };
  }

  async countUnread(userId: string): Promise<number> {
    return memoryDb.notifications.filter((n) => n.userId === userId && !n.read).length;
  }

  async markAsRead(id: string, userId: string): Promise<StoredNotification | null> {
    const notification = memoryDb.notifications.find((n) => n.id === id && n.userId === userId);
    if (!notification) return null;
    notification.read = true;
    return notification;
  }

  async markAllAsRead(userId: string): Promise<number> {
    let updatedCount = 0;
    for (const n of memoryDb.notifications) {
      if (n.userId === userId && !n.read) {
        n.read = true;
        updatedCount++;
      }
    }
    return updatedCount;
  }

  async delete(id: string, userId: string): Promise<boolean> {
    const initialLen = memoryDb.notifications.length;
    memoryDb.notifications = memoryDb.notifications.filter(
      (n) => !(n.id === id && n.userId === userId),
    );
    return memoryDb.notifications.length < initialLen;
  }

  async deleteByUserId(userId: string): Promise<number> {
    const initialLen = memoryDb.notifications.length;
    memoryDb.notifications = memoryDb.notifications.filter((n) => n.userId !== userId);
    return initialLen - memoryDb.notifications.length;
  }
}
