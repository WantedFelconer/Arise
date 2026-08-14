You are executing ARISE SPRINT A2 — Real Networking + Authentication Vertical Slice. This is a FRESH Antigravity session. Do not carry over A1's conversation history — load artifacts, not transcripts.

============================================================
GOAL
============================================================
The goal of this sprint is to make authentication genuinely work between:

```
Flutter
    ↕
NestJS
    ↕
PostgreSQL
```

This should be the first complete end-to-end vertical slice.

Do not implement quests or AI yet.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A1.md` (A1 handoff digest)
4. The relevant Auth SRS/API requirements — from `ARISE_SRS.md`: Section 6.1 (FR-AUTH-001 … FR-AUTH-010), Section 9 API specification for auth endpoints, Section 13 Security Architecture (relevant parts), Section 11 Screen ↔ API Mapping (auth screens). Do not load the entire SRS.
5. The actual NestJS auth module (`backend/src/modules/auth`)
6. The actual Flutter auth screens (`client_web/`)

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. HTTP CLIENT
============================================================
Replace the current placeholder `ApiClient` with a real HTTP implementation.

Use **Dio** unless a justified existing dependency is preferable.

Implement:

- GET
- POST
- PATCH
- DELETE
- JSON decoding
- typed API errors
- timeouts

============================================================
2. AUTHENTICATION VERTICAL SLICE
============================================================
Wire the existing Flutter auth screens end-to-end against the real NestJS auth module and PostgreSQL:

- register / signup (with onboarding defaults where the backend requires them)
- login
- refresh token flow (access + refresh token lifecycle)
- logout
- token persistence via the secure storage built in A1 (never SharedPreferences / plain SQLite)

Verify the error contract matches the backend's uniform error shape and that the client maps it to typed, user-visible errors.

============================================================
3. INTEGRATION WITH A1 INFRASTRUCTURE
============================================================
- Use the persistent command queue for auth-adjacent mutations only where the SRS allows offline behavior; auth itself is server-gated — the UI must show an explicit offline limitation rather than pretending a login/register succeeded.
- Persist the authenticated user context so the persistent command queue can attach authenticated user context in later sprints.

============================================================
4. OFFLINE / UNAUTHORIZED HANDLING
============================================================
- 401 handling: trigger refresh; on refresh failure, surface a signed-out state cleanly.
- No hardcoded production endpoint — endpoint configuration must come from environment/build configuration.
- Do not begin implementing quests or AI.

============================================================
DEFINITION OF DONE
============================================================
- [ ] Real HTTP client replaces placeholder `ApiClient`; typed errors and timeouts implemented
- [ ] Full auth flow (register → login → refresh → logout) works Flutter ↔ NestJS ↔ PostgreSQL
- [ ] Refresh token handling proven (expired access token refreshes without user re-login)
- [ ] Tokens persisted via secure storage from A1; nothing secret in SharedPreferences / plain SQLite
- [ ] Error mapping matches backend uniform error shape
- [ ] Endpoint configuration is environment-driven, not hardcoded
- [ ] Tests pass; `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A2.md` handoff written for Sprint A3

Stop here. Sprint A3 starts in a fresh session.
