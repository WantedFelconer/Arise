import { GateRepository } from '../repository/gates.repository';

export class GateService {
  constructor(private readonly repo: GateRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
