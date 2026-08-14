export interface AiRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaAiRepository implements AiRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
