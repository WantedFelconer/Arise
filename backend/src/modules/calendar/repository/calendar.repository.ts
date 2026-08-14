export interface CalendarRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaCalendarRepository implements CalendarRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
