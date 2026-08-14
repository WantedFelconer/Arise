import { describe, it, expect, beforeEach } from 'vitest';
import { NoteRepository } from '../repository/note.repository';
import { NoteService } from '../service/note.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('NoteService (FR-NOTE-001)', () => {
  let repository: NoteRepository;
  let service: NoteService;
  const userId = 'note-test-user-1';

  beforeEach(() => {
    memoryDb.clear();
    repository = new NoteRepository();
    service = new NoteService(repository);
  });

  it('creates folders and notes linked to folders', async () => {
    const folder = await service.createFolder(userId, { name: 'Operating Systems' });
    expect(folder.id).toBeDefined();

    const note = await service.createNote(userId, {
      title: 'Process Scheduling Algorithms',
      body: 'Round Robin, Priority Scheduling, CFS notes...',
      folderId: folder.id,
      tags: ['os', 'cs301'],
    });

    expect(note.id).toBeDefined();
    expect(note.folderId).toBe(folder.id);

    const folderNotes = await service.listNotes(userId, { folderId: folder.id });
    expect(folderNotes.length).toBe(1);
    expect(folderNotes[0].title).toBe('Process Scheduling Algorithms');
  });

  it('searches notes by query string and tags', async () => {
    await service.createNote(userId, {
      title: 'Database Indexing B-Trees',
      body: 'Postgres uses B-Tree indexes by default.',
      tags: ['db', 'sql'],
    });

    await service.createNote(userId, {
      title: 'NestJS Architecture Patterns',
      body: 'Clean architecture with modular monolith pattern.',
      tags: ['backend', 'nestjs'],
    });

    const searchResult = await service.listNotes(userId, { q: 'B-Tree' });
    expect(searchResult.length).toBe(1);
    expect(searchResult[0].title).toBe('Database Indexing B-Trees');

    const tagResult = await service.listNotes(userId, { tag: 'nestjs' });
    expect(tagResult.length).toBe(1);
    expect(tagResult[0].title).toBe('NestJS Architecture Patterns');
  });

  it('unlinks notes when parent folder is deleted', async () => {
    const folder = await service.createFolder(userId, { name: 'Temporary Folder' });
    const note = await service.createNote(userId, {
      title: 'Draft Note',
      folderId: folder.id,
    });

    await service.deleteFolder(userId, folder.id);

    const updatedNote = await service.getNote(userId, note.id);
    expect(updatedNote.folderId).toBeNull();
  });
});
