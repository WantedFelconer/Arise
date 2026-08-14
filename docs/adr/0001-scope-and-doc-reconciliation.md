# ADR 0001: Scope, Architecture Documentation, and Offline Authority Reconciliation

## Status
**Accepted** (One-Time Bootstrap Baseline) — 2026-08-14

## Context
ARISE is an offline-first, gamified, AI-assisted personal productivity platform ("Life Operating System") designed to run on a Node.js/Express/TypeScript/PostgreSQL backend integrated with an existing Flutter frontend (Solo Leveling–inspired "System" UI).

During the initial project onboarding and bootstrap review, several discrepancies and drifts were identified between earlier prompt drafts/planning documents and the authoritative repository specification (`ARISE_SRS.md` v1.0, dated 2026-08-09):

1. **Document Structure & Section Numbering:** Earlier planning documents referenced non-existent section numbers (e.g. §3.6 Module Inventory, §3.7 Engines, §7 Event Catalog, §14 Acceptance Criteria). The authoritative specification in the repository is structured into distinct chapters, with functional requirements indexed by requirement IDs (`FR-<MODULE>-<NNN>`), non-functional requirements by `NFR-<NNN>`, and acceptance criteria by `AC-<MODULE>-<NNN>`.
2. **MVP Scope Boundaries:** Early drafts included Habits, Inbox Quick Capture, Quest Dependencies, Natural Language Quest Input, and Kanban/Bulk Operations in the initial MVP sprints. In the authoritative SRS, Habits are explicitly classified under **Phase 2 Future Roadmap (§18)**, and Quest Dependencies (`FR-QST-006`), Inbox Quick Capture (`FR-NOTE-003`), Templates, Duplication, and NLP input are classified as **P2**.
3. **Core Loop Sequencing:** The core reward cascade (`core/reward-cascade.ts`) is the critical business transaction uniting Quests, Boss damage, and Gate focus expeditions. Gate sessions were previously misplaced into later AI-focused sprints rather than the core productivity loop, while Screen Time and Reminders belong in supporting systems.
4. **Commercial Scope:** The product specification contains no payment gateway, subscription management, or real-money monetization. Premium currency ("Gems") is strictly an in-game ledger entry (§2.5). The only quota mechanism specified is a per-user daily AI call budget (§10.5).
5. **Offline-First Authority Contract:** SRS requirement NFR-008 mandates offline queueing and idempotent replay for quest actions via an `Idempotency-Key` header. However, product-owner directives require this offline-first, server-authoritative model to apply universally across all progression-bearing interactions.
6. **Frontend State & Architecture:** Inspection of the existing Flutter codebase revealed an in-memory repository implementation (`InMemoryQuestRepository`, `InMemoryPlayerRepository`) without local database persistence (no SQLite/Drift/Isar package in `pubspec.yaml`), and a centralized repository/provider structure rather than a feature-first Clean Architecture (`presentation/application/domain/infrastructure`).

---

## Decision

### 1. Canonical Requirement Identification
All architectural specifications, sprint plans, and agent tickets SHALL cite requirement IDs (`FR-AUTH-001`, `FR-CHAR-001`, `NFR-008`, `AC-AUTH-004`, etc.) as the primary source of truth, rather than fragile section numbers.

### 2. Strict MVP Boundary Enforcement
Sprints 1 through 4 SHALL strictly implement MVP-scoped functional requirements. Non-MVP features are classified and tracked as follows:
- **Phase 2 Roadmap (Deferred):** Habits module (streaks, skip allowance, routine builder).
- **P2 Backlog (Deferred):** Quest Dependencies (`FR-QST-006`), Inbox Quick Capture & AI Triage (`FR-QST-016`, `FR-NOTE-003`), Quest Templates (`FR-QST-010`), Duplication (`FR-QST-009`), Bulk Operations (`FR-QST-014`), Natural Language Quest Input (`FR-QST-015`), Eisenhower Matrix Tagging (`FR-QST-017`).
- **Recurrence:** RRULE-based recurrence (`FR-QST-005`, MVP) is implemented directly inside the `quests` module (no separate recurrence engine module).

