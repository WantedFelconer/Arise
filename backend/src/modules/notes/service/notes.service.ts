import { NoteRepository } from '../repository/notes.repository';

export class NoteService {
  constructor(private readonly repo: NoteRepository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
