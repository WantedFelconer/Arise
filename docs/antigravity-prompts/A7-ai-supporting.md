You are executing ARISE SPRINT A7 — AI + Supporting MVP Features. This is a FRESH Antigravity session. Do not carry over A6's conversation history — load artifacts, not transcripts.

============================================================
CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `docs/sprint-tracking/integration-A6.md` (A6 handoff digest)
4. From `ARISE_SRS.md`, only: Section 6.12 (FR-AIP-001 … ), Section 6.13 (FR-COACH-001 … ), Section 10 AI Architecture (full, including §10.5 quota), Section 7.4 AI state machine, Section 8.2 planner sequence, Section 11 Screen ↔ API Mapping (AI screens), and the MVP-supporting FR sections only if the SRS marks them MVP (reminders/notifications/statistics/achievements/settings/screen-time as applicable). Do not load the entire SRS.
5. The current Flutter AI Planner / AI Coach screens
6. The generated backend AI module (providers abstraction, planner, coach, mock provider) — for the exact API contracts

Act according to `.agents/skills/sprint-orchestrator.md`. Use `module-builder.md` for bounded implementation tickets. Use `integration-reviewer.md` at completion.

============================================================
1. AI PROVIDER
============================================================
Support development mock mode.

Support real provider mode through backend environment configuration.

Do not require an API key merely to run the application locally.

The SRS specifies provider abstraction; API keys are environment configuration, never hardcoded into business logic. The existing backend's mock provider is useful — now build the actual client integration on top of the abstraction.

============================================================
2. AI PLANNER
============================================================
Integrate:

- request plan
- display proposed plan
- user approval
- only after approval materialize real quests

AI must never silently create quests.

============================================================
3. AI COACH
============================================================
Connect the existing AI Coach screen.

Handle:

- loading
- response
- quota exceeded
- unauthorized
- offline
- provider unavailable

Offline behavior should be explicit rather than pretending AI is available.

============================================================
4. AI QUOTA
============================================================
Ensure the UI correctly reflects backend quota state.

Never trust a client-maintained quota.

============================================================
5. SUPPORTING MVP
============================================================
Integrate the MVP-required:

- reminders
- notifications
- statistics
- achievements
- settings
- screen-time related functionality

Only if these are actually MVP requirements in the SRS.

Do not implement P2/P3 roadmap functionality.

============================================================
6. UI
============================================================
Keep AI UI premium and restrained.

Do not create a generic chatbot UI that breaks ARISE's visual identity.

============================================================
7. TESTS
============================================================
Test with mock provider.

Test:

- approval gate
- quota
- unauthorized
- provider failure
- offline behavior

============================================================
DEFINITION OF DONE
============================================================
- [ ] AI Planner connected: request → proposed plan display → user approval → quests materialized only after approval
- [ ] AI never silently creates quests
- [ ] AI Coach connected with loading/response/quota-exceeded/unauthorized/offline/provider-unavailable handling
- [ ] Offline AI behavior is explicit, never a faked response
- [ ] Quota UI reflects backend quota state; no client-maintained quota trusted
- [ ] Supporting MVP features integrated only where the SRS marks them MVP; no P2/P3 roadmap scope
- [ ] AI UI preserves the ARISE visual identity
- [ ] Tests pass (mock provider, approval gate, quota, unauthorized, provider failure, offline); `integration-reviewer` has run
- [ ] `docs/sprint-tracking/integration-A7.md` handoff written for Sprint A8

STOP. Sprint A8 starts in a fresh session.