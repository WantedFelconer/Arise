# Character Module (`modules/character`)

## 1. Purpose & Responsibilities
Provides the authoritative character state, Level, Rank, Stat progression, and transaction ledger queries for ARISE:
- Character retrieval (`GET /api/v1/character`) with XP to next level, current/max Mana, Coins, Gems, and Rank.
- 7 independently-levelable stats breakdown (`GET /api/v1/character/stats`).
- Immutable XP and Mana ledger transaction history (`GET /api/v1/character/history`).
- Real-time XP aggregations (`GET /api/v1/character/aggregates`) for today, this week, this month, and lifetime.
- Title equipping (`PATCH /api/v1/character/title`).
- Centralized `awardXp` and `modifyMana` mutation APIs enforcing **ledger-first write guarantees** (FR-XP-001, FR-MANA-001, §17.3 Rule 1).

## 2. Public API
- `CharacterService.getCharacter(userId: string): Promise<CharacterResponse>`
- `CharacterService.getStats(userId: string): Promise<any>`
- `CharacterService.awardXp(userId: string, input: AwardXpInput): Promise<any>`
- `CharacterService.modifyMana(userId: string, input: ModifyManaInput): Promise<any>`
- `CharacterService.equipTitle(userId: string, titleId: string | null): Promise<any>`
- `CharacterService.getXpAggregates(userId: string): Promise<XpAggregationSummary>`
- `CharacterService.getTransactionHistory(userId: string): Promise<any>`

## 3. Dependencies
- `RpgEngine` (`core/rpg-engine.ts`)
- `PrismaService` (`db/prisma/prisma.service.ts`)
- `config/rank_thresholds.json`
- `config/circadian_curves.json`

## 4. Database Tables
- `characters` (primary cache)
- `xp_transactions` (immutable append-only ledger)
- `mana_transactions` (immutable append-only ledger)

## 5. Non-Negotiable Progression Law
No external route handler or feature module may ever update `characters.total_xp` or `characters.current_mana` directly. All mutations MUST route through `CharacterService.awardXp` or `CharacterService.modifyMana`, writing to the respective transaction table before updating the cached fields.
