import { AchievementRepository } from '../repository/achievements.repository';

export class AchievementService {
  constructor(private readonly repo: AchievementRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
