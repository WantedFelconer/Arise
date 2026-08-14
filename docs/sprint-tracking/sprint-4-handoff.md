# ARISE Sprint 4 — Handoff Digest

**Date:** 2026-08-14  
**Sprint Name:** Sprint 4 — Supporting Systems (Sprint 4A MVP Scope)  
**Status:** COMPLETE & PASSING (135/135 Tests Passed across 34 Test Suites, 0 Lint Errors, Clean Build)  

---

## 1. Executive Summary & Delivered Scope

Sprint 4 built and hardened the complete **Supporting Systems** layer of ARISE per `ARISE_SRS.md`, `SPRINT_PLAN.md`, and `.agents/rules/arise_flutter.md`. All progression-affecting rules strictly observe centralized server authority (Rule 7, Rule 6 Offline-First Authority Contract), PII minimization (NFR-009), non-retroactive ledger immutability (FR-MODE-003), and background asynchronous worker topologies (§15.2).

### Delivered Modules & Components

1. **Screen Time Module (`backend/src/modules/screen-time`)**:
   - **Anti-Cheat Server Authority (§6.10, FR-SCREEN-001, FR-SCREEN-002, Rule 7)**: Discards client-submitted `manaDelta` / `manaImpact` and evaluates authoritative Mana impacts via `RpgEngine.calculateScreenTimeManaImpact` against `screen_time_modifiers.json` and user overrides.
   - **PII Minimization (NFR-009)**: Stores strictly application package identifiers and durations, never keystrokes, screen contents, or URLs.
   - **Per-User Category Customization**: Default app categories (`productive`, `learning`, `neutral`, `entertainment`, `high_distraction`) with user-specific rate overrides stored in `app_categories`.
   - **Insights & Distraction Analytics**: Computes usage totals, category breakdown, most-used apps, and peak distraction hour windows.

2. **Reminders Module (`backend/src/modules/reminders`)**:
   - **Supported Types (FR-REM-001)**: Quest, deadline, hydration, medication, sleep, prayer, behavioral, custom.
   - **Recurrence & Trigger Evaluation (FR-REM-002, FR-REM-003)**: Evaluates one-off ISO timestamps, time-of-day + days-of-week schedules, RRULE patterns, and free-text behavioral trigger interventions.
   - **Priority & Delivery Throttling (FR-REM-004)**: Enforces maximum dispatch rate (5 notifications/hour/user) with priority ordering (`deadline > urgent > high > medium > low > custom`).
   - **Snooze Support (FR-REM-005)**: Temporary suppression for N minutes (`POST /reminders/:id/snooze`).
   - **Background Worker Dispatch (§15.2)**: `ReminderDispatchJob` (`backend/src/jobs/reminder-dispatch.job.ts`) for asynchronous evaluation and dispatch.

3. **Notifications Module (`backend/src/modules/notifications`)**:
   - **In-App Inbox & Unread Counter (§6.21, FR-NOTIF-001, FR-NOTIF-002)**: Paginated inbox (`GET /notifications`), mark single/all as read, unread count badge indicator.
   - **FCM Push Integration & Secret Safety (NFR-011)**: `FcmService` encapsulates Firebase Cloud Messaging with backend-only credentials, guaranteeing server keys and service account JSONs are never exposed in client API responses.

4. **Statistics Module (`backend/src/modules/statistics`)**:
   - **Lifetime Aggregate Stats (§6.20, FR-STAT-001)**: Consolidated aggregation (`GET /stats`) over quests (completed, created, streak, completion rate), focus sessions (total time, success rate), dungeon/boss records, level, rank, and XP/Mana transactions.

5. **Achievements Finalization (`backend/src/modules/achievements`)**:
   - **Config-Driven Catalog Seed**: Seeded from `backend/src/config/achievements_catalog.json`.
   - **Machine-Evaluable Trigger Engine (FR-ACH-001, FR-ACH-002)**: Evaluates `minQuestsCompleted`, `minGatesCleared`, `minBossesDefeated`, `minStreak`, `minStability`, `minLevel`, preventing duplicate awards.

6. **Notes Module Baseline (`backend/src/modules/notes`)**:
   - **Hierarchy & Full-Text Search (§6.15, FR-NOTE-001)**: Folders CRUD, note tags, case-insensitive full-text search across titles/bodies/tags, and optional quest linkage with cascade unlinking upon folder deletion.

7. **Fitness Module (`backend/src/modules/fitness`)**:
   - **Manual & Ingested Metrics (§6.17, FR-FIT-001, FR-FIT-002)**: Ingests steps, workout minutes, sleep hours, water intake, weight, heart rate, and calories.
   - **Threshold-Crossing Rewards (Rule 5)**: Activity exceeding configured targets in `fitness_thresholds.json` awards character stat XP (`fitness`, `health`) and restores Mana via `RpgEngine.calculateFitnessRewards`.

