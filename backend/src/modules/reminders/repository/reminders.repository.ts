export interface ReminderRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaReminderRepository implements ReminderRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
