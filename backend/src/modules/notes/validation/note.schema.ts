import { z } from 'zod';

export const createNoteFolderSchema = z.object({
  name: z.string().min(1, 'Folder name is required').max(100),
});

export const createNoteSchema = z.object({
  title: z.string().min(1, 'Title is required').max(255),
  body: z.string().default(''),
  folderId: z.string().uuid().nullable().optional(),
  questId: z.string().uuid().nullable().optional(),
  tags: z.array(z.string()).optional().default([]),
});

export const updateNoteSchema = createNoteSchema.partial().extend({
  syncStatus: z.string().optional(),
});

export const noteFilterSchema = z.object({
  folderId: z.string().uuid().optional(),
  tag: z.string().optional(),
  questId: z.string().uuid().optional(),
  q: z.string().optional(),
});
