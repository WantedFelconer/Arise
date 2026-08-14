export interface NoteRepository {
  findById(id: string): Promise<unknown | null>;
}

export class PrismaNoteRepository implements NoteRepository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
