You are executing ARISE SPRINT 1 — Secure Foundation. This is a FRESH Antigravity session. Do not carry over Chat 0's conversation history — load artifacts, not transcripts.

============================================================
LOAD (and nothing more)
============================================================
1. `.agents/rules/arise_flutter.md` (patched — includes §6 Offline-First Authority Contract)
2. The Sprint 1 row of the corrected coverage table in `SPRINT_PLAN.md`
3. From `ARISE_SRS.md`, only:
   - §5 Data Model (5.1 ERD, 5.2 principles, 5.3 full DDL)
   - §6.1 Authentication & User Management (FR-AUTH-001 … FR-AUTH-010)
   - §6.2 Character System (FR-CHAR-001 … FR-CHAR-005)
   - §6.7 XP System (FR-XP-001 … FR-XP-003)
   - §6.8 Mana System (FR-MANA-001 … FR-MANA-004)
   - §6.9 Energy System (FR-ENERGY-001 … FR-ENERGY-003)
   - §8.1 Authentication sequence diagram
   - §12 NFR-003, NFR-004, NFR-005, NFR-006, NFR-008, NFR-012
   - §13 Security Architecture (full)
   - §15.4 Environment Variables (authoritative list)
   - §17.1 Phase 1 (full) and Phase 2 item 4 only
   - §17.3 Non-Negotiable Implementation Rules (full)
   - §19 AC for FR-AUTH-004 (refresh token reuse detection)
4. ADR 0001 from Chat 0 (for the offline-first generalization rationale)

Do not load the full SRS. If something outside this list turns out to be required, say so explicitly rather than pulling it in silently — that's a planning gap to flag, not a reason to re-ingest the document.

============================================================
EXECUTION MODEL
============================================================
Act as `sprint-orchestrator`. Decompose into module-sized tickets, sequence by dependency, dispatch each to `module-builder`, and run `integration-reviewer` only once every ticket in `docs/sprint-tracking/sprint-1.md` is `done`. Do not implement the sprint as one giant session.

