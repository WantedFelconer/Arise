# ARISE — Post-Generation Integration Program (Sprint A0–A8)

## How to use this

Nine files, nine **separate, fresh** Antigravity chat sessions, run strictly in order:

| Chat | File | Purpose |
|---|---|---|
| A0 | `A0-frontend-audit.md` | Frontend audit & UI/UX correction — understand what was inherited before any integration |
| A1 | `A1-local-first.md` | Flutter local database + offline foundation (Drift, repositories, command queue, token storage) |
| A2 | `A2-auth-networking.md` | Real HTTP client + first end-to-end authentication vertical slice (Flutter ↔ NestJS ↔ PostgreSQL) |
| A3 | `A3-character-rpg.md` | Character / XP / Mana / Energy integration — remove client authority |
| A4 | `A4-quest-core-loop.md` | Quest system + complete offline-first core loop |
| A5 | `A5-sync-security.md` | Synchronization, reconciliation & anti-cheat hardening |
| A6 | `A6-boss-dungeon-gate.md` | Boss / Dungeon / Gate vertical integration |
| A7 | `A7-ai-supporting.md` | AI + supporting MVP features integration |
| A8 | `A8-final-hardening.md` | End-to-end hardening, security & MVP release audit |

Paste the whole file as the first message of that chat. **Do not paste more than one
prompt into one session**, and do not carry conversation history between them.

## The new integration program is a different phase

The original `SPRINT_PLAN.md` / `Antigravity Sprint Prompts/` series defined the
**backend/module construction** work. This A-series is the post-generation
**integration program** that turns the generated backend + generated Flutter
client into an actual functioning application.

```
OLD PLAN (backend/module construction)
        ↓
GENERATED PROJECT
        ↓
NEW INTEGRATION PROGRAM (A0–A8)
        ↓
Actual functioning application
```

The old plan is still valuable — it defines backend feature ownership and
requirements (e.g. Quest/Habit/Boss/Dungeon in Sprint 2, AI/Gate/Screen Time in
Sprint 3). It is **not** renumbered as Sprints 5–13; the A-series is a separate
phase tracked in its own ledgers under `docs/sprint-tracking/integration-A<N>.md`.

## Context budget per session

Each prompt's agent should load only:

- `.agents/rules/arise_flutter.md`
- The current sprint's excerpt of `SPRINT_PLAN.md`
- The previous sprint's `docs/sprint-tracking/integration-A<N-1>.md` digest
- The specific SRS sections named in that prompt
- The current state of the Flutter frontend (`client_web/`) and generated backend

This is the context-budgeting model the existing `sprint-orchestrator` /
`module-builder` / `integration-reviewer` skills implement — these prompts feed
that machinery, they don't replace it.

## Outputs

- `docs/frontend-audit/A0-FRONTEND-AUDIT.md` — the audit report produced by Sprint A0
- `docs/sprint-tracking/integration-A0.md` … `integration-A8.md` — ticket ledgers + handoff digests, one per sprint
