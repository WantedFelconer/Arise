# A0 — ARISE Frontend Audit Report
**Sprint A — Post-Generation UI/UX & Integration Audit**
**Date:** 2026-08-14
**Auditor:** Antigravity Senior Frontend Agent
**Scope:** Full Flutter client under `flutter frontend/lib/`

---

## 1. Executive Summary

The ARISE Flutter frontend is architecturally coherent and visually on-brand. The design system is clean, the component library is solid, and the navigation model (Riverpod `NavigationNotifier` + `PhaseContentRouter`) is appropriate. However, the client is **not integration-ready** in its current state. The most critical category of issues is the complete absence of real data flow: every screen renders hardcoded static data, and every infrastructure layer (auth, character, quest) returns fabricated mock responses. Secondary issues include UI bugs in layout, scroll collision, and accessibility deficits.

**Overall integration-readiness score: 2 / 10**
No screen currently calls a live API. All displayed data is fabricated.

---

## 2. Severity Classification

| Priority | Description | Count |
|---|---|---|
| **P0 — Blocker** | Prevents real data integration or causes functional breakage | 11 |
| **P1 — High** | Significant UX/usability defect or integration gap | 14 |
| **P2 — Polish** | Visual inconsistency, minor UX friction, or non-critical | 9 |

---

## 3. Architecture Findings

### 3.1 Repository Layer — Static Stubs Everywhere

| File | Issue | Priority |
|---|---|---|
| `player_provider.dart` L5-7 | `playerRepositoryProvider` hard-wires `InMemoryPlayerRepository()` directly. Swapping to a real repository requires editing provider code. | **P0** |
| `quest_provider.dart` L5-7 | `questRepositoryProvider` hard-wires `InMemoryQuestRepository()`. Same structural problem. | **P0** |
| `auth_remote_data_source.dart` L14-19 | `signup()` and `login()` return hardcoded Map responses. `ApiClient` is imported but never called. Real JWT flow is completely bypassed. | **P0** |
| `character_remote_data_source.dart` L8-16 | `fetchCharacter()` returns a static map. Backend character endpoint is never called. | **P0** |

**Root cause:** Repository abstraction exists (`PlayerRepository`, `QuestRepository` interfaces) but is never leveraged. The DI seam is there; it is just not wired.

### 3.2 Token / Session Persistence — P0

`TokenStorage` exists in `core/network/` but is never read by any provider or screen. After `completeAuth()` is called, the session token is not persisted. The app always begins at `AppPhase.auth` on cold start — no session hydration.

### 3.3 Onboarding Data — Not Persisted — P0

`OnboardingScreen._handleArise()` copies `PlayerData.defaultPlayer` with only `name` and `title`. It discards the chosen `_selectedClasses`, `_chronotype`, and `_difficulty`. The setup wizard collects meaningful user profile data that should reach the backend (`POST /api/v1/auth/signup` takes `chronotype` and `difficultyMode`). Currently thrown away.

### 3.4 Offline-First Sync Layer — Declared but Unconnected — P0

`core/sync/offline_command_queue.dart` exists with `QueuedCommand` and `CommandSyncStatus`. However, no screen or notifier enqueues a command. Quest completion (`QuestNotifier.toggleQuest`) calls the in-memory repository but does not enqueue a `COMPLETE_QUEST` command. Gate collapse/victory applies no XP mutation and does not enqueue `COMPLETE_GATE` or `COLLAPSE_GATE`. The sync engine is a dead letter.

### 3.5 XP / Level Computation Client-Side — P0

`PlayerNotifier.addExp()` (player_provider.dart L33-51) computes level-up logic directly on the client: `maxExp = (maxExp * 1.25).round()`. This violates SRS §4.28 (FR-VALID-1): the backend is authoritative for XP, Level, and related values.

### 3.6 `PlayerData` Model — Missing Backend Fields — P1

`PlayerData` has no `id`, no `email`, no `difficultyMode`, no `chronotype`, and no `syncStatus`. When real auth/character data arrives from the backend, there is no model field to store or map these values into.

### 3.7 `Quest` Model — Missing Backend Fields — P1

`Quest` has no `idempotencyKey`, no `syncStatus`, no `createdAt`, no `userId`, and no `manaReward`. The `deadline` field is typed as `String`, not `DateTime`. Model cannot round-trip to the backend DTO as-is.

---

## 4. Screen-by-Screen Analysis

### 4.1 Auth Screen

