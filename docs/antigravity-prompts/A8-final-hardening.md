You are executing ARISE SPRINT A8 — Final MVP Hardening, Security & Release Audit. This is a FRESH Antigravity session. Do not carry over A7's conversation history — load artifacts, not transcripts.

This is the final sprint. No new features.

The SRS's quality strategy calls for real Postgres integration tests, API contract validation, AI schema validation, and load testing before production.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A7.md` (A7 handoff digest) and the full set of A0–A7 handoff digests
4. From `ARISE_SRS.md`: Section 16 Testing & Quality Strategy (full), Section 12 NFRs (full), Section 13 Security Architecture (full), Section 19 Acceptance Criteria (all), Section 5.3 DDL (for migration/index/constraint verification), Section 15.4 environment configuration. Do not load the entire SRS.
5. The generated backend (full) and the Flutter client (full)

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. BACKEND / DATABASE
============================================================
Verify against the SRS quality strategy:

- PostgreSQL persistence
- migrations
- indexes
- foreign keys
- transactions
- ownership isolation
- no accidental in-memory production repositories

============================================================
2. FLUTTER
============================================================
Search the entire Flutter project for:

- `InMemory`
- `TODO`
- `FIXME`
- `mock`
- `fake`
- `hardcoded quest`
- `defaultPlayer`
- `static progression`
- `placeholder repository`

Classify every remaining occurrence.

No critical production path may depend on an in-memory implementation.

============================================================
3. NETWORK
============================================================
Verify:

- no hardcoded localhost production endpoint
- timeout handling
- refresh handling
- 401 handling
- error mapping
- retry safety
- idempotency

============================================================
4. OFFLINE
============================================================
Physically test:

- airplane mode
- app kill
- app restart
- reconnect
- duplicate sync
- failed sync
- retry

============================================================
5. SECURITY ATTACKS
============================================================
Attempt:

- arbitrary XP
- arbitrary level
- arbitrary Mana
- arbitrary Energy
- arbitrary Boss HP
- another user's entity ID
- another user's userId
- replayed operation
- cross-account idempotency
- expired token
- refresh token replay
- AI quota manipulation
- premium entitlement manipulation

Every protected attack must fail.

============================================================
6. UI REGRESSION
============================================================
Review every existing screen for:

- overflow
- loading
- empty
- error
- offline
- sync status

============================================================
DEFINITION OF DONE
============================================================
- [ ] Database verified: migrations, indexes, foreign keys, transactions, ownership isolation; no accidental in-memory production repositories
- [ ] Flutter sweep complete; every `InMemory`/`TODO`/`FIXME`/`mock`/`fake`/`hardcoded`/`defaultPlayer`/`static progression`/`placeholder repository` occurrence classified; no critical production path depends on in-memory implementations
- [ ] Network verification passed: no hardcoded localhost endpoint, timeouts/refresh/401/error-mapping/retry/idempotency handled
- [ ] Offline physical test matrix passed (airplane mode, kill, restart, reconnect, duplicate sync, failed sync, retry)
- [ ] All security attacks in section 5 fail with the correct response
- [ ] UI regression review passed across all screens
- [ ] Postgres integration tests, API contract validation, AI schema validation, and load testing run per SRS §16
- [ ] Final handoff written at `docs/sprint-tracking/integration-A8.md`; MVP release readiness confirmed

STOP. This completes the A0–A8 integration program.