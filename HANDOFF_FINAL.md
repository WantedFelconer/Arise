# ARISE — Final Architecture, Hardening & Release Audit Handoff

---

## 1. System Overview & Architectural Topology

**ARISE** is an offline-first, gamified, AI-assisted personal productivity platform ("Life Operating System") designed around a solo modular monolith backend architecture powering Flutter mobile and web clients.

```
+-----------------------------------------------------------------------------------+
|                                  FLUTTER CLIENTS                                  |
|            Presentation  <--->  Application (Use Cases)  <--->  Domain             |
|                                         |                                         |
|                 Local Database (Drift SQLite) + Offline Command Queue             |
+------------------------------------------+----------------------------------------+
                                           | HTTPS / JSON (Idempotent Domain Commands)
                                           v
+-----------------------------------------------------------------------------------+
|                               NESTJS MODULAR MONOLITH                             |
|                                                                                   |
|  [Global Filters / Guards / Pipes]                                                |
|    - GlobalExceptionFilter (RFC 7807 uniform error format)                        |
|    - RateLimitGuard (Proxy-aware sliding window limiter)                          |
|    - JwtAuthGuard (RS256 Bearer Token Verification)                               |
|    - ZodValidationPipe (Strict DTO schema parsing & sanitization)                  |
|                                                                                   |
|  [Feature Modules (21 Total)]                                                     |
|    - auth             - character        - quests           - bosses              |
|    - dungeons         - gates            - achievements     - screen-time         |
|    - fitness          - notes            - reminders        - notifications       |
|    - music            - settings         - statistics       - analytics           |
|    - sync             - admin            - calendar         - integrations        |
|    - ai (planner / coach / quota)                                                 |
|                                                                                   |
|  [Centralized Core Engines]                                                       |
|    - RpgEngine (XP curves, Mana recovery, Boss damage, Streaks, Gate stability)   |
|    - RewardCascadeService (Atomic single-transaction quest & gate resolution)     |
|                                                                                   |
|  [Persistence & Storage Layer]                                                    |
|    - PostgreSQL (Prisma ORM with normalized models & composite indexes)           |
|    - MemoryDb Fallback (Fast-path in-memory relational store for tests)           |
|    - Redis & BullMQ (Asynchronous background processing)                         |
+-----------------------------------------------------------------------------------+
```

---

## 2. Local Development & Environment Setup

### 2.1 Prerequisites
- **Node.js**: v20.x or later
- **pnpm / npm**: npm 10+ or pnpm 9+
- **Flutter SDK**: 3.22.x or later (Dart 3.4+)
- **PostgreSQL**: 15+ (optional for local memory testing, required for production)
- **Redis**: 7+ (for rate limiting and job queues)

### 2.2 Backend Setup
```bash
# 1. Navigate to backend directory
cd backend

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env

# 4. Generate Prisma client & apply database migrations (if using PostgreSQL)
npx prisma generate
npx prisma migrate dev --name init

# 5. Run development server
npm run start:dev
# Backend runs at: http://localhost:3000/api/v1 (Health check: http://localhost:3000/health)
```

### 2.3 Flutter Frontend Setup
```bash
# 1. Navigate to flutter directory
cd "flutter frontend"

# 2. Get dependencies
flutter pub get

# 3. Generate Drift SQLite code (if modifying database tables)
dart run build_runner build --delete-conflicting-outputs

# 4. Run application
# For Chrome/Web:
flutter run -d chrome

# For Android (connects automatically to 10.0.2.2 on emulator):
flutter run -d emulator-5554

# For Custom API Base URL:
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

---

## 3. Automated Test Suites & Commands

### 3.1 Backend Tests
```bash
cd backend

# Run entire test suite (42 test files, 195 tests)
npm test

# Run specific integration/security audits
npx vitest run tests/sprint6-e2e-user-journey.test.ts
npx vitest run tests/sprint5-security-audit.test.ts
npx vitest run tests/sprint5-sync-anti-cheat.test.ts
npx vitest run tests/sprint5-offline-idempotency-audit.test.ts
```

### 3.2 Flutter Tests
```bash
cd "flutter frontend"

