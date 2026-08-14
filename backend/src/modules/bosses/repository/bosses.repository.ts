export interface BossRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaBossRepository implements BossRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
