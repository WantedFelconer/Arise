import { QuestRepository } from '../repository/quests.repository';

export class QuestService {
  constructor(private readonly repo: QuestRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
