export interface QuestRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaQuestRepository implements QuestRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
