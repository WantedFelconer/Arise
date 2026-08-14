You are executing ARISE SPRINT 3 — Intelligence Layer. Fresh Antigravity session.

============================================================
LOAD (and nothing more)
============================================================
1. `.agents/rules/arise_flutter.md`
2. The Sprint 3 row of the corrected coverage table in `SPRINT_PLAN.md`
3. `docs/sprint-tracking/sprint-2-handoff.md`
4. From `ARISE_SRS.md`, only:
   - §6.12 AI Quest Planner (FR-AIP-001 … 006 MVP; 007, 008 P2)
   - §6.13 AI Coach (FR-COACH-001, 003 MVP; 002, 004 P2)
   - §10 AI Architecture, full (10.1 provider abstraction, 10.2 prompt construction, 10.3 JSON schema, 10.4 tool-calling, 10.5 cost/safety)
   - §7.4 AI Generated Plan Lifecycle
   - §8.2 AI Quest Planner sequence diagram
   - §9.2 AI endpoint group
   - §5.3 tables: `ai_conversations`, `ai_messages`, `ai_generated_plans` (already migrated in Sprint 1 — just the relevant rows)
   - §17.1 Phase 3
   - §19 AC for FR-AIP-003/005 (plan staging and approval)
   - §2.5 (confirms: no payment processing in scope) and ADR 0001 from Chat 0 (confirms: AI budget only, no subscription system)

============================================================
EXECUTION MODEL
============================================================
Act as `sprint-orchestrator`. Ticket order:
1. `ai/providers` (interface + at least one concrete adapter)
2. `ai/planner`
3. `ai/coach`
4. AI budget/quota enforcement (§10.5, cross-cutting for both planner and coach)

Dispatch to `module-builder`. Run `integration-reviewer` once all tickets in `docs/sprint-tracking/sprint-3.md` are `done`.

============================================================
PROVIDER ABSTRACTION — build exactly to §10.1
============================================================
Implement this interface verbatim (types may be refined, shape must match):

```typescript
interface AIProvider {
  generateStructured<T>(params: {
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    maxTokens?: number;
  }): Promise<T>;

  chat(params: {
    conversation: { role: 'user' | 'assistant' | 'system'; content: string }[];
    tools?: ToolDefinition[];
  }): Promise<{ content: string; toolCalls?: ToolCall[] }>;
}
```

