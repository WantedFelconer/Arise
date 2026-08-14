import { CalendarRepository } from '../repository/calendar.repository';

export class CalendarService {
  constructor(private readonly repo: CalendarRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
