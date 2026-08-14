export interface NoteFolderResponse {
  id: string;
  userId: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateNoteFolderDto {
  name: string;
}

export interface CreateNoteDto {
  title: string;
  body?: string;
  folderId?: string | null;
  questId?: string | null;
  tags?: string[];
}

export interface UpdateNoteDto {
  title?: string;
  body?: string;
  folderId?: string | null;
  questId?: string | null;
  tags?: string[];
  syncStatus?: string;
}

export interface NoteFilterDto {
  folderId?: string;
  tag?: string;
  questId?: string;
  q?: string; // Full-text search query
}

export interface NoteResponse {
  id: string;
  userId: string;
  folderId: string | null;
  questId: string | null;
  title: string;
  body: string;
  tags: string[];
  notionPageId: string | null;
  syncStatus: string;
  createdAt: Date;
  updatedAt: Date;
}
