# Quests Module (MVP Subset)

## Purpose & Responsibilities
The **Quests Module** manages task and objective lifecycles in the ARISE platform. It implements the formal §7.1 state machine, unlimited nesting of subquests with parent auto-completion, RRULE recurrence spawning, full-text search and filtering, hardcore deadline penalties, and a 10-second reversible undo window.

## Scope Boundary & Deferred Backlog
- **In MVP Scope (Sprint 2)**: FR-QST-001 (types), FR-QST-002 (nesting), FR-QST-003 (parent auto-complete), FR-QST-004 (fields), FR-QST-005 (smart recurrence), FR-QST-007 (archive/restore), FR-QST-008 (search/filter/sort), FR-QST-011 (completion rewards via cascade), FR-QST-012 (boss damage), FR-QST-013 (hardcore deadline penalty), FR-QST-018 (undo window).
- **Deferred to P2 (Explicit Backlog)**: FR-QST-006 (dependencies), FR-QST-009 (duplication), FR-QST-010 (templates), FR-QST-014 (bulk operations), FR-QST-015 (natural language parsing), FR-QST-016 (inbox), FR-QST-017 (Eisenhower matrix tagging).

## State Machine (§7.1)
- `pending -> in_progress` (Start)
- `in_progress -> completed` or `pending -> completed` (Complete, triggers Reward Cascade)
- `in_progress -> pending` (Pause / Focus Collapse)
- `pending -> failed` (Hardcore Deadline Miss)
- `{completed, pending, failed} -> archived` (Archive)
- `archived -> pending` or `trashed -> pending` (Restore)
- `* -> trashed` (Soft Delete)
- `trashed/completed -> pending` (Undo within 10s window)

## Public Service API
- `getQuest(userId: string, id: string): Promise<QuestResponse>`
- `listQuests(userId: string, filters?: QuestListQueryInput): Promise<QuestResponse[]>`
- `createQuest(userId: string, input: CreateQuestInput): Promise<QuestResponse>`
- `updateQuest(userId: string, id: string, input: UpdateQuestInput): Promise<QuestResponse>`
- `startQuest(userId: string, id: string): Promise<QuestResponse>`
- `pauseQuest(userId: string, id: string): Promise<QuestResponse>`
- `completeQuest(userId: string, id: string, options?: { focusQualityMultiplier?: number }): Promise<QuestRewardCascadeResult>`
- `archiveQuest(userId: string, id: string): Promise<QuestResponse>`
- `restoreQuest(userId: string, id: string): Promise<QuestResponse>`
- `failQuest(userId: string, id: string, userDifficultyMode?: string): Promise<QuestResponse>`
- `deleteQuest(userId: string, id: string): Promise<{ success: boolean }>`
- `undo(userId: string, id: string): Promise<QuestResponse>`

## HTTP Endpoints
- `GET /api/v1/quests` — Filter, search, and list quests
- `POST /api/v1/quests` — Create a new quest
- `GET /api/v1/quests/:id` — Get quest detail with subquests
- `PATCH /api/v1/quests/:id` — Update quest fields
- `POST /api/v1/quests/:id/start` — Start quest (`pending -> in_progress`)
- `POST /api/v1/quests/:id/pause` — Pause quest (`in_progress -> pending`)
- `POST /api/v1/quests/:id/complete` — Complete quest and execute Reward Cascade
- `POST /api/v1/quests/:id/archive` — Archive quest
- `POST /api/v1/quests/:id/restore` — Restore quest from archive or trash
- `POST /api/v1/quests/:id/undo` — Undo complete or delete action within 10 seconds
- `POST /api/v1/quests/:id/fail` — Mark quest failed on missed deadline
- `DELETE /api/v1/quests/:id` — Soft-delete quest to trash

## Dependencies
- `core/reward-cascade.ts` — Authoritative atomic reward cascade execution.
- `modules/bosses` — Public `BossService` for boss validation and damage.
- `modules/character` — Public `CharacterService` for XP/Mana operations.
