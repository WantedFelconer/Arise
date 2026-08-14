import { IntegrationRepository } from '../repository/integrations.repository';

export class IntegrationService {
  constructor(private readonly repo: IntegrationRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
