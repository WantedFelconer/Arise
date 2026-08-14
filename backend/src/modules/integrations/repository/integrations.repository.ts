export interface IntegrationRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaIntegrationRepository implements IntegrationRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
