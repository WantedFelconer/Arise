# ARISE Backend — Antigravity Prompt Series (Refined)

## How to use this

Six files, six **separate, fresh** Antigravity chat sessions, in order:

| Chat | File | Purpose |
|---|---|---|
| 0 | `00-bootstrap.md` | Reconcile docs against the real SRS, scaffold the repo (historical — ran against Express; superseded on the framework point by ADR 0002) |
| 0b | `00b-nest-migration.md` | One-time: migrate the already-scaffolded Express backend to NestJS |
| 1 | `01-sprint1-secure-foundation.md` | Auth, Character/XP/Mana/Energy, schema, sync + security base |
| 2 | `02-sprint2-core-productivity-loop.md` | Quest, Boss, Dungeon, Gate, Reward Cascade, Achievements |
| 3 | `03-sprint3-intelligence-layer.md` | AI Provider Abstraction, AI Planner, AI Coach |
| 4 | `04-sprint4-supporting-systems.md` | Screen Time, Reminders, Notifications, Stats, Settings, Fitness, Notes, Analytics, Modes |
| 5 | `05-sprint5-security-sync-hardening-regression.md` | Anti-cheat audit, offline audit, full AC regression, HANDOFF_FINAL.md |

Paste the whole file as the first message of that chat. Do not paste more than one prompt into one session, and do not carry conversation history between them — each sprint's agent should load only: `arise_flutter.md` (patched), the current sprint's excerpt of `SPRINT_PLAN.md` (patched), the previous sprint's handoff digest, and the specific SRS sections named in that prompt. This is the context-budgeting model your `sprint-orchestrator` / `module-builder` / `integration-reviewer` skills already implement — these prompts feed that machinery, they don't replace it.

## Priority order used to write these prompts

Per your instruction, where documents disagree, priority is:

1. **Your explicit instructions in the ChatGPT conversation** (offline-first is mandatory, backend is authoritative, no client-trusted progression values, non-exploitable by design) — this is now written into `arise_flutter.md` as a new §6 rule (see Chat 0).
2. **`ARISE_SRS.md`** (the actual uploaded file, v1.0, Aug 9 2026) — this is the real spec. It disagrees with the ChatGPT conversation and with the existing `SPRINT_PLAN.md`/skills in several concrete, checkable ways (below). Where the SRS is silent (it has no formal premium/subscription system, no formal sync-conflict spec beyond one NFR line), the ChatGPT conversation's design fills the gap and is treated as authoritative for those gaps only — not as license to override things the SRS *does* specify.
3. **`SPRINT_PLAN.md` / `arise_flutter.md` / the three skills**, corrected per below.
4. Engineering judgment, flagged explicitly wherever used.

## Corrections made vs. the ChatGPT draft and the existing project docs

I read the actual `ARISE_SRS.md` end to end before writing these (the ChatGPT conversation never saw its content — it only saw the skills/rules files, which were themselves written against an earlier draft of the SRS). Six concrete drifts, all fixed below:

**1. Section numbers don't match.** `SPRINT_PLAN.md` and the skills reference SRS "§3.6 Module Inventory," "§3.7 Engines," "§3.9/3.10 AI/Integration abstraction," "§3.13 background workers," "§7 Event Catalog," functional requirements as "§4.1–4.28," and Acceptance Criteria as "§14." None of these exist. The real table of contents is:

| # | Actual SRS section |
|---|---|
| 1 | Introduction |
| 2 | Overall Description |
| 3 | User Personas |
| 4 | System Architecture (4.1 diagram, 4.2 components, 4.3 stack) |
| 5 | Data Model (5.1 ERD, 5.2 principles, 5.3 full DDL) |
| 6 | Functional Requirements — `FR-<MODULE>-<NNN>`, tagged MVP/P2/P3 (6.1 Auth … 6.27 Admin) |
| 7 | Core System Loop — State Machines |
| 8 | Sequence Diagrams |
| 9 | API Specification |
| 10 | AI Architecture |
| 11 | Screen ↔ API Mapping |
| 12 | Non-Functional Requirements (`NFR-NNN`) |
| 13 | Security Architecture |
| 14 | External Integrations |
| 15 | Deployment Architecture |
| 16 | Testing & Quality Strategy |
| 17 | Implementation Directives (17.1 build order, 17.2 repo structure, 17.3 non-negotiable rules) |
| 18 | Future Roadmap (Phase 2 / Phase 3) |
| 19 | Acceptance Criteria |
| 20 | Glossary |

Every prompt below cites the real numbers and, more importantly, real requirement IDs (`FR-AUTH-004`, `NFR-008`, etc.) — IDs survive document edits better than section numbers ever will, so builders should resolve by ID first, section number second.

**2. Sprint 2 was scoped to features the SRS marks post-MVP.** The old plan put a "Habit Engine," Inbox/Quick-Capture, and a "Dependency Engine" into Sprint 2 as core work. In the actual SRS: **Habits are explicitly Phase 2 Future Roadmap** (§18 — "Habits (distinct from Quests, with streaks/skip-allowance)"), **Inbox/Quick Capture is P2** (FR-NOTE-003), **quest dependencies are P2** (FR-QST-006), and templates/duplication/bulk-ops/NL-input/Eisenhower are all P2. Sprint 2 below builds only the MVP-tagged Quest/Boss/Dungeon/Gate requirements; every P2 item is named explicitly as backlog, not silently dropped.

