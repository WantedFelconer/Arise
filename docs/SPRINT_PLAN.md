# ARISE — Progressive Build Sprint Plan (6-Session Series)

**Companion document to:** `ARISE_SRS.md` (v1.0) & `.agents/rules/arise_flutter.md`  
**Purpose:** Structure the complete backend build into a 6-session progressive architecture (1 Bootstrap + 5 Sprints) so coding agents operate within clean, context-bounded scopes without context exhaustion or dropped requirements.

---

## Session Structure & Context Strategy

| Session | Focus Area | Core Modules / Assets | Primary Reference Anchors |
|---|---|---|---|
| **0 — Bootstrap** | Repo scaffolding, Doc reconciliation, Dev infra | Scaffolding, `docker-compose.yml`, `.env.example`, ADR 0001 | §17.2, §15.4, ADR 0001, Rule 6 |
| **1 — Secure Foundation** | Auth, Character/RPG Engine, DB Schema, Security, Sync Base | `auth`, `core/rpg-engine.ts`, Prisma schema (full), sync foundation, security middleware | §6.1, §6.2, §6.7, §6.8, §6.9, §13, NFR-003..006, NFR-008, NFR-012, AC-AUTH-004 |
| **2 — Core Productivity Loop** | Quests, Bosses, Dungeons, Gates, Reward Cascade, Achievement hooks | `quests` (MVP only), `bosses`, `dungeons`, `gates`, `core/reward-cascade.ts`, `achievements` (hook) | §6.3 (MVP), §6.4, §6.5, §6.6, §6.19, §7.1–7.3, §8.3–8.4, §17.3 rule 5, AC-QST-011, AC-GATE-005 |
| **3 — Intelligence Layer** | AI Provider Abstraction, AI Planner, AI Coach | `ai/providers/`, `ai/planner`, `ai/coach`, AI daily quota budget | §6.12, §6.13, §10 (all), §7.4, §8.2, §10.5, AC-AIP-003, AC-AIP-005 |
| **4 — Supporting Systems** | Screen Time, Reminders, Notifications, Stats, Settings, Fitness, Notes, Analytics | `screen-time`, `reminders`, `notifications`, `achievements` (finalize), `statistics`, `settings`, `fitness`, `notes`, `analytics`, `admin` | §6.10, §6.11, §6.14 (partial), §6.15 (partial), §6.17, §6.19, §6.20, §6.21, §6.23, §6.24, §6.27, NFR-008..011, §14 |
| **5 — Hardening & Regression** | Anti-Cheat Audit, Sync/Offline Audit, Full AC Regression | No new modules; comprehensive audits across Sprints 1–4 | Full §6 MVP regression, §12, §13, §16, §18 (confirm untouched), §19 (all), `HANDOFF_FINAL.md` |

---

## Authoritative Scope & Triage Reconciliation

1. **Section ID Mapping:** Requirement IDs (e.g. `FR-AUTH-001`, `FR-CHAR-001`, `NFR-008`, `AC-AUTH-004`) serve as the primary source of truth across all sprints.
2. **P2 / Backlog Deferred Items (Explicitly NOT in MVP Sprints 1–4):**
   - **Habits** (distinct from Quests, with streaks/skip allowance): Deferred to **Phase 2 Future Roadmap (§18)**.
   - **Quest Dependencies** (`FR-QST-006`): P2 Backlog.
   - **Quick Capture / Inbox AI Triage** (`FR-QST-016`, `FR-NOTE-003`): P2 Backlog.
   - **Quest Templates, Duplication, Bulk Operations** (`FR-QST-009`, `FR-QST-010`, `FR-QST-014`): P2 Backlog.
   - **Natural Language Quest Input** (`FR-QST-015`): P2 Backlog.
   - **Eisenhower Matrix Tagging** (`FR-QST-017`): P2 Backlog.
   - **Smart Recurrence** (`FR-QST-005`, RRULE-based): MVP scope handled directly inside the `quests` module (no standalone recurrence engine module).