8. **Music Module (`backend/src/modules/music`)**:
   - **Ambient Focus Catalog (§6.16, FR-MUSIC-001)**: Category-grouped ambient tracks (Lo-fi, Rain, Brown Noise, Fantasy, Nature, Cafe) served from `music_catalog.json` for Gate study sessions.

9. **Analytics Module Baseline (`backend/src/modules/analytics`)**:
   - **Multi-Horizon Rollups (§6.14, FR-ANLY-001)**: Reconciles metrics from underlying transaction ledgers (`xp_transactions`, `mana_transactions`, `quests`, `gate_sessions`, `screen_time_sessions`, `fitness_logs`) across Daily, Weekly, Monthly, and Yearly horizons.
   - **Permanent Retention (FR-ANLY-004)**: Monthly snapshot reports stored permanently in `analytics_snapshots`, exempt from data pruning.

10. **Settings & Account Management (`backend/src/modules/settings`)**:
    - **Preferences CRUD (§6.23, FR-SET-001)**: Theme, sound, haptics, language, reminder schedule, and granular notification toggles.
    - **Difficulty Modes (FR-MODE-001..003)**: Non-retroactive mode switching (`casual` vs `hardcore`).
    - **Full Data Portability Export (FR-SET-002)**: Compiles complete JSON archive across all 19 domain tables without omission.
    - **Soft-Delete & 30-Day Purge Lifecycle (FR-AUTH-009, NFR-009, NFR-010)**: Sets `deletedAt`, revokes all active refresh tokens, schedules 30-day permanent erasure worker (`AccountPurgeJob`).

11. **Admin Module (§6.27, FR-ADMIN-002)**:
    - Exposes balancing constants (`rank_thresholds`, `boss_damage_table`, `gate_rewards`, `screen_time_modifiers`, `fitness_thresholds`, `difficulty_modes`) tunable without code redeployment.

12. **BullMQ Background Workers (`backend/src/jobs/`)**:
    - `ReminderDispatchJob`: Evaluates active reminder schedules and dispatches throttled notifications.
    - `AccountPurgeJob`: Permanently erases PII and related rows for accounts soft-deleted > 30 days ago.
    - `AnalyticsRollupJob`: Generates scheduled daily and monthly snapshots for active users.

---

## 2. Acceptance Criteria & Literal AC Verification

| AC Identifier | Target Specification | Test Suite Verification | Status |
|---|---|---|---|
| **FR-SCREEN-001, 002** | Screen time batch ingestion discards spoofed client deltas; computes authoritative Mana modifiers; provides app category overrides. | `tests/sprint4-integration.test.ts`<br>`src/modules/screen-time/tests/screen-time.test.ts` | **PASS** |
| **FR-REM-001..005** | Reminders evaluate triggers (one-off, RRULE, behavioral), enforce max 5/hr throttle with priority ordering (`deadline > custom`), and support snooze. | `tests/sprint4-integration.test.ts`<br>`src/modules/reminders/tests/reminder.test.ts` | **PASS** |
| **FR-NOTIF-001, 002** | Inbox tracks unread count accurately; FCM credentials are kept server-side only and never leaked in API payloads. | `tests/sprint4-integration.test.ts`<br>`src/modules/notifications/tests/notification.test.ts` | **PASS** |
| **FR-FIT-001, 002** | Fitness logs evaluate activity thresholds; activity exceeding target grants XP to `fitness`/`health` and recovers Mana; sub-threshold logs award 0 XP. | `tests/sprint4-integration.test.ts`<br>`src/modules/fitness/tests/fitness.test.ts` | **PASS** |
| **FR-NOTE-001** | Note folders, tags, quest linkage, and case-insensitive full-text search across titles/bodies/tags. | `tests/sprint4-integration.test.ts`<br>`src/modules/notes/tests/note.test.ts` | **PASS** |
| **FR-SET-001, 002** | Full JSON data export contains records across all user-owned domain tables; account soft-deletion revokes tokens and schedules 30-day purge. | `tests/sprint4-integration.test.ts`<br>`src/modules/settings/tests/settings.test.ts` | **PASS** |
| **FR-MODE-001..003** | Mode switch alters current difficulty parameter without retroactively mutating past ledger entries. | `tests/sprint4-integration.test.ts`<br>`src/modules/settings/tests/settings.test.ts` | **PASS** |
| **FR-ANLY-001, 004** | Analytics rollups reconcile metrics directly from transaction tables and permanently retain monthly snapshot reports. | `tests/sprint4-integration.test.ts`<br>`src/modules/analytics/tests/analytics.test.ts` | **PASS** |
| **FR-STAT-001** | Lifetime stats endpoint aggregates quests, focus, bosses, dungeons, and character progression. | `tests/sprint4-integration.test.ts`<br>`src/modules/statistics/tests/statistics.test.ts` | **PASS** |
| **Multi-Tenant Isolation** | User B cannot view, modify, or export User A's notes, reminders, notifications, or settings. | `tests/sprint4-integration.test.ts` | **PASS** |

