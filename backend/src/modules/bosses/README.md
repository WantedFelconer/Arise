# Bosses Module

## Purpose & Responsibilities
The **Bosses Module** manages large-scale projects represented as RPG Bosses with max/current HP, difficulty tiers, and status lifecycle. Completing linked quests inflicts damage on the boss based on a config-driven lookup table (`config/boss_damage_table.json`).

## Public Service API
- `getBoss(userId: string, id: string): Promise<BossResponse>`
- `listBosses(userId: string, filters?: { status?: string; dungeonId?: string }): Promise<BossResponse[]>`
- `createBoss(userId: string, input: CreateBossInput): Promise<BossResponse>`
- `updateBoss(userId: string, id: string, input: UpdateBossInput): Promise<BossResponse>`
- `abandonBoss(userId: string, id: string): Promise<BossResponse>`
- `reactivateBoss(userId: string, id: string): Promise<BossResponse>`
- `applyDamage(userId: string, bossId: string, damage: number): Promise<{ boss: BossResponse; defeated: boolean; rewards?: { xp: number; coins: number }; damageDealt: number }>`
- `applyHpRecovery(userId: string, bossId: string, recoveryRate?: number): Promise<BossResponse>`
- `getBossHistory(userId: string): Promise<BossHistoryItem[]>`

## Database Tables Owned
- `bosses`: Primary project container with `hp_max`, `hp_current`, `difficulty`, `status`, `deadline`, `defeated_at`.

## HTTP Endpoints
- `GET /api/v1/bosses` — List user bosses
- `GET /api/v1/bosses/history` — Boss defeat history with time-to-defeat
- `GET /api/v1/bosses/:id` — Get boss detail
- `POST /api/v1/bosses` — Create boss
- `PATCH /api/v1/bosses/:id` — Update boss
- `POST /api/v1/bosses/:id/abandon` — Abandon active boss
- `POST /api/v1/bosses/:id/reactivate` — Reactivate abandoned boss

## Dependencies
- `core/rpg-engine.ts` — Config-driven damage and defeat reward calculations.
- `config/boss_damage_table.json` — Externalized damage matrix.
