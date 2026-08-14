You are executing ARISE SPRINT A5 — Synchronization, Reconciliation & Anti-Cheat. This is a FRESH Antigravity session. Do not carry over A4's conversation history — load artifacts, not transcripts.

This sprint is about trust. The rules explicitly say the backend must recompute protected progression from raw events rather than trusting client final values.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md` — in particular the Offline-First Authority Contract in §6
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A4.md` (A4 handoff digest)
4. From `ARISE_SRS.md`: NFR-008, Section 13 Security Architecture (full), Section 17.3 Non-Negotiable Rules, Section 19 Acceptance Criteria (relevant ACs), Section 12 any sync/reconciliation NFRs. Do not load the entire SRS.
5. The current Flutter sync layer (`OfflineCommandQueue` / persistent command queue from A1), sync engine, and repositories
6. The generated backend sync/idempotency module and reward cascade — for reconciliation-relevant contracts

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. SYNCING
============================================================
Harden the command-based sync engine:

```
AUTHENTICATED COMMAND QUEUE
 ↓
SYNCING
 ↓
BACKEND VALIDATION
```

Persist the state. Every command's state transitions must be durable across app restarts (established in A1; verify and complete here).

============================================================
2. IDEMPOTENCY
============================================================
Every mutation that can be retried must have an idempotency key.

Prove:

```
same command
same key
multiple submissions
```

= one logical mutation.

Ensure idempotency is scoped correctly to the authenticated user.

A key from User A must not be reusable by User B.

============================================================
3. OWNERSHIP SECURITY
============================================================
Never trust client-supplied:

- userId
- accountId
- ownerId

Derive ownership from the authenticated principal.

Test:

- User A modifies User B's quest

Expected: 403/404 according to the API security policy.

============================================================
4. TAMPER TESTS
============================================================
Attempt:

- set XP to 999999
- set Level to 100
- set Mana to 999999
- set Energy to 999999
- set Boss HP to 0
- grant premium
- grant AI quota
- modify another user's entity
- reuse another user's operation

All must fail.

============================================================
5. RECONCILIATION
============================================================
Implement a deterministic reconciliation strategy.

When local state differs from authoritative server state:

- server wins for protected state
- the UI must converge to server state
- do not silently keep a locally modified authoritative value

Simple editable fields (title, description, tags) may use last-write-wins per §6 of the rules; reward-bearing operations never do.

============================================================
6. CONFLICTS
============================================================
Implement the SRS-defined conflict policy for the MVP entities.

Document:

- last-write behavior where applicable
- command ordering
- rejected commands
- stale entities
- tombstones/deletions
- retries

============================================================
DEFINITION OF DONE
============================================================
- [ ] Sync engine hardens command state persistence and durable ordering
- [ ] Idempotency proven: same command + same key + multiple submissions = one mutation; cross-user key reuse fails
- [ ] No client-supplied userId/accountId/ownerId is trusted anywhere in the client path
- [ ] Tamper test matrix (section 4) runs and all attempts fail
- [ ] Deterministic reconciliation implemented: server wins for protected state; UI converges
- [ ] Conflict policy documented per section 6
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A5.md` handoff written for Sprint A6

Stop here. Sprint A6 starts in a fresh session.