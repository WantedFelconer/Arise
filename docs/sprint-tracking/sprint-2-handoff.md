# ARISE Sprint 2 — Handoff Digest

**Date:** 2026-08-14  
**Sprint Name:** Sprint 2 — Core Productivity Loop  
**Status:** COMPLETE & PASSING (70/70 Tests Passed, Zero Lint Errors, Clean Build)  

---

## 1. Executive Summary & Delivered Scope

Sprint 2 successfully implemented the entire **Core Productivity Loop** of ARISE per `ARISE_SRS.md`, `SPRINT_PLAN.md`, and `.agents/rules/arise_flutter.md`. All business logic runs under clean architecture layers in NestJS, with centralized game mechanics and server-authoritative progression.

### Delivered Modules & Components

1. **Quests Module (`backend/src/modules/quests`)**:
   - **MVP Features**: FR-QST-001 (CRUD), FR-QST-002 (Hierarchical nesting), FR-QST-003 (Parent auto-complete on all child quests completed), FR-QST-004 (Config metadata & priorities), FR-QST-005 (RRULE recurrence spawning next instance), FR-QST-007 (Archive/restore), FR-QST-008 (Search/filter/sort), FR-QST-011 (Reward cascade execution), FR-QST-012 (Status lifecycle), FR-QST-013 (Hardcore deadline failure Mana penalty), FR-QST-018 (10-second undo window for deletion and completion).
   - *P2 items (dependencies, duplicate, templates, bulk ops, NL input, Inbox, Eisenhower) were strictly excluded.*

2. **Bosses Module (`backend/src/modules/bosses`)**:
   - **MVP Features**: FR-BOSS-001 (Boss CRUD & multi-boss support), FR-BOSS-002 (Config-driven damage calculation), FR-BOSS-003 (Boss defeat and reward payout), FR-BOSS-004 (Active boss capacity), FR-BOSS-005 (Boss defeat history tracking duration and quest count), §7.3 Lifecycle (`active -> defeated`, `active -> abandoned -> active`).
   - Boss HP recovery for hardcore mode gate collapse.

3. **Dungeons Module (`backend/src/modules/dungeons`)**:
   - **MVP Features**: FR-DUNG-001 (Multi-boss project container), FR-DUNG-002 (Dynamic progress calculation %: `floor(defeated / total * 100)`), FR-DUNG-003 (Auto-complete dungeon when all child bosses are defeated).

4. **Gates Focus Module (`backend/src/modules/gates`)**:
   - **MVP Features**: FR-GATE-001 (Session starting), FR-GATE-002 (Stability growth), FR-GATE-003 (Expedition clear at 100% stability), FR-GATE-004 (Clear Mana bonus and XP rewards), FR-GATE-005 (Gate collapse penalty), FR-GATE-006 (Pause mechanics: 1 pause allowed in Casual, strictly disallowed in Hardcore), FR-GATE-007 (Expedition statistics), FR-GATE-008 (Server-authoritative anti-tamper calculation of elapsed time and stability percentage).

5. **Centralized Reward Cascade (`backend/src/core/reward-cascade.ts`)**:
   - Atomic multi-module cascade flow executing XP/Mana ledger transactions, boss damage, parent auto-completion, RRULE recurrence generation, and achievement evaluations.
   - Enforces §17.3 Rule 5: Duplicate non-idempotent complete calls return `409 Conflict` (`QUEST_ALREADY_COMPLETED`).
   - Enforces Rule 6 (Offline-First Authority Contract): Replaying requests with `Idempotency-Key` returns original cached 200 response with zero duplicate ledger rows.

6. **Achievements Trigger Module (`backend/src/modules/achievements`)**:
   - Machine-evaluable criteria evaluator for `quest_complete`, `gate_clear`, `boss_defeat` events (FR-ACH-001).
   - Generates notification log records and awards bonus XP through `CharacterService` (FR-ACH-002).

7. **Centralized Config Tables**:
   - `backend/src/config/boss_damage_table.json`: Base damage matrix (Difficulty x Priority), boss defeat rewards, and hardcore recovery rate (0.15).
   - `backend/src/config/gate_rewards.json`: Gate XP rate, clear mana reward, and casual vs hardcore collapse penalties.
   - `backend/src/config/quest_penalties.json`: Hardcore deadline miss penalties.

---

## 2. Acceptance Criteria Verification

