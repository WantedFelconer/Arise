import { DungeonRepository } from '../repository/dungeons.repository';

export class DungeonService {
  constructor(private readonly repo: DungeonRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
