---
trigger: always_on
description: Global, always-apply project rules for ARISE (Life Operating System). Load this on every task regardless of sprint or module.
---

# ARISE — Global Project Rules

You are working on **ARISE**, an offline-first, gamified, AI-assisted personal productivity platform ("Life Operating System"). A Flutter frontend already exists. 

The existing Flutter frontend is the product UI baseline.

Do not rebuild it from scratch or replace its visual identity.

However, you MAY and SHOULD modify existing Flutter screens, layouts,
components, navigation, states, and interactions when required to:

- fix identified UX/UI defects
- support real data
- support offline-first behavior
- support loading/error/empty/offline/sync states
- improve accessibility
- improve responsive behavior
- remove misleading placeholder behavior
- correct performance problems

UI changes must preserve the ARISE design language and must be justified
by usability, correctness, integration, accessibility, or performance.
Do not redesign merely for personal aesthetic preference.

Authoritative references, in order of precedence: `ARISE_SRS.md` (the spec) > `SPRINT_PLAN.md` (what to build now) > this file (how to build it) > your own judgment. If this file and the SRS ever conflict, the SRS wins and you should flag the conflict rather than silently picking one.

## 1. Non-negotiable architecture laws

1. **Modular Monolith.** One deployable backend. Do not introduce microservices, separate deployables, or a second database for a "new" module without an explicit ADR.
2. **Feature-First organization, both sides.** Backend: `backend/src/modules/<module>/`. Frontend: `frontend/lib/features/<feature>/`. Never organize by technical layer at the top level (no top-level `controllers/`, `services/` folders spanning multiple features).
3. **Clean Architecture layering inside every module.** Backend: `controller → service → repository`, plus a `<module>.module.ts` (NestJS module — the DI/routing boundary that replaces a hand-built `routes/` file), `validation/`, `dto/`, `events/`, `types/`, `tests/`. Route paths and HTTP verbs live as decorators on the controller class (`@Controller()`, `@Get()`, `@Post(':id/complete')`, etc.) — never construct an `express.Router()` by hand, and never register a route outside a controller. Frontend: `presentation → application → domain ← infrastructure`. Dependencies point inward only. `domain/` (frontend) and `service/` (backend business logic) never import a UI widget, an HTTP client, or a DB driver directly.
4. **Module ownership is absolute.** A module may not read or write another module's repository, database tables, or internal service methods. Cross-module reads go through the other module's public service API. Cross-module *reactions* go through the domain event bus (Section 3.8 of the SRS) — never a direct function call into another module for a "this happened" notification.
5. **Centralized Game Engines only.** XP, Mana, Energy, Boss damage, Gate stability, Habit streaks, Screen Time Mana modifiers, and Achievement triggers are calculated exclusively by the centralized engines (SRS Section 3.7 / `core/rpg-engine.ts`). If you find yourself computing an XP number, a streak, or a damage value inline in a feature module, stop — call the engine instead, or add the missing engine method.
6. **Offline-first / local-first is not optional polish.** Every write the user makes MUST hit the local database and update the UI immediately, before any network call. Network calls happen through the sync engine's event queue, asynchronously. If a feature you're building would require the UI to wait on a network response for a normal interaction, that's a design bug — fix the flow, don't ship it.
7. **Backend is authoritative, client is never trusted.** The backend recomputes XP, Level, Mana, Energy, Boss HP, streaks, and achievement unlocks from raw events. Never accept a client-submitted final value for any of these fields as-is. See SRS Section 4.28 (FR-VALID-1 through FR-VALID-3).
8. **AI and integrations go through their abstraction layers, always.** Business logic depends on `AIProvider` / `ExternalIntegration` interfaces (SRS Section 3.9, 3.10 / Section 11.1), never on an OpenAI/Gemini/Claude/Notion/Google SDK directly. If you're about to `import` a vendor SDK outside `modules/ai/providers/` or `modules/integrations/providers/`, stop.
9. **Config-driven balancing.** XP curves, reward tables, difficulty multipliers, and screen-time Mana modifiers live in `config/*.json` (or DB-backed config tables), never as magic numbers in business logic.
10. **AI proposes, it never commits.** Any AI-generated plan, triage suggestion, or reschedule requires explicit user approval before it creates or mutates real domain data. This applies even if it would be "more convenient" to auto-apply it.
11. **Backend framework is NestJS, not raw Express.** NestJS runs on top of Express by default (`@nestjs/platform-express`) — swapping frameworks did not remove Express from the dependency tree, but application code must never talk to it directly. Cross-cutting concerns route through Nest's own primitives, not hand-rolled Express middleware functions:
    - **Auth / ownership checks** → `Guard`s (`@UseGuards()`), never an inline `(req, res, next) => {}` check duplicated per route.
    - **Request validation** → `Pipe`s (a global `ValidationPipe`, or a `ZodValidationPipe`/`nestjs-zod` wrapper around the module's Zod schemas), applied before the handler body runs.
    - **Cross-request concerns that need a raw `req`/`res`** (request-id tagging, structured request logging) → `NestMiddleware` classes registered in a module's `configure()`, not global `app.use()` callbacks scattered across files.
    - **Response shaping / logging around a handler** → `Interceptor`s (`@UseInterceptors()`).
    - **Error → uniform response shape** → a global `ExceptionFilter` (`@Catch()`), never a bare Express error-handling middleware.
    - Framework-level concerns that are genuinely just Express under the hood (`helmet()`, CORS) are still wired via `app.use()` / `app.enableCors()` in `main.ts` — that's normal, idiomatic Nest, not a violation of this rule. What's prohibited is building a *second*, parallel Express routing/middleware layer alongside Nest's.
    - Business logic (`service/`, `core/`) never imports `express` types (`Request`, `Response`, `NextFunction`) directly — if a service needs something from the request, it's passed in as a plain argument by the controller, keeping `service/` framework-agnostic and unit-testable without spinning up HTTP.

## 2. Coding standards

- Prioritize readability over cleverness. An intermediate engineer should understand any file without external context.
- Explicit naming, small functions, low cyclomatic complexity, strong typing (TypeScript backend, Dart frontend — no `any`/`dynamic` escape hatches without a comment explaining why).
- Every module ships with: unit tests, integration tests for its API surface, and a `README.md` covering purpose, responsibilities, public API, dependencies, database tables, events emitted/consumed, and future extension points.
- Significant architectural decisions get an ADR in `docs/adr/`, numbered sequentially, following the format in SRS's architecture constitution source (Decision / Reasoning / Alternatives Considered / Tradeoffs / Future Implications).
- Prefer editing/extending an existing module's engine or repository over duplicating logic in a new location "just for this feature."

## 3. Sprint discipline

- Work only within the current sprint's assigned modules (see `SPRINT_PLAN.md`). Do not silently start next-sprint modules while "finishing up" the current sprint — flag it instead if you believe a dependency is missing.
- Do not re-derive the whole system from `ARISE_SRS.md` every session. Load: this file + the current sprint's SRS excerpt + the previous sprint's handoff digest. If something outside that scope seems required, say so explicitly rather than quietly pulling in the full SRS.
- End every module with a completion note appended to `docs/sprint-tracking/sprint-N.md` (see `.agents/skills/module-builder.md`).
- End every sprint with a handoff digest (see `.agents/skills/integration-reviewer.md`) — the next sprint's agent should never need this sprint's full conversation history.

## 4. Flutter/frontend integration rules

- Treat the existing Flutter frontend as ground truth for UI/UX; you are not redesigning screens.
- Before wiring an endpoint, check the frontend's existing repository/API-client layer under `frontend/lib/features/<feature>/infrastructure/`. If it doesn't already follow the `presentation/application/domain/infrastructure` split from SRS Section 3.4, flag the mismatch — do not silently bend backend DTOs to match a non-conforming frontend shape without noting it.
- Local database (Drift or Isar) tables mirror the backend schema per SRS Section 6.3, including a `sync_status` column on every locally-mutable table.
- Riverpod providers/notifiers live in `presentation/`; they call into `application/` use cases, never directly into `infrastructure/`.

## 5. Prohibited without an explicit flag to the user/orchestrator

- Adding a new top-level module not listed in SRS Section 3.6 / §17.2 repo structure.
- Accepting client-submitted XP/Level/Mana/Energy/Boss-HP/streak/achievement values as final.
- Calling a vendor AI or integration SDK outside its abstraction layer.
- Hardcoding a game-balance number that should be config-driven.
- Auto-materializing an AI-generated plan without user approval.
- Building anything listed in SRS Section 15 (Future Roadmap) during Sprints 1–5.

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