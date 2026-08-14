You are executing ARISE SPRINT A6 — Boss, Dungeon & Gate Vertical Integration. This is a FRESH Antigravity session. Do not carry over A5's conversation history — load artifacts, not transcripts.

Now the gamification loop becomes real.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A5.md` (A5 handoff digest)
4. From `ARISE_SRS.md`, only: Section 6.4 (FR-BOSS-001 … ), Section 6.5 (FR-DUNG-001 … ), Section 6.6 (FR-GATE-001 … ), Section 7 Gate/Boss state machines, Section 8.3–8.4 sequences (gate completion, reward cascade), Section 11 Screen ↔ API Mapping (boss/dungeon/gate screens), Section 17.1 Phase 2 items. Do not load the entire SRS.
5. The current Flutter boss/dungeon/gate screens
6. The generated backend bosses, dungeons, gates modules and the reward cascade — for the exact API contracts

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. FEATURES
============================================================
Integrate:

- Bosses
- Dungeons
- Gate sessions
- Gate completion
- Gate collapse
- reward cascade
- boss damage
- XP/Mana effects
- relevant penalties
- relevant achievements

Use the existing backend modules. Do not create duplicate game logic in Flutter.

============================================================
2. GATE
============================================================
The Gate UI must represent a real server/domain state machine.

Support:

- starting a gate
- active state
- pause if permitted
- completion
- collapse/failure
- reward
- penalty

The frontend may display timers and animation. The backend remains authoritative for important state transitions and rewards.

============================================================
3. OFFLINE
============================================================
Determine from the SRS which Gate operations may be performed offline.

For offline-supported operations:

- persist commands locally

For server-gated operations:

- show an explicit offline limitation

Never pretend an unsupported offline operation succeeded.

============================================================
4. BOSS / DUNGEON
============================================================
- Boss HP and damage values display from authoritative server state — the client neither owns nor trusts damage/HP math
- Dungeon screens reflect real state from the backend contracts
- Reward cascade results reconcile into the local projection exactly as delivered

============================================================
DEFINITION OF DONE
============================================================
- [ ] Bosses, Dungeons, Gate sessions, gate completion/collapse, and their reward/penalty effects connected to the real backend
- [ ] No duplicate game logic created in Flutter (no client-side authoritative damage/HP/reward computation)
- [ ] Gate UI represents the server/domain state machine, with timers/animation only
- [ ] Offline-supported gate operations persist commands; server-gated operations show an explicit offline limitation; nothing false "succeeds" offline
- [ ] Reward cascade results reconcile into local projection atomically
- [ ] Loading/empty/error/offline/sync states on all gamification screens
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A6.md` handoff written for Sprint A7

Stop here. Sprint A7 starts in a fresh session.