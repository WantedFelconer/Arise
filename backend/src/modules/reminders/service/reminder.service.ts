import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { ReminderRepository } from '../repository/reminder.repository';
import { NotificationService } from '../../notifications/service/notification.service';
import {
  CreateReminderDto,
  UpdateReminderDto,
  ReminderResponse,
  SnoozeReminderDto,
} from '../dto/reminder.dto';

const PRIORITY_WEIGHTS: Record<string, number> = {
  deadline: 100,
  urgent: 90,
  high: 70,
  medium: 50,
  low: 30,
  custom: 10,
};

@Injectable()
export class ReminderService {
  private readonly maxDispatchesPerHourPerUser = 5;
  private readonly userHourlyDispatchCount = new Map<string, { hourKey: string; count: number }>();

  constructor(
    @Inject(ReminderRepository) private reminderRepository: ReminderRepository,
    @Inject(NotificationService) private notificationService: NotificationService,
  ) {}

  async createReminder(userId: string, dto: CreateReminderDto): Promise<ReminderResponse> {
    const record = await this.reminderRepository.create(userId, dto);
    return record as ReminderResponse;
  }

  async listReminders(userId: string, activeOnly = false): Promise<ReminderResponse[]> {
    const list = await this.reminderRepository.findByUser(userId, activeOnly);
    return list as ReminderResponse[];
  }

  async getReminder(userId: string, id: string): Promise<ReminderResponse> {
    const found = await this.reminderRepository.findById(id, userId);
    if (!found) {
      throw new NotFoundException({
        code: 'REMINDER_NOT_FOUND',
        message: 'Reminder not found or access denied',
      });
    }
    return found as ReminderResponse;
  }

  async updateReminder(userId: string, id: string, dto: UpdateReminderDto): Promise<ReminderResponse> {
    const updated = await this.reminderRepository.update(id, userId, dto);
    if (!updated) {
      throw new NotFoundException({
        code: 'REMINDER_NOT_FOUND',
        message: 'Reminder not found or access denied',
      });
    }
    return updated as ReminderResponse;
  }

  async snoozeReminder(userId: string, id: string, dto: SnoozeReminderDto): Promise<ReminderResponse> {
    const snoozedUntil = new Date(Date.now() + dto.snoozeMinutes * 60 * 1000);
    const updated = await this.reminderRepository.snooze(id, userId, snoozedUntil);
    if (!updated) {
      throw new NotFoundException({
        code: 'REMINDER_NOT_FOUND',
        message: 'Reminder not found or access denied',
      });
    }
    return updated as ReminderResponse;
  }

  async deleteReminder(userId: string, id: string): Promise<void> {
    const deleted = await this.reminderRepository.delete(id, userId);
    if (!deleted) {
      throw new NotFoundException({
        code: 'REMINDER_NOT_FOUND',
        message: 'Reminder not found or access denied',
      });
    }
  }

  /**
   * Evaluates if a reminder is due to fire at a specific timestamp
   */
  isReminderDue(reminder: ReminderResponse, now = new Date()): boolean {
    if (!reminder.active) return false;

    // If snoozed, check if snooze window has expired
    if (reminder.snoozedUntil) {
      return now >= new Date(reminder.snoozedUntil);
    }

    const config = reminder.triggerConfig;

    // 1. One-off ISO timestamp
    if (config.timestamp) {
      const targetTime = new Date(config.timestamp).getTime();
      const currentTime = now.getTime();
      // Due if targetTime is within past 5 minutes and not already triggered recently
      if (currentTime >= targetTime && currentTime - targetTime <= 300000) {
        if (!reminder.lastTriggeredAt || new Date(reminder.lastTriggeredAt).getTime() < targetTime) {
          return true;
        }
      }
      return false;
    }

    // 2. Daily/Weekly time of day + days of week
    if (config.timeOfDay) {
      const parts = config.timeOfDay.split(':');
      const targetHour = parseInt(parts[0] || '0', 10);
      const targetMin = parseInt(parts[1] || '0', 10);

      const currentHour = now.getUTCHours();
      const currentMin = now.getUTCMinutes();
      const currentDay = now.getUTCDay();

      if (config.daysOfWeek && config.daysOfWeek.length > 0) {
        if (!config.daysOfWeek.includes(currentDay)) return false;
      }

      if (currentHour === targetHour && Math.abs(currentMin - targetMin) <= 1) {
        // Prevent double trigger in same hour
        if (reminder.lastTriggeredAt) {
          const last = new Date(reminder.lastTriggeredAt);
          if (last.getUTCFullYear() === now.getUTCFullYear() &&
              last.getUTCMonth() === now.getUTCMonth() &&
              last.getUTCDate() === now.getUTCDate() &&
              last.getUTCHours() === now.getUTCHours()) {
            return false;
          }
        }
        return true;
      }
    }

    // 3. Behavioral reminder (custom trigger)
    if (config.triggerPhrase && config.interventionMessage) {
      return true;
    }

    return false;
  }

  /**
   * FR-REM-004: Evaluates and dispatches all due active reminders, respecting throttle limits & priority.
   */
  async processDueReminders(now = new Date()): Promise<{ dispatchedCount: number; throttledCount: number }> {
    const activeReminders = (await this.reminderRepository.findAllActive()) as ReminderResponse[];
    const dueReminders = activeReminders.filter((r) => this.isReminderDue(r, now));

    // Sort by priority weight descending (deadline > urgent > high > medium > low > custom)
    dueReminders.sort((a, b) => {
      const weightA = PRIORITY_WEIGHTS[a.priority] || 10;
      const weightB = PRIORITY_WEIGHTS[b.priority] || 10;
      return weightB - weightA;
    });

    let dispatchedCount = 0;
    let throttledCount = 0;
    const currentHourKey = `${now.getUTCFullYear()}-${now.getUTCMonth()}-${now.getUTCDate()}-${now.getUTCHours()}`;

    for (const reminder of dueReminders) {
      const userState = this.userHourlyDispatchCount.get(reminder.userId) || { hourKey: currentHourKey, count: 0 };
      if (userState.hourKey !== currentHourKey) {
        userState.hourKey = currentHourKey;
        userState.count = 0;
      }

      // Check throttle limit
      if (userState.count >= this.maxDispatchesPerHourPerUser) {
        throttledCount++;
        continue;
      }

      // Dispatch notification
      await this.notificationService.sendNotification({
        userId: reminder.userId,
        title: `Reminder: ${reminder.type.toUpperCase()}`,
        message: reminder.message,
        type: reminder.type,
        data: { reminderId: reminder.id, priority: reminder.priority },
        sendPush: true,
      });

      await this.reminderRepository.recordTriggered(reminder.id);
      userState.count++;
      this.userHourlyDispatchCount.set(reminder.userId, userState);
      dispatchedCount++;
    }

    return { dispatchedCount, throttledCount };
  }
}