| # | Issue | Priority |
|---|---|---|
| A-01 | Auth form submits but login/signup returns hardcoded Map — no HTTP call made | **P0** |
| A-02 | Successful auth transitions phase but no JWT is stored | **P0** |
| A-03 | No loading state — submit button has no in-progress feedback | **P1** |
| A-04 | No error state — failed login/signup produces no user-visible feedback | **P1** |
| A-05 | Input validation is client-only (empty check). Email format not validated | **P2** |

### 4.2 Onboarding Screen

| # | Issue | Priority |
|---|---|---|
| O-01 | `_handleArise()` discards `_selectedClasses`, `_chronotype`, and `_difficulty` | **P0** |
| O-02 | Onboarding completion does not call backend signup — user is registered nowhere | **P0** |
| O-03 | `PlayerData.defaultPlayer` values (level 14, rank B) injected after onboarding — new users start with fabricated stats | **P0** |
| O-04 | Step 5 has a hardcoded 800ms delay before showing CTA — timer artifact, not a loading state | **P2** |
| O-05 | Progress indicator is text-only (STEP 1 OF 5). No visual progress bar. | **P2** |

### 4.3 Home Screen

| # | Issue | Priority |
|---|---|---|
| H-01 | XP bar reads from `PlayerData.exp / maxExp` hardcoded at 7340/10000 | **P0** |
| H-02 | Daily quest log driven by `InMemoryQuestRepository` with hardcoded entries | **P0** |
| H-03 | "MORNING BRIEFING" block is completely static strings with no data binding | **P1** |
| H-04 | Activity log (if present) shows hardcoded entries — no provider backing | **P1** |

### 4.4 Quest List Screen

| # | Issue | Priority |
|---|---|---|
| Q-01 | Quest data from `InMemoryQuestRepository` is fabricated (hardcoded 12 entries) | **P0** |
| Q-02 | `toggleQuest()` mutates in-memory state but does not enqueue a `COMPLETE_QUEST` command | **P0** |
| Q-03 | `addQuest()` saves to in-memory repository only — no sync command, no idempotency key | **P0** |
| Q-04 | "Add Quest" modal does not expose `manaReward`, `syncStatus`, or `idempotencyKey` | **P1** |
| Q-05 | Quest `deadline` displayed as raw string — not parsed from any real timestamp | **P1** |

### 4.5 Status Screen

| # | Issue | Priority |
|---|---|---|
| S-01 | Stat values (STR 53, AGI 38, etc.) are hardcoded in `PlayerData.defaultPlayer` | **P0** |
| S-02 | `incrementStat()` writes to in-memory repository only. Stat allocation not synced. | **P1** |
| S-03 | `remainingPoints: 3` is hardcoded — backend awards points on level-up, not consumed here | **P1** |
| S-04 | Rank display is a static field on `PlayerData`, not from a backend-authoritative rank field | **P1** |

### 4.6 Focus Gate Screen

| # | Issue | Priority |
|---|---|---|
| G-01 | Victory state shows `+200 EXP` as a hardcoded label — not a real reward calculation | **P0** |
| G-02 | On victory: no `COMPLETE_GATE` command enqueued, no XP added via provider | **P0** |
| G-03 | On collapse: no `COLLAPSE_GATE` command enqueued, no penalty assigned | **P0** |
| G-04 | Collapse penalty card shows hardcoded values — not real backend penalty data | **P1** |
| G-05 | Timer runs with `Timer.periodic` inside `setState`. No wakelock — timer stops if app is backgrounded | **P1** |
| G-06 | Session duration selector is local state only — duration not sent as part of the gate command | **P2** |

### 4.7 Boss Detail Screen

| # | Issue | Priority |
|---|---|---|
| B-01 | All boss data is static: `SHIP THE APP`, HP `6500/10000`, attack log all fabricated | **P0** |
| B-02 | `_isDefeated = false` is a `final` constant — defeated state can never be reached at runtime | **P1** |
| B-03 | HP percentage "65% REMAINING" is a hardcoded string literal | **P2** |
| B-04 | Attack log entries are hardcoded `static const` maps — not driven by quest completion history | **P1** |

### 4.8 AI Coach Screen

| # | Issue | Priority |
|---|---|---|
| AI-01 | Chat simulated with `Timer` delays and static response strings — no AI provider called | **P1** |
| AI-02 | "ACCEPT & DEPLOY" calls `_acceptPlan()` which adds a static chat message — no quests created | **P0** |
| AI-03 | "QUEST TREE DEPLOYED" violates SRS §8 rule 10 (AI proposes, user approves, then real data created) | **P1** |
| AI-04 | Mana quota for AI not displayed or enforced. SRS §3.7 defines AI Mana cost per query. | **P2** |
| AI-05 | No empty/loading/error state. Only "thinking" text indicator exists. | **P1** |

