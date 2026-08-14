import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { NoteRepository } from '../repository/note.repository';
import {
  CreateNoteDto,
  CreateNoteFolderDto,
  NoteFilterDto,
  NoteFolderResponse,
  NoteResponse,
  UpdateNoteDto,
} from '../dto/note.dto';

@Injectable()
export class NoteService {
  constructor(@Inject(NoteRepository) private noteRepository: NoteRepository) {}

  // Folder Operations
  async createFolder(userId: string, dto: CreateNoteFolderDto): Promise<NoteFolderResponse> {
    return this.noteRepository.createFolder(userId, dto);
  }

  async listFolders(userId: string): Promise<NoteFolderResponse[]> {
    return this.noteRepository.findFoldersByUser(userId);
  }

  async deleteFolder(userId: string, id: string): Promise<void> {
    const deleted = await this.noteRepository.deleteFolder(id, userId);
    if (!deleted) {
      throw new NotFoundException({
        code: 'FOLDER_NOT_FOUND',
        message: 'Folder not found or access denied',
      });
    }
  }

  // Note Operations
  async createNote(userId: string, dto: CreateNoteDto): Promise<NoteResponse> {
    return this.noteRepository.createNote(userId, dto);
  }

  async listNotes(userId: string, filter?: NoteFilterDto): Promise<NoteResponse[]> {
    return this.noteRepository.findByUser(userId, filter);
  }

  async getNote(userId: string, id: string): Promise<NoteResponse> {
    const note = await this.noteRepository.findById(id, userId);
    if (!note) {
      throw new NotFoundException({
        code: 'NOTE_NOT_FOUND',
        message: 'Note not found or access denied',
      });
    }
    return note;
  }

  async updateNote(userId: string, id: string, dto: UpdateNoteDto): Promise<NoteResponse> {
    const updated = await this.noteRepository.updateNote(id, userId, dto);
    if (!updated) {
      throw new NotFoundException({
        code: 'NOTE_NOT_FOUND',
        message: 'Note not found or access denied',
      });
    }
    return updated;
  }

  async deleteNote(userId: string, id: string): Promise<void> {
    const deleted = await this.noteRepository.deleteNote(id, userId);
    if (!deleted) {
      throw new NotFoundException({
        code: 'NOTE_NOT_FOUND',
        message: 'Note not found or access denied',
      });
    }
  }
}
