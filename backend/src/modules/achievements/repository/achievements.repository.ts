export interface AchievementRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaAchievementRepository implements AchievementRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