| AC Identifier | Target Specification | Test Suite Verification | Status |
|---|---|---|---|
| **AC-QST-011** | Given a pending quest with `xp_reward=50`, `mana_reward=5`, linked to an active boss at `current_hp=200`<br>When `POST /api/v1/quests/{id}/complete` is called<br>Then 200, `quest.status == "completed"`, an `xp_transactions` row of +50 exists, a `mana_transactions` row of +5 exists, `bosses.current_hp` reduced by computed damage.<br>And calling the same endpoint again returns **409** and creates **no duplicate ledger rows**.<br>And with `Idempotency-Key` header, replaying returns cached 200 with zero duplicate ledger rows. | `backend/tests/sprint2-integration.test.ts`<br>`src/core/tests/reward-cascade.test.ts` | **PASS** |
| **AC-GATE-005** | Given an active Gate session in hardcore mode at 40% stability<br>When `POST /api/v1/gates/{id}/collapse` is called<br>Then `gate_sessions.status == "collapsed"`, a negative `xp_transactions` row and negative `mana_transactions` row exist per the hardcore penalty table, and if boss-linked, boss HP recovery is applied per the configured hardcore recovery rate. | `backend/tests/sprint2-integration.test.ts`<br>`src/core/tests/reward-cascade.test.ts`<br>`src/modules/gates/tests/gates.test.ts` | **PASS** |
| **Multi-Tenant Isolation** | Multi-tenant query isolation ensures User B receives 404 on accessing, modifying, or completing User A's quests, bosses, dungeons, and gates. | `backend/tests/sprint2-integration.test.ts` | **PASS** |

---

## 3. Public Service APIs for Downstream Sprints

Downstream modules (Sprint 3: Habit Engine, Streaks, Focus Analytics, Screen Time) can inject the following public services:

### `QuestService` (`modules/quests/service/quest.service.ts`)
- `createQuest(userId, input): Promise<QuestResponse>`
- `getQuest(userId, id): Promise<QuestResponse>`
- `listQuests(userId, query): Promise<QuestResponse[]>`
- `completeQuest(userId, id, options?): Promise<QuestCompleteResponse>`
- `startQuest(userId, id): Promise<QuestResponse>`
- `pauseQuest(userId, id): Promise<QuestResponse>`
- `archiveQuest(userId, id): Promise<QuestResponse>`
- `restoreQuest(userId, id): Promise<QuestResponse>`
- `failQuest(userId, id, userDifficultyMode?): Promise<QuestResponse>`
- `deleteQuest(userId, id): Promise<{ success: boolean }>`
- `undo(userId, id): Promise<QuestResponse>`

### `BossService` (`modules/bosses/service/boss.service.ts`)
- `createBoss(userId, input): Promise<BossResponse>`
- `getBoss(userId, id): Promise<BossResponse>`
- `listBosses(userId, filters?): Promise<BossResponse[]>`
- `applyDamage(userId, bossId, damage): Promise<{ boss, defeated, rewards? }>`
- `applyHpRecovery(userId, bossId, recoveryRate): Promise<BossResponse>`
- `abandonBoss(userId, id): Promise<BossResponse>`
- `reactivateBoss(userId, id): Promise<BossResponse>`
- `getBossHistory(userId): Promise<BossHistoryItem[]>`

### `DungeonService` (`modules/dungeons/service/dungeon.service.ts`)
- `createDungeon(userId, input): Promise<DungeonResponse>`
- `getDungeon(userId, id): Promise<DungeonResponse>`
- `listDungeons(userId): Promise<DungeonResponse[]>`
- `recalculateProgress(userId, id): Promise<DungeonResponse>`

### `GateService` (`modules/gates/service/gate.service.ts`)
- `startSession(userId, input): Promise<GateSessionResponse>`
- `getSession(userId, id): Promise<GateSessionResponse>`
- `pauseSession(userId, id, difficultyMode?): Promise<GateSessionResponse>`
- `resumeSession(userId, id): Promise<GateSessionResponse>`
- `completeSession(userId, id): Promise<GateSessionResponse>`
- `collapseSession(userId, id, difficultyMode?, input?): Promise<GateSessionResponse>`
- `getStats(userId): Promise<GateStatsResponse>`

### `RewardCascadeService` (`core/reward-cascade.ts`)
- `executeQuestRewardCascade(userId, questId, options?): Promise<QuestRewardCascadeResult>`
- `executeGateClearRewardCascade(userId, session, stabilityPct): Promise<GateRewardCascadeResult>`
- `executeGateCollapseRewardCascade(userId, session, userDifficultyMode): Promise<{ xpDelta, manaDelta, bossRecovered }>`

### `AchievementService` (`modules/achievements/service/achievement.service.ts`)
- `evaluateTriggers(userId, event: AchievementTriggerEvent): Promise<AchievementResponse[]>`
- `listAchievements(userId?): Promise<AchievementResponse[]>`
- `getUserAchievements(userId): Promise<AchievementResponse[]>`

---

## 4. Test Suite Summary

- **Total Test Files:** 23 passing (0 failing)
- **Total Unit & Integration Tests:** 70 passing (0 failing)
- **Linter Status:** 0 errors, 0 warnings (`eslint "src/**/*.ts" "tests/**/*.ts"`)
- **Build Status:** Clean TypeScript build (`nest build`)

---

## 5. Handoff to Sprint 3

Sprint 3 will implement:
1. **Habit Engine & Streak System** (§6.7)
2. **Screen Time & Mana Modifier Engine** (§6.8)
3. **Focus Analytics & Productivity Dashboard** (§6.9)
4. Integration with `RewardCascadeService` and `CharacterService` for habit completion rewards and streak maintenance.