- Concrete adapters: `OpenAIAdapter`, `GeminiAdapter`, `ClaudeAdapter` (implement at least one for real; stub the others behind the same interface if provider credentials aren't available in this environment — the point is the abstraction holds, not that all three are live)
- Active provider selected via `AI_PROVIDER` env var, **read once at startup, injected via dependency injection** — no `if (provider === 'openai')` branching scattered through business logic (§17.3 rule 4)
- No business logic outside `ai/providers/` imports a vendor SDK directly, ever (`arise_flutter.md` rule 8) — this is also a straightforward security requirement: provider API keys live only in backend environment configuration (§15.4), are never returned in any API response, never logged, never reach the Flutter client under any circumstance.

============================================================
AI QUEST PLANNER — build exactly to §6.12 / §10.2 / §10.3
============================================================
- User submits free-text context: goal, deadline, available time, constraints, resources (**FR-AIP-001**)
- System returns a structured plan — main quest + nested subquests + estimates + priorities + suggested schedule + XP rewards — conforming to the JSON schema in §10.3 (**FR-AIP-002**). Reproduce that schema exactly (required: `mainQuest.title`, `mainQuest.subquests[].title/estimatedMinutes/priority`; optional: `mainQuest.deadline`, `subquests[].dependsOnIndex`, `suggestedSchedule[]`).
- System prompt construction per §10.2: act as a planning engine not a conversational assistant; decompose into main quest + nested subquests; respect stated constraints; output **only** JSON conforming to the schema — no prose; never fabricate resources/dates not implied by input. User prompt = free-text context + structured hints (deadline, available time/day, current Mana/Energy pulled server-side via `core/rpg-engine`'s read path from Sprint 1).
- **Staging, not writing**: generated plans are stored in `ai_generated_plans` with `status = 'pending_approval'` and are **not** written to `quests` until approved (**FR-AIP-003**) — this is `arise_flutter.md` rule 10 ("AI proposes, it never commits") made concrete, and it's the literal §19 AC for FR-AIP-003/005:
  - Given a submitted planning context
  - When `POST /ai/plan` returns a structured plan
  - Then **no rows exist yet in `quests`** for this plan
  - When the user calls `POST /ai/plan/{id}/approve`
  - Then all subquests are created as `quests` rows **with correct `parent_quest_id` nesting in a single transaction**, and `ai_generated_plans.status == "approved"`
  - Write this exact test.
- User may edit the staged plan before approval — add/remove/reorder subquests, change estimates (**FR-AIP-004**); edits set `status = 'edited'` per §7.4's lifecycle
- On approval: materialize into `quests` rows preserving nesting, single transaction (**FR-AIP-005**) — reuse the quest-creation path from Sprint 2's `quests` module rather than duplicating insert logic
- Regeneration with additional context replaces the staged plan (**FR-AIP-006**)
- Output validated server-side against the §10.3 schema **before** staging; on validation failure, **one automatic retry** with an error-correction instruction appended; if still non-conforming, fail with `422 AI_PLAN_INVALID` (§10.3) — implement and test both the success path and the retry-then-fail path
- Plan lifecycle per §7.4: `pending_approval ↔ edited`, `pending_approval → approved` (materializes), `pending_approval → rejected` (discards)
- FR-AIP-007 (save as template) and FR-AIP-008 (schedule biased by Mana/Energy) are P2 — skip, note in handoff.

============================================================
AI COACH — build exactly to §6.13 / §10.4
============================================================
- Persistent chat interface backed by `ai_conversations`/`ai_messages`, for planning/review/reflection (**FR-COACH-001**)
- Tool-calling grounds responses in real data instead of hallucination (**FR-COACH-003**). Implement exactly these read-only tools, each automatically scoped to the authenticated user's ID server-side — **the model never supplies a user ID, ever**:
  - `get_recent_quests(status, limit)`
  - `get_xp_mana_trend(days)`
  - `get_screen_time_summary(period)` — Screen Time data doesn't exist until Sprint 4; implement the tool now returning an empty/placeholder result if no data exists yet, so the Coach's tool surface is complete and doesn't need revisiting
  - `get_active_bosses()`
- FR-COACH-002 (triggered daily/weekly/monthly review flows) and FR-COACH-004 (proactive postponement detection) are P2 — skip, note in handoff.

============================================================
COST & SAFETY CONTROLS — §10.5, and the AI-quota security requirement
============================================================
- **Per-user daily AI call budget**, configurable, default generous for MVP single-user context (§10.5) — this is the *only* quota/entitlement mechanism specified anywhere in this SRS. Implement it as a real, server-enforced counter (Redis or Postgres — Redis is a natural fit given TTL-based daily reset), checked **before** any provider call is made, incremented atomically to avoid a race where two concurrent requests both read the same "under budget" state and both proceed.
- All AI output is treated as **untrusted input** to the app layer: schema-validated (already covered above for the planner), and quest titles/descriptions sanitized before storage/render — this specifically prevents stored-XSS via AI-authored quest text (§10.5, §13.4).
- AI Coach system prompt explicitly excludes medical/legal/financial advice-giving; redirect those topics to a generic "consult a professional" response (§10.5) — enforce this in the fixed system prompt, and add a test asserting the system prompt contains this instruction (you can't easily test live-model behavior in CI without a real provider call, so the enforceable, testable contract is: the instruction is present in what's sent to the provider).
- **No payment/subscription system.** Per ADR 0001 and SRS §2.5, do not build billing, plan tiers, or payment processing here. What you *should* build, as light forward-compatible scaffolding only: a check, before the daily-budget check, against the existing `feature_flags` table (already in the §5.3 schema from Sprint 1) for an `ai_coach_enabled` / `ai_planner_enabled` style flag per user or globally. This gives a future premium system a place to plug in later without touching the AI module's internals — it is explicitly **not** an entitlement/billing system itself, just a flag read. Document this distinction in the module README so nobody mistakes it for monetization infrastructure.

============================================================
OFFLINE BEHAVIOR
============================================================
AI features are inherently online-only — there is no meaningful way to generate a plan or hold a coach conversation without reaching the provider. Per `arise_flutter.md`'s Offline-First Authority Contract (added in Chat 0): do not fake a successful AI response while offline, and do not queue AI calls into the general offline sync mechanism from Sprint 1 as if they were deferrable domain commands. Document in the module README that AI endpoints require connectivity and return a clear, distinguishable error when offline rather than silently failing or queuing.

============================================================
TESTING (per §16)
============================================================
- Provider abstraction: business logic never imports a vendor SDK directly (a lint rule or a simple grep-based test is fine here); provider swap via env var requires no business-logic change
- Planner: schema-validation success path, retry-then-422 path, staging-produces-no-quests-rows AC, approval-produces-correct-nesting-in-one-transaction AC (both literal §19 tests above), double-approval rejected
- Coach: tool calls are scoped to the authenticated user with no way for the model-supplied arguments to override that scoping; test by attempting to pass a foreign user id through a tool argument and confirming it's ignored/rejected
- AI budget: concurrent-request race test (two simultaneous calls near the budget boundary must not both succeed if only one should)
- Per §16's "AI" row: planner output validated against the §10.3 JSON Schema using recorded fixture prompts, run in CI **without live provider calls** (mocked adapter)

============================================================
DO NOT
============================================================
- Build a payment/subscription/billing system
- Let AI-generated content create or mutate `quests` rows without an explicit user approval step
- Import an OpenAI/Gemini/Claude SDK anywhere outside `ai/providers/`
- Let the model supply its own user-scoping for any tool call
- Treat the daily AI budget as optional or client-enforced — it's a server-side counter, checked server-side, every time

============================================================
DEFINITION OF DONE
============================================================
- [ ] `AIProvider` interface implemented exactly per §10.1, ≥1 real adapter working
- [ ] Provider keys confirmed server-only (grep/test for any client-facing leak)
- [ ] Planner staging/approval matches §7.4 lifecycle and both literal §19 ACs, with tests
- [ ] Schema validation + retry-once-then-422 behavior implemented and tested
- [ ] Coach tool-calling implemented, all four tools scoped server-side, tested against a spoofed-user-id attempt
- [ ] Daily AI budget enforced server-side, atomic under concurrency, tested
- [ ] `feature_flags`-based enable/disable hook present and clearly documented as non-billing scaffolding
- [ ] AI output sanitized before storage (XSS-safety test)
- [ ] Offline behavior documented, no fake success paths
- [ ] `integration-reviewer` boundary + anti-cheat audit passes
- [ ] `docs/sprint-tracking/sprint-3-handoff.md` written — provider interface, planner/coach public API, budget mechanism, P2 backlog (FR-AIP-007/008, FR-COACH-002/004)

Stop here. Sprint 4 starts fresh.
