# Notes Module (`modules/notes`)

## Purpose
Manages user notes, folder hierarchy, tagging, quest linkages, and full-text search per §6.15 (FR-NOTE-001).

## Features
- **Folders**: Organizational hierarchy for notes.
- **Full-Text Search**: Case-insensitive search across titles, bodies, and tags.
- **Quest Linkage**: Optional association between a note and a parent quest.

## Endpoints
- `GET /api/v1/notes`: List/search notes.
- `POST /api/v1/notes`: Create note.
- `GET /api/v1/notes/:id`: Get note.
- `PATCH /api/v1/notes/:id`: Update note.
- `DELETE /api/v1/notes/:id`: Delete note.
- `GET /api/v1/notes/folders`: List folders.
- `POST /api/v1/notes/folders`: Create folder.
- `DELETE /api/v1/notes/folders/:id`: Delete folder.
