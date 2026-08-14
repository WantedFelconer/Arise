# Dungeons Module

## Purpose & Responsibilities
The **Dungeons Module** aggregates multiple related Bosses (e.g. an entire academic semester or a major multi-boss initiative). It dynamically calculates completion progress and automatically marks the dungeon completed when all contained bosses are defeated (FR-DUNG-001..003).

## Public Service API
- `getDungeon(userId: string, id: string): Promise<DungeonResponse>`
- `listDungeons(userId: string): Promise<DungeonResponse[]>`
- `createDungeon(userId: string, input: CreateDungeonInput): Promise<DungeonResponse>`
- `updateDungeon(userId: string, id: string, input: UpdateDungeonInput): Promise<DungeonResponse>`
- `deleteDungeon(userId: string, id: string): Promise<{ success: boolean }>`

## Database Tables Owned
- `dungeons`: Container table with `title`, `status` (`active` | `completed`).

## HTTP Endpoints
- `GET /api/v1/dungeons` — List dungeons with progress %
- `GET /api/v1/dungeons/:id` — Get dungeon detail and contained bosses
- `POST /api/v1/dungeons` — Create dungeon
- `PATCH /api/v1/dungeons/:id` — Update dungeon
- `DELETE /api/v1/dungeons/:id` — Delete dungeon and unlink contained bosses

## Dependencies
- `modules/bosses` — Public `BossService` for retrieving and unlinking contained bosses.
