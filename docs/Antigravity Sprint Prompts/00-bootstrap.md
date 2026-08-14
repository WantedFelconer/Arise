> **Historical note (post-migration):** This session already ran against an Express-based backend stack. The project has since moved to NestJS (ADR 0002). This file is kept for the record of what Chat 0 actually decided; it is **not** re-run. If you need to migrate an already-scaffolded Express backend to NestJS, use `00b-nest-migration.md` instead — a one-time session in the same spirit as this one.

You are working on ARISE, an offline-first, gamified, AI-assisted personal productivity platform ("Life Operating System"). A Flutter frontend already exists (Solo Leveling–inspired "System" UI) and is a fixed constraint — you are not redesigning it.

THIS IS A ONE-TIME BOOTSTRAP SESSION. Do not implement Sprint 1+ features here. Your job is to make the project documents and repository scaffold trustworthy before any feature work starts.

============================================================
LOAD
============================================================
1. `ARISE_SRS.md` — the full document. This is the only session in this entire series permitted to load it in full; every later sprint loads bounded excerpts only.
2. `SPRINT_PLAN.md`
3. `.agents/rules/arise_flutter.md`
4. `.agents/skills/sprint-orchestrator.md`, `.agents/skills/module-builder.md`, `.agents/skills/integration-reviewer.md`
5. The existing Flutter repository structure

============================================================
WHY THIS SESSION EXISTS
============================================================
`SPRINT_PLAN.md` and `.agents/rules/arise_flutter.md` were written against an earlier draft of the SRS. The version now in the repo (v1.0, dated 2026-08-09) has a different table of contents, different section numbers, and — more importantly — a different MVP boundary than what those two files assume. Concretely, verify and then correct all of the following. Do not take my word for it — confirm each one directly against `ARISE_SRS.md` as you find it in the repo, and if the repo's copy disagrees with what's listed here, the repo's copy wins; update this reconciliation accordingly and note the discrepancy in the ADR from step 4 below.

**1. Section numbers.** The real ToC is: 1 Introduction, 2 Overall Description, 3 User Personas, 4 System Architecture, 5 Data Model, 6 Functional Requirements (`FR-<MODULE>-<NNN>`, tagged MVP/P2/P3), 7 Core System Loop state machines, 8 Sequence Diagrams, 9 API Specification, 10 AI Architecture, 11 Screen↔API Mapping, 12 Non-Functional Requirements (`NFR-NNN`), 13 Security Architecture, 14 External Integrations, 15 Deployment Architecture, 16 Testing & Quality Strategy, 17 Implementation Directives (17.1 build order, 17.2 repo structure, 17.3 non-negotiable rules), 18 Future Roadmap, 19 Acceptance Criteria, 20 Glossary.

There is no "§3.6 Module Inventory," "§3.7 Engines table," "§3.9/3.10 AI/Integration abstraction," "§3.13 background workers," or "§7 Event Catalog" section. The nearest real equivalents are: module inventory → §17.2; RPG engine responsibilities → §6.7–6.9 + §4.2 component table; AI provider abstraction → §10.1; background workers → §15.2 (BullMQ); there is no formal cross-module domain-event catalog in this SRS — treat "domain events" as an internal implementation pattern you may still use for in-process decoupling (per `arise_flutter.md` rule 4), not as something with an SRS-defined payload contract to conform to.

**2. MVP scope.** Cross-check every module against its actual FR priority tags in §6 before scheduling it into a sprint. In particular: Habits (distinct from Quests, with streaks/skip-allowance) are explicitly **§18 Future Roadmap, Phase 2** — not MVP, not Sprint 2. Quest dependencies (FR-QST-006), duplication (FR-QST-009), templates (FR-QST-010), bulk ops (FR-QST-014), NL quest input (FR-QST-015), Inbox/Quick Capture (FR-QST-016, FR-NOTE-003), Eisenhower classification (FR-QST-017) are all **P2**. Do not schedule P2/P3 items into Sprints 1–4 as first-class work; they become explicitly tracked backlog per §18's own instruction.

**3. Sprint assignment for Gate and Screen Time.** §17.1's own build order puts Gate Session Service in **Phase 2 — Core Loop**, wired to the RPG Engine alongside Quest/Boss/Dungeon and the reward cascade (§8.4) — the SRS calls the reward cascade "the single most important piece of business logic in the system," and Gate completion is one of its two callers. Screen Time and Reminders are **Phase 4 — Supporting Systems**, after the Intelligence Layer, not inside it.

**4. No payment/subscription system exists in this SRS.** §2.5 explicitly scopes premium currency ("Gems") as ledger-only with no real-money payment processing in scope. The only quota mechanism actually specified anywhere is a per-user daily AI call budget (§10.5). Do not build a subscription/entitlement/payment system anywhere in this project unless a future SRS revision adds one.

