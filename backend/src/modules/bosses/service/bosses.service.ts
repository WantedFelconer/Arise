import { BossRepository } from '../repository/bosses.repository';

export class BossService {
  constructor(private readonly repo: BossRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
