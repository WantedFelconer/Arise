---
name: backend-core-logic
description: Executes core functional requirements, backend services, controller logic pipelines, and validates code output against acceptance criteria.
---

---

## 4. Functional Requirements

Each module below states purpose, then numbered functional requirements. All progression-value requirements are subject to design constraint C-7 (backend-authoritative validation).

### 4.1 Authentication (`modules/auth`)

| ID | Requirement |
|---|---|
| FR-AUTH-1 | The system SHALL support account creation via email/password and MAY support OAuth (Google/Apple) sign-in. |
| FR-AUTH-2 | The system SHALL issue a short-lived JWT access token and a rotating refresh token on successful login. |
| FR-AUTH-3 | The system SHALL allow the client to refresh an expired access token using a valid refresh token, without re-entering credentials. |
| FR-AUTH-4 | The system SHALL support logout, invalidating the refresh token. |
| FR-AUTH-5 | The system SHALL support password reset via email verification. |
| FR-AUTH-6 | The system SHALL allow local (offline) session continuity using the last valid access token until it expires, after which protected write-sync operations queue until reconnection. |

### 4.2 Character (`modules/character`)

| ID | Requirement |
|---|---|
| FR-CHAR-1 | Each user account SHALL own exactly one Character. |
| FR-CHAR-2 | The Character SHALL expose: Level, current XP, XP-to-next-level, Mana, Energy, Coins, Gems, Titles (unlocked + equipped), Rank, and a set of Stats (Strength, Intelligence, Discipline, Creativity, Fitness, Coding, Business, Health — configurable list). |
| FR-CHAR-3 | Stats SHALL increase only as a computed side effect of tagged Quest/Habit completions (e.g., a Quest tagged `fitness` contributes to the Fitness stat), via the XP Engine, never via direct client write. |
| FR-CHAR-4 | The system SHALL allow the user to equip one unlocked Title at a time for display. |
| FR-CHAR-5 | Character state changes SHALL always originate from a domain event (QuestCompleted, GateCompleted, etc.), never from a direct "set stat" API. |

### 4.3 XP Engine (`modules/xp`)

| ID | Requirement |
|---|---|
| FR-XP-1 | The XP Engine SHALL compute XP awards as a function of Quest/Habit difficulty, estimated duration, consistency (streak), and focus quality (Gate outcome). |
| FR-XP-2 | The XP Engine SHALL expose a configurable Level Curve (XP required per level) loaded from configuration, not hardcoded. |
| FR-XP-3 | The system SHALL persist every XP change as an immutable `xp_transactions` record referencing its triggering event. |
| FR-XP-4 | The client MAY display a locally predicted ("pending") XP value immediately on quest completion, which SHALL be reconciled against the backend's authoritative value upon sync. |

### 4.4 Mana Engine (`modules/mana`)

| ID | Requirement |
|---|---|
| FR-MANA-1 | Mana SHALL decrease based on: high-distraction screen time, failed Gate sessions, missed Quest deadlines. |
| FR-MANA-2 | Mana SHALL increase based on: completed Quests, successful Gate sessions, logged exercise, logged sleep. |
| FR-MANA-3 | The AI Coach and AI Planner SHALL factor current Mana into scheduling/workload recommendations. |
| FR-MANA-4 | Mana SHALL never fall below a configurable floor (default 0) nor exceed a configurable ceiling. |

### 4.5 Energy Engine (`modules/energy`)

| ID | Requirement |
|---|---|
| FR-ENERGY-1 | The user SHALL be able to select a circadian profile: Early Bird, Night Owl, or Custom. |
| FR-ENERGY-2 | The Energy Engine SHALL compute an intraday energy curve from the selected profile. |
| FR-ENERGY-3 | The AI Planner/Coach SHALL prefer scheduling high-difficulty Quests during predicted high-energy windows. |
| FR-ENERGY-4 | Mana depletion rate SHALL vary with the current point on the Energy curve. |

### 4.6 Quest (`modules/quests`)

