# Achievements Module

## Purpose & Responsibilities
The **Achievements Module** evaluates machine-evaluable rule triggers on gameplay events (`quest_complete`, `gate_clear`, `boss_defeat`). Unlocking an achievement creates an authoritative unlock record, an in-app notification row, and awards bonus XP through the centralized progression engine (FR-ACH-001..002).

## Public Service API
- `listAchievements(userId?: string): Promise<AchievementResponse[]>`
- `getUserAchievements(userId: string): Promise<AchievementResponse[]>`
- `evaluateTriggers(userId: string, event: AchievementTriggerEvent): Promise<AchievementResponse[]>`

## Database Tables Owned
- `achievements`: Static definitions with `code`, `title`, `xp_reward`, and `criteria` JSONB.
- `user_achievements`: Join table recording user unlocks with `unlocked_at`.
- `notifications`: Generated in-app notification records upon unlocking.

## HTTP Endpoints
- `GET /api/v1/achievements` — List all achievements with user unlock status
- `GET /api/v1/achievements/unlocked` — List unlocked achievements for authenticated user

## Dependencies
- `modules/character` — Public `CharacterService` for awarding achievement XP bonuses.
