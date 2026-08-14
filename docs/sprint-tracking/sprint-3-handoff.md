# ARISE Sprint 3 — Handoff Digest

**Date:** 2026-08-14  
**Sprint Name:** Sprint 3 — Intelligence Layer  
**Status:** COMPLETE & PASSING (99/99 Tests Passed across 28 Test Suites, 0 Lint Errors, Clean Build)  

---

## 1. Executive Summary & Delivered Scope

Sprint 3 successfully built the entire **Intelligence Layer** of ARISE per `ARISE_SRS.md` (§6.12, §6.13, §10, §7.4, §8.2, §9.2), `SPRINT_PLAN.md`, and `.agents/rules/arise_flutter.md`. All generative AI logic runs behind clean architecture provider abstractions, with robust schema validation, auto-correction retry loops, staging/approval workflows, anti-spoofing read-only tool calling, atomic per-user quota controls, and offline safety.

### Delivered Modules & Components

1. **AI Provider Abstraction (`backend/src/modules/ai/providers`)**:
   - **Verbatim §10.1 Interface**: Standardized `AIProvider` contract with `generateStructured` and `chat` methods, plus `ToolDefinition` and `ToolCall` schemas.
   - **Concrete Adapters**:
     - `MockAIProvider`: Deterministic adapter supporting queuing of structured responses and multi-turn chat responses (with tool-calling simulations) for CI and unit tests.
     - `GeminiAdapter`: REST adapter for Google Gemini 1.5 (`gemini-1.5-flash`, `gemini-1.5-pro`) using structured JSON mode.
     - `OpenAIAdapter`: REST adapter for OpenAI GPT-4o / GPT-4o-mini (`gpt-4o-mini`, `gpt-4o`) using `response_format: { type: "json_object" }`.
     - `ClaudeAdapter`: REST adapter for Anthropic Claude 3.5 Sonnet (`claude-3-5-sonnet-20241022`).
   - **Zero Vendor SDK Leakage (Rule 8)**: Active provider is selected via `AI_PROVIDER` env variable at startup in `AiProvidersModule` and injected via `AI_PROVIDER_TOKEN`. No vendor SDKs (`@google/generative-ai`, `openai`, `@anthropic-ai/sdk`, `langchain`) are imported in business logic.

2. **AI Quota & Cost Controls (`backend/src/modules/ai/quota`)**:
   - **Per-User Daily Quota Counter (§10.5)**: Atomic check-and-increment against `AI_DAILY_QUOTA` (default 50 calls/day), resetting automatically at UTC midnight.
   - **Concurrency Mutex Lock**: Per-user promise mutex (`acquireLock`) eliminates race conditions near the quota boundary, guaranteeing simultaneous requests cannot exceed budget.
   - **Forward-Compatible Feature Flag Scaffolding**: Integrated pre-check against `feature_flags` table (`ai_enabled`, `ai_planner_enabled`, `ai_coach_enabled`). Disabling throws HTTP 403 `FEATURE_DISABLED`. *(Explicitly documented as operational feature toggles, not monetization/billing per ADR 0001).*

3. **AI Quest Planner (`backend/src/modules/ai/planner`)**:
   - **§10.2 System Prompt & Context Enrichment**: Enriches prompts with user chronotype, character level, mana/energy, difficulty mode, and active bosses.
   - **§10.3 Schema Validation & Auto-Correction**: Validates AI JSON output with Zod (`aiPlanSchema`). On malformed output, automatically executes a single-turn error-correction retry before returning HTTP 422 `AI_PLAN_INVALID`.
   - **Staging Lifecycle (Rule 10 & §7.4)**: Plans are stored in `ai_generated_plans` with `status: 'pending_approval'`. **Zero rows are written to `quests` upon generation (Literal §19 AC-AIP-003).**
   - **Plan Mutation & Approval**: Supports editing (`status: 'edited'`), rejection (`status: 'rejected'`), regeneration, and atomic transactional materialization into `quests` preserving `parent_quest_id` (Literal §19 AC-AIP-005). Duplicate approvals return HTTP 409 `AI_PLAN_ALREADY_APPROVED`.

4. **AI Coach (`backend/src/modules/ai/coach`)**:
   - **Multi-Turn Chat Persistence**: Full session state tracked across `ai_conversations` and `ai_messages`.
   - **4 Server-Scoped Read-Only Tools (§10.4)**: `get_recent_quests`, `get_xp_mana_trend`, `get_screen_time_summary`, `get_active_bosses`.
   - **Anti-Spoofing Security Law**: Tool execution strictly discards any client- or model-supplied `userId` parameter and injects the authenticated JWT identity server-side.
   - **Safety & Disclaimers (§10.5)**: System prompt enforces medical, legal, and financial exclusion directives.
   - **Proactive Coaching & Routines**: Proactive nudges for capacity overload (>8h planned), overdue task procrastination, and boss battle momentum; daily schedule proposals (`POST /ai/coach/daily`); weekly reviews (`POST /ai/coach/weekly-review`).

