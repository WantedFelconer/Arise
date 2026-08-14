You are working on ARISE, an offline-first, gamified, AI-assisted personal productivity platform ("Life Operating System"). A Flutter frontend already exists and is a fixed constraint — you are not touching it in this session.

THIS IS A ONE-TIME MIGRATION SESSION, run after `00-bootstrap.md` but before Sprint 1. Do not implement Sprint 1+ feature/business logic here — that constraint carries over unchanged from bootstrap. Your job is to convert the existing Express-shaped scaffold to NestJS, and nothing else.

============================================================
LOAD
============================================================
1. `.agents/rules/arise_flutter.md` (patched — includes rule 11, Backend framework is NestJS)
2. `docs/adr/0001-scope-and-doc-reconciliation.md` and `docs/adr/0002-backend-framework-migration-express-to-nestjs.md` (already written — read for context, do not rewrite them)
3. `SPRINT_PLAN.md`
4. The existing `backend/` directory as it stands right now — this is the actual source of truth for what needs to move, not a description of it. Inspect it directly: `package.json`, `tsconfig.json`, folder structure under `src/modules/`, `src/core/`, any existing `server.ts`/`app.ts`/`index.ts` entrypoint, `docker-compose.yml`, `.env.example`.

Do not re-read `ARISE_SRS.md` in full. If this migration surfaces something that genuinely requires it (an FR/NFR you can't resolve from the rule file or the ADRs), say so explicitly rather than pulling in the whole document.

============================================================
WHY THIS SESSION EXISTS
============================================================
`00-bootstrap.md` scaffolded `backend/` against a Node.js + Express + TypeScript stack, per the SRS as it read at the time (ADR 0001). Per ADR 0002, the project has since moved to NestJS, keeping every other stack decision (Node 20, TypeScript strict, Prisma, PostgreSQL 16, Redis 7, JWT RS256, BullMQ) unchanged. Because bootstrap's own definition of done explicitly excluded implementing any business logic, what exists right now is scaffolding only — empty module folders, dev infra, config. That makes this the cheapest possible point to migrate: there is no feature code to port, only structure, entrypoint, and tooling.

============================================================
WHAT YOU MUST PRODUCE
============================================================

**A. Install and configure NestJS.**
- Add: `@nestjs/core`, `@nestjs/common`, `@nestjs/platform-express`, `@nestjs/config`, `@nestjs/testing`, `reflect-metadata`, `rxjs`.
- Keep: `helmet`, `cors` (if already present) — these are still used, just wired through Nest's bootstrap (`app.use(helmet())`, `app.enableCors()`) rather than a raw Express app.
- Remove any bare `express` app-instantiation code (`const app = express()`), but leave the `express` package itself as a transitive dependency of `@nestjs/platform-express` — do not fight the platform adapter.
- Add `nest-cli.json` and update `tsconfig.json` for `experimentalDecorators: true`, `emitDecoratorMetadata: true`, and Nest's expected `target`/`module` settings.
- Update `package.json` scripts to Nest CLI equivalents (`nest start`, `nest start --watch`, `nest build`), keeping the existing test runner (Vitest, per bootstrap's dev-infra setup) — Nest doesn't require Jest specifically; wire `@nestjs/testing`'s `Test.createTestingModule()` to work under the existing test runner rather than switching test frameworks.

**B. Convert the entrypoint.**
- Create `backend/src/main.ts`: standard Nest bootstrap — `NestFactory.create(AppModule)`, `app.use(helmet())`, `app.enableCors({ origin: <known client origin(s) from .env.example> })`, global `ValidationPipe` placeholder (wired for Zod per rule 11 — a `ZodValidationPipe`/`nestjs-zod` stub is fine at this stage, since no schemas exist yet), global `ExceptionFilter` placeholder, `/api/v1` global prefix (§9's API Specification base path), `app.listen(...)`.
- Create `backend/src/app.module.ts`: root `@Module()` that imports `ConfigModule.forRoot()` and will import each feature module as Sprint 1+ builds them. It's fine for this to import an empty array of feature modules right now — the point is the wiring point exists.
- Delete whatever raw Express `server.ts`/`app.ts`/`index.ts` bootstrap file bootstrap produced, once `main.ts`/`app.module.ts` fully replace its responsibilities. Don't leave two competing entrypoints.

**C. Convert each module's scaffold shape.**
For every module folder under `backend/src/modules/<module>/` (per §17.2 / rule 6 of `00-bootstrap.md`: `auth, character, quests, bosses, dungeons, gates, ai, screen-time, reminders, notes, fitness, calendar, analytics, achievements, notifications, integrations, settings, admin`):
- Add `<module>.module.ts` — an empty `@Module({})` shell (no controllers/providers registered yet, since none exist — Sprint 1 is the first sprint allowed to add real ones). This is the file that replaces a `routes/` folder; if bootstrap created a `routes/` subfolder in any module, delete it.
- Leave `controller/`, `service/`, `repository/`, `validation/`, `dto/`, `events/`, `types/`, `tests/`, `README.md` as-is structurally — they stay empty of business logic per bootstrap's own scope, this session only changes *how routing/DI will be wired*, not what's inside them yet.
- Do not pre-register these empty modules' non-existent controllers anywhere — just confirm the folder shape and the presence of `<module>.module.ts` matches what Sprint 1 onward expects.

**D. Convert `core/`.**
- `core/middleware/` → keep the folder, but its contents (once Sprint 1 builds them) will be `NestMiddleware` classes, `Guard`s, `Pipe`s, `Interceptor`s, and `Filter`s per `arise_flutter.md` rule 11 — not raw Express middleware functions. No code exists yet to convert; just confirm the folder is present and, if bootstrap left a placeholder Express middleware stub in here, remove it.
- `core/rpg-engine.ts`, `core/reward-cascade.ts`, `core/errors.ts` are framework-agnostic pure TypeScript and need no changes — confirm they don't import anything from `express`.

**E. Dev infra.**
- `docker-compose.yml`: update the backend service's start command if it referenced a raw Express entrypoint (e.g. `node dist/server.js`) to the Nest build output (`node dist/main.js`, or `nest start` for dev). Postgres 16 / Redis 7 services are unaffected.
- `.env.example`: unaffected by this migration — confirm it still matches §15.4's authoritative variable list; do not add or remove variables as part of this session.
- Confirm ESLint/Prettier config still applies cleanly to Nest's decorator-heavy syntax (Nest's default ESLint config is a reasonable base if the existing config conflicts — flag it rather than silently overriding project lint rules).

**F. Write the migration completion note.**
Append a short note to `docs/sprint-tracking/sprint-0-migration.md` (new file, same spirit as a sprint ledger entry): what was converted, what was deleted, any flagged assumption (e.g. if bootstrap's scaffold had already drifted from `00-bootstrap.md`'s spec in some way you had to reconcile). This is what Sprint 1's `sprint-orchestrator` should be able to skim to confirm the scaffold it's inheriting is Nest-shaped, without reading this session's full transcript.

============================================================
DO NOT
============================================================
- Implement any auth, character, quest, boss, gate, AI, or supporting-system business logic — that still starts in Sprint 1.
- Rewrite `docs/adr/0001-scope-and-doc-reconciliation.md` — it's a historical record; ADR 0002 already supersedes it on the framework point.
- Switch the Nest platform adapter to Fastify — ADR 0002 specifies the Express adapter.
- Replace Zod with `class-validator` in `validation/` — ADR 0002 keeps Zod, wrapped in a Nest `ValidationPipe`.
- Add, remove, or rename any `.env.example` variable, database table, or module beyond what's needed to change the routing/DI mechanism.
- Leave two competing HTTP entrypoints (an old Express one and the new `main.ts`) in the repo at the end of this session.

============================================================
DEFINITION OF DONE
============================================================
- [ ] `@nestjs/*` dependencies installed; `nest-cli.json` and `tsconfig.json` configured
- [ ] `backend/src/main.ts` and `backend/src/app.module.ts` exist and are the only HTTP entrypoint; old Express bootstrap file removed
- [ ] Every module under `src/modules/` has a `<module>.module.ts`; no module has a `routes/` folder
- [ ] `core/middleware/` confirmed framework-appropriate (empty or Nest-shaped, no raw Express middleware stubs)
- [ ] `core/rpg-engine.ts` / `core/reward-cascade.ts` / `core/errors.ts` confirmed to have zero `express` imports
- [ ] `docker-compose.yml` start command updated to the Nest build output
- [ ] Project builds clean (`nest build`), lints clean, and boots (`app.listen` succeeds against local Postgres/Redis)
- [ ] `docs/sprint-tracking/sprint-0-migration.md` written
- [ ] Nothing beyond scaffolding/tooling has been implemented — grep confirms no new business logic was added

Stop here. Sprint 1 starts in a fresh session, loading only the patched `arise_flutter.md` + the Sprint 1 excerpt of `SPRINT_PLAN.md` + this migration's completion note — not this session's transcript.