**5. Offline-first is real but the SRS's own baseline for it is thin.** The only explicit offline requirement is **NFR-008**: client may queue quest create/update/complete actions offline; server accepts an `Idempotency-Key` header to safely replay on reconnect. The project owner has separately and explicitly instructed (outside this SRS) that the system must be genuinely offline-first across the whole core loop, and that the backend must remain authoritative for all protected progression values (XP, Level, Mana, Energy, Boss HP, streaks, AI quota) regardless of what any client submits, even while offline. This instruction sits above the SRS for this specific topic — implement the fuller model, but do so as an explicit *generalization* of NFR-008 (same idempotency-key discipline, extended to gate/quest reward-bearing writes), not as a contradiction of anything the SRS actually states. Document this as an ADR (see below).

**6. Repo/module names.** Use §17.2's own suggested structure as the base: modules `auth, character, quests, bosses, dungeons, gates, ai (providers/planner/coach), screen-time, reminders, notes, fitness, calendar, analytics, achievements, notifications, integrations, settings, admin`, plus shared `core/rpg-engine.ts` (single source of truth for XP/Mana/Energy/Level math — never let a feature module compute these inline), `core/reward-cascade.ts` (the shared quest-complete/gate-complete transaction), `core/errors.ts`, `core/middleware/`, `db/prisma/schema.prisma`, `jobs/` (BullMQ workers). There is no "Habit Engine," "Dependency Engine," or "Recurrence Engine" module — RRULE-based recurrence (FR-QST-005, MVP) lives inside the `quests` module itself.

============================================================
WHAT YOU MUST PRODUCE
============================================================

