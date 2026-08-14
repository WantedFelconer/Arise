You are executing the FINAL ARISE HARDENING AND REGRESSION PASS. Fresh Antigravity session.

THIS IS NOT A FEATURE-DEVELOPMENT SPRINT. Do not add new product features. Do not build anything from §18 Future Roadmap. Your job is to prove — with evidence, not assertion — that what Sprints 1–4 built is secure, genuinely offline-first, internally consistent, and matches the SRS's own acceptance criteria. Where you find a real defect, fix it with a narrowly-scoped `module-builder` ticket; do not rebuild whole modules speculatively.

============================================================
LOAD
============================================================
This is the one session in the series permitted broad context, because regression requires it:
1. `.agents/rules/arise_flutter.md`
2. `docs/sprint-tracking/sprint-1-handoff.md` through `sprint-4-handoff.md`
3. `SPRINT_PLAN.md` (corrected version)
4. From `ARISE_SRS.md`: §12 (all NFRs), §13 (all), §16 (all), §17.3 (all), §18 (Future Roadmap — to confirm nothing in it was built), §19 (all Acceptance Criteria), plus the full §6 FR table for a priority-tag cross-check (you need to see every MVP-tagged row across every module to regress against it)

============================================================
ROLE
============================================================
Act primarily as `integration-reviewer` running a project-wide audit, not as `sprint-orchestrator` building new tickets. Use `module-builder` only for defect fixes discovered during the audit — scoped to the specific broken behavior, not a rewrite.

============================================================
1. SECURITY / ANTI-CHEAT AUDIT
============================================================
For each attack below: attempt it against the real running system (or a test that simulates it precisely), record expected defense, actual result, and evidence (test name + assertion, or request/response pair). A "should be fine" without a concrete check is a FAIL for that line.

| # | Attack | Expected defense |
|---|---|---|
| 1 | Client submits `{ xp: 999999999 }` to any endpoint | Ignored/rejected — no such endpoint accepts a final XP value |
| 2 | Client submits `{ level: 999 }` | Same |
| 3 | Client submits `{ mana: 999999 }` or a fake Mana delta on Screen Time ingestion | Server recomputes from raw data, ignores client value |
| 4 | Client submits `{ currentHp: 0 }` directly on a boss | No such endpoint; HP only changes via reward cascade |
| 5 | Client fabricates a streak/achievement unlock | Rejected — achievements evaluated server-side from ledger data only |
| 6 | Client calls `POST /quests/{id}/complete` twice (or replays an idempotency key) | Second call: 409 or identical cached result, zero duplicate ledger rows |
| 7 | Client submits a Gate session with a manipulated client-side elapsed time | Server computes elapsed time from `started_at` + `planned_duration_seconds`, ignores client-submitted duration (FR-GATE-008) |
| 8 | Client submits `{ premium: true }` or attempts to flip an AI `feature_flags` gate via a user-writable endpoint | No client-writable path to `feature_flags`; flags are read-only from the client's perspective |
| 9 | Client exceeds the daily AI budget by firing concurrent requests | Atomic counter prevents race; both requests can't both succeed if only one should |
| 10 | Client calls AI endpoints without authentication | 401 |
| 11 | Any response leaks an AI provider API key, FCM service-account credential, or JWT signing key | Never — grep test across all serializers/DTOs |
| 12 | User A requests user B's quest/boss/note/notification/etc. by ID | 403/404, verified for every resource type, not just Quests |
| 13 | A rotated (already-used) refresh token is replayed | 401, **and all active sessions for that user are revoked** — the literal §19 AC for FR-AUTH-004 |
| 14 | A revoked session's access token is used after revocation | Rejected once the token's `tokenVersion` no longer matches |
| 15 | Rate limits on `/auth/*` and AI endpoints are trivially bypassable (e.g. no limiting at all, or limiting keyed only on something spoofable) | Confirm Redis-backed limiting is actually enforced, not just present in code |
| 16 | AI-generated quest title/description contains a script tag or similar | Sanitized before storage/render — no stored XSS |