| ID | Requirement |
|---|---|
| FR-QUEST-1 | The system SHALL support Quest types: Daily, Main, Side, Recurring, Boss Quest, AI-Generated. |
| FR-QUEST-2 | Quests SHALL support fields: title, description, priority, difficulty, deadline, estimated duration, XP reward (computed), Mana reward (computed), tags, category, status, parent Quest (for nesting). |
| FR-QUEST-3 | Quests SHALL support unlimited nesting depth into Subquests. |
| FR-QUEST-4 | The system SHALL support Quest Dependencies: a Quest MAY declare prerequisite Quest(s) that must be completed before it becomes actionable. |
| FR-QUEST-5 | The system SHALL support Smart Recurrence rules beyond fixed weekday patterns: every N days, "every second Tuesday," monthly, "after completion" (recur N days after last completion), "when skipped" (reschedule), and a custom cron-like expression. |
| FR-QUEST-6 | The system SHALL record Estimated Duration vs. Actual Duration per Quest and feed this into the AI's per-category speed model (see 4.9). |
| FR-QUEST-7 | The system SHALL support an Eisenhower quadrant tag (Urgent/Important combinations), settable manually or suggested by AI. |
| FR-QUEST-8 | The system SHALL support multiple views over the same Quest data: List, Kanban (Todo/Doing/Done or custom columns), Calendar, Timeline, Agenda. |
| FR-QUEST-9 | The system SHALL support drag-and-drop reassignment of a Quest's day, Kanban column, parent Boss, or parent Dungeon. |
| FR-QUEST-10 | The system SHALL support Tags, color labels, Favorites, Pin, Duplicate, Bulk Edit, Bulk Complete, Archive, Trash (soft delete), and Restore from Trash. |
| FR-QUEST-11 | The system SHALL support Undo for the most recent destructive or completion action (delete, complete, bulk-edit) within a reasonable time window (default 10s client-side, plus Restore-from-Trash indefinitely). |
| FR-QUEST-12 | Completing a Quest SHALL emit a `QuestCompleted` domain event carrying enough payload for XP, Boss, Analytics, and Achievement engines to react independently. |
| FR-QUEST-13 | A Quest with unmet dependencies SHALL be visibly locked and SHALL NOT be completable until prerequisites are satisfied. |

### 4.7 Habit (`modules/habits`) — *promoted from backlog as MVP-critical*

| ID | Requirement |
|---|---|
| FR-HABIT-1 | The system SHALL support Habits as a distinct entity from Quests: repeated indefinitely rather than finished once. |
| FR-HABIT-2 | Habits SHALL support: frequency (daily, N times/week, custom), streak tracking, XP reward, reminder time(s), skip allowance (configurable grace count before a streak breaks), and statistics (completion rate, longest streak). |
| FR-HABIT-3 | The Habit Engine SHALL compute streak continuity, applying skip allowance before breaking a streak. |
| FR-HABIT-4 | Logging a Habit completion SHALL emit a `HabitCompleted` event consumed by the XP Engine and Analytics Engine. |
| FR-HABIT-5 | The system SHALL support a Daily/Evening/Night/Study/Gym Routine Builder: an ordered sequence of Habits/Quests grouped and completed as a checklist block. |

### 4.8 Inbox & Quick Capture (`modules/inbox`) — *promoted from backlog as MVP-critical ("the one feature you're missing most")*

| ID | Requirement |
|---|---|
| FR-INBOX-1 | The system SHALL provide a single-tap Quick Capture entry point accepting text, voice-to-text, photo, or screenshot, saved unsorted to the Inbox. |
| FR-INBOX-2 | Inbox items SHALL persist fully offline and sync opportunistically. |
| FR-INBOX-3 | The system SHALL provide AI Triage: on request (or automatically on next online session), the AI SHALL propose a destination per Inbox item — new Quest, new Note, subtask under an existing Boss, or a scheduled item with a suggested date/time. |
| FR-INBOX-4 | The user MUST approve or edit each AI Triage suggestion before it converts into a Quest/Note/etc.; the AI SHALL NOT silently convert Inbox items. |
| FR-INBOX-5 | The Inbox SHALL show an unsorted-item count badge to encourage regular triage. |

### 4.9 Natural Language Quest Input (`modules/ai_planner` sub-capability)

| ID | Requirement |
|---|---|
| FR-NLI-1 | The system SHALL accept a single free-text line (e.g., "Study OS tomorrow 8pm for 2 hours") and parse it into a structured Quest draft (title, deadline, duration, suggested priority). |
| FR-NLI-2 | The parsed draft SHALL be presented for user confirmation before creation. |
| FR-NLI-3 | The parser SHALL use the AI Provider Abstraction (Section 3.9), not a hardcoded vendor call. |

### 4.10 AI Quest Planner (`modules/ai_planner`) — flagship feature

