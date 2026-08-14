import { Injectable, Logger } from '@nestjs/common';
import { ReminderService } from '../modules/reminders/service/reminder.service';

@Injectable()
export class ReminderDispatchJob {
  private readonly logger = new Logger(ReminderDispatchJob.name);

  constructor(private reminderService: ReminderService) {}

  /**
   * BullMQ worker processor for reminder dispatch (§15.2)
   */
  async execute(): Promise<{ dispatched: number; throttled: number }> {
    this.logger.debug('Running scheduled reminder dispatch cycle...');
    const result = await this.reminderService.processDueReminders(new Date());
    this.logger.log(
      `Reminder dispatch finished: ${result.dispatchedCount} dispatched, ${result.throttledCount} throttled`,
    );
    return {
      dispatched: result.dispatchedCount,
      throttled: result.throttledCount,
    };
  }
}
