export interface DungeonRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaDungeonRepository implements DungeonRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