**A. Patch `SPRINT_PLAN.md`** to reflect a 6-session structure (this bootstrap + 5 sprints), each with the corrected SRS section/FR/NFR references and the corrected MVP scope from above. Use this as the sprint-to-scope table (adjust only if your own reading of the repo's SRS copy disagrees — note any such disagreement explicitly):

| Sprint | Modules | Primary FR sections (MVP only) | Key anchors |
|---|---|---|---|
| 1 — Secure Foundation | auth, core/rpg-engine (character+xp+mana+energy), full db schema, sync foundation, security middleware | §6.1, §6.2, §6.7, §6.8, §6.9 | §13 all, NFR-003/004/005/006/008/012, §19 AC-AUTH-004 |
| 2 — Core Productivity Loop | quests (MVP FRs only), bosses, dungeons, gates, core/reward-cascade, achievements (trigger hook) | §6.3 (MVP subset), §6.4, §6.5, §6.6, §6.19 | §7.1–7.3, §8.3–8.4, §17.3 rule 5, §19 AC-QST-011/AC-GATE-005 |
| 3 — Intelligence Layer | ai/providers, ai/planner, ai/coach | §6.12, §6.13, §10 (all) | §7.4, §8.2, §19 AC-AIP-003/005, §10.5 |
| 4 — Supporting Systems | screen-time, reminders, notifications, achievements (finalize), statistics, settings, game-mode config, fitness, notes (baseline), analytics (baseline), admin config | §6.10, §6.11, §6.14 (partial), §6.15 (partial), §6.17, §6.19/§6.20, §6.21, §6.23, §6.24, §6.27 (partial) | NFR-008/009/010/011, §14 |
| 5 — Hardening & Regression | none new; audits 1–4 | full §6 MVP regression | §12, §13, §16, §18 (confirm untouched), §19 (all) |

**B. Patch `.agents/rules/arise_flutter.md`.** Fix every section-number reference to match the real ToC above. Then append a new rule — do not silently fold it into an existing one, since it's a genuine addition beyond the literal SRS text and should be visible as such:

```
## 6. Offline-First Authority Contract (extends NFR-008)

The SRS's NFR-008 requires idempotent offline replay for quest actions via an
Idempotency-Key header. This rule generalizes that requirement across the
whole core loop per explicit product-owner direction:

1. Every user-facing write hits local client storage and updates the UI
   immediately, before any network call. Network sync is asynchronous.
2. The client synchronizes DOMAIN COMMANDS (e.g. COMPLETE_QUEST,
   CREATE_QUEST, START_GATE, COMPLETE_GATE, COLLAPSE_GATE), never final
   authoritative state (never SET_XP, SET_LEVEL, SET_MANA, SET_ENERGY,
   SET_BOSS_HP, SET_AI_QUOTA).
3. Every synchronized command carries a unique idempotency key and MUST be
   safe to replay — replaying an already-processed key returns the original
   result and performs no new mutation, per §17.3 rule 5's requirement that
   the reward cascade be idempotent per quest/gate-session id.
4. The backend never accepts a client-submitted value for XP, Level, Mana,
   Energy, Boss HP, streaks, achievements, or AI quota as final. These are
   always recomputed server-side from validated commands and existing
   ledger state (xp_transactions, mana_transactions), per §17.3 rule 1.
5. When local and server state disagree for any of the values in (4), the
   client reconciles toward the server's response. Simple editable fields
   (title, description, tags) may use last-write-wins; reward-bearing
   operations never do.
```

**C. Confirm/patch `.agents/skills/module-builder.md` and `.agents/skills/integration-reviewer.md`.** They mostly reference the ledger and README pattern generically and shouldn't need section-number fixes, but re-read them against the corrected SPRINT_PLAN.md excerpts they'll actually be fed and flag anything that assumes a document structure that no longer exists (e.g. any implicit assumption of a formal Event Catalog table with fixed payload names — there isn't one; event names/payloads used internally are your own implementation detail, keep them consistent within a sprint and document them in each module's README instead of cross-checking them against a nonexistent §7 catalog).

**D. Write an ADR** at `docs/adr/0001-scope-and-doc-reconciliation.md` covering: the section-number drift found, the MVP-scope corrections (Habits/Inbox/dependencies → backlog), the Gate/Screen-Time sprint reassignment, the confirmation that no payment system is in scope, and the offline-first generalization beyond NFR-008 — Decision / Reasoning / Alternatives Considered / Tradeoffs / Future Implications, per the ADR format `arise_flutter.md` already specifies.

**E. Scaffold the backend** per §17.2, adapted with the sync/security additions from rule 6 above:

```
backend/
  src/
    modules/
      auth/  character/  quests/  bosses/  dungeons/  gates/
      ai/providers/  ai/  screen-time/  reminders/  notes/
      fitness/  calendar/  analytics/  achievements/
      notifications/  integrations/  settings/  admin/
    core/
      rpg-engine.ts
      reward-cascade.ts
      errors.ts
      middleware/
    db/
      prisma/
  jobs/
  tests/
  scripts/
docs/
  adr/
  sprint-tracking/
docker-compose.yml
.env.example   (fields per §15.4's authoritative list)
```

Each module folder gets the standard internal shape from `arise_flutter.md` (`<module>.module.ts` + `controller/service/repository/validation/dto/tests/README.md` — no standalone `routes/` folder; a module's routes are its controller's `@Get()`/`@Post()`/etc. decorators) but stays EMPTY of business logic — Sprint 1 is the first sprint allowed to implement anything beyond scaffolding.

**F. Set up local dev infra**: `docker-compose.yml` for Postgres 16 + Redis 7, base TypeScript/ESLint/Prettier config (strict mode, no `any`/`dynamic` escape hatches without a comment), a test runner config pointed at a real Postgres test container per §16's testing strategy (not mocked DB for transactional tests).

**G. Inspect the Flutter frontend.** Document (don't rewrite) its existing repository/API-client layer, local database technology, and Riverpod structure. Note any mismatch with the `presentation/application/domain/infrastructure` split `arise_flutter.md` expects, and with the offline sync contract in rule 6 above. This becomes part of the ADR's "Future Implications" section, not a redesign task.

============================================================
DO NOT
============================================================
- Implement any auth, character, quest, boss, gate, AI, or supporting-system business logic. That starts in Chat 1.
- Build a payment/subscription system.
- Build Habits, Inbox, quest dependencies, or any other P2/P3 item as first-class scaffolding beyond what §17.2's structure already implies.
- Invent SRS section numbers you have not verified against the actual document text in the repo.

============================================================
DEFINITION OF DONE
============================================================
- [ ] `SPRINT_PLAN.md` patched with corrected section/FR/NFR references and corrected sprint scope
- [ ] `arise_flutter.md` patched — section refs fixed, new §6 Offline-First Authority Contract appended
- [ ] `module-builder.md` / `integration-reviewer.md` reviewed, patched if needed
- [ ] ADR 0001 written
- [ ] Backend scaffold exists per §17.2 + additions, compiles, lints clean
- [ ] `docker-compose.yml` brings up Postgres 16 + Redis 7 locally
- [ ] `.env.example` matches §15.4's authoritative variable list
- [ ] Flutter integration notes documented (not implemented)
- [ ] Nothing beyond scaffolding has been implemented

Stop here. Chat 1 starts Sprint 1 in a fresh session, loading only the patched `arise_flutter.md` + the corrected Sprint 1 excerpt of `SPRINT_PLAN.md` — not this session's transcript.