### 4.9 Mana Core Screen

| # | Issue | Priority |
|---|---|---|
| MC-01 | `ManaCoreScreen` is `StatelessWidget` with `static const appBreakdown` — all data fabricated | **P0** |
| MC-02 | Main Mana ring renders `pct: 0.65` hardcoded — not from any provider | **P0** |
| MC-03 | "MANA DEPLETES IN 2H 14M" is a static string | **P1** |
| MC-04 | No integration with screen-time API — must show "awaiting data" state, not fabricated data | **P1** |

### 4.10 Penalty Screen

| # | Issue | Priority |
|---|---|---|
| P-01 | `missedQuest` defaults to hardcoded `'10KM RUN'` — not passed from real quest failure data | **P1** |
| P-02 | Penalty countdown starts at `23:59:47` hardcoded — not computed from real penalty deadline | **P1** |
| P-03 | Consequences (EXP, penalty quest, stat decay) are static — not from backend `PenaltyEvent` | **P1** |
| P-04 | `onAcknowledge` fires but no backend call is made to record acknowledgement | **P1** |

### 4.11 Settings Screen

| # | Issue | Priority |
|---|---|---|
| ST-01 | Account section shows hardcoded `PLAYER ONE`, `WOLF SLAYER`, `B-RANK` — not from player provider | **P1** |
| ST-02 | Toggle/switch state is local `setState` only — settings are not persisted | **P1** |
| ST-03 | `RESET ALL DATA` button has a label but no `onTap` handler — completely non-functional | **P1** |
| ST-04 | Theme selection is local state only, resets on hot restart | **P2** |

### 4.12 Notifications Screen

| # | Issue | Priority |
|---|---|---|
| N-01 | All 11 reminder entries are hardcoded lists in screen state | **P1** |
| N-02 | Snooze and toggle actions are local state only — not persisted | **P1** |
| N-03 | No actual device notification scheduling (`flutter_local_notifications` not in pubspec) | **P2** |

### 4.13 Level Up Screen

| # | Issue | Priority |
|---|---|---|
| LU-01 | `unlockedSkill` and `unlockedTitle` computed with magic-number logic — should be server-authoritative | **P1** |
| LU-02 | Triggered after onboarding complete — not wired to real level-up events from the server | **P1** |

### 4.14 Top Status Bar

| # | Issue | Priority |
|---|---|---|
| TSB-01 | HP/MP read from `playerProvider` backed by `InMemoryPlayerRepository` — correct pattern, wrong data source | — (pattern correct) |
| TSB-02 | Mini Mana Ring uses hardcoded `pct: 0.65` — not from any Mana provider | **P1** |
| TSB-03 | Streak count reads from `player.streak` hardcoded at `14` in defaultPlayer | **P1** |

---

## 5. Hardcoded Data Inventory

| Location | Hardcoded Value | Replace With |
|---|---|---|
| `player_data.dart:43-61` | Entire `defaultPlayer` (level 14, rank B, etc.) | Backend `GET /api/v1/character` response |
| `player_provider.dart:12` | `super(PlayerData.defaultPlayer)` | Loaded from repository on init |
| `quest_repository.dart` (InMemory) | 12 fabricated quest entries | Backend `GET /api/v1/quests` |
| `auth_remote_data_source.dart:16-18` | Hardcoded map instead of HTTP response | Real `ApiClient.post('/auth/login')` |
| `character_remote_data_source.dart:10-15` | `{level:1, totalXp:0, rank:'E'}` | Real `ApiClient.get('/character')` |
| `boss_detail_screen.dart:31-37` | `attackLog` static const list | Backend boss + attack-log endpoint |
| `boss_detail_screen.dart:149,158` | `SHIP THE APP`, `6,500 / 10,000` | Backend boss entity |
| `mana_core_screen.dart:16-23` | `appBreakdown` static const list | Screen-time platform API |
| `mana_core_screen.dart:47` | `pct: 0.65` | Player mana provider |
| `top_status_bar.dart:150` | `_MiniManaRing(pct: 0.65)` | Player mana provider |
| `penalty_screen.dart:25,16` | `_countdown`, `missedQuest='10KM RUN'` | Real penalty event data |
| `settings_screen.dart:60-64` | `PLAYER ONE`, `WOLF SLAYER`, account info | `playerProvider` |
| `levelup_screen.dart:45-46` | Magic-number skill/title unlock logic | Backend unlock event payload |
| `ai_coach_screen.dart:24-33` | Seeded message history | Empty or real session history |
| `notifications_screen.dart:34-46` | 11 hardcoded reminders | Persisted user notification config |

