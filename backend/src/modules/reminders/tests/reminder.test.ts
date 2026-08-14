import { describe, it, expect, beforeEach } from 'vitest';
import { ReminderRepository } from '../repository/reminder.repository';
import { ReminderService } from '../service/reminder.service';
import { NotificationService } from '../../notifications/service/notification.service';
import { NotificationRepository } from '../../notifications/repository/notification.repository';
import { FcmService } from '../../notifications/service/fcm.service';
import { ConfigService } from '@nestjs/config';
import { memoryDb } from '../../../db/memory/memory-db';

describe('ReminderService (FR-REM-001 through FR-REM-005)', () => {
  let reminderRepo: ReminderRepository;
  let notifRepo: NotificationRepository;
  let notifService: NotificationService;
  let service: ReminderService;
  const userId = 'reminder-test-user-1';

  beforeEach(() => {
    memoryDb.clear();
    const configService = new ConfigService();
    const fcmService = new FcmService(configService);
    notifRepo = new NotificationRepository();
    notifService = new NotificationService(notifRepo, fcmService);
    reminderRepo = new ReminderRepository();
    service = new ReminderService(reminderRepo, notifService);
  });

  it('creates, retrieves, and updates reminders with behavioral configurations', async () => {
    const reminder = await service.createReminder(userId, {
      type: 'behavioral',
      message: 'Pause before opening social media',
      triggerConfig: {
        triggerPhrase: 'open_distraction_app',
        interventionMessage: 'Take 3 deep breaths and remember your goal.',
        delayMinutes: 5,
      },
      priority: 'high',
    });

    expect(reminder.id).toBeDefined();
    expect(reminder.type).toBe('behavioral');

    const fetched = await service.getReminder(userId, reminder.id);
    expect(fetched.message).toBe('Pause before opening social media');

    const updated = await service.updateReminder(userId, reminder.id, {
      message: 'Pause and reflect for 2 minutes',
    });
    expect(updated.message).toBe('Pause and reflect for 2 minutes');
  });

  it('snoozes a reminder for a given duration (FR-REM-005)', async () => {
    const reminder = await service.createReminder(userId, {
      type: 'hydration',
      message: 'Drink 250ml water',
      triggerConfig: { timeOfDay: '10:00' },
    });

    const snoozed = await service.snoozeReminder(userId, reminder.id, { snoozeMinutes: 15 });
    expect(snoozed.snoozedUntil).toBeDefined();
    expect(new Date(snoozed.snoozedUntil!).getTime()).toBeGreaterThan(Date.now());
  });

  it('processes due reminders with priority ordering and enforces max hourly throttle (FR-REM-004)', async () => {
    // Create 7 reminders for the user (limit is 5 per hour)
    for (let i = 1; i <= 7; i++) {
      await service.createReminder(userId, {
        type: 'custom',
        message: `Task Reminder ${i}`,
        triggerConfig: {
          triggerPhrase: 'trigger_now',
          interventionMessage: 'Do work',
        },
        priority: i === 1 ? 'deadline' : 'low',
      });
    }

    const result = await service.processDueReminders(new Date());

    // Max 5 dispatched, 2 throttled
    expect(result.dispatchedCount).toBe(5);
    expect(result.throttledCount).toBe(2);

    // Verify in-app notifications inbox received the 5 notifications
    const userNotifs = await notifService.listNotifications(userId);
    expect(userNotifs.total).toBe(5);

    // Verify the deadline priority reminder was among the dispatched items
    const deadlineNotif = userNotifs.items.find((n) => n.message === 'Task Reminder 1');
    expect(deadlineNotif).toBeDefined();
    expect(deadlineNotif?.data?.priority).toBe('deadline');
  });
});
