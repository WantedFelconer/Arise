You are executing ARISE SPRINT A4 — Quest System + Complete Offline-First Core Loop. This is a FRESH Antigravity session. Do not carry over A3's conversation history — load artifacts, not transcripts.

This is the most important MVP sprint. At the end of this sprint, you should have a real task manager. Not a prototype.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A3.md` (A3 handoff digest)
4. From `ARISE_SRS.md`, only: Section 6.3 (FR-QST-001 … FR-QST-009, MVP subset), Section 7 Quest state machine, Section 8.4 reward-cascade sequence, Section 11 Screen ↔ API Mapping (quest screens), NFR-008, Section 17.3 rules. Do not load the entire SRS.
5. The current Flutter quest UI and quest repositories (`InMemoryQuestRepository` etc.)
6. The generated backend quests module — for the exact API contracts

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. TARGET FLOW
============================================================
Create and prove:

```
CAPTURE
 ↓
LOCAL QUEST
 ↓
VIEW
 ↓
COMPLETE
 ↓
LOCAL OPTIMISTIC UPDATE
 ↓
PERSISTED COMMAND
 ↓
SYNC
 ↓
BACKEND VALIDATION
 ↓
REWARD CASCADE
 ↓
XP/Mana/Boss/etc.
 ↓
AUTHORITATIVE RESPONSE
 ↓
LOCAL RECONCILIATION
```

============================================================
2. QUEST DATA
============================================================
Remove hardcoded production quest lists from Flutter.

The quest screen must load from:

```
Local DB
 ↓
repository
```

with remote synchronization.

============================================================
3. QUEST OPERATIONS
============================================================
Implement actual backend-connected:

- list quests
- create quest
- update quest
- complete quest
- archive
- trash
- restore
- favorite/pin where supported
- dependencies where MVP requires them

Use the actual SRS/API contracts.

============================================================
4. OFFLINE CREATE
============================================================
User creates a quest while offline:

```
Local DB
 ↓
UI immediately shows quest
 ↓
persistent sync command
```

============================================================
5. COMPLETE / REWARD PATH
============================================================
- Completing a quest writes a persistent command with an idempotency key
- Local projection updates optimistically where safe
- The backend validates, runs the reward cascade, and returns the authoritative result
- Local projection reconciles to the server result — the client never assumes a reward it did not receive

============================================================
6. UI STATES
============================================================
Every quest screen must render real states:

- loading
- empty
- error
- offline
- sync status / pending commands

Do not present a locally-queued change as server-confirmed. Surface pending sync explicitly.

Preserve the ARISE visual identity.

============================================================
DEFINITION OF DONE
============================================================
- [ ] No hardcoded production quest lists remain; quests load from local DB via repository with remote sync
- [ ] All listed quest operations connected to the real backend per SRS/API contracts
- [ ] Offline create proven: quest appears instantly in UI from local DB, command persisted
- [ ] Complete/reward path proven end-to-end including local reconciliation to the authoritative response
- [ ] Loading/empty/error/offline/sync states present on quest screens
- [ ] No misleading "success" for a not-yet-synced command
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A4.md` handoff written for Sprint A5

Stop here. Sprint A5 starts in a fresh session.