---

## 3. Sprint 4B Explicit Backlog (P2 / Deferred Items)

Per sprint guidelines, the following P2 items were explicitly partitioned into Sprint 4B rather than dropped:

1. **Notion Two-Way Note Sync (FR-NOTE-002, P2)**: Full bidirectional synchronization between ARISE local notes and Notion workspace pages via `ExternalIntegration` provider.
2. **Google Fit / Apple Health HealthKit Automated Sync (FR-FIT-003, P2)**: Passive background step count and workout sync via OAuth provider adapters.
3. **Advanced Spotify/YouTube Music Integration (FR-MUSIC-002, P2)**: External music streaming provider auth & playback controllers.
4. **AI-Powered Reminder Timing Optimization (FR-REM-006, P2)**: Circadian-rhythm predictive dispatch scheduling.
5. **Separate Admin Web Dashboard & RBAC (FR-ADMIN-001, P2)**: Superadmin authentication surface and granular role-based permissions.

---

## 4. Public Service APIs for Downstream Sprints

Downstream systems (Sprint 5: Sync Engine, Edge Cases, Polish) can inject the following services:

### `ScreenTimeService` (`modules/screen-time/service/screen-time.service.ts`)
- `ingestSessions(userId, dto): Promise<ScreenTimeIngestResult>`
- `getInsights(userId): Promise<ScreenTimeInsightResponse>`
- `getCategoryConfig(userId): Promise<{ defaults, userOverrides }>`
- `setAppCategory(userId, appPackage, dto): Promise<{ data }>`

### `ReminderService` (`modules/reminders/service/reminder.service.ts`)
- `createReminder(userId, dto): Promise<ReminderResponse>`
- `listReminders(userId, activeOnly?): Promise<ReminderResponse[]>`
- `getReminder(userId, id): Promise<ReminderResponse>`
- `updateReminder(userId, id, dto): Promise<ReminderResponse>`
- `snoozeReminder(userId, id, dto): Promise<ReminderResponse>`
- `deleteReminder(userId, id): Promise<void>`
- `processDueReminders(now?): Promise<{ dispatchedCount, throttledCount }>`

### `NotificationService` (`modules/notifications/service/notification.service.ts`)
- `sendNotification(dto): Promise<NotificationResponse>`
- `listNotifications(userId, filter?): Promise<NotificationListResponse>`
- `markAsRead(userId, id): Promise<NotificationResponse>`
- `markAllAsRead(userId): Promise<{ updatedCount }>`
- `deleteNotification(userId, id): Promise<void>`

### `NoteService` (`modules/notes/service/note.service.ts`)
- `createFolder(userId, dto): Promise<NoteFolderResponse>`
- `listFolders(userId): Promise<NoteFolderResponse[]>`
- `deleteFolder(userId, id): Promise<void>`
- `createNote(userId, dto): Promise<NoteResponse>`
- `listNotes(userId, filter?): Promise<NoteResponse[]>`
- `getNote(userId, id): Promise<NoteResponse>`
- `updateNote(userId, id, dto): Promise<NoteResponse>`
- `deleteNote(userId, id): Promise<void>`

### `FitnessService` (`modules/fitness/service/fitness.service.ts`)
- `logActivity(userId, dto): Promise<FitnessLogResponse>`
- `listLogs(userId, filter?): Promise<FitnessLogResponse[]>`
- `getSummary(userId): Promise<FitnessSummaryResponse>`

### `AnalyticsService` (`modules/analytics/service/analytics.service.ts`)
- `getDailyReport(userId, dateStr?): Promise<AnalyticsSnapshotResponse>`
- `getWeeklyReport(userId, startDateStr?): Promise<AnalyticsSnapshotResponse>`
- `getMonthlyReport(userId, yearStr?, monthStr?): Promise<AnalyticsSnapshotResponse>`
- `getYearlyReport(userId, yearStr?): Promise<AnalyticsSnapshotResponse>`
- `generateSnapshot(userId, dto): Promise<AnalyticsSnapshotResponse>`
- `listSnapshots(userId, period?): Promise<AnalyticsSnapshotResponse[]>`

### `SettingsService` (`modules/settings/service/settings.service.ts`)
- `getSettings(userId): Promise<SettingsResponse>`
- `updateSettings(userId, dto): Promise<SettingsResponse>`
- `setDifficultyMode(userId, dto): Promise<{ difficultyMode }>`
- `getDifficultyMode(userId): Promise<{ difficultyMode }>`
- `exportUserData(userId): Promise<UserDataExportResponse>`
- `requestAccountDeletion(userId): Promise<{ deletedAt, purgeScheduledDays }>`
- `cancelAccountDeletion(userId): Promise<{ restored }>`

---

## 5. Test Execution & Build Verification

```
 Test Files  34 passed (34)
      Tests  135 passed (135)
   Start at  16:37:43
   Duration  7.36s
```