3. **Core Loop Sequencing:**
   - **Gate Focus Sessions** belong to **Sprint 2 (Core Productivity Loop)**, wired directly into `core/reward-cascade.ts` alongside Quests, Bosses, and Dungeons.
   - **Screen Time & Reminders** belong to **Sprint 4 (Supporting Systems)**.
4. **Payment & Subscriptions:**
   - There is **NO real-money payment or subscription processing** in scope (§2.5). Premium currency ("Gems") is ledger-only. AI call limits are governed by daily per-user quotas (§10.5).
5. **Offline-First & Security Posture:**
   - Extended via Rule 6 (Offline-First Authority Contract): Client synchronizes domain operations/commands with unique `Idempotency-Key` headers. Backend is strictly authoritative for XP, Level, Mana, Energy, Boss HP, streaks, and AI quotas.

---

## Sprint Execution & Tracking Status

| Sprint | Status | Handoff Digest | Test Coverage |
|---|---|---|---|
| **0 — Bootstrap** | `COMPLETE` | `docs/adr/0001-scope-and-doc-reconciliation.md` | Infrastructure & Linters passing |
| **1 — Secure Foundation** | `COMPLETE` | `docs/sprint-tracking/sprint-1-handoff.md` | 42/42 tests passing (100%), 0 lint errors |
| **2 — Core Productivity Loop** | `READY_TO_START` | `docs/sprint-tracking/sprint-2-handoff.md` | Pending Sprint 2 |
| **3 — Intelligence Layer** | `PLANNED` | — | Pending Sprint 3 |
| **4 — Supporting Systems** | `PLANNED` | — | Pending Sprint 4 |
| **5 — Hardening & Regression** | `PLANNED` | `docs/sprint-tracking/HANDOFF_FINAL.md` | Pending Sprint 5 |

---

## Detailed Sprint Specifications

### Session 0 — Bootstrap (One-Time Setup)
- **Goal:** Reconcile documentation, build the complete repository scaffold, configure dev environment (PostgreSQL 16, Redis 7, Prisma, TypeScript, ESLint, Prettier, Vitest), inspect Flutter frontend, and write ADR 0001.
- **Deliverables:**
  - Patched `SPRINT_PLAN.md`, `.agents/rules/arise_flutter.md`.
  - Review `.agents/skills/`.
  - `docs/adr/0001-scope-and-doc-reconciliation.md`.
  - Backend scaffold per §17.2 with clean compilation and linting (no business logic).
  - `docker-compose.yml`, `.env.example`.
  - Frontend inspection notes documented in ADR 0001.

---

### Sprint 1 — Secure Foundation
- **Goal:** Full DB schema migrated, auth system complete, RPG Engine implemented, security middleware and sync foundation in place.
- **SRS Scope:** §5 Data Model (DDL), §6.1 (Auth: FR-AUTH-001..010), §6.2 (Char: FR-CHAR-001..005), §6.7 (XP: FR-XP-001..003), §6.8 (Mana: FR-MANA-001..004), §6.9 (Energy: FR-ENERGY-001..003), §13 (Security), §15.4 (Env), §17.3 Rule 1, §19 AC-AUTH-004.
- **Modules Built:** `auth`, `character`, `core/rpg-engine.ts`, `core/middleware/`, `db/prisma/schema.prisma`, sync idempotency handler.
- **Key Deliverables:**
  - User registration, login, logout, password reset, token refresh with reuse detection (revoking all sessions per AC-AUTH-004).
  - `core/rpg-engine.ts` with pure math and ledger-first writes (`xp_transactions`, `mana_transactions`).
  - Generalized idempotency key middleware for replay-safe writes.
  - Query-level ownership isolation (`user_id = req.auth.userId`).
- **Handoff Artifact:** `docs/sprint-tracking/sprint-1-handoff.md`.

---

