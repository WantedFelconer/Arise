You are executing ARISE SPRINT A1 — Flutter Local Database + Offline Foundation. This is a FRESH Antigravity session. Do not carry over A0's conversation history — load artifacts, not transcripts.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A0.md` (A0 handoff digest — including the audit findings `docs/frontend-audit/A0-FRONTEND-AUDIT.md` that apply to data persistence)
4. `ARISE_SRS.md` — only: Section 5 Data Model (relevant tables), Section 11 Screen ↔ API Mapping, NFR-008, and the offline-first-relevant FR items. Do not load the entire SRS.
5. The current Flutter repository (the real source under `client_web/`)
6. The generated backend only for domain/entity contract inspection

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. GOAL
============================================================
Build the real offline client. This is the most important missing frontend infrastructure.

Recommended stack: **Drift + SQLite** unless a justified existing dependency is preferable. Justify the choice in the ticket summary.

============================================================
2. PERSISTENT REPOSITORY IMPLEMENTATIONS
============================================================
Replace the current in-memory implementations with persistent implementations. Use:

```
Repository interface
    ↓
Local data source
    +
Remote data source
```

Do not let UI access Drift directly.

============================================================
3. LAYERING
============================================================
- `domain/` defines repository interfaces and domain entities only — no Drift, no HTTP imports
- `infrastructure/` provides the Drift-backed local data source and (later) the remote data source
- `application/` (use cases) selects the data source
- `presentation/` consumes repositories through application use cases only

The global rule already requires `presentation → application → domain ← infrastructure` and prohibits `domain/` from directly importing HTTP/database code. Verify the existing code obeys this; fix violations as part of this sprint.

============================================================
4. PERSISTENT COMMAND QUEUE
============================================================
Replace the current in-memory `OfflineCommandQueue`.

Every user mutation that needs server synchronization must create a persistent command containing at minimum:

- local command ID
- idempotency key
- authenticated user context
- command type
- validated payload
- createdAt
- retry count
- status
- last error
- ordering metadata if required

The queue must survive app restart.

============================================================
5. LOCAL-FIRST WRITE RULE
============================================================
For a normal user interaction:

```
UI
 ↓
Application command
 ↓
Local DB transaction
 ↓
UI immediately reflects change
 ↓
Sync engine asynchronously sends command
```

Never:

```
UI
 ↓
wait for network
 ↓
update UI
```

unless the SRS explicitly defines an operation as server-gated.

============================================================
6. LOCAL DATA RECONCILIATION FOUNDATION
============================================================
Implement the infrastructure required for:

- optimistic local state
- server authoritative state
- reconciliation
- failed commands
- retry
- rollback/compensation where necessary

Do not implement the full conflict-resolution policy for every entity yet. Build the reusable foundation.

============================================================
7. TOKEN STORAGE
============================================================
Replace `InMemoryTokenStorage` with secure persistent storage.

Use an appropriate Flutter secure storage mechanism.

Access and refresh tokens must survive normal app restarts securely.

Do not store secrets in:

- SharedPreferences
- plain SQLite

============================================================
DEFINITION OF DONE
============================================================
- [ ] Drift (or justified equivalent) database schema created, mirrors backend entity shapes relevant to the MVP client
- [ ] Repository interfaces in `domain/`; Drift-backed implementations in `infrastructure/`; UI never touches Drift directly
- [ ] All `InMemory*Repository` replacements live behind the same interfaces the UI already consumes, so A2+ can swap remote sources without UI changes
- [ ] Persistent command queue survives app restart with all required fields and status lifecycle
- [ ] Local-first write rule demonstrable on at least one real screen (UI updates from local DB before any network)
- [ ] Reconciliation foundation (optimistic state, server-authoritative state, retry, rollback/compensation primitives) exists as reusable infrastructure
- [ ] Tokens stored via secure mechanism; `InMemoryTokenStorage` removed from production path
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A1.md` handoff written for Sprint A2

Stop here. Sprint A2 starts in a fresh session.
