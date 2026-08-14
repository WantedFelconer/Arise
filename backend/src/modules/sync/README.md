# Sync Module (`modules/sync`)

## 1. Purpose & Responsibilities
Provides the foundational offline synchronization and idempotency replay mechanics for ARISE:
- Generalized `Idempotency-Key` header handling and deterministic replay protection for all mutating operations (NFR-008, Rule 6).
- Caches and returns original execution results for duplicate command replays without re-executing business logic or writing duplicate ledger rows.
- Baseline endpoint `POST /api/v1/sync/idempotency-test` for validating offline command replay against the progression ledger.

## 2. Public API
- `IdempotencyService.executeIdempotent<T>(userId, idempotencyKey, operationType, operation): Promise<CachedResponse<T>>`
- `SyncService.executeTestCommand(userId, idempotencyKey, amount): Promise<any>`

## 3. Dependencies
- `IdempotencyService` (`core/idempotency/idempotency.service.ts`)
- `CharacterService` (`modules/character/service/character.service.ts`)
- `PrismaService` (`db/prisma/prisma.service.ts`)

## 4. Database Tables
- `idempotency_records` (unique `[userId, idempotencyKey]`)
- `sync_events` (event queue mirror)

## 5. Offline-First Authority Contract
The client synchronizes domain commands carrying a unique idempotency key. The backend recomputes all progression state server-side and stores the idempotency record to ensure zero duplicate rewards on network retry.
