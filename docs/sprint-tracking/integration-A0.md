# Sprint A — Integration Tracking: Frontend Audit (A0)

**Sprint:** A (Pre-Integration Audit)
**Phase:** DISCOVERY / AUDIT — COMPLETE
**Date Completed:** 2026-08-14
**Auditor:** Antigravity Senior Frontend Agent

---

## Deliverables Completed

- [x] Full screen-by-screen audit of 14 Flutter screens
- [x] Architecture layer inspection (providers, repositories, models, infrastructure stubs)
- [x] Hardcoded data inventory
- [x] Missing state analysis (loading/error/empty)
- [x] Layout & scrolling collision findings
- [x] Performance findings
- [x] Accessibility gap inventory
- [x] Integration readiness checklist (18 capabilities)
- [x] Recommended Sprint 2 work order
- [x] `docs/frontend-audit/A0-FRONTEND-AUDIT.md` — written and delivered

---

## Audit Summary

**Integration-readiness score: 2 / 10**

The Flutter frontend is visually complete and architecturally coherent. The design system, navigation model, repository interface layer, and layout inset utility are all well-built and should be preserved. However, all 18 backend integration capabilities are NOT READY. No screen currently calls a live API. All displayed data is fabricated.

---

## P0 Blockers — Sprint 2 Prerequisites

The following P0 issues MUST be resolved before any Sprint 2 backend integration work can be considered functional:

| ID | Blocker | File |
|---|---|---|
| P0-1 | `playerRepositoryProvider` hard-wires `InMemoryPlayerRepository` — DI seam not wired | `player_provider.dart` |
| P0-2 | `questRepositoryProvider` hard-wires `InMemoryQuestRepository` — DI seam not wired | `quest_provider.dart` |
| P0-3 | `AuthRemoteDataSource.login/signup` returns hardcoded Map — no HTTP call | `auth_remote_data_source.dart` |
| P0-4 | `CharacterRemoteDataSource.fetchCharacter` returns hardcoded Map — no HTTP call | `character_remote_data_source.dart` |
| P0-5 | `TokenStorage` declared but never read — no session hydration on cold start | `core/network/token_storage.dart` |
| P0-6 | Onboarding discards `chronotype`, `difficultyMode`, `classes` — never sent to backend | `onboarding_screen.dart:79-88` |
| P0-7 | Offline command queue is declared but no screen enqueues commands | `core/sync/offline_command_queue.dart` |
| P0-8 | `PlayerNotifier.addExp()` computes XP/Level client-side — violates SRS §4.28 | `player_provider.dart:33-51` |
| P0-9 | Gate victory/collapse call `onExit()` with no command enqueue, no stat mutation | `focus_gate_screen.dart:417,486` |
| P0-10 | All boss data is `static const` — boss entity never loaded from backend | `boss_detail_screen.dart:31-37` |
| P0-11 | AI Coach "ACCEPT & DEPLOY" creates no real quests — plan materialization is dead | `ai_coach_screen.dart:76-85` |

---

## What Must NOT Change (Design Preservation Constraints)

| Asset | Preservation Constraint |
|---|---|
| `AppColors`, `AppTypography` | Do not modify — design tokens are canonical |
| All `core/design_system/components/` | Do not modify component visual behavior |
| `FocusGateScreen` animations (portal rings, breathe, shake) | Preserve exactly — premium UI |
| `OnboardingScreen` 5-step flow and visual design | Preserve — only wire data persistence |
| `PenaltyScreen` visual design | Preserve — only wire real penalty event data |
| `NavigationNotifier` + `PhaseContentRouter` pattern | Preserve — correct architecture |
| `AriseLayoutInsets` | Preserve — used consistently across all screens |
| `PlayerRepository` and `QuestRepository` interfaces | Preserve — these are the correct DI seam |

---

## Sprint 2 Entry Conditions

Sprint 2 (Backend Integration) may begin once:

1. This audit document is reviewed and accepted by the team
2. `pubspec.yaml` is updated with Sprint 2 required packages (`dio`, `flutter_secure_storage`, `connectivity_plus`, `uuid`)
3. The Sprint 2 module list is confirmed from `SPRINT_PLAN.md`

---

## Notes for Sprint 2 Agent

- Do NOT rebuild the frontend from scratch. Do NOT redesign any screen.
- The DI seam is already in place. The `Provider<PlayerRepository>` and `Provider<QuestRepository>` only need their bodies swapped to return `RemotePlayerRepository` and `RemoteQuestRepository` respectively. The notifier code does not change.
- Riverpod `2.5.1` is already installed and supports `AsyncNotifierProvider`. Migrate loading surfaces to `AsyncNotifierProvider` to enable skeleton loaders and error states.
- The `InMemory*` repository implementations should be retained as test doubles — do not delete them.
- Remove `PlayerNotifier.addExp()` computation only after confirming the backend XP reconciliation flow is working end-to-end.
- The offline command queue (`core/sync/offline_command_queue.dart`) infrastructure is present — wire it, do not rebuild it.
