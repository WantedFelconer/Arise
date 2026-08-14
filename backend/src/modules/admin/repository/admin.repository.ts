export interface AdminRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaAdminRepository implements AdminRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