**3. Gate and Screen Time were in the wrong sprints.** The SRS's own build order (§17.1) puts **Gate Session in Phase 2 — Core Loop**, wired to the RPG Engine right alongside Quest/Boss/Dungeon and the reward cascade — not bundled with AI. It puts **Screen Time and Reminders in Phase 4 — Supporting Systems**, after the Intelligence Layer, not inside it. I moved both to match. This isn't cosmetic: the reward cascade (§8.4) is explicitly "the single most important piece of business logic in the system" per §17.1, and Gate completion is one of its two callers — it has to exist before Sprint 3's AI Coach can meaningfully reason about focus-session data anyway.

**4. There is no premium/subscription system in this SRS.** §2.5 explicitly scopes "Gems" as ledger-only with **no real-money payment processing** in this document. The only quota mechanism actually specified is a **per-user daily AI call budget** (§10.5). Sprint 3 builds that budget as MVP and adds a minimal, config-table-backed entitlement hook (using the `feature_flags` table already in §5.3) so a future premium tier can gate AI usage later without a redesign — it does **not** build a payment/subscription system, and the prompt says so explicitly to stop Antigravity from inventing one.

**5. Offline-first is a real elevation beyond the literal SRS text — flagged everywhere it applies.** The SRS's only offline requirement is **NFR-008**: the client may queue quest actions offline; the server accepts an `Idempotency-Key` header to replay safely on reconnect. That's a thin, quest-only mechanism. Your explicit instruction in the ChatGPT conversation — the app is genuinely offline-first across the whole core loop, and the backend must remain authoritative for XP/Level/Mana/Energy/Boss HP/streaks/premium/AI-quota regardless of what a client submits — goes further than NFR-008 says. I built Sprint 1's sync foundation as **NFR-008 generalized**: the same idempotency-key discipline, extended to every reward-bearing write (quest complete, gate complete/collapse), never as a replacement for server-side recomputation. Every prompt below says explicitly where it's satisfying literal SRS text versus implementing your broader instruction.

**6. Module/folder names corrected to the SRS's own repo structure (§17.2).** Modules are: `auth, character, quests, bosses, dungeons, gates, ai (providers/planner/coach), screen-time, reminders, notes, fitness, calendar, analytics, achievements, notifications, integrations, settings, admin`, plus shared `core/rpg-engine.ts` (single source of truth for XP/Mana/Energy/Level) and `core/reward-cascade.ts` (the shared quest-complete/gate-complete transaction). There is no "Habit Engine," "Dependency Engine," or "Recurrence Engine" as separate top-level modules in the actual SRS — recurrence (FR-QST-005, RRULE, MVP) lives inside the `quests` module.

## Corrected Sprint → SRS coverage map

| Sprint | Modules built | Primary SRS FR sections (MVP scope only unless noted) | Key NFR/Security/AC anchors |
|---|---|---|---|
| 1 — Secure Foundation | `auth`, `core/rpg-engine` (character+xp+mana+energy), db schema (full), sync foundation, security middleware | §6.1 AUTH, §6.2 CHAR, §6.7 XP, §6.8 MANA, §6.9 ENERGY | §13 (all), NFR-003/004/005/006/008/012, §19 AC-AUTH-004 |
| 2 — Core Productivity Loop | `quests` (MVP FRs only), `bosses`, `dungeons`, `gates`, `core/reward-cascade`, `achievements` (trigger hook) | §6.3 QST (MVP subset), §6.4 BOSS, §6.5 DUNG, §6.6 GATE, §6.19 ACH | §7.1–7.3 state machines, §8.3–8.4 sequences, §17.3 rule 5, §19 AC-QST-011/AC-GATE-005 |
| 3 — Intelligence Layer | `ai/providers`, `ai/planner`, `ai/coach` | §6.12 AIP, §6.13 COACH, §10 (all) | §7.4 state machine, §8.2 sequence, §19 AC-AIP-003/005, §10.5 |
| 4 — Supporting Systems | `screen-time`, `reminders`, `notifications`, `achievements` (finalize), `statistics`, `settings`, game-mode config, `fitness`, `notes` (baseline), `analytics` (baseline rollups), admin config | §6.10 SCREEN, §6.11 REM, §6.14 ANLY (partial), §6.15 NOTE (partial), §6.17 FIT, §6.19 ACH/INV, §6.20 STAT, §6.21 NOTIF, §6.23 SET, §6.24 MODE, §6.27 ADMIN (partial) | NFR-008/009/010/011, §14 |
| 5 — Hardening & Regression | no new modules; audits every module built in 1–4 | full §6 MVP regression, §12 (all), §13 (all), §16, §18 (confirm untouched), §19 (all) | Everything |

Sections 9 (API), 11 (Screen↔API mapping), 15 (deployment), 17.2 (repo structure) are cross-cutting reference material loaded by whichever sprint is touching that surface, per the existing `sprint-orchestrator` convention — they don't need a dedicated owning sprint.

## What I did **not** change

- Stack: Node 20 + **NestJS** (Express adapter under the hood) + TypeScript (strict) + Prisma + PostgreSQL 16 + Redis 7, JWT RS256. *(Originally Express; migrated to NestJS post-bootstrap per ADR 0002 — see `00b-nest-migration.md`. Everything else about the stack — Prisma, Postgres, Redis, JWT scheme — is unchanged.)*
- The Orchestrator → Builder → Reviewer skill pattern and its context-budgeting discipline — kept as-is, it's a good mechanism and doesn't need to change, only the content it's fed needs correcting.
- The core security posture from the ChatGPT conversation (server-authoritative progression, command-based sync instead of state-sync, idempotent reward cascades, refresh-token reuse detection revoking all sessions) — this matches §13 and §17.3 almost exactly already; I kept it and cited the real section numbers instead of inventing new policy.