# Run all Flutter tests (64 tests across 10 modules)
flutter test

# Run End-to-End User Journey test suite
flutter test test/e2e/complete_user_journey_test.dart

# Run specific unit/integration suites
flutter test test/sync/sync_security_reconciliation_test.dart
flutter test test/quests/offline_quest_flow_test.dart
flutter test test/character/authoritative_character_test.dart
flutter test test/boss_gate/boss_gate_integration_test.dart
flutter test test/network/api_client_test.dart
flutter test test/database/persistence_test.dart
```

---

## 4. Environment Variables Reference

```ini
# Server
NODE_ENV=production
PORT=3000
API_PREFIX=api/v1
CORS_ORIGIN=http://localhost:3000,http://localhost:8443

# PostgreSQL Database
DATABASE_URL=postgresql://arise_user:arise_secret_password@localhost:5432/arise_db?schema=public

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT Cryptography (RS256 / HS256)
JWT_SECRET=arise_dev_jwt_secret_key_change_in_production_32_chars_min
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d

# Rate Limiting & Anti-Spam
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=60
AUTH_RATE_LIMIT_LIMIT=10

# AI Provider Configuration
AI_PROVIDER=mock                     # Options: 'gemini' | 'openai' | 'claude' | 'mock'
AI_MODEL=gemini-1.5-flash            # Model selector
GEMINI_API_KEY=
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
AI_DAILY_QUOTA=50                    # Per-user daily request quota
```

---

## 5. Security & Anti-Cheat Architecture Summary

1. **Server-Authoritative Economy**: The backend recomputes all XP, Mana, Energy, Rank, Level, Boss Damage, and Achievements from raw domain events and transaction ledgers. Any client-submitted final numbers are strictly ignored.
2. **Multi-Tenant Isolation**: All queries filter by `userId` extracted strictly from validated JWT claims. Direct object references across users return 404 Not Found.
3. **Idempotency & Replay Protection**: Every state-altering mutation requires an `Idempotency-Key` header. Duplicate submissions replay the cached response with zero duplicate mutations.
4. **Token Security & Reuse Detection**: Token families are tracked with single-use refresh tokens. Replaying an already-used token triggers immediate revocation of all active sessions for that account.
5. **AI Safety & Propose-Only Contract**: AI plans and suggestions are staged with status `pending_approval`. No real domain objects or quests are created without explicit user confirmation.

---

## 6. Offline-First Architecture Summary

1. **Drift SQLite Single Source of Truth**: All local reads and writes route through persistent SQLite tables (`quests`, `character_snapshot`, `bosses`, `gate_sessions`, `dungeons`, `local_event_queue`).
2. **Persistent Command Queue**: User operations are logged as domain commands with UUID idempotency keys, surviving process termination, backgrounding, and phone reboots.
3. **Automatic Synchronization**: `SyncEngine` listens to network transitions and drains the queue via batch sync endpoints with exponential backoff (2s &rarr; 4s &rarr; 8s).
4. **Authoritative Reconciliation**: Local optimistic predictions are reconciled against authoritative server responses upon reconnection.

---

## 7. Pre-Production Deployment Checklist

- [x] All 42 backend vitest test files pass (195 tests)
- [x] All 64 Flutter tests pass (0 failures)
- [x] Full 22-step End-to-End User Journey verified in both backend and frontend test harnesses
- [x] Database migrations verified with composite indexes and foreign key cascades
- [x] Zero critical paths depend on in-memory implementations in production builds
- [x] Rate limiting and XSS sanitization verified
- [x] Refresh token reuse detection verified
- [x] Network base URL environment configuration verified (`ApiConfig.auto()`)
- [x] UI responsive layouts, safe area insets (`AriseLayoutInsets`), and dynamic date headers verified
- [x] Audit report authored in `docs/MVP-VERIFICATION.md`
