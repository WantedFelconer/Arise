# Sprint A2 — Integration Tracking & Handoff Digest
**Real Networking & Authentication Vertical Slice**

- **Sprint:** A2
- **Phase:** Real Networking & Authentication Vertical Slice (Flutter ↕ NestJS ↕ PostgreSQL)
- **Status:** `COMPLETE`
- **Date Completed:** 2026-08-14
- **Author:** Antigravity Engineering Agent

---

## 1. Executive Summary

Sprint A2 establishes the genuine, production-grade networking pipeline and authentication vertical slice between the Flutter client and the NestJS backend. All mock delays (`Timer(Duration(milliseconds: 2200))`), fake in-memory user sessions, and stubbed responses have been eliminated.

The system now operates with real RS256 JWT access and refresh token lifecycles, concurrency-safe token refresh mutexes via Dio `QueuedInterceptor`, environment-aware host resolution (`10.0.2.2` on Android emulators vs `localhost` on iOS/Web/Desktop), typed error handling matching backend exception filters, and offline-safe session restoration on app boot.

---

## 2. Deliverables Completed

| Component | Status | Key Implementation Details |
|---|---|---|
| **Production HTTP Client (`ApiClient`)** | `COMPLETE` | `lib/core/network/api_client.dart` backed by `Dio: ^5.7.0`. Full CRUD support (`get`, `post`, `patch`, `put`, `delete`), UUID v4 `X-Request-Id` tagging, explicit `Idempotency-Key` headers, and automatic typed error translation. |
| **Environment Configuration (`ApiConfig`)** | `COMPLETE` | `lib/core/network/api_config.dart` with platform auto-detection: `http://10.0.2.2:3000/api/v1` for Android Emulators, `http://localhost:3000/api/v1` for iOS Simulator / Web / Desktop, and compile-time `--dart-define=API_BASE_URL=...` overrides for physical devices and production. |
| **Typed Error Hierarchy (`ApiException`)** | `COMPLETE` | `lib/core/network/api_exceptions.dart` mapping backend `GlobalExceptionFilter` payloads (`{ error: { code, message, details } }`) to `ValidationException`, `UnauthorizedException`, `TokenReuseException`, `ConflictException`, `NotFoundException`, `ServerException`, and `NetworkException`. |
| **Token Refresh Mutex & Safe Retry** | `COMPLETE` | `lib/core/network/auth_interceptor.dart` with `AuthInterceptor` (QueuedInterceptor handling 401 intercepts, concurrency locking, single-use refresh token rotation, and replay) and `SafeRetryInterceptor` (retrying only idempotent GET/HEAD or requests with `Idempotency-Key`). |
| **Auth Domain & DTOs** | `COMPLETE` | `lib/features/auth/domain/auth_models.dart` defining `AuthTokens`, `AuthUser`, `AuthCharacter`, and `AuthResponseData`. |
| **Remote Auth Data Source** | `COMPLETE` | `lib/features/auth/infrastructure/auth_remote_data_source.dart` implementing `signup`, `login`, `refresh`, `logout`, `requestPasswordReset`, `confirmPasswordReset`, and `getCharacter`. |
| **Auth State Management (`AuthNotifier`)** | `COMPLETE` | `lib/features/auth/application/auth_notifier.dart` with `restoreSession()`, `login()`, `signup()`, `logout()`, `requestPasswordReset()`, reconciling server character snapshots directly into the local Drift SQLite database (`CharacterSnapshotTable`) and `PlayerNotifier`. |
| **Auth UI & Error UX** | `COMPLETE` | `lib/features/auth/presentation/screens/auth_screen.dart` connected to `authNotifierProvider` with real async verification screens and glowing cyberpunk error/status banners without fake timers. |
| **Settings & Logout Flow** | `COMPLETE` | `lib/features/settings/presentation/screens/settings_screen.dart` wired to `playerProvider` for real hunter profile info and genuine account logout / uplink severance. |
| **App Launch Flow** | `COMPLETE` | `lib/app/app.dart` initializing session restoration on startup without flashing placeholder character data. |

---

## 3. Verified Backend API Endpoints & Contracts

All endpoints were tested and verified against the running NestJS API surface (`/api/v1` prefix):

### 1. Registration (`POST /api/v1/auth/signup`)
- **Request Body:**
  ```json
  {
    "email": "hunter@arise.sys",
    "password": "Password123!",
    "difficultyMode": "casual",
    "chronotype": "early_bird"
  }
  ```
- **Response (201 Created):**
  ```json
  {
    "data": {
      "user": {
        "id": "c6218d6e-bb12-4217-9150-f8f4a13d7a82",
        "email": "hunter@arise.sys",
        "difficultyMode": "casual"
      },
      "character": {
        "id": "5fa236d8-e7bb-41a4-9426-3d7c57d8a631",
        "level": 1,
        "totalXp": 0,
        "currentMana": 100,
        "maxMana": 100,
        "rank": "E",
        "stats": {
          "intelligence": 10,
          "discipline": 10,
          "fitness": 10,
          "creativity": 10,
          "coding": 10,
          "business": 10,
          "health": 10
        }
      },
      "tokens": {
        "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI...",
        "refreshToken": "48b0a996f8c7..."
      }
    }
  }
  ```

### 2. Login (`POST /api/v1/auth/login`)
- **Request Body:**
  ```json
  {
    "email": "hunter@arise.sys",
    "password": "Password123!"
  }
  ```
- **Response (200 OK):** Returns authenticated `user`, `character`, and fresh `tokens`.