---

## 6. Missing Loading / Error / Empty States

The current frontend has virtually zero handling for async states outside the happy path.

| Screen | Missing States |
|---|---|
| Auth | Loading (submit spinner), Error (invalid credentials, server error) |
| Home | Loading skeleton for XP bar + quest log, Error (connection failed), Empty (no quests) |
| Quest List | Loading skeleton, Error, Empty (filtered tab has no quests) |
| Status | Loading skeleton for stat grid |
| Boss Detail | Loading, Error, Empty (no active boss) |
| AI Coach | Error (AI provider unavailable), Mana-depleted state (quota exhausted) |
| Mana Core | Loading, No-data (screen-time permission not granted) |
| Penalty | No-penalty state (screen should not appear if no penalty is active) |
| Settings | Loading (user profile fetch), Save-in-progress |

---

## 7. Layout & Scrolling Issues

| Issue | Location | Priority |
|---|---|---|
| `FocusGateScreen` and `NotificationsScreen` own their own `Scaffold` — will conflict with shell's `TopStatusBar` if both are in the stack simultaneously | `focus_gate_screen.dart:112`, `notifications_screen.dart:73` | **P1** |
| `BossDetailScreen` is a full-screen `Scaffold` — `TopStatusBar` should not be rendered when this overlay is active, but there is no mechanism to suppress it | `boss_detail_screen.dart:111` | **P1** |
| `AICoachScreen` is a full-screen `Scaffold` — same consideration | `ai_coach_screen.dart:89` | **P1** |
| `ManaCore` and `Settings` return bare scroll views without Scaffold wrappers. Back button uses `VoidCallback`, not `NavigationNotifier`. | `mana_core_screen.dart:27`, `settings_screen.dart:36` | **P2** |

---

## 8. State Management Architecture Assessment

The Riverpod setup is sound at the structural level:
- `NavigationNotifier` cleanly owns `AppPhase`, `activeTab`, and overlay state
- `PlayerNotifier` and `QuestNotifier` use `StateNotifier` correctly with `copyWith` patterns
- `filteredQuestsProvider` is a clean derived `Provider` — no issues

**Gaps to resolve before backend wiring:**
1. `playerRepositoryProvider` and `questRepositoryProvider` must become overridable via `ProviderScope.overrides`
2. No `AsyncValue` usage anywhere — loading/error states require migration to `AsyncNotifierProvider` or `FutureProvider`
3. Riverpod `2.5.1` already supports `AsyncNotifierProvider` — no upgrade needed

---

## 9. Performance Findings

| Finding | Location | Notes |
|---|---|---|
| `_RotatingPortalRings` creates new `MapEntry` list each frame via `.asMap().entries.map(...)` in `AnimatedBuilder`. Should be precomputed. | `focus_gate_screen.dart:553-571` | Minor |
| `OnboardingScreen._buildStep2Chronotype()` constructs sparkline bars inline inside `ListView.builder` — re-allocates on every rebuild | `onboarding_screen.dart:318-322` | Minor |
| `TopStatusBar` rebuilds on every `playerProvider` state change. With live data, `select()` should be used to prevent redundant full-tree rebuilds. | `top_status_bar.dart:31-36` | **P2** |
| `AriseSimulationBackground` runs an `AnimationController` persistent throughout app lifecycle. Verify disposal. | `phone_shell.dart:61` | **P2** |

---

## 10. Accessibility Gaps

| Issue | Priority |
|---|---|
| No `Semantics` labels on any interactive element (quest cards, stat buttons, gate timer) | **P2** |
| Contrast: `AppColors.textDisabled` at low opacity over `AppColors.voidEdge` may fail WCAG AA | **P2** |
| All `PressableCard` wrappers lack `tooltip` or `semanticsLabel` | **P2** |
| `CustomSwitch` does not pass `semanticsLabel` | **P2** |

---

## 11. Missing Packages

`pubspec.yaml` declares only 4 runtime deps: `flutter`, `google_fonts`, `flutter_riverpod`, `fl_chart`, `intl`.

