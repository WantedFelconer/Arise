export interface NotificationRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaNotificationRepository implements NotificationRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
