You are executing ARISE SPRINT A3 — Character / XP / Mana / Energy Integration. This is a FRESH Antigravity session. Do not carry over A2's conversation history — load artifacts, not transcripts.

============================================================
GOAL
============================================================
Connect the RPG state. This is where we eliminate `PlayerData.defaultPlayer` and frontend-side XP calculations.

Architecture to achieve:

```
Flutter Character UI
      ↕
Local persistent projection
      ↕
Sync layer
      ↕
NestJS Character/RPG APIs
      ↕
PostgreSQL
```

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A2.md` (A2 handoff digest)
4. From `ARISE_SRS.md`, only: Section 6.2 (FR-CHAR-001 … FR-CHAR-005), Section 6.7 (FR-XP-001 … FR-XP-003), Section 6.8 (FR-MANA-001 … FR-MANA-004), Section 6.9 (FR-ENERGY-001 … FR-ENERGY-003), Section 7 State Machines (character-relevant), Section 11 Screen ↔ API Mapping (character screens), Section 17.3 Non-Negotiable Rules. Do not load the entire SRS.
5. The current Flutter repository — especially `PlayerData`, `PlayerNotifier`, and any local `addExp()` / stat mutation logic
6. The generated backend character module and `core/rpg-engine.ts` — for the exact public API contracts

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. REMOVE CLIENT AUTHORITY
============================================================
The Flutter client MUST NOT calculate authoritative:

- XP
- Level
- Rank
- Mana
- Energy
- Boss HP
- achievement unlocks

Remove/refactor client methods such as:

- `addExp()`
- direct authoritative level mutation
- direct authoritative Mana mutation

The UI may calculate presentation-only values (e.g. visual progress percentages derived from already-authoritative values), but never the authoritative numbers themselves.

The current `PlayerNotifier` is explicitly doing local `addExp()` and stat mutation — this is precisely what must disappear.

============================================================
2. CHARACTER LOAD
============================================================
On authentication:

1. fetch authoritative character state
2. persist it locally
3. render from the local projection

============================================================
3. OFFLINE
============================================================
When an allowed user action affects progression:

1. record the raw domain command locally
2. update local projection optimistically where safe
3. queue command
4. synchronize later
5. accept server authoritative result
6. reconcile local projection

Do NOT synchronize:

```
"set XP = 5000"
```

Instead synchronize the underlying valid action/event (e.g. the quest/gate action that legitimately earns the XP).

============================================================
4. XP LEDGER
============================================================
Ensure the frontend understands that XP changes are transaction-based.

Display state from the authoritative projection.

Do not duplicate RPG formulas in Dart.

============================================================
5. MANA / ENERGY
============================================================
Integrate the backend values. Make sure:

- current values
- maximum values
- regeneration/display information
- transaction effects

are consistent with the backend contracts.

============================================================
6. UI
============================================================
- Update the character/status screens to render from the local projection
- Show loading / error / offline / sync states where the local projection is unavailable or stale
- Preserve the ARISE visual identity
- Remove `PlayerData.defaultPlayer` from production paths — no static progression on a primary path

============================================================
DEFINITION OF DONE
============================================================
- [ ] No authoritative XP/Level/Rank/Mana/Energy/Boss HP calculation remains in Dart
- [ ] `addExp()` and direct authoritative mutations removed/refactored; presentation-only calculations remain explicitly marked
- [ ] Character loads from backend on auth, persists locally, renders from local projection
- [ ] Offline progression path: raw command → optimistic projection → queue → sync → authoritative result → reconcile
- [ ] Client synchronizes actions/events, never `SET_XP`-style final values
- [ ] Mana/energy display matches backend contracts (current, max, regen, transaction effects)
- [ ] `PlayerData.defaultPlayer` gone from production paths
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A3.md` handoff written for Sprint A4

Stop here. Sprint A4 starts in a fresh session.