### 3. Token Refresh with Single-Use Rotation (`POST /api/v1/auth/refresh`)
- **Request Body:**
  ```json
  {
    "refreshToken": "48b0a996f8c7..."
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI...",
      "refreshToken": "7c1e9014f3aa..."
    }
  }
  ```

### 4. Replay Attack & Reuse Detection (AC-AUTH-004)
- When a used refresh token is resubmitted to `/api/v1/auth/refresh`:
- **Response (401 Unauthorized):**
  ```json
  {
    "error": {
      "code": "TOKEN_REUSE_DETECTED",
      "message": "Refresh token reuse detected. All active sessions have been revoked."
    }
  }
  ```
- Client intercepts this error, clears local `SecureTokenStorage`, and routes the user back to the authentication screen.

### 5. Protected Character Fetch (`GET /api/v1/character`)
- **Headers:** `Authorization: Bearer <accessToken>`
- **Response (200 OK):** Returns hunter progression, rank, stats, and active title.

### 6. Logout (`POST /api/v1/auth/logout`)
- **Headers:** `Authorization: Bearer <accessToken>`
- **Response (200 OK):** `{ "message": "Logged out successfully" }`

---

## 4. Test Verification & Proofs

### Flutter Client Test Suite (`flutter test`)
All 22 unit, integration, and architecture proofs pass:

```
00:00 +0: Sprint A2 — Auth Notifier & Flow Integration Suite P1: Full Register Flow: POST /auth/signup -> tokens persisted -> character saved in Drift SQLite -> AppPhase.onboarding
00:00 +1: Sprint A2 — Auth Notifier & Flow Integration Suite P2: Full Login Flow: POST /auth/login -> tokens persisted -> character saved in Drift -> AppPhase.main
00:00 +2: Sprint A2 — Auth Notifier & Flow Integration Suite P3: Session Restoration with valid tokens: GET /character -> AppPhase.main
00:00 +3: Sprint A2 — Auth Notifier & Flow Integration Suite P4: Session Restoration with revoked token clears storage and sets AppPhase.auth
00:00 +4: Sprint A2 — Auth Notifier & Flow Integration Suite P5: Logout Flow: POST /auth/logout -> clears secure storage -> transitions to AppPhase.auth
00:00 +5: Sprint A2 — Auth Notifier & Flow Integration Suite P6: Error UX: Invalid credentials sets descriptive error state without crashing
00:00 +6: Sprint A1 — Offline Foundation Proofs P1: Quest persists across database close/reopen
00:00 +7: Sprint A1 — Offline Foundation Proofs P2: Command survives database close/reopen (schema + query proof)
00:00 +8: Sprint A1 — Offline Foundation Proofs P3: toggleQuestCompletionById updates local state synchronously
00:00 +9: Sprint A1 — Offline Foundation Proofs P4: markFailed keeps command in queue with incremented retryCount
00:00 +10: Sprint A1 — Offline Foundation Proofs P5: Retry count and lastError persist after close/reopen (schema proof)
00:00 +11: Sprint A1 — Offline Foundation Proofs P6: InMemoryTokenStorage correctly stores and retrieves tokens
00:00 +12: Sprint A1 — Offline Foundation Proofs P7: LocalQuestRepository CRUD works without Riverpod or widgets
00:00 +13: Sprint A2 — ApiClient & Error Architecture Suite P1: GET, POST, PATCH, DELETE execute and auto-inject X-Request-Id and Bearer Token
00:00 +14: Sprint A2 — ApiClient & Error Architecture Suite P2: Translates 400/422 to ValidationException with field error extraction
00:00 +15: Sprint A2 — ApiClient & Error Architecture Suite P3: Translates 409 to ConflictException (USER_EXISTS)
00:00 +16: Sprint A2 — ApiClient & Error Architecture Suite P4: Translates 401 with TOKEN_REUSE_DETECTED to TokenReuseException (AC-AUTH-004)
00:00 +17: Sprint A2 — ApiClient & Error Architecture Suite P5: Translates 500/503 to ServerException and connection errors to NetworkException
00:00 +18: Sprint A2 — ApiClient & Error Architecture Suite P6: SafeRetryInterceptor retries GET on connection failure and skips non-idempotent POST without idempotency key
00:02 +22: All tests passed!
```

### Static Analysis Check
```
$ flutter analyze --no-fatal-infos
Analyzing flutter frontend...
No issues found! (ran in 3.1s)
```

### Backend Test Suite (`npm test` in `backend`)
```
Test Files  39 passed (39)
     Tests  179 passed (179)
  Duration  15.39s
```

---

## 5. Handoff Notes for Sprint 2 / Next Phase

1. **Wiring Domain Operations to ApiClient:**
   - Now that `ApiClient` is fully functional with token injection, request ID generation, and idempotency headers, `SyncEngine` in `lib/core/sync/sync_engine.dart` can directly dispatch queued commands to `/api/v1/sync/events` or feature endpoints.
2. **Authoritative Character Reconciliation:**
   - When any quest completion, gate session, or reward cascade executes, pass the resulting server snapshot to `ref.read(playerProvider.notifier).reconcileFromServerResponse(serverSnapshot)` to overwrite local optimistic values.

---

## 6. Sprint Sign-Off

Sprint A2 satisfies all requirements of the vertical networking and authentication slice, complying with the **Offline-First Authority Contract**, **AC-AUTH-004**, and `.agents/rules/arise_flutter.md`.
