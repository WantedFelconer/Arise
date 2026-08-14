export interface GateRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaGateRepository implements GateRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