5. **Stored-XSS Sanitizer (`backend/src/modules/ai/utils/sanitizer.util.ts`)**:
   - Sanitizes user input and model output by stripping script tags, `javascript:` URIs, and dangerous event handlers.

---

## 2. Acceptance Criteria & Literal AC Verification

| AC Identifier | Target Specification | Test Suite Verification | Status |
|---|---|---|---|
| **AC-AIP-003** | Given a submitted planning context (goal, constraints, deadline, available time per day)<br>When `POST /api/v1/ai/plan` is called<br>Then a structured plan is generated and staged in `ai_generated_plans` with `status = 'pending_approval'`<br>And **NO rows exist yet in `quests` for this plan**. | `backend/tests/sprint3-integration.test.ts`<br>`src/modules/ai/tests/ai-planner.test.ts` | **PASS** |
| **AC-AIP-005** | Given a staged plan in `pending_approval` or `edited` state<br>When `POST /api/v1/ai/plan/{id}/approve` is called<br>Then all subquests are created as `quests` rows with correct `parent_quest_id` pointing to the main quest in a single transaction<br>And `ai_generated_plans.status == "approved"`<br>And re-approving returns **409 Conflict** (`AI_PLAN_ALREADY_APPROVED`). | `backend/tests/sprint3-integration.test.ts`<br>`src/modules/ai/tests/ai-planner.test.ts` | **PASS** |
| **FR-COACH-003** | AI Coach executes tool-calling loops to ground responses in real database data without hallucinations. | `backend/tests/sprint3-integration.test.ts`<br>`src/modules/ai/tests/ai-coach.test.ts` | **PASS** |
| **Anti-Spoofing Law** | Tool execution rejects/ignores spoofed `userId` arguments in model tool-calls, strictly scoping queries to the authenticated user ID. | `src/modules/ai/tests/ai-coach.test.ts` | **PASS** |
| **Quota Limiting (§10.5)** | Daily requests are tracked atomically per user; requests exceeding budget receive HTTP 429 `AI_DAILY_QUOTA_EXCEEDED`. | `backend/tests/sprint3-integration.test.ts`<br>`src/modules/ai/tests/ai-quota.test.ts` | **PASS** |
| **Concurrency Race Safety** | Two simultaneous requests at limit 1 result in exactly 1 success and 1 HTTP 429 rejection. | `src/modules/ai/tests/ai-quota.test.ts` | **PASS** |
| **Offline Safety (Rule 6)** | Offline provider failures return HTTP 503 `AI_OFFLINE_UNAVAILABLE` and are never faked or queued into general offline replay. | `src/modules/ai/tests/ai-quota.test.ts` | **PASS** |
| **Multi-Tenant Isolation** | User B cannot view, edit, or approve User A's AI plans or read/send messages in User A's conversations. | `backend/tests/sprint3-integration.test.ts` | **PASS** |

---

## 3. Public Service APIs for Downstream Sprints

Downstream modules (Sprint 4: Habits, Streaks, Focus Analytics, Screen Time) can inject the following public services:

### `AiPlannerService` (`modules/ai/planner/service/ai-planner.service.ts`)
- `generatePlan(userId, input): Promise<AiGeneratedPlanResponse>`
- `getPlan(userId, planId): Promise<AiGeneratedPlanResponse>`
- `editPlan(userId, planId, input): Promise<AiGeneratedPlanResponse>`
- `regeneratePlan(userId, planId, input?): Promise<AiGeneratedPlanResponse>`
- `rejectPlan(userId, planId): Promise<AiGeneratedPlanResponse>`
- `approvePlan(userId, planId, input?): Promise<ApprovePlanResponse>`

### `AiCoachService` (`modules/ai/coach/service/ai-coach.service.ts`)
- `createConversation(userId, input): Promise<AiConversationResponse>`
- `listConversations(userId): Promise<AiConversationResponse[]>`
- `getConversation(userId, conversationId): Promise<AiConversationResponse>`
- `sendMessage(userId, conversationId, input): Promise<{ message, toolExecutions? }>`
- `directChat(userId, input): Promise<{ message: string }>`
- `getDailyProposal(userId, input): Promise<{ proposal, questsSuggested }>`
- `getWeeklyReview(userId, input): Promise<{ summary, statsSnapshot }>`
- `getNudges(userId): Promise<NudgeItem[]>`

### `AiQuotaService` (`modules/ai/quota/ai-quota.service.ts`)
- `checkAndIncrement(userId, feature): Promise<{ allowed, remaining, resetAt }>`
- `getQuotaStatus(userId): Promise<{ remaining, limit, resetAt }>`
- `setFeatureFlag(featureName, isEnabled, userId?): void`

### `AIProvider` (`modules/ai/providers/ai-provider.interface.ts`)
- Available via NestJS injection token `AI_PROVIDER_TOKEN`.

---

## 4. Test Execution & Build Verification

```
Test Files  28 passed (28)
     Tests  99 passed (99)
  Duration  5.19s
ESLint:     0 errors, 0 warnings
Nest Build: Clean output
```
