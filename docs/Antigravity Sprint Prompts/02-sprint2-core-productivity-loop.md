You are executing ARISE SPRINT 2 — Core Productivity Loop. Fresh Antigravity session.

============================================================
LOAD (and nothing more)
============================================================
1. `.agents/rules/arise_flutter.md`
2. The Sprint 2 row of the corrected coverage table in `SPRINT_PLAN.md`
3. `docs/sprint-tracking/sprint-1-handoff.md`
4. From `ARISE_SRS.md`, only:
   - §6.3 Quest System — **MVP items only**: FR-QST-001, 002, 003, 004, 005, 007, 008, 011, 012, 013, 018. (P2 items **006** dependencies, **009** duplicate, **010** templates, **014** bulk ops, **015** NL input, **016** Inbox, **017** Eisenhower are explicitly OUT of this sprint — see "Backlog" below, do not build them.)
   - §6.4 Boss System (FR-BOSS-001 … 005; FR-BOSS-006 is P2, skip)
   - §6.5 Dungeon System (FR-DUNG-001 … 003, all MVP)
   - §6.6 Gate Focus System (FR-GATE-001 … 008, all MVP)
   - §6.19 Achievements only (FR-ACH-001, FR-ACH-002 — Inventory/FR-INV is Sprint 4)
   - §7.1 Quest Lifecycle, §7.2 Gate Session Lifecycle, §7.3 Boss Lifecycle state diagrams
   - §8.3 Gate Focus Session sequence, §8.4 Quest Completion → Reward Cascade flowchart
   - §9.2 endpoint index: Quests, Bosses/Dungeons, Gate Sessions sections only
   - §17.1 Phase 2 items 5, 6, 7
   - §17.3 rule 5 (idempotent reward cascade)
   - §19 AC for FR-QST-011 (quest completion rewards) and FR-GATE-005 (gate collapse penalty)

Do not load Habit, Inbox, AI, or Screen Time material — none of it belongs to this sprint.

