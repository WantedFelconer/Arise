import { ReminderRepository } from '../repository/reminders.repository';

export class ReminderService {
  constructor(private readonly repo: ReminderRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
