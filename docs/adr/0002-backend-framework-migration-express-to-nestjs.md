# ADR 0002: Backend Framework Migration — Express → NestJS

## Status
**Accepted** — 2026-08-14

## Context
ADR 0001 recorded the bootstrap baseline for ARISE, including a Node.js/Express/TypeScript/PostgreSQL backend, and the bootstrap session (`00-bootstrap.md`) scaffolded the repository against that stack. Sprint 1 ("Secure Foundation") had not yet been executed.

Mid-project, the decision was made to build on **NestJS** instead of raw Express, while keeping every other part of the stack (Node 20, TypeScript strict, Prisma, PostgreSQL 16, Redis 7, JWT RS256, BullMQ) unchanged. NestJS itself runs on top of Express by default (`@nestjs/platform-express`), so this is a framework/paradigm change — decorators, dependency injection, modules, Guards/Pipes/Interceptors/Filters — not a change to the underlying HTTP engine or any other infrastructure decision in ADR 0001.

Because bootstrap already ran, a real (if still-empty, per bootstrap's own scope) Express-shaped scaffold exists in the repository. This ADR does not re-litigate ADR 0001's other decisions (MVP scope, sprint sequencing, offline-first authority contract) — those stand. It supersedes ADR 0001 **only** on the specific point of "Backend: Node.js + Express.js + TypeScript."

## Decision
1. **Framework:** The backend is built on **NestJS**, using the Express platform adapter (`@nestjs/platform-express`) rather than the Fastify adapter, to minimize churn against anything already written (Express-compatible middleware like `helmet`/`cors` continues to work unchanged via `app.use()`).
2. **Module boundary:** A NestJS `<module>.module.ts` per feature module (per `arise_flutter.md` Section 1.3/§3.5) replaces the standalone `routes/` folder. Routing is expressed as decorators on `@Controller()` classes, never a hand-built `express.Router()`.
3. **Cross-cutting concerns map to Nest primitives**, not ad hoc Express middleware functions (see `arise_flutter.md` rule 11 for the full mapping): auth/ownership → `Guard`s; request validation → `Pipe`s (Zod schemas wrapped in a `ValidationPipe`/`nestjs-zod`); response shaping/logging → `Interceptor`s; error handling → a global `ExceptionFilter`; request-scoped concerns needing raw `req`/`res` (request-id tagging) → `NestMiddleware` classes.
4. **Dependency injection is native.** Where the SRS's AI Provider Abstraction (§3.9/§10.1) already called for "injected via dependency injection, no `if (provider === ...)` branching," Nest's built-in DI container is now the actual mechanism, not an informal pattern layered on top of Express.
5. **Validation library:** Zod is retained (not replaced with `class-validator`) to avoid rewriting every module's `validation/` schemas — Zod schemas are wrapped in a Nest `ValidationPipe` rather than called manually inside each handler.
6. **Testing:** `@nestjs/testing`'s `Test.createTestingModule()` replaces manual Express app instantiation for integration tests; the real-Postgres-test-container requirement from §16 is unaffected.

## Reasoning
- **Structural fit with the project's own architecture laws.** `arise_flutter.md`'s non-negotiable laws (Clean Architecture layering, module ownership, centralized engines, event-driven cross-module communication) map almost one-to-one onto Nest's own module/provider/DI system. Nest enforces several of these boundaries at the framework level (a module only sees what another module explicitly exports) where Express required convention and code review alone.
- **Lower long-term maintenance cost for a solo/small team.** The project's own stated rationale for its architectural style (Section 3.1 of the SRS) is minimizing operational complexity for a team transitioning off AI-assisted "vibe coding." Nest's opinionated structure reduces the number of ways the same cross-cutting concern (auth, validation, logging) gets reinvented per module — which is exactly the kind of drift Clean Architecture is meant to prevent.
- **Minimal actual rework, since bootstrap had not passed Sprint 1.** No business logic exists yet (bootstrap's own definition of done explicitly excluded implementing anything beyond scaffolding). The migration is scaffold-and-doc-level, not a rewrite of working features.

## Alternatives Considered
1. **Stay on Express.** Rejected — the module owner's explicit reason for switching was structural (DI, decorator-based routing, and framework-enforced module boundaries), not a defect in Express itself; Express remains perfectly capable, but the team wants Nest's guardrails going forward.
2. **NestJS with the Fastify adapter.** Rejected for now — Fastify is faster, but the Express adapter preserves compatibility with anything already written against Express's request/response shape (e.g. `helmet`, existing middleware patterns) and keeps the migration surface smaller. Revisit only if a concrete performance need arises (see NFR-PERF-2); switching adapters later is a `main.ts`-level change, not a rewrite.
3. **Replace Zod with `class-validator`/`class-transformer`** (Nest's more "native" validation idiom). Rejected for this migration — would require rewriting every module's validation schemas for no functional gain. Nothing prevents a future module from using `class-validator` instead; both can coexist behind Nest's `ValidationPipe` abstraction.

## Tradeoffs
- **New framework-specific vocabulary** (Guards, Pipes, Interceptors, Filters, Providers) that every sprint prompt and skill file must now assume the coding agent understands — `arise_flutter.md` rule 11 documents the mapping so this doesn't have to be re-explained every sprint.
- **One-time migration cost** for whatever the bootstrap scaffold already produced (see `00b-nest-migration.md`), even though it's scaffold-only.
- **Slightly heavier boilerplate per module** (a `.module.ts` file, decorator-based DI wiring) compared to a minimal Express router — accepted as the cost of the structural guarantees in "Reasoning" above.

## Future Implications
- All sprint prompts (`01`–`05`) and the two skills that scaffold/audit code (`module-builder`, `integration-reviewer`) now assume NestJS's module/controller/provider shape when they say "controller," "service," or "module boundary." No sprint prompt beyond Sprint 1 required content changes beyond this framing, since none of them contained Express-specific implementation detail — they were already framework-agnostic at the FR/AC level.
- `docs/adr/0001-scope-and-doc-reconciliation.md` is left untouched as an accurate historical record of the bootstrap-time decision; this ADR supersedes it only on the framework point, per standard ADR practice (superseding rather than editing history).
- If a future performance requirement (NFR-PERF-2) demands it, switching the Nest platform adapter from Express to Fastify is a contained `main.ts` / bootstrap-level change under this same ADR's umbrella, not a new architectural decision.