### 3. Sprint Sequence Realignment (6-Session Series)
- **Session 0 (Bootstrap):** Scaffolding, doc reconciliation, dev environment, ADR 0001.
- **Sprint 1 (Secure Foundation):** `auth`, `core/rpg-engine.ts` (character, xp, mana, energy), full Prisma DDL, security middleware, sync foundation (idempotency key engine).
- **Sprint 2 (Core Productivity Loop):** `quests` (MVP subset), `bosses`, `dungeons`, `gates`, `core/reward-cascade.ts`, `achievements` (trigger hooks).
- **Sprint 3 (Intelligence Layer):** `ai/providers/` (`gemini`, `openai`, `claude`), `ai/planner`, `ai/coach`, AI daily quota budget.
- **Sprint 4 (Supporting Systems):** `screen-time`, `reminders`, `notifications`, `achievements` (finalize), `statistics`, `settings`, `fitness`, `notes`, `analytics`, `admin`.
- **Sprint 5 (Hardening & Regression):** Anti-cheat audit, offline sync audit, full AC regression, final handoff digest (`HANDOFF_FINAL.md`).

### 4. Generalization of Offline-First Authority Contract (Extending NFR-008)
The offline-first model is established as a core architectural law (Rule 6 in `.agents/rules/arise_flutter.md`):
1. **Local-First Writes:** Client writes immediately to local storage and updates UI optimistically.
2. **Command Synchronization:** The client synchronizes intent via domain commands (`COMPLETE_QUEST`, `START_GATE`, `COMPLETE_GATE`, `COLLAPSE_GATE`), never arbitrary authoritative state (forbidden: `SET_XP`, `SET_LEVEL`, `SET_MANA`, `SET_ENERGY`, `SET_BOSS_HP`, `SET_AI_QUOTA`).
3. **Idempotency Guarantee:** Every mutating operation transmits an `Idempotency-Key` header (or body field), stored uniquely as `(user_id, idempotency_key)` to ensure deterministic, non-duplicative replay.
4. **Server Authority & Anti-Cheat:** Progression-affecting values are recomputed server-side from validated commands and immutable ledger rows (`xp_transactions`, `mana_transactions`). Client predictions remain labeled as pending until reconciled.
5. **Conflict Resolution:** Data reconciliation favors server-authoritative progression. Last-write-wins (LWW) is restricted strictly to simple mutable metadata (e.g. title, notes, tags).

### 5. Frontend Integration Strategy
The existing Flutter UI remains the fixed ground truth for visual presentation. During frontend-backend integration:
- Local database persistence (e.g. Drift/SQLite) and a persistent offline command queue MUST be introduced in the Flutter application.
- Frontend data models will transition from integer IDs to UUIDs to align with PostgreSQL authoritative primary keys.
- Integration will bridge existing Riverpod providers to Clean Architecture domain/application use cases without visual redesign.

---

## Reasoning
- **Context Budgeting & Agent Success:** Enforcing explicit requirement IDs and a 5-sprint breakdown prevents context bloat, hallucination of non-existent sections, and dropped acceptance criteria.
- **Data Integrity & Progression Security:** A Life-OS game loop collapses if users or buggy offline clients can submit forged XP, levels, or boss damage. Ledger-first appending with server-side calculation guarantees absolute progression integrity.
- **Separation of Concerns:** Placing Gate focus sessions in Sprint 2 ensures `core/reward-cascade.ts` is fully validated before Sprint 3's AI Coach analyzes focus data.

---

## Alternatives Considered
1. **Treating Client Progression as Authoritative:** Rejected because it allows trivial progression tampering, clock manipulation, and unresolvable ledger divergence.
2. **Implementing Full Habits & Inbox in MVP:** Rejected because attempting to build non-MVP backlog items during initial sprints risks context exhaustion and compromises core stability.
3. **Using a BaaS (e.g., Supabase/Firebase) with Client-Side Math:** Rejected because the custom reward cascade, level curve formulas, and anti-cheat validation require centralized backend business logic.

---

## Tradeoffs
- **Increased Initial Plumbing:** Generalizing idempotency keys and ledger transactions in Sprint 1 requires building middleware and ledger tables before feature endpoints exist.
- **Client Reconciliation Overhead:** Optimistic UI state must handle subtle reconciliation transitions when server-calculated XP or Boss damage differs from local estimates.

---

## Future Implications
- **Frontend Refactoring Needed for Sync:** The Flutter app currently utilizes `InMemoryQuestRepository` and `InMemoryPlayerRepository` in `lib/core/repositories/`. When wiring the client in Sprints 1 and 2, Drift/SQLite and an HTTP client with token storage/interception must replace the in-memory stubs.
- **Phase 2 Seamless Transition:** All deferred items (Habits, Dependencies, Inbox AI Triage) have preserved database schemas in the initial Prisma migration, allowing them to be activated in Phase 2 without destructive migrations.
