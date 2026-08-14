import { NotificationRepository } from '../repository/notifications.repository';

export class NotificationService {
  constructor(private readonly repo: NotificationRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