Ticket order (dependency-ordered, not document-ordered):
1. Backend infra/config (env validation, logging, docker-compose already scaffolded in Chat 0 — verify, don't redo)
2. Full Prisma schema + initial migration from §5.3 (all tables — later sprints populate, this sprint creates)
3. Shared HTTP/security cross-cutting concerns as NestJS primitives (Zod validation via a `ValidationPipe`/`nestjs-zod`, `helmet()` + CORS wired in `main.ts`, Redis-backed rate limiting via a `Guard`, structured logging with request id via `Middleware` + an `Interceptor`, per NFR-012)
4. `auth` module
5. `core/rpg-engine.ts` (character + xp + mana + energy — one engine, four concerns)
6. Sync foundation (idempotency-key handling, generalized per Chat 0's ADR)
7. API contract/testing infrastructure
8. Flutter integration skeleton (client-side, thin — auth + token storage + local DB + sync queue plumbing only)

============================================================
SPRINT GOAL
============================================================
By the end of this sprint: a user can register/login/refresh/logout securely; their data is isolated from every other user at the query level; the Character/XP/Mana/Energy engine exists, is unit-tested, and is the *only* place these values are computed; every reward-bearing write is idempotent; nothing built later (Quest, Boss, Gate, AI) will need to touch character state directly — it will call this engine.

============================================================
AUTH — build exactly to §6.1 / §13.1
============================================================
- Registration (email/password, **FR-AUTH-001**), Google + Apple Sign-In (**FR-AUTH-002**)
- Password hashing: **argon2id** preferred, bcrypt cost ≥12 acceptable fallback (§13.1)
- JWT: RS256, access token 15 min, refresh token 30 days, access token payload contains ONLY `userId` and `tokenVersion` (**FR-AUTH-003**, §13.1) — never put role/plan/entitlement claims in the access token that the client could otherwise infer trust from; those are re-checked server-side per request.
- Refresh tokens stored server-side **hashed, never plaintext**, rotated on every use, **single-use** — reuse triggers full session revocation for that user (**FR-AUTH-004**). This is a hard acceptance criterion:
  - Given a refresh token that has already been rotated (used once)
  - When it is submitted again to `POST /auth/refresh`
  - Then the request is rejected 401, **and all active sessions for that user are revoked**
  - Write an integration test that demonstrates this exact scenario — this is §19's literal AC for FR-AUTH-004, not an interpretation.
- Password reset via emailed time-limited token (**FR-AUTH-005**), email verification (**FR-AUTH-006**)
- On first registration, auto-create a `character` row and default `settings` row (**FR-AUTH-007**)
- Capture chronotype + difficulty mode during onboarding → `circadian_profiles` / `users.difficulty_mode` (**FR-AUTH-008**)
- Account deletion: soft-delete all owned rows, purge PII within 30 days (**FR-AUTH-009**) — implement the soft-delete now, the 30-day purge job can be a `jobs/` worker stub wired to real logic in Sprint 4 alongside Settings/data-export
- Multi-device sessions with per-device revocation (**FR-AUTH-010**) — tagged P2 in the SRS; scaffold the `devices` table (already in §5.3) and a revoke-by-device endpoint stub, but don't over-invest here this sprint
- Rate limiting on `/auth/*`, Redis-backed (§13.1 example: 10 attempts / 15 min / IP+email combo)
- Authorization baseline (§13.2): **every** query for any user-owned resource is scoped `user_id = req.auth.userId` at the ORM/query level — never filter after fetch, never trust a client-supplied user id anywhere, in any module, ever. This is the rule every later sprint inherits from this one; get it right here.

============================================================
CORE/RPG-ENGINE — build exactly to §6.2, §6.7, §6.8, §6.9
============================================================
Single module, four responsibilities, one export surface other modules call into. No feature module (not even later sprints') computes XP/Mana/Energy/Level inline — ever.

**Character / Level**
- `level = floor(0.1 * sqrt(total_xp)) + 1` (**FR-CHAR-001**) — exact formula, unit test it against several fixed `total_xp` values including edge cases (0, exactly-on-boundary values)
- 7 independently-levelable stats: intelligence, discipline, fitness, creativity, coding, business, health, each driven by `xp_transactions.stat_key` (**FR-CHAR-002**)
- Rank E→S derived from level via a **configurable** threshold table, default E<10, D<25, C<45, B<70, A<100, S≥100 (**FR-CHAR-003**) — externalize this table to `config/`, not a hardcoded switch (§17.3 rule 1, NFR-006)
- Full XP/Mana transaction history exposed per character (**FR-CHAR-004**)
- Title equipping (**FR-CHAR-005**) — P2, scaffold the field only

**XP**
- Every XP change is written to `xp_transactions` **before** the `characters.total_xp` cache is updated — never the reverse, never a direct mutation (**FR-XP-001**, §17.3 rule 1: "Never mutate `characters.total_xp` / `current_mana` directly from a route handler — always go through the RPG Engine, and always write the ledger row first")
- Award formula factors: base value × difficulty multiplier × (1 + streak bonus) × (1 + focus-quality bonus from Gate stability) (**FR-XP-002**) — the engine should expose this as a pure, testable function even though quest/gate callers don't exist until Sprint 2; write it against fixture inputs now
- Daily/weekly/monthly/lifetime XP aggregates (**FR-XP-003**)

**Mana**
- `current_mana` clamped `[0, max_mana]` on every write, never exceeds or goes negative (**FR-MANA-001**)
- Decrease sources: high-distraction screen time, missed quests, Gate collapse (**FR-MANA-002**) — the engine exposes the mutation primitive now; Screen Time (Sprint 4) and Quest/Gate (Sprint 2) call it later
- Increase sources: completed quests, cleared Gates, logged sleep above threshold, logged exercise (**FR-MANA-003**)
- Expose current Mana for AI Planner/Coach to read (**FR-MANA-004** — the read path only; AI consumption is Sprint 3)

**Energy**
- Hourly Energy curve computed from `circadian_profiles` (early_bird/night_owl/custom) (**FR-ENERGY-001**)
- FR-ENERGY-002/003 (AI scheduling bias, screen-time modulation) are **P2** — expose the curve read function now, leave the consumers for later sprints

**Ledger principle (§5.2, §17.3 rule 1):** `xp_transactions` and `mana_transactions` are append-only. `characters.total_xp` / `current_mana` are cached, always recomputable from the ledger. Every engine mutation method takes a `source_type` + optional `source_id` + `reason` — no anonymous mutations.

============================================================
SYNC FOUNDATION — generalizes NFR-008, per ADR 0001
============================================================
NFR-008 literally requires: client may queue quest actions offline; server accepts an `Idempotency-Key` header to safely replay on reconnect. Build the general mechanism now so Sprint 2's Quest/Gate modules and Sprint 3's AI module have it available on day one:

- Every mutating endpoint that awards XP/Mana/Boss-damage/streak/achievement state accepts an `Idempotency-Key` header (or equivalent request field if the client can't set headers per-operation).
- Store processed keys with enough context to detect a replay and return the original result rather than reprocessing: `(user_id, idempotency_key)` unique constraint, referencing the operation type and its result.
- A replayed key must produce the exact same response as the original call and must not create a second ledger row, second reward, or second side effect. Test this explicitly — call twice, assert one `xp_transactions` row.
- This sprint builds the mechanism and proves it against a stub/dummy protected write (since Quest/Gate don't exist yet); Sprint 2 wires it to real quest/gate completion.
- Reiterate the rule this exists to enforce: the client submits **intent** (a command with an idempotency key), never a final value. There is no endpoint anywhere that accepts `{ xp: <number> }`, `{ level: <number> }`, or similar, and there never will be — flag it as a defect if any later sprint tries to add one.

============================================================
SECURITY — AS NESTJS PRIMITIVES, NOT RAW EXPRESS MIDDLEWARE
============================================================
Per `arise_flutter.md` rule 11: NestJS runs on Express under the hood, but application code talks to Nest's own abstractions, not `(req, res, next)` functions scattered across files.

- **Request body validation**: Zod schemas per `validation/`, applied via a global `ValidationPipe` wrapping Zod (or `nestjs-zod`) so every controller handler receives already-validated input before any business logic runs (§13.4)
- **Rate limiting**: global Redis-backed rate limiting per user/IP implemented as a `Guard` (`@nestjs/throttler` with a Redis storage adapter, or a hand-rolled `RateLimitGuard`), applied globally via `APP_GUARD`; stricter per-route limits reserved for AI endpoints (Sprint 3, but build the shared guard/primitive now so Sprint 3 only needs a stricter config, not a new mechanism)
- **`helmet()` and CORS**: wired directly in `main.ts` (`app.use(helmet())`, `app.enableCors({ origin: <known client origin(s)> })`) — this is the one place raw Express-style setup is expected and correct, since it's Nest's own documented bootstrap pattern
- **Centralized error handling**: a global `ExceptionFilter` (`@Catch()`, registered via `APP_FILTER`), uniform error shape per §9.1 (`{ error: { code, message, details } }`), never leak stack traces or internal detail in production responses
- **Structured JSON logging with a request-tracing ID**: a `NestMiddleware` that attaches/propagates the request id, paired with an `Interceptor` that logs entry/exit (NFR-012) — never log passwords, tokens, or provider secrets
- **Auth/ownership checks** on protected routes: a `Guard` (e.g. `JwtAuthGuard`) that populates `request.auth` from the validated token; every query for a user-owned resource is then scoped `user_id = request.auth.userId` at the ORM/query level inside the service, never filtered after fetch
- TLS is a load-balancer/deployment concern (§13.3) — note it in the module README, don't try to implement it in application code

============================================================
TESTING (per §16)
============================================================
- Unit: level formula, rank thresholds, mana clamping, XP award formula, refresh-token rotation logic, reuse detection — target near-100% coverage on these per §16's own "trust-critical core" framing
- Integration: register → login → refresh → logout, refresh-reuse-revokes-all-sessions (the literal AC above), unauthorized request rejected, user A cannot read/write user B's data, idempotency-key replay produces no duplicate side effect
- Use a real Postgres test container for the transactional/ledger tests, not a mocked DB (§16 table, "Integration" row)

============================================================
DO NOT
============================================================
- Implement Quest, Boss, Dungeon, Gate, AI, Screen Time, or any Sprint 2–5 module
- Build a subscription/payment/premium system
- Accept any client-submitted final value for XP, Level, Mana, Energy, rank, or achievement state
- Skip the refresh-reuse-revokes-all-sessions test — this is the one explicit AC this sprint owns

============================================================
DEFINITION OF DONE
============================================================
- [ ] Auth end-to-end, all FR-AUTH-001–009 implemented (010 scaffolded), tests passing
- [ ] Refresh rotation + reuse detection test passes exactly per the §19 AC
- [ ] Ownership isolation tested (user A / user B)
- [ ] `core/rpg-engine.ts` implements Character/XP/Mana/Energy exactly per FR-CHAR/XP/MANA/ENERGY, formulas unit-tested
- [ ] Ledger-first writes verified — no direct mutation of `characters.total_xp` / `current_mana` anywhere
- [ ] Rank table and XP curve constants live in `config/`, not inline
- [ ] Idempotency-key mechanism built and proven against a stub write
- [ ] Full Prisma schema from §5.3 migrated cleanly from empty DB
- [ ] Security cross-cutting concerns in place as Nest primitives: `ValidationPipe`(Zod), `helmet()`/CORS in `main.ts`, rate-limit `Guard`, request-id `Middleware` + logging `Interceptor`, global `ExceptionFilter` — not hand-rolled Express middleware functions
- [ ] Every module has README + tests per `module-builder` skill
- [ ] `integration-reviewer` has run: boundary audit, anti-cheat audit (confirms nothing accepts client-submitted protected values), AC walkthrough
- [ ] `docs/sprint-tracking/sprint-1-handoff.md` written — engine public methods, auth endpoints, idempotency mechanism contract, known gaps (e.g. FR-AUTH-010 stub, FR-ENERGY-002/003 not consumed yet)

Stop here. Sprint 2 starts in a fresh session, loading only the patched rules + its own SRS excerpt + this handoff digest.