============================================================
2. OFFLINE-FIRST AUDIT
============================================================
Verify, per `arise_flutter.md`'s §6 Offline-First Authority Contract:
- Quest create/edit/delete/complete works with no network reachable, updates local state and UI immediately
- Gate start/complete/collapse works offline (session timing itself still ultimately reconciles against server `started_at` once synced — verify the client doesn't award itself XP for an unsynchronized session it can't prove happened)
- Queued operations survive an app restart before syncing
- On reconnect, queued operations sync, using the idempotency-key mechanism from Sprint 1
- A locally-modified XP/Level/Mana/Boss-HP value (simulating a tampered local DB) is **overwritten by the server's authoritative response** on next sync, not preserved
- A sync conflict on a simple editable field (e.g. quest title edited on two devices while offline) resolves without crashing and without duplicating rewards
- AI endpoints correctly refuse to operate offline rather than faking success (Sprint 3's documented behavior)

============================================================
3. IDEMPOTENCY / TRANSACTION AUDIT
============================================================
- Enumerate every endpoint that touches `xp_transactions`, `mana_transactions`, `bosses.current_hp`, or `user_achievements`. For each, confirm: single DB transaction (NFR-005), idempotency-key handling, no code path that updates the cached total (`characters.total_xp`, `current_mana`) without first writing the ledger row (§17.3 rule 1).
- Confirm the reward cascade (`core/reward-cascade.ts`) is the only writer to these tables reachable from a route handler — grep for any direct `characters` update outside `core/rpg-engine.ts` / `core/reward-cascade.ts`.

============================================================
4. API / AUTHORIZATION AUDIT
============================================================
- Every list endpoint supports pagination per §9.1 (`?page=&pageSize=` → `{ data, page, pageSize, total }`), even ones added in Sprint 4 — §17.3 rule 2 warns retrofitting pagination later breaks clients, confirm nobody skipped it.
- Every protected route requires `Authorization: Bearer` and derives identity from the token, never from a request body/query param.
- Error responses match the uniform `{ error: { code, message, details } }` shape everywhere, and never include a raw stack trace or internal exception message in a non-local environment.
- Admin-tagged surfaces (feature flags, balancing constants) are not reachable by a normal consumer JWT — separate audience claim per §13.2, if any admin surface beyond config-reading was built.

============================================================
5. PERFORMANCE / NFR AUDIT
============================================================
- NFR-001: 95th-percentile response time < 300ms for non-AI endpoints under nominal load — basic load test on `/quests` and `/gates` per §16's own testing table, record actual p95.
- NFR-002: AI Planner responds (incl. provider round-trip) within 15s p95, with a client-visible loading-state contract documented.
- Check for N+1 query patterns on any list endpoint that includes nested data (e.g. quest with children, boss with linked quests).
- Confirm indexes exist for the query patterns actually used (§5.3 already defines several — `idx_quests_user_status`, `idx_quests_parent`, `idx_quests_boss`, `idx_gate_sessions_user`, `idx_screentime_user_time`, `idx_fitness_user_type_time` — verify each is actually hit by its corresponding query, via `EXPLAIN`).

============================================================
6. FAILURE-MODE AUDIT
============================================================
Simulate and confirm graceful failure (clear error, no data corruption, no silent partial state) for: Postgres unavailable, Redis unavailable, AI provider unavailable/timeout, malformed request body, expired/invalid JWT, refresh failure, malformed AI provider output on both the first attempt and the retry attempt (confirm the documented `422 AI_PLAN_INVALID` actually fires).

============================================================
7. FULL ACCEPTANCE-CRITERIA + FR REGRESSION
============================================================
Run every literal AC in §19 as a checklist (not just the four examples reproduced in earlier sprint prompts — re-read §19 in full here, there may be criteria beyond the representative sample already covered). For each: PASS (with the test that proves it), FAIL (with what's broken), or BLOCKED (with why, e.g. a P2 dependency wasn't built).

Then walk every **MVP-tagged** row across all of §6 (6.1 through 6.27) and confirm it was actually built by some sprint — cross-reference against the four handoff digests. Anything MVP-tagged that fell through the cracks between sprints gets fixed here with a scoped `module-builder` ticket; anything genuinely missed and too large to fix in this session gets logged as a known gap in the final handoff, not silently ignored.

Confirm explicitly, by name, that nothing from §18 Future Roadmap was built (Skill Tree, Social/Guilds/Leaderboards, Prestige, seasonal content, AI rescheduling/long-term-memory, Habits, Inbox/Quick Capture, quest dependencies/templates, and everything else tagged P2/P3 across the sprints) — list what's deferred and confirm it, don't just assume it wasn't touched.

============================================================
8. FINAL DOCUMENTATION
============================================================
Write `HANDOFF_FINAL.md` at the repo root, covering:
- Architecture overview (matching what was actually built, not the original plan, where they diverged)
- Module inventory with public API per module
- Database schema overview
- Authentication/authorization model
- Offline-first sync model (as actually implemented, referencing the Offline-First Authority Contract)
- Reward-cascade/progression-authority model
- AI architecture (provider abstraction, planner, coach, budget mechanism)
- Security controls implemented, and the results of the section-1 attack table above
- Deployment requirements and environment variables (§15.4, confirmed current)
- Known limitations and known gaps (P2/P3 backlog, anything found-but-not-fixed in this audit)
- Recommended next steps for whoever picks up Phase 2/3 of §18

Also confirm every sprint's `docs/sprint-tracking/sprint-N-handoff.md` still exists and is accurate — patch any that drifted from what was actually shipped.

============================================================
DO NOT
============================================================
- Implement any §18 Future Roadmap item
- Build a payment/subscription system
- Treat "the code compiles" or "it probably passes" as sufficient evidence for any checklist item above — every PASS needs a named test or a reproducible request/response pair
- Defer a discovered anti-cheat or authorization violation "for later" — fix it now, it's the reason this sprint exists

============================================================
FINAL DEFINITION OF DONE
============================================================
- [ ] All 16 attack-table rows in section 1 tested with evidence
- [ ] Offline-first audit complete, tampered-local-state-gets-overwritten confirmed
- [ ] Idempotency/transaction audit complete, no direct writer to protected tables found outside `core/`
- [ ] API/authorization audit complete (pagination, uniform errors, admin isolation)
- [ ] NFR-001/002 measured with real numbers, not estimated
- [ ] Failure-mode simulations complete
- [ ] Every §19 AC resolved PASS/FAIL/BLOCKED with evidence
- [ ] Every MVP-tagged FR across §6 confirmed built or logged as a fixed-now/known gap
- [ ] §18 confirmed untouched, explicit list of what's deferred
- [ ] `HANDOFF_FINAL.md` written and accurate
- [ ] All four sprint handoff digests re-verified against what actually shipped

Only after every box above is checked with real evidence may the project be considered MVP-complete on the backend.