| ID | Requirement |
|---|---|
| FR-AIPLAN-1 | The user SHALL be able to submit free-form planning context (goal, deadline, constraints, available time/day, current proficiency). |
| FR-AIPLAN-2 | The AI SHALL generate a draft plan: Main Quests, Subquests, time estimates, priorities, a recommended schedule, XP rewards, and dependencies between generated Quests. |
| FR-AIPLAN-3 | The generated plan SHALL remain fully editable (add/remove/reorder/re-time any generated item) before activation. |
| FR-AIPLAN-4 | The plan SHALL NOT become active (i.e., SHALL NOT create real Quests) until the user explicitly approves it (design constraint C-10). |
| FR-AIPLAN-5 | The AI SHALL incorporate the user's learned per-category speed model (Section 4.6 FR-QUEST-6 data) when estimating durations. |
| FR-AIPLAN-6 | If the network/AI provider is unavailable, the system SHALL inform the user gracefully and allow manual Quest creation as a fallback; previously AI-generated content remains accessible offline. |

### 4.11 Boss (`modules/boss`)

| ID | Requirement |
|---|---|
| FR-BOSS-1 | A Boss SHALL represent a project with fields: HP, Difficulty, Rewards, Deadline, and its related Quests. |
| FR-BOSS-2 | Completing a related Quest SHALL damage the Boss's HP via the Boss Engine's `calculateBossDamage`. |
| FR-BOSS-3 | When Boss HP reaches zero, the system SHALL mark the Boss Defeated and emit a `BossDefeated` event. |
| FR-BOSS-4 | In Hardcore Difficulty Mode, a missed deadline or failed Gate tied to a Boss Quest MAY trigger partial Boss HP recovery (regression), per configuration. |

### 4.12 Dungeon (`modules/dungeon`)

| ID | Requirement |
|---|---|
| FR-DUNGEON-1 | A Dungeon SHALL group multiple related Bosses (e.g., a semester grouping several course Bosses). |
| FR-DUNGEON-2 | Dungeon completion SHALL be computed as all child Bosses Defeated. |

### 4.13 Gate Focus (`modules/gate`)

| ID | Requirement |
|---|---|
| FR-GATE-1 | The user SHALL select a Quest and a duration, then "enter a Gate" to begin a focus session. |
| FR-GATE-2 | During a session, the Gate Engine SHALL compute a rising Stability value as the session progresses uninterrupted. |
| FR-GATE-3 | Exiting before completion SHALL destabilize and, past a threshold, collapse the Gate, applying configurable XP/Mana penalties and, in Hardcore Mode, possible Boss HP recovery. |
| FR-GATE-4 | The session UI SHALL display: current Quest, remaining time, Mana, background music control, and the Gate Stability Orb — nothing else (minimalism requirement). |
| FR-GATE-5 | The system SHALL track Gate Success Rate, Longest Expedition, Total Gates Cleared, and Gate Collapse Count. |
| FR-GATE-6 | Gate sessions SHALL function fully offline, storing start time, end time, duration, linked Quest, pause count, exit reason, and completion status locally, then syncing for backend validation (see Section 4.25). |

### 4.14 Screen Time Intelligence (`modules/screen_time`)

| ID | Requirement |
|---|---|
| FR-SCREEN-1 | The system SHALL record per-app usage duration (platform APIs permitting) and categorize each app: Productive, Educational, Communication, Entertainment, High Distraction. |
| FR-SCREEN-2 | Each app category (and optionally each app) SHALL have a configurable Mana modifier (e.g., VS Code +2, Instagram −8). |
| FR-SCREEN-3 | The system SHALL surface peak distraction periods, most-distracting apps, most-productive apps, app-switching frequency, and focus interruption counts. |
| FR-SCREEN-4 | The AI SHALL generate actionable recommendations from this data, not statistics alone (e.g., "move your Gate sessions before 7pm"). |

### 4.15 Reminder Engine (`modules/reminders`)

| ID | Requirement |
|---|---|
| FR-REM-1 | The system SHALL support Quest/Habit/deadline reminders, plus general wellness reminders (hydration, medication, sleep, and optionally prayer). |
| FR-REM-2 | The system SHALL support user-defined Behavioral Reminders with a trigger phrase and an intervention message (e.g., delaying a compulsive action by a set number of minutes). |
| FR-REM-3 | Reminder scheduling SHALL use native OS scheduling and SHALL NOT require an active network connection to fire. |
| FR-REM-4 | The Reminder Engine SHALL throttle/consolidate notifications to avoid overwhelming the user (no more than a configurable max per time window, batched where reasonable). |

### 4.16 AI Coach (`modules/ai_coach`)