============================================================
EXECUTION MODEL
============================================================
Act as `sprint-orchestrator`. Ticket order:
1. `quests` module (MVP subset)
2. `bosses` module
3. `dungeons` module
4. `gates` module
5. `core/reward-cascade.ts` — built once both Quest and Gate completion need it, so it's genuinely shared, not duplicated
6. `achievements` trigger hook (evaluated from the reward cascade, per §8.4's own flowchart)
7. Sync extension — wire Sprint 1's idempotency mechanism to real quest/gate completion

Dispatch each to `module-builder`. Run `integration-reviewer` only once every ticket in `docs/sprint-tracking/sprint-2.md` is `done`.

============================================================
QUESTS — MVP subset only
============================================================
- Quest types: daily, main, side, recurring, boss_quest, ai_generated (**FR-QST-001**) — `ai_generated` is a valid enum value now even though nothing produces it until Sprint 3
- Unlimited nesting via `parent_quest_id` (**FR-QST-002**)
- A parent auto-completes when all non-optional children complete — default behavior, configurable per-quest via `metadata` (**FR-QST-003**)
- Fields: priority, difficulty, deadline, estimated/actual duration, tags, notes, attachments (**FR-QST-004**)
- RRULE-based recurrence: completing a recurring instance spawns the next occurrence (**FR-QST-005**) — this logic lives inside the `quests` module, there is no separate "Recurrence Engine"
- Archive/restore without data loss (**FR-QST-007**)
- Full-text search, filter (status/priority/tag/date range), sort (**FR-QST-008**)
- On completion: award `xp_reward` to the correct `character_stats.stat_key` via `core/rpg-engine`, award `mana_reward`, apply boss damage if `boss_id` set, record `completed_at` (**FR-QST-011**) — this whole sequence is the reward cascade, don't implement it ad hoc inside the quest controller
- Boss-linked completion reduces `bosses.current_hp` by computed damage (**FR-QST-012**)
- Hardcore-mode deadline miss applies a Mana penalty (**FR-QST-013**) — the penalty table itself is config-driven (§17.3 rule 1); Game Modes (casual/hardcore) full wiring is Sprint 4's FR-MODE, but this specific penalty behavior is tagged MVP here, so implement it against a simple `difficulty_mode` check now
- Undo for delete/complete within a 10-second window, soft-delete + reversible transaction (**FR-QST-018**)
- Quest lifecycle is a literal state machine per §7.1 — implement it as one, not as scattered `status` string checks: `pending → in_progress → completed`, `in_progress → pending` (pause/collapse), `pending → failed` (hardcore deadline), `{completed, pending, failed} → archived`, `archived → pending` (restore)

**Backlog (do not build, flag in handoff as deferred to a future P2 sprint):** dependencies (006), duplication (009), templates (010), bulk ops (014), NL input (015), Inbox (016), Eisenhower (017).

============================================================
BOSSES
============================================================
- `max_hp`, `current_hp`, `difficulty`, optional `deadline`, status active/defeated/abandoned (**FR-BOSS-001**)
- Damage on linked quest completion = `base_damage(difficulty, priority) * focus_quality_multiplier`, `base_damage` a **configurable lookup table** (**FR-BOSS-002**) — not hardcoded, per NFR-006
- `current_hp` reaching 0 → `defeated`, `defeated_at` set, `reward_xp`/`reward_coins` granted (**FR-BOSS-003**)
- Multiple concurrent active bosses per user (**FR-BOSS-004**)
- Boss history: defeated bosses, time-to-defeat, quest count (**FR-BOSS-005**)
- Boss lifecycle per §7.3: `active → active` (quest completed, HP reduced), `active → defeated` (HP=0), `active → abandoned`, `abandoned → active` (reactivate)
- FR-BOSS-006 (retroactive quest-group → boss conversion) is P2 — skip.

============================================================
DUNGEONS
============================================================
- Groups multiple Bosses (**FR-DUNG-001**)
- Progress % = defeated bosses / total bosses in dungeon (**FR-DUNG-002**)
- Status → `completed` when all contained bosses are `defeated` (**FR-DUNG-003**)

============================================================
GATES
============================================================
- Starting a session requires optional `quest_id` + `planned_duration_seconds` (**FR-GATE-001**)
- `stability_pct` increases 0→100 monotonically over the planned duration while `active` (**FR-GATE-002**)
- Exit before 100% → `collapsed`; reach 100% and confirm → `cleared` (**FR-GATE-003**)
- On `cleared`: award XP (duration × difficulty multiplier), award Mana, apply boss damage if boss-linked (**FR-GATE-004**)
- On `collapsed`: apply XP/Mana loss per difficulty mode (larger in hardcore); hardcore may also apply partial boss HP recovery at a configurable rate (**FR-GATE-005**) — this is the literal §19 AC:
  - Given an active Gate session in hardcore mode at 40% stability
  - When `POST /gates/{id}/collapse` is called
  - Then `gate_sessions.status == "collapsed"`, a negative `xp_transactions` row and negative `mana_transactions` row exist per the hardcore penalty table, and if boss-linked, boss HP recovery is applied per the configured hardcore recovery rate — test this exactly.
- One pause allowed in casual mode; hardcore disallows pausing entirely (**FR-GATE-006**)
- Statistics: success rate, longest expedition, total cleared, total collapsed (**FR-GATE-007**)
- **Anti-tamper**: the session resumes from server `started_at` + `planned_duration_seconds`, never from a client-side timer alone (**FR-GATE-008**) — this is a security requirement disguised as a UX requirement; get it right, since a client-side-only timer is trivially exploitable to fake session duration for XP.
- Gate lifecycle per §7.2: `active → paused` (casual only) → `active`, `active → cleared`, `active → collapsed`.

============================================================
REWARD CASCADE — `core/reward-cascade.ts`
============================================================
This is, per §17.1, "the single most important piece of business logic in the system." One atomic, well-tested function, reused by both the quest-complete path and the gate-complete path. Implement it exactly per the §8.4 flowchart:

```
quest/gate marked complete
  → linked to boss? → yes: compute + apply boss damage
                        boss HP <= 0? → yes: boss → defeated, grant boss rewards
  → award XP to stat + Mana (via core/rpg-engine)
  → all sibling quests complete? → yes: auto-complete parent quest
  → achievement criteria met? → yes: unlock achievement + notify
  → push completion notification / update analytics rollup hook (rollup itself is Sprint 4 — just leave the hook point)
```

Non-negotiable properties:
- **Single DB transaction** — no partial XP/Mana/boss-damage states, ever (NFR-005)
- **Idempotent per quest/gate-session id** — completing the same quest twice must not double-award (§17.3 rule 5). This is FR-QST-011's literal §19 AC:
  - Given a pending quest with `xp_reward=50`, `mana_reward=5`, linked to an active boss at `current_hp=200`
  - When `POST /quests/{id}/complete` is called
  - Then 200, `quest.status == "completed"`, an `xp_transactions` row of +50 exists, a `mana_transactions` row of +5 exists, `bosses.current_hp` reduced by computed damage
  - And calling the same endpoint again returns **409** and creates **no duplicate ledger rows**
  - Write this exact test.
- Wire this to Sprint 1's idempotency-key mechanism — the reward cascade IS the primary consumer that mechanism was built for.

============================================================
ACHIEVEMENTS (trigger hook only)
============================================================
- Criteria are machine-evaluable rules in `achievements.criteria` JSONB, evaluated on relevant events: quest complete, gate clear, streak-related (**FR-ACH-001**) — since Habits/streaks aren't built yet, implement the evaluator against quest/gate events only this sprint; streak-based criteria become live once Sprint 4's statistics/streak tracking exists, but the evaluator's interface should already accept a generic "criteria met?" check so it isn't rewritten later
- Unlocking generates a `notifications` row, and a `user_inventory` row if the achievement grants an item (**FR-ACH-002**) — Notifications module itself is built properly in Sprint 4; this sprint just needs the DB row created correctly, not push delivery

============================================================
TESTING (per §16)
============================================================
- Quest state machine transitions (all edges in §7.1, including invalid-transition rejection)
- Quest ownership isolation
- Reward cascade: the exact duplicate-completion AC above, boss-defeat-on-zero-HP, parent-auto-complete-on-all-children-done
- Gate lifecycle: cleared path, collapsed path (the exact hardcore AC above), pause/resume in casual, pause rejection in hardcore
- Gate anti-tamper: session duration computed from `started_at`, not trusted from client-submitted elapsed time
- Boss HP transitions, dungeon progress %, dungeon auto-complete
- Two rapid completion requests for the same quest/gate session → exactly one reward, second returns 409
- Real Postgres test container for all transactional tests

============================================================
DO NOT
============================================================
- Build Habits, Inbox, dependencies, templates, bulk ops, NL input, or Eisenhower — all explicitly P2/backlog this sprint
- Build any AI, Screen Time, Reminders, or Notification-delivery logic
- Let the quest or gate controller compute XP/Mana/damage inline — route through `core/rpg-engine` and `core/reward-cascade` only
- Accept a client-submitted final `current_hp`, `xp`, `mana`, or `stability_pct` value anywhere

============================================================
DEFINITION OF DONE
============================================================
- [ ] Quest MVP subset implemented, lifecycle matches §7.1 exactly, P2 items explicitly deferred (not silently dropped — named in handoff)
- [ ] Boss lifecycle matches §7.3, damage table config-driven
- [ ] Dungeon progress/completion correct
- [ ] Gate lifecycle matches §7.2, anti-tamper duration resume verified
- [ ] `core/reward-cascade.ts` exists, atomic, idempotent, passes both literal §19 ACs (FR-QST-011 duplicate-completion, FR-GATE-005 hardcore collapse)
- [ ] Achievement trigger hook fires on quest/gate events
- [ ] All new mutating endpoints wired to Sprint 1's idempotency-key mechanism
- [ ] `integration-reviewer` boundary + anti-cheat audit passes (no module reaches into another's repository; no protected value accepted from client)
- [ ] `docs/sprint-tracking/sprint-2-handoff.md` written — public API of quests/bosses/dungeons/gates, reward-cascade signature, achievement evaluator interface, explicit backlog list (dependencies/templates/Inbox/etc.), known gaps

Stop here. Sprint 3 starts fresh, loading only patched rules + its own SRS excerpt + this handoff.