| Package | Purpose | Sprint Required |
|---|---|---|
| `dio` or `http` | Real HTTP client for `ApiClient` | Sprint 2 |
| `flutter_secure_storage` | JWT token persistence | Sprint 2 |
| `drift` or `isar` | Local SQLite for offline-first (SRS §6.3) | Sprint 2-3 |
| `flutter_local_notifications` | Device-level notification scheduling | Sprint 3 |
| `connectivity_plus` | Online/offline detection for sync engine | Sprint 2 |
| `uuid` | Idempotency key generation | Sprint 2 |

---

## 12. Integration Readiness Checklist

| Capability | Status |
|---|---|
| JWT auth token stored and read on cold start | NOT READY |
| Login/signup calls real backend endpoint | NOT READY (stub only) |
| Player/character data loaded from backend | NOT READY (stub only) |
| Quest data loaded from backend | NOT READY (stub only) |
| Quest completion enqueues offline command | NOT READY |
| Gate complete/collapse enqueues offline command | NOT READY |
| Onboarding data (chronotype, difficulty) sent to backend | NOT READY (discarded) |
| XP/Level computed server-side and reconciled | NOT READY (client computes) |
| Mana ring reads from real player Mana value | NOT READY (hardcoded 0.65) |
| Penalty screen shows real penalty event data | NOT READY (all hardcoded) |
| AI Coach calls real AI provider | NOT READY (timer simulation) |
| Loading states exist for async operations | NOT READY (none) |
| Error states exist for async failures | NOT READY (none) |
| Empty states exist for zero-data scenarios | NOT READY (none) |
| Offline command queue processes and syncs | NOT READY (declared, not wired) |
| Screen-time data from platform API | NOT READY (fabricated) |
| Settings persisted (local or backend) | NOT READY (local setState only) |
| Notifications scheduled via system API | NOT READY |

**All 18 integration capabilities: NOT READY**

---

## 13. What Is Working Well (Preserve)

- **Design system** — `AppColors`, `AppTypography`, all component files are clean and consistent. Do not touch.
- **Navigation model** — `NavigationNotifier` + `PhaseContentRouter` pattern is correct and extensible.
- **Repository interface layer** — `PlayerRepository` and `QuestRepository` abstract interfaces are the correct DI seam. Replace `InMemory*` with `Remote*`, do not discard.
- **`AriseLayoutInsets`** — centralized inset utility is well-designed and used consistently.
- **`FocusGateScreen` animations** — portal rings, breathe animation, shake animation are premium quality. Do not modify.
- **`OnboardingScreen`** — flow, visual design, and animation are excellent. Only data persistence is missing.
- **`PenaltyScreen`** — visual design and tone are excellent. Only data binding is missing.
- **`AICoachScreen`** — UI scaffold is correct. Only backend call and plan materialization are missing.
- **Riverpod 2.5.1** — supports `AsyncNotifierProvider` needed for Sprint 2 without any upgrade.

---

## 14. Recommended Sprint 2 Work Order

1. **Foundation:** Add `dio`, `flutter_secure_storage`, `connectivity_plus`, `uuid` to pubspec.
2. **ApiClient:** Implement `ApiClient` using `dio` with JWT interceptor and token refresh.
3. **Auth:** Wire `AuthRemoteDataSource` to real login/signup. Persist JWT via `TokenStorage`. Hydrate session on cold start.
4. **Onboarding:** Pass `chronotype`, `difficultyMode`, `classes` to signup endpoint.
5. **PlayerRepository:** Create `RemotePlayerRepository` implementing `PlayerRepository`. Swap provider.
6. **QuestRepository:** Create `RemoteQuestRepository` implementing `QuestRepository`. Swap provider.
7. **Offline queue:** Wire `QuestNotifier.toggleQuest()` and gate exit handlers to enqueue `COMPLETE_QUEST`, `COMPLETE_GATE`, `COLLAPSE_GATE` commands.
8. **Reconciliation:** After each network response, reconcile XP/Level/Mana/Streak from server response into `PlayerNotifier`. Remove client-side `addExp()` computation.
9. **Loading/Error states:** Migrate `playerProvider` and `questProvider` to `AsyncNotifierProvider`. Add skeleton loaders.
10. **Settings persistence:** Wire settings to `SharedPreferences` (local) as minimum; backend sync is stretch.

---

## 15. Audit Sign-Off

This audit covers all 14 screen files, 4 provider files, 2 model files, 3 infrastructure files, and the shared layout/component layer. No files were skipped.

**Next step:** Create `docs/sprint-tracking/integration-A0.md` and confirm P0 blockers as Sprint 2 prerequisites.