| ID | Requirement |
|---|---|
| FR-COACH-1 | The system SHALL provide AI-assisted Daily Planning: given the user's stated availability, propose a schedule for the day's Quests. |
| FR-COACH-2 | The system SHALL provide a Weekly Review flow (what went well / what didn't / goals for next week) and a Monthly Reflection distinct from the Weekly Review. |
| FR-COACH-3 | The AI SHALL detect Overload (planned workload exceeding a realistic daily capacity) and propose rebalancing. |
| FR-COACH-4 | The AI SHALL detect repeated postponement of the same Quest and proactively offer help (break it down, reschedule, reduce scope). |
| FR-COACH-5 | The AI SHALL propose Rescheduling when a deadline is missed, subject to user approval. |
| FR-COACH-6 | The system SHALL maintain an AI Memory of the user's preferred study times, favorite session durations, subjects, and working speed, to personalize future planning (see also Section 11). |

### 4.17 Notes (`modules/notes`)

| ID | Requirement |
|---|---|
| FR-NOTES-1 | The system SHALL support Notes organized into Folders and Tags, full-text searchable. |
| FR-NOTES-2 | The system SHALL support Quick Notes for fast capture, syncing to the Notes module (or Inbox, if untriaged). |
| FR-NOTES-3 | The user SHALL be able to select individual Notes to sync to a chosen Notion page via the Notion integration. |
| FR-NOTES-4 | Notes SHALL be fully editable offline; sync occurs automatically on reconnection with a manual conflict-resolution flow (Section 7). |

### 4.18 Analytics & Reports (`modules/analytics`)

| ID | Requirement |
|---|---|
| FR-ANALYTICS-1 | The system SHALL generate Daily, Weekly, Monthly, and Yearly reports covering XP, Focus time, Mana, Energy, Screen Time, Quest completion rate, Boss progress, Gate success rate, Study time, and Fitness. |
| FR-ANALYTICS-2 | The AI SHALL generate a narrative Monthly Summary (e.g., completion rate, peak productivity window, notable screen-time shifts, Gate success trend, one concrete recommendation). |
| FR-ANALYTICS-3 | Monthly reports SHALL remain permanently accessible (not purged). |
| FR-ANALYTICS-4 | Analytics SHALL be computable locally offline from cached data and reconciled with backend-aggregated analytics once synced, with the backend's aggregation authoritative. |

### 4.19 Fitness (`modules/fitness`)

| ID | Requirement |
|---|---|
| FR-FIT-1 | The system SHALL track Steps, Weight, Water Intake, Exercise sessions, Sleep, Calories, and (where available) Heart Rate. |
| FR-FIT-2 | Logged fitness activity SHALL contribute to Character Stats (e.g., Fitness, Health) and Mana recovery via the relevant engines. |
| FR-FIT-3 | The system SHALL support syncing from Google Health Connect / Apple Health where the platform permits. |

### 4.20 Calendar (`modules/calendar`)

| ID | Requirement |
|---|---|
| FR-CAL-1 | The system SHALL render Quests/Gate sessions/Habits with due times on a calendar view. |
| FR-CAL-2 | The system SHALL support two-way sync with Google Calendar via the Integration Abstraction. |

### 4.21 Music & Brain Reset (`modules/music`)

| ID | Requirement |
|---|---|
| FR-MUSIC-1 | The system SHALL provide built-in focus audio: Lo-fi, Rain, Brown/White/Pink Noise, Nature, Cafe Ambience, Fantasy Ambience. |
| FR-MUSIC-2 | Playback SHALL continue while the app is minimized, subject to platform background-audio limitations. |
| FR-MUSIC-3 | The system SHALL provide a Brain Reset feature (e.g., 852 Hz tones, relaxation sounds, guided breathing) usable between sessions. |

### 4.22 Notifications (`modules/notifications`)

| ID | Requirement |
|---|---|
| FR-NOTIF-1 | The system SHALL dispatch push notifications via FCM for reminders, AI Coach nudges, and sync-conflict alerts requiring user input. |
| FR-NOTIF-2 | The system SHALL maintain an in-app Notification Center with read/unread state. |

### 4.23 Settings (`modules/settings`)

| ID | Requirement |
|---|---|
| FR-SET-1 | The system SHALL allow switching between Casual Mode and Hardcore RPG Mode (Section 4.26). |
| FR-SET-2 | The system SHALL allow configuring circadian profile, notification preferences, and integration connections. |
| FR-SET-3 | The system SHALL support data Export/Import (JSON/CSV) and manual Backup trigger. |

### 4.24 Integrations (`modules/integrations`)

| ID | Requirement |
|---|---|
| FR-INT-1 | The system SHALL support connecting/disconnecting Notion, Google Calendar, and Health Connect/Apple Health accounts via OAuth, through the Integration Abstraction. |
| FR-INT-2 | Integration credentials SHALL be stored encrypted and scoped per user. |

### 4.25 Search Everywhere (`modules/search`)

| ID | Requirement |
|---|---|
| FR-SEARCH-1 | The system SHALL provide a single global search across Quests, Bosses, Dungeons, Habits, Notes, Achievements, Projects, and Settings. |
| FR-SEARCH-2 | Search SHALL work offline against the local database, with results limited to locally-synced data. |

### 4.26 Difficulty Modes

| ID | Requirement |
|---|---|
| FR-DIFF-1 | Casual Mode SHALL apply small penalties, high AI assistance, gentle progression curve, and guided onboarding. |
| FR-DIFF-2 | Hardcore RPG Mode SHALL apply higher rewards, larger penalties, Boss HP recovery on failure, Gate collapse consequences, and minimal AI hand-holding. |
| FR-DIFF-3 | Difficulty Mode SHALL be a per-user setting affecting Game Engine parameters via configuration, not separate code paths. |

### 4.27 Sync & Offline Behavior (`modules/sync`) — cross-cutting, see also Sections 3.11 and 7

| ID | Requirement |
|---|---|
| FR-SYNC-1 | Every mutating client action SHALL write to the local database immediately and enqueue a corresponding domain event for sync, without waiting on network response. |
| FR-SYNC-2 | The Sync Engine SHALL detect connectivity changes and automatically flush the queue when back online. |
| FR-SYNC-3 | The Sync Engine SHALL retry failed sync attempts with exponential backoff and SHALL deduplicate by event ID. |
| FR-SYNC-4 | Every syncable object SHALL expose a `syncStatus` (Synced/Pending/Syncing/Failed/Conflict) surfaced subtly in the UI. |
| FR-SYNC-5 | The backend SHALL validate every incoming event and MAY reject/flag it (Section 4.28) before it becomes authoritative; on rejection, the client SHALL reconcile to the authoritative state and surface a non-blocking notice if the user-visible result changed. |

### 4.28 Backend Authority & Anti-Cheat Validation (`modules/xp`, `modules/gate`, `modules/boss`, cross-cutting)

| ID | Requirement |
|---|---|
| FR-VALID-1 | The backend SHALL recompute XP, Level, Mana, Energy, Boss damage, streaks, and achievement unlocks from raw events; it SHALL NOT accept client-submitted final values for these fields. |
| FR-VALID-2 | The backend SHALL reject or flag events exhibiting: impossible Gate durations, unrealistic XP gains, duplicate event IDs, timestamps inconsistent with device clock drift bounds, impossible completion rates, duplicate rewards, or replay of a previously-processed event. |
| FR-VALID-3 | Flagged events SHALL be held in a review state rather than silently applied or silently discarded, and SHALL be logged for audit. |

---

## 14. Acceptance Criteria

**AC-1 — Quest completion awards correct XP (Given/When/Then)**
Given a Quest with difficulty=Medium and estimated_minutes=60, when the user completes it, then the backend SHALL compute XP via `XP Engine.calculateQuestXP()` using the configured formula, persist an `xp_transactions` row, and the client's optimistic XP display SHALL match the backend value within one sync cycle (or be visibly reconciled if it doesn't).

**AC-2 — Gate collapse applies penalty**
Given an in-progress Gate session, when the user exits after the destabilization threshold but before completion, then the session SHALL be marked `collapsed`, an XP and Mana penalty SHALL be applied per configuration, and (in Hardcore Mode) the linked Boss's HP MAY partially recover per its configured recovery rule.

**AC-3 — Offline-to-online reconciliation**
Given a Quest completed fully offline, when connectivity is restored, then the Sync Engine SHALL push the `QuestCompleted` event exactly once (idempotent via `event_id`), the backend SHALL validate and persist authoritative XP/Boss-damage, and the client's `syncStatus` for that Quest SHALL transition Pending → Synced without user intervention.

**AC-4 — AI plan requires approval**
Given an AI-generated plan draft, when the draft is returned to the client, then no real Quest rows SHALL exist in the database until the user explicitly calls the approve endpoint; editing the draft before approval SHALL be reflected in the materialized Quests.

**AC-5 — Habit streak with skip allowance**
Given a Habit with skip_allowance=1 and a current streak, when the user misses exactly one day within the allowance window, then the streak SHALL NOT reset; when the user misses a second consecutive day beyond the allowance, then the streak SHALL reset to 0.

---
