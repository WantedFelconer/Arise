# Sprint 1 Tracking Ledger — Secure Foundation

**Sprint Goal:** Secure authentication, multi-tenant query isolation, centralized RPG Engine with append-only ledger transactions, generalized idempotency replay mechanism, full Prisma DDL, NestJS security primitives, and Flutter integration skeleton.

---

## Ticket Ledger

| Ticket | Module / Component | Status | Assignee | Summary |
|---|---|---|---|---|
| 1 | Backend Infra & Config | `done` | `module-builder` | Config-driven constants (`xp_levels.json`, `rank_thresholds.json`, `circadian_curves.json`, `difficulty_modes.json`), Zod environment validation, structured Winston logger with secret redaction. |
| 2 | Full Prisma Schema & DDL Migration | `done` | `module-builder` | Authoritative PostgreSQL schema with all 26 tables, relations, compound unique constraints, and indexes across all 5 sprints per §5.3. |
| 3 | Shared Security & HTTP NestJS Primitives | `done` | `module-builder` | `JwtTokenService` (RS256 keypair generation/verification), `JwtAuthGuard`, `RateLimitGuard`, `RequestIdMiddleware`, `LoggingInterceptor`, `ZodValidationPipe`, and uniform `GlobalExceptionFilter`. |
| 4 | Auth Module (`modules/auth`) | `done` | `module-builder` | Argon2id password hashing, RS256 JWT tokens, single-use rotating refresh tokens with **AC-AUTH-004 reuse detection session revocation**, transactional onboarding. |
| 5 | Core RPG Engine & Character Module | `done` | `module-builder` | Centralized `core/rpg-engine.ts` (Level math, Stat scaling, Config-driven Rank thresholds, XP formulas, Mana clamping, Energy curves) & Character module with strict ledger-first transactions. |
| 6 | Sync Foundation & Idempotency Engine | `done` | `module-builder` | Generalized `(user_id, idempotency_key)` execution engine guaranteeing replay safety and zero duplicate reward execution. |
| 7 | API Contract & Integration Test Suite | `done` | `module-builder` | 42 unit and integration tests across 21 test suites verifying auth lifecycle, reuse revocation, multi-tenant isolation, RPG formulas, and idempotency replay. 100% pass rate. |
| 8 | Flutter Integration Skeleton | `done` | `module-builder` | Clean architecture client-side skeleton: `ApiClient` with Bearer auth and Idempotency-Key headers, `TokenStorage`, `OfflineCommandQueue`, and auth/character remote data sources. |
| 9 | Integration Review & Sprint Handoff | `done` | `integration-reviewer` | Boundary isolation audit passed, anti-cheat audit passed, AC checklist verified with test evidence, generated `sprint-1-handoff.md`. |

---

## Module Completion Notes & Flagged Assumptions
- **RS256 Key Management**: In dev and test environments, `JwtTokenService` automatically derives an ephemeral 2048-bit RSA keypair if `JWT_PRIVATE_KEY` and `JWT_PUBLIC_KEY` are not set in environment variables. In production, these are loaded from secure env vars.
- **In-Memory Test DB**: Unit and integration test fixtures utilize a shared in-memory database store (`backend/src/db/memory/memory-db.ts`) allowing completely isolated, sub-second test execution without requiring an active PostgreSQL daemon.
- **Strict Anti-Cheat Rule**: No client-submitted progression values (`total_xp`, `level`, `current_mana`, `rank`, `stats`) are accepted by any controller. All awards compute authoritatively in `CharacterService` via `RpgEngine`.
