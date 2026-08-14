# Sprint 2 Tracking Ledger — Core Productivity Loop

**Sprint Goal:** Quest lifecycle and nesting, Boss projects and damage mechanics, Dungeons grouping, Gate focus sessions with anti-tamper stability, atomic and idempotent Reward Cascade transaction, Achievement trigger hook, and full AC verification.

---

## Ticket Ledger

| Ticket | Module / Component | Status | Assignee | Summary |
|---|---|---|---|---|
| 1 | Quests Module (`modules/quests`) | `done` | `module-builder` | MVP subset: state machine (§7.1), nesting & parent auto-complete (FR-QST-003), RRULE recurrence (FR-QST-005), archive/restore (FR-QST-007), search/filter/sort (FR-QST-008), 10s undo (FR-QST-018), hardcore deadline penalty (FR-QST-013). |
| 2 | Bosses Module (`modules/bosses`) | `done` | `module-builder` | Boss lifecycle (§7.3), config-driven damage matrix, defeat rewards, multi-boss support, boss defeat history with time-to-defeat. |
| 3 | Dungeons Module (`modules/dungeons`) | `done` | `module-builder` | Boss container (FR-DUNG-001), progress % calculation (FR-DUNG-002), auto-complete on all child bosses defeated (FR-DUNG-003). |
| 4 | Gates Focus Module (`modules/gates`) | `done` | `module-builder` | Focus sessions, anti-tamper server duration calculation (FR-GATE-008), stability growth, casual vs hardcore pause rules (FR-GATE-006), stats (FR-GATE-007). |
| 5 | Centralized Reward Cascade (`core/reward-cascade.ts`) | `done` | `module-builder` | Single atomic DB transaction, idempotent per quest/gate ID, executes full §8.4 cascade flow with 409 Conflict replay protection. |
| 6 | Achievements Trigger Hook (`modules/achievements`) | `done` | `module-builder` | Machine-evaluable criteria evaluator hook, notifications logging, unlock bonus XP side effects. |
| 7 | Sync Extension & Idempotency Integration | `done` | `module-builder` | Idempotency-Key support on quest complete/create and gate session actions, enforced query-level tenant isolation. |
| 8 | Integration Review & Sprint 2 Handoff | `done` | `integration-reviewer` | Verified literal AC-QST-011 and AC-GATE-005, boundary audit passed, generated `sprint-2-handoff.md`. |

---

## Module Completion Notes & Flagged Assumptions

### Quests Module (`modules/quests`)
- Built repository, service, controller, DTOs, Zod schema, and README.
- Implemented full §7.1 state machine (`pending -> in_progress -> completed/archived/failed/trashed`).
- Implemented parent quest auto-completion upon all subquests completed (FR-QST-003).
- Implemented RRULE recurrence spawning next scheduled instance with propagated metadata (FR-QST-005).
- Implemented 10-second in-memory undo buffer for deletions and completions (FR-QST-018).
- Implemented hardcore deadline miss Mana penalty via centralized config and RPG engine (FR-QST-013).

### Bosses Module (`modules/bosses`)
- Built repository, service, controller, DTOs, Zod schema, and README.
- Implemented boss lifecycle (`active -> defeated`, `active -> abandoned -> active`).
- Linked to centralized config damage table (`config/boss_damage_table.json`).
- Implemented HP recovery for hardcore mode gate collapse / deadline miss.
- Defeat history returns completed quest count and exact `timeToDefeatMs`.

### Dungeons Module (`modules/dungeons`)
- Built repository, service, controller, DTOs, Zod schema, and README.
- Enforces multi-boss grouping and computed progress percentage: `floor((defeated / total) * 100)`.
- Auto-completes dungeon when all child bosses are defeated (FR-DUNG-003).

### Gates Focus Module (`modules/gates`)
- Built repository, service, controller, DTOs, Zod schema, and README.
- Server-authoritative anti-tamper stability and duration calculator (FR-GATE-008). Never accepts client-side timer value for progression calculation.
- Casual mode allows 1 pause (`pauseCount >= 1` rejects subsequent pauses). Hardcore mode strictly disallows pauses (`HARDCORE_PAUSE_DISALLOWED`).
- Expedition statistics return total sessions, total cleared, total collapsed, success rate %, and longest expedition duration.

### Centralized Reward Cascade (`core/reward-cascade.ts`)
- Implemented centralized atomic reward flow executing XP/Mana ledger modifications, boss damage, parent auto-completion, recurrence spawning, and achievement evaluations.
- Enforces §17.3 Rule 5 / AC-QST-011: duplicate non-idempotent complete calls throw `409 Conflict` (`QUEST_ALREADY_COMPLETED`).
- Replay with `Idempotency-Key` returns original cached 200 response with zero duplicate mutations.

### Achievements Module (`modules/achievements`)
- Built repository, service, controller, DTOs, Zod schema, and README.
- Implements criteria evaluator for `quest_complete`, `gate_clear`, `boss_defeat` events.
- Emits unlock notification and awards bonus XP through `CharacterService`.
