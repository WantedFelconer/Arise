You are executing ARISE SPRINT 4 — Supporting Systems. Fresh Antigravity session.

============================================================
LOAD (and nothing more)
============================================================
1. `.agents/rules/arise_flutter.md`
2. The Sprint 4 row of the corrected coverage table in `SPRINT_PLAN.md`
3. `docs/sprint-tracking/sprint-3-handoff.md`
4. From `ARISE_SRS.md`, only the FR ranges named per module below, plus:
   - §12 NFR-008, NFR-009, NFR-010, NFR-011
   - §14 External Integrations table
   - §15.2 (BullMQ worker topology)
   - §17.1 Phase 4, and Phase 5 items only for the specific FRs marked MVP below (this SRS's own Phase 5 grouping is coarser than its own FR priority tags — trust the FR tags, not the phase label, where they disagree; see note under "Fitness" below)

This sprint's FR priority tags are less uniform than earlier sprints — several modules mix MVP and P2 requirements within the same section. Read each module's FR table directly and build only the rows tagged MVP in **Sprint 4A**; everything else is **Sprint 4B**, explicitly deferred, not silently dropped.

============================================================
SPRINT 4A — build first, this is the real MVP scope
============================================================

**Screen Time (§6.10)** — FR-SCREEN-001, 002 (MVP); 003, 004 are P2.
- Client pushes per-app usage sessions (start/end/app id); **server is the source of truth for Mana impact**, not the client (FR-SCREEN-001) — the client reports raw usage, the server computes the Mana delta via `core/rpg-engine`, exactly the same "client proposes, server computes" pattern as Quest/Gate.
- Each app maps to a category (productive/educational/communication/entertainment/high_distraction) and a `mana_modifier_per_minute`, user-overridable per app (FR-SCREEN-002) — config-driven default table, per-user override rows in `app_categories`.
- Batch endpoint: `POST /screen-time/sessions`.

**Reminders (§6.11)** — FR-REM-001 through 005, all MVP.
- Types: quest, deadline, hydration, medication, sleep, prayer, behavioral, custom (FR-REM-001)
- RRULE recurrence and one-off ISO timestamps (FR-REM-002)
- User-authored free-text behavioral reminders (FR-REM-003)
- Delivery throttled to max N/hour/user (configurable), priority ordering deadline > custom (FR-REM-004)
- Snooze (FR-REM-005)
- Scheduling/dispatch runs as a `jobs/` BullMQ worker, separate from the API process (§15.2) — don't schedule reminders inline in a request handler.

**Notifications (§6.21)** — FR-NOTIF-001, 002, both MVP.
- Push delivery via FCM for reminders, deadlines, streak warnings, AI suggestions, achievements (FR-NOTIF-001) — FCM service-account credentials are backend-only, per the same secret-handling discipline as AI provider keys (§15.4)
- In-app notification inbox with read/unread state (FR-NOTIF-002)

**Achievements — finalize (§6.19 ACH rows)**
- Sprint 2 built the trigger hook against quest/gate events only. This sprint adds real streak-based criteria once Statistics (below) exists to compute streaks from, and finalizes the listing/unlock endpoints (`GET /achievements`).

**Statistics (§6.20)** — FR-STAT-001, MVP.
- Aggregate lifetime stats: total/completed/failed quests, focus hours, bosses defeated, dungeons cleared, lifetime XP/Mana (`GET /stats`)

**Settings (§6.23)** — FR-SET-001, 002, both MVP.
- Theme, notifications, sound, language, privacy settings per user (FR-SET-001)
- Full data export (JSON) and account deletion (FR-SET-002) — this is where Sprint 1's soft-delete-on-account-deletion (FR-AUTH-009) gets its real trigger endpoint and its 30-day PII-purge job gets implemented for real in `jobs/`, matching NFR-009/010.

**Game Modes (§6.24)** — FR-MODE-001, 002, 003, all MVP.
- Casual: smaller penalties, more AI-suggested defaults, gentler failure states (FR-MODE-001)
- Hardcore: larger XP/Mana penalties, no pausing, partial boss HP regen on Gate collapse (FR-MODE-002) — this is the config table that Sprint 2's Gate-collapse and hardcore-deadline-miss logic already reads from; this sprint is where that table gets a real, complete, admin-configurable home instead of the inline stub from Sprint 2.
- Mode switch doesn't retroactively alter past transactions (FR-MODE-003) — mode is read at the time of the reward-cascade call, never applied backward over the ledger.

**Admin config (§6.27)** — FR-ADMIN-002 only is MVP this sprint (balancing constants — XP formulas, Mana modifiers, boss damage tables, difficulty-mode penalty tables — stored as configuration, tunable without redeploy). FR-ADMIN-001 (full separately-authenticated admin API, feature-flag management, user lookup) is P2 — build the `feature_flags` table's read path only (already exists from Sprint 1/3), not a full admin surface.

**Analytics — baseline only (§6.14)** — FR-ANLY-001 and FR-ANLY-004 are MVP; FR-ANLY-002 (AI narrative) and FR-ANLY-003 (PDF export) are P2.
- Daily/weekly/monthly/yearly rollups of XP, Mana, Focus time, quest completion rate, screen time, fitness (FR-ANLY-001) — this is the hook Sprint 2's reward cascade left a placeholder for; wire it now.
- Monthly reports permanently retained, not subject to rollup pruning (FR-ANLY-004)

**Notes — baseline only (§6.15)** — FR-NOTE-001 is MVP; FR-NOTE-002 (Notion sync) and FR-NOTE-003 (Quick Capture/Inbox) are P2.
- Folders, tags, full-text search, optional quest linkage (FR-NOTE-001)

**Fitness (§6.17)** — FR-FIT-001, 002, both MVP. (Note: §17.1's Phase 5 grouping lists Fitness alongside clearly-P2 items like Notes+Notion sync, but the FR table itself tags both Fitness requirements MVP — build it in 4A per the FR tags, which are the more granular and more authoritative source when the two disagree.)
- Log steps, water, weight, workouts, sleep, heart rate, calories — manual or via Health integration (FR-FIT-001) — the Health integration *connection* itself (OAuth, HealthKit ingestion) is P2/§14; build the manual-logging path and the ingestion endpoint shape now, wire a real external connection in 4B if time allows.
- Logged activity above configurable thresholds generates `fitness` stat XP and Mana via `core/rpg-engine` (FR-FIT-002)

**Music catalog (§6.16)** — FR-MUSIC-001 only is MVP; FR-MUSIC-002 (auto-select on Gate start) and FR-MUSIC-003 (Brain Reset content type) are P2.
- Expose a catalog of ambient tracks served from S3/CDN (FR-MUSIC-001) — this is a content-serving endpoint, not meaningful business logic; keep it small.

============================================================
SPRINT 4B — build only after every 4A item's DoD passes; otherwise convert to tracked backlog
============================================================
- Notion sync for Notes (FR-NOTE-002), Quick Capture/Inbox (FR-NOTE-003)
- Calendar + Google Calendar two-way sync (§6.18, FR-CAL-001, 002 — both P2)
- Analytics AI narrative (FR-ANLY-002), PDF export (FR-ANLY-003)
- Inventory (§6.19, FR-INV-001)
- Full Admin API/RBAC surface (FR-ADMIN-001)
- Generalized Integrations OAuth connect/disconnect flow for Notion/GCal/Health/Spotify (§6.22, FR-INTG-001) — when built, tokens are encrypted at rest via envelope encryption/KMS per §13.3, never stored plaintext
- Music Brain Reset content type (FR-MUSIC-002, 003)

If you reach the end of the sprint with 4A solid and time remaining, pick from 4B in the order listed. If not, log every unbuilt 4B item in the handoff digest as backlog — do not leave them undocumented.

============================================================
EXECUTION MODEL
============================================================
Act as `sprint-orchestrator`, same pattern as prior sprints. Sequence 4A tickets by dependency (Statistics before achievement streak criteria; Settings' account-deletion endpoint after Sprint 1's soft-delete primitive is confirmed present; Notifications before Reminders' dispatch worker needs a delivery channel). Dispatch to `module-builder`, close with `integration-reviewer` once every 4A ticket (and any attempted 4B ticket) is `done`.

============================================================
CROSS-CUTTING RULES THAT STILL APPLY
============================================================
- Screen Time Mana impact is server-computed from raw client-submitted usage sessions, never a client-submitted Mana delta — same server-authoritative pattern as every prior sprint.
- Every new mutating, reward-adjacent endpoint (Screen Time ingestion, Fitness logging above threshold) goes through Sprint 1's idempotency mechanism.
- Balancing constants (Mana modifiers, penalty tables, thresholds) are config, not inline numbers (NFR-006, §17.3 rule 1) — this sprint is where the largest number of new config tables get introduced; keep them consistent with the pattern set in Sprint 1/2.
- Data export (FR-SET-002) and account deletion touch every module built so far — coordinate with each module's repository for what belongs in the export payload rather than hand-rolling a second data-access path.
- PII minimization: screen-time data stores app bundle IDs and durations only, **never screen content** (NFR-009).

============================================================
TESTING (per §16)
============================================================
- Screen Time: server recomputes Mana delta from submitted sessions regardless of any client-submitted delta value (attempt to submit a fake delta, confirm it's ignored)
- Reminders: RRULE + one-off firing, throttle cap respected, snooze behavior
- Notifications: unread-count correctness, FCM credentials never exposed in any response
- Settings: full export contains data from every module without omission; account deletion soft-deletes across all owned tables and schedules the 30-day purge job
- Game Modes: mode switch does not alter historical ledger rows (append a transaction under casual, switch to hardcore, confirm the old row is unchanged)
- Fitness: threshold-crossing logs generate the correct XP/Mana via the RPG engine, sub-threshold logs don't
- Analytics: rollup numbers reconcile against the underlying ledger tables for a fixed fixture dataset

============================================================
DO NOT
============================================================
- Build Habits, quest dependencies, or any other Sprint-2-deferred P2 item — still out of scope
- Build the 4B list before 4A is fully done and reviewed
- Build a payments/subscription system anywhere in Settings, Admin, or Integrations
- Accept a client-submitted Mana delta, XP value, or streak count for anything built this sprint

============================================================
DEFINITION OF DONE
============================================================
- [ ] Every 4A module implemented, tested, README'd
- [ ] Screen Time Mana impact proven server-authoritative under a spoofed-delta test
- [ ] Reminders dispatch via a real BullMQ worker, not inline in request handlers
- [ ] Settings export/deletion covers every module built to date
- [ ] Game-mode penalty tables config-driven and non-retroactive, tested
- [ ] 4B items either built-and-tested or explicitly logged as backlog with rationale
- [ ] `integration-reviewer` boundary + anti-cheat + PII-minimization audit passes
- [ ] `docs/sprint-tracking/sprint-4-handoff.md` written — every module's public API, config files introduced, 4B backlog list, known gaps

Stop here. Sprint 5 starts fresh and is the final hardening/regression pass — it loads all prior handoffs, not just this one.
