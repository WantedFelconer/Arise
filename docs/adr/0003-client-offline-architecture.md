# ADR 0003: Client Offline-First Database & Command Queue Architecture

- **Status:** Accepted
- **Date:** 2026-08-14
- **Sprint:** A1 (Persistent Flutter Local Database & Offline Foundation)
- **Author:** Antigravity Engineering Agent

---

## 1. Context & Problem Statement

ARISE is designed as an offline-first, gamified personal productivity system ("Life Operating System"). Prior to Sprint A1, the Flutter frontend relied exclusively on in-memory collections (`InMemoryPlayerRepository`, `InMemoryQuestRepository`, and an in-memory `OfflineCommandQueue`). On every hot restart or app termination, all state was reset to hardcoded defaults, and operations had no durable audit trail or idempotency keys.

To satisfy the non-negotiable architecture laws in `.agents/rules/arise_flutter.md` and SRS §3.11, §6.3, §7.2, and Rule 6 (Offline-First Authority Contract), the client requires:
1. A persistent, robust local database engine.
2. A typed local data schema mirroring backend contracts.
3. Repositories backed by local persistence behind standard DI interfaces.
4. A durable, persistent command queue surviving app restarts and crashes.
5. Strict separation between client-projected pending state and server-authoritative state.
6. A network-awareness abstraction isolating UI and business logic from third-party networking packages.

---

## 2. Decisions

### 2.1 Local Database Engine: Drift (SQLite)

We chose **Drift** (`drift` + `drift_flutter` + `sqlite3_flutter_libs`) as the primary client database engine.

- **Reasoning:**
  - Standard SQLite foundation ensures cross-platform durability across iOS, Android, macOS, Linux, and Windows.
  - Compile-time type safety via Dart build_runner code generation eliminates SQL typo runtime crashes.
  - Native reactive stream queries (`watch()`) integrate seamlessly with Flutter Riverpod providers.
  - Schema migrations are explicit and inspectable.
  - Fast in-memory executor (`NativeDatabase.memory()`) allows full unit and integration testing without spinning up UI or platform channels.
- **Alternatives Considered:**
  - *Isar:* Fast NoSQL database, but less mature SQL migration tooling and uncertain long-term maintenance compared to SQLite standards.
  - *Hive / ObjectBox:* Key-value or object stores lacking relational foreign-key consistency and rich query capabilities needed for subquests, dependencies, and queue ordering.
  - *Raw sqflite:* Lacks type generation, reactive streams, and unit-testable in-memory wrappers out of the box.

### 2.2 Local Schema & Projection Boundary

The local database defines 5 core tables in `AriseDatabase`:
1. `character_snapshot` — Projection of the server `characters` entity with local `sync_status` and `pending_xp_delta`.
2. `quests` — Local projection and pending cache of user quests with `idempotency_key`, `sync_status`, `is_dirty`, and typed dates.
3. `local_event_queue` — Persistent command queue for offline mutations matching SRS §7.2.
4. `sync_meta` — Incremental sync cursors (`last_synced_at`, `server_revision`) per entity type.
5. `app_meta` — Key-value metadata store (device ID, schema version).

**Local vs. Server Responsibility Boundary:**
- The local database is a **client projection / cache plus pending operations**, NOT a second authoritative server.
- The client NEVER computes or asserts final authoritative values for XP, Level, Mana, Energy, Boss HP, streaks, or achievements.
- Progression changes are recorded locally as `pending` predictions to maintain optimistic UI responsiveness, and reconciled strictly against server responses.

### 2.3 Command Queue & Idempotency Model

Every user-driven mutation (e.g., `COMPLETE_QUEST`, `CREATE_QUEST`, `START_GATE`, `COMPLETE_GATE`, `COLLAPSE_GATE`) generates a persistent command in `local_event_queue`:
- **Structure:** `eventId` (UUID PK), `userId`, `deviceId`, `eventType`, `payloadJson`, `occurredAtClient`, `syncStatus`, `retryCount`, `version`, `lastError`, `nextRetryAt`.
- **Idempotency Key:** The client generates a unique UUID `eventId` and passes it as the `Idempotency-Key` HTTP header. Replaying an already-processed command on the server is guaranteed idempotent per SRS Rule 6 §17.3.
- **Retry Strategy:** Exponential backoff ($2^n$ seconds, starting at 2s, doubling to 4s, 8s, 16s... capped at 300s). Failed commands remain queued until successful delivery or explicit user action.

### 2.4 Token & Credential Storage

We replaced `InMemoryTokenStorage` with `SecureTokenStorage` using `flutter_secure_storage`:
- iOS: Stored in Keychain.
- Android: Stored in `EncryptedSharedPreferences`.
- Web / Desktop / Test fallback: Secure platform storage fallback.
- Secrets are NEVER stored in plain SQLite, `SharedPreferences`, or ordinary JSON files.

### 2.5 Network Awareness & Abstraction

We introduced `NetworkStatusService` (`ConnectivityNetworkStatusService`):
- Exposes high-level application states: `online`, `offline`, `reconnecting`.
- Emits `reconnecting` during the initial 2-second grace period after regaining physical connectivity to allow link stabilization before firing queued sync traffic.
- The UI and business logic depend exclusively on `NetworkStatusService` / `networkStatusProvider`, never importing `connectivity_plus` directly.

---

## 3. Reconciliation & Optimistic State Philosophy

1. **Local-First Writes:**
   $$\text{UI Interaction} \rightarrow \text{Application Command} \rightarrow \text{Local DB Transaction} \rightarrow \text{Immediate UI State Update} \rightarrow \text{Async Queue Processing}$$
   Interaction never blocks on network roundtrips unless explicitly required by SRS server-gated operations (e.g., payment/subscription verification, AI real-time streaming).
2. **Optimistic Tagging:** All locally created/modified records carry `sync_status = 'pending'` and `isProgressionPending = true`.
3. **Reconciliation on Sync:** When the backend responds with authoritative payload data, the client calls `reconcileFromServerResponse()`, updating local records to `sync_status = 'verified'` and replacing optimistic prediction values with exact server figures.
4. **Conflict Policy:**
   - Quest metadata: Last-write-wins or field-level merge.
   - Rewards & Progression: Server is 100% authoritative; local predictions yield to server computation.

---

## 4. Consequences & Tradeoffs

- **Positive:**
  - 100% offline functionality for quest viewing, creation, and completion.
  - Zero data loss on app restart or OS termination.
  - Clean DI separation: UI components bind to Riverpod providers and domain models, completely unaware of Drift or SQLite details.
  - Comprehensive unit testability without device simulators or real HTTP servers.
- **Negative / Costs:**
  - Requires code-generation step (`build_runner`) when modifying database tables.
  - Schema changes require explicit migration strategies once released to production.
  - Slight storage overhead for local JSON payload storage in `local_event_queue`.

---

## 5. References

- `ARISE_SRS.md` (§3.11 Sync Engine, §6.3 Local Database, §7.1–7.3 Event Catalog & Conflict Resolution)
- `.agents/rules/arise_flutter.md` (Rule 6: Offline-First Authority Contract)
- `docs/frontend-audit/A0-FRONTEND-AUDIT.md` (P0-1, P0-2, P0-5, P0-7, P0-8)
