import { describe, it, expect } from 'vitest';
import { NoteService } from '../service/notes.service';
import { NoteRepository } from '../repository/notes.repository';

describe('Note Module (Scaffold)', () => {
  const mockRepo: NoteRepository = {
    findById: async () => ({ id: 'test-id' }),
  };

  it('instantiates service cleanly', async () => {
    const service = new NoteService(mockRepo);
    const result = await service.getById('test-id');
    expect(result).toEqual({ id: 'test-id' });
  });
});
