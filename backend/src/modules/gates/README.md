# Gates Module

## Purpose & Responsibilities
The **Gates Module** manages high-focus expedition sessions in ARISE. It enforces server-authoritative stability calculation to prevent anti-tamper client duration manipulation, applies casual vs. hardcore pause restrictions, routes completions and collapses through the centralized Reward Cascade, and tracks expedition statistics (FR-GATE-001..008).

## State Machine (§7.2)
- `active -> paused` (Casual mode only, max 1 pause)
- `paused -> active` (Resume)
- `active -> cleared` (Stability reaches 100%, awards XP/Mana/Boss damage)
- `active -> collapsed` (Early exit before 100%, applies penalties per difficulty mode)

## Anti-Tamper Security Contract (FR-GATE-008)
Elapsed duration and stability percentage are computed on-demand from server timestamps (`started_at`, `total_paused_duration_s`, and server `Date.now()`). Client-reported elapsed durations are ignored for progression calculation.

## Public Service API
- `startSession(userId: string, input: StartGateSessionInput): Promise<GateSessionResponse>`
- `getSession(userId: string, id: string): Promise<GateSessionResponse>`
- `pauseSession(userId: string, id: string, userDifficultyMode?: string): Promise<GateSessionResponse>`
- `resumeSession(userId: string, id: string): Promise<GateSessionResponse>`
- `completeSession(userId: string, id: string): Promise<GateSessionResponse>`
- `collapseSession(userId: string, id: string, userDifficultyMode?: string, input?: CollapseGateSessionInput): Promise<GateSessionResponse>`
- `getStats(userId: string): Promise<GateStatsResponse>`

## HTTP Endpoints
- `POST /api/v1/gates/sessions` — Start focus session
- `GET /api/v1/gates/sessions/:id` — Get focus session with current stability %
- `POST /api/v1/gates/sessions/:id/pause` — Pause active session (casual mode only)
- `POST /api/v1/gates/sessions/:id/resume` — Resume paused session
- `POST /api/v1/gates/sessions/:id/complete` (and `/api/v1/gates/:id/complete`) — Clear completed expedition
- `POST /api/v1/gates/sessions/:id/collapse` (and `/api/v1/gates/:id/collapse`) — Collapse active session
- `GET /api/v1/gates/stats` — Aggregate expedition statistics

## Dependencies
- `core/reward-cascade.ts` — Executes rewards on clear and penalties on collapse.
- `modules/quests` — Public `QuestService` for validating linked quests.
