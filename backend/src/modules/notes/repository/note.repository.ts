import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import {
  memoryDb,
  StoredNote,
  StoredNoteFolder,
} from '../../../db/memory/memory-db';
import {
  CreateNoteDto,
  CreateNoteFolderDto,
  NoteFilterDto,
  UpdateNoteDto,
} from '../dto/note.dto';

@Injectable()
export class NoteRepository {
  // Folder methods
  async createFolder(userId: string, dto: CreateNoteFolderDto): Promise<StoredNoteFolder> {
    const now = new Date();
    const folder: StoredNoteFolder = {
      id: uuidv4(),
      userId,
      name: dto.name,
      createdAt: now,
      updatedAt: now,
    };
    memoryDb.noteFolders.set(folder.id, folder);
    return folder;
  }

  async findFoldersByUser(userId: string): Promise<StoredNoteFolder[]> {
    return Array.from(memoryDb.noteFolders.values()).filter((f) => f.userId === userId);
  }

  async deleteFolder(id: string, userId: string): Promise<boolean> {
    const folder = memoryDb.noteFolders.get(id);
    if (!folder || folder.userId !== userId) return false;
    // Unlink notes from this folder
    for (const note of memoryDb.notes.values()) {
      if (note.folderId === id && note.userId === userId) {
        note.folderId = null;
      }
    }
    return memoryDb.noteFolders.delete(id);
  }

  // Note methods
  async createNote(userId: string, dto: CreateNoteDto): Promise<StoredNote> {
    const now = new Date();
    const note: StoredNote = {
      id: uuidv4(),
      userId,
      folderId: dto.folderId || null,
      questId: dto.questId || null,
      title: dto.title,
      body: dto.body || '',
      tags: dto.tags || [],
      notionPageId: null,
      syncStatus: 'synced',
      createdAt: now,
      updatedAt: now,
    };
    memoryDb.notes.set(note.id, note);
    return note;
  }

  async findById(id: string, userId: string): Promise<StoredNote | null> {
    const note = memoryDb.notes.get(id);
    if (!note || note.userId !== userId) return null;
    return note;
  }

  async findByUser(userId: string, filter?: NoteFilterDto): Promise<StoredNote[]> {
    let items = Array.from(memoryDb.notes.values()).filter((n) => n.userId === userId);

    if (filter?.folderId) {
      items = items.filter((n) => n.folderId === filter.folderId);
    }
    if (filter?.questId) {
      items = items.filter((n) => n.questId === filter.questId);
    }
    if (filter?.tag) {
      items = items.filter((n) => n.tags.includes(filter.tag!));
    }
    if (filter?.q) {
      const search = filter.q.toLowerCase();
      items = items.filter(
        (n) =>
          n.title.toLowerCase().includes(search) ||
          n.body.toLowerCase().includes(search) ||
          n.tags.some((t) => t.toLowerCase().includes(search)),
      );
    }

    items.sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    return items;
  }

  async updateNote(id: string, userId: string, dto: UpdateNoteDto): Promise<StoredNote | null> {
    const note = await this.findById(id, userId);
    if (!note) return null;

    if (dto.title !== undefined) note.title = dto.title;
    if (dto.body !== undefined) note.body = dto.body;
    if (dto.folderId !== undefined) note.folderId = dto.folderId;
    if (dto.questId !== undefined) note.questId = dto.questId;
    if (dto.tags !== undefined) note.tags = dto.tags;
    if (dto.syncStatus !== undefined) note.syncStatus = dto.syncStatus;
    note.updatedAt = new Date();

    memoryDb.notes.set(id, note);
    return note;
  }

  async deleteNote(id: string, userId: string): Promise<boolean> {
    const note = await this.findById(id, userId);
    if (!note) return false;
    return memoryDb.notes.delete(id);
  }

  async deleteByUserId(userId: string): Promise<number> {
    let count = 0;
    for (const [id, n] of memoryDb.notes.entries()) {
      if (n.userId === userId) {
        memoryDb.notes.delete(id);
        count++;
      }
    }
    for (const [id, f] of memoryDb.noteFolders.entries()) {
      if (f.userId === userId) {
        memoryDb.noteFolders.delete(id);
      }
    }
    return count;
  }
}