### Sprint 2 — Core Productivity Loop
- **Goal:** Quest lifecycle, Boss projects, Dungeons, Gate focus sessions, and the atomic reward cascade transaction operational.
- **SRS Scope:** §6.3 (Quests MVP: FR-QST-001..005, 007, 008, 011..013), §6.4 (Boss: FR-BOSS-001..004), §6.5 (Dungeon: FR-DUNG-001..003), §6.6 (Gate: FR-GATE-001..006), §6.19 (Achievements hook), §7.1–7.3, §8.3–8.4, §17.3 Rule 5, §19 AC-QST-011, AC-GATE-005.
- **Modules Built:** `quests`, `bosses`, `dungeons`, `gates`, `core/reward-cascade.ts`, `achievements` (trigger integration).
- **Key Deliverables:**
  - Quest CRUD, RRULE recurrence, nesting, completion.
  - Boss damage/defeat calculations tied to Quest completions.
  - Gate start, pause, exit, completion, and collapse mechanics.
  - `core/reward-cascade.ts` executing atomic, idempotent XP, Mana, Boss damage, and achievement evaluation.
- **Handoff Artifact:** `docs/sprint-tracking/sprint-2-handoff.md`.

---

### Sprint 3 — Intelligence Layer
- **Goal:** Provider-abstracted AI integrations for plan generation and coaching, with guardrails and daily quotas.
- **SRS Scope:** §6.12 (AI Planner: FR-AIP-001..006), §6.13 (AI Coach: FR-COACH-001..007), §10 AI Architecture (10.1–10.5), §7.4, §8.2, §10.5 Quotas, §19 AC-AIP-003, AC-AIP-005.
- **Modules Built:** `ai/providers/` (`gemini`, `openai`, `claude`), `ai/planner`, `ai/coach`.
- **Key Deliverables:**
  - `AIProvider` interface and concrete implementations.
  - AI plan generation workflow: asynchronous job execution, draft persistence, explicit user approval requirement (C-10).
  - AI Coach: daily plan suggestions, weekly review reflections, overload/procrastination nudges.
  - Per-user daily AI call budget enforcement.
- **Handoff Artifact:** `docs/sprint-tracking/sprint-3-handoff.md`.

---

### Sprint 4 — Supporting Systems
- **Goal:** Screen time monitoring, reminders, notifications, achievements, stats, fitness, notes, analytics, and admin/settings.
- **SRS Scope:** §6.10 (Screen Time), §6.11 (Reminders), §6.14 (Analytics MVP), §6.15 (Notes baseline), §6.17 (Fitness), §6.19 (Achievements & Inventory), §6.20 (Statistics), §6.21 (Notifications), §6.23 (Settings), §6.24 (Difficulty Modes), §6.27 (Admin config), NFR-008..011, §14.
- **Modules Built:** `screen-time`, `reminders`, `notifications`, `achievements`, `statistics`, `settings`, `fitness`, `notes`, `analytics`, `admin`.
- **Key Deliverables:**
  - Screen time logging and server-side Mana modifier calculation.
  - Reminder and push notification dispatch abstractions.
  - Achievement unlocking engine and statistics aggregation.
  - Notes baseline CRUD and Notion sync provider stub.
  - Data export (JSON) and account deletion soft-delete/30-day purge worker.
- **Handoff Artifact:** `docs/sprint-tracking/sprint-4-handoff.md`.

---

### Sprint 5 — Hardening & Regression
- **Goal:** End-to-end quality assurance, anti-cheat validation, offline sync audit, full Acceptance Criteria regression, and final project handoff.
- **Scope:** Full §6 MVP regression, §12 (Use Cases), §13 (Security), §16 (Testing), §18 (Backlog verification), §19 (Acceptance Criteria).
- **Key Deliverables:**
  - Anti-cheat audit verifying no route accepts client-computed progression values.
  - Offline sync replay verification with network interruption simulation.
  - Comprehensive integration test suite pass on a real PostgreSQL instance.
  - Final project handoff digest: `docs/sprint-tracking/HANDOFF_FINAL.md`.
