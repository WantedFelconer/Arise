# AI Intelligence Layer Module (`modules/ai`)

## 1. Purpose & Responsibilities

The **AI Intelligence Layer Module** implements the generative AI capabilities of the ARISE platform per **ARISE SRS Section 6.12, 6.13, and Section 10**:

1. **AI Quest Planner (`FR-AIP-001..006`, §6.12, §10.2, §10.3, §19 AC)**:
   - Decomposes high-level user goals and constraints into structured RPG quests and subquests.
   - Enforces **Rule 10 ("AI proposes, it never commits")** by staging plans in `ai_generated_plans` with `status: 'pending_approval'`. **Zero rows are written to the `quests` table until explicit user approval.**
   - Validates all AI structured output against the strict Section 10.3 JSON schema and Zod schema with automated single-turn error-correction retry before returning HTTP 422 `AI_PLAN_INVALID`.
   - Supports user editing (`status: 'edited'`), rejection (`status: 'rejected'`), and regeneration (`status: 'pending_approval'`).
   - Materializes approved plans into the primary `quests` table in a single transactional operation, preserving `parent_quest_id` hierarchy.
   - Blocks duplicate approval replay with HTTP 409 `AI_PLAN_ALREADY_APPROVED`.

2. **AI Coach (`FR-COACH-001..003`, §6.13, §10.4, §10.5)**:
   - Multi-turn conversational coaching sessions persisted across `ai_conversations` and `ai_messages`.
   - Read-only tool execution loop (§10.4) grounding responses in real application state (`get_recent_quests`, `get_xp_mana_trend`, `get_screen_time_summary`, `get_active_bosses`).
   - **Anti-Spoofing Architecture**: Server-side injection of the authenticated user's ID into all tool invocations — any model-supplied or client-supplied `userId` parameter is strictly stripped and ignored.
   - Guardrails: System prompt enforces medical, legal, and financial exclusion directives.
   - Proactive nudges (`GET /ai/coach/nudges`) for workload overload, overdue task procrastination, and boss battle momentum.
   - Daily schedule proposals (`POST /ai/coach/daily`) and weekly reviews (`POST /ai/coach/weekly-review`).

3. **AI Cost Controls & Quota Enforcement (§10.5)**:
   - Daily per-user request budget (`AI_DAILY_QUOTA`, default 50 calls/day), resetting at UTC midnight.
   - Concurrency safety with per-user mutex locking (`acquireLock`) preventing race condition budget overruns.
   - Returns HTTP 429 `AI_DAILY_QUOTA_EXCEEDED` when quota is exhausted.

4. **Security & Sanitization (§10.5, §13.4)**:
   - Input/output HTML sanitization (`sanitizer.util.ts`) stripping malicious script tags and event handlers to prevent Stored XSS.

---

## 2. Clean Architecture & Structure

```
backend/src/modules/ai/
├── providers/                     # Section 10.1 AI Provider Abstraction
│   ├── ai-provider.interface.ts   # Core AIProvider interface, ToolDefinition, ToolCall
│   ├── mock.adapter.ts            # Deterministic mock adapter for CI and unit tests
│   ├── gemini.adapter.ts          # Google Gemini 1.5 REST adapter
│   ├── openai.adapter.ts          # OpenAI GPT-4o REST adapter
│   ├── claude.adapter.ts          # Anthropic Claude 3.5 Sonnet REST adapter
│   └── ai-providers.module.ts     # Startup DI factory selecting provider via AI_PROVIDER env
├── quota/                         # Section 10.5 Quota & Feature Flags
│   └── ai-quota.service.ts        # Atomic check-and-increment, mutex lock, feature flag checks
├── planner/                       # Section 6.12 AI Quest Planner
│   ├── controller/                # HTTP route decorators
│   ├── service/                   # Staging, auto-retry, approval transaction
│   ├── dto/                       # Request/Response data transfer objects
│   └── validation/                # Zod schemas & JSON schema definitions (§10.3)
├── coach/                         # Section 6.13 AI Coach
│   ├── controller/                # Conversation, chat, daily, review, and nudge endpoints
│   ├── service/                   # Multi-turn chat persistence & tool calling loop
│   ├── tools/                     # 4 read-only server-scoped tool definitions & executor
│   ├── dto/                       # Coach DTOs
│   └── validation/                # Coach Zod validation schemas
├── utils/
│   └── sanitizer.util.ts          # XSS sanitization utilities
├── ai.module.ts                   # NestJS DI boundary
└── README.md                      # Module documentation
```

---

## 3. Public API Surface

All routes are protected by `JwtAuthGuard` and scoped under `/api/v1/ai`.

| Verb | Path | Description | Expected Status |
|---|---|---|---|
| `POST` | `/api/v1/ai/plan` | Generate and stage structured quest plan | 201 Created |
| `GET` | `/api/v1/ai/plan/:id` | Get staged plan by ID | 200 OK / 404 |
| `PATCH` | `/api/v1/ai/plan/:id` | Edit staged plan (`status -> 'edited'`) | 200 OK / 404 / 409 |
| `POST` | `/api/v1/ai/plan/:id/regenerate` | Re-prompt AI with feedback | 200 OK / 404 / 409 |
| `POST` | `/api/v1/ai/plan/:id/reject` | Reject/discard staged plan | 200 OK / 404 / 409 |
| `POST` | `/api/v1/ai/plan/:id/approve` | Approve plan & materialize into `quests` | 200 OK / 404 / 409 |
| `POST` | `/api/v1/ai/coach/conversations` | Create persistent coaching conversation | 201 Created |
| `GET` | `/api/v1/ai/coach/conversations` | List user's conversations | 200 OK |
| `GET` | `/api/v1/ai/coach/conversations/:id` | Get conversation with messages | 200 OK / 404 |
| `POST` | `/api/v1/ai/coach/conversations/:id/messages` | Multi-turn chat with tool execution | 201 Created / 404 / 429 |
| `POST` | `/api/v1/ai/coach/chat` | Single-turn direct coach chat | 200 OK / 429 |
| `POST` | `/api/v1/ai/coach/daily` | Generate daily schedule proposal | 200 OK / 429 |
| `POST` | `/api/v1/ai/coach/weekly-review` | Synthesize weekly productivity review | 200 OK / 429 |
| `GET` | `/api/v1/ai/coach/nudges` | Fetch proactive overload/procrastination nudges | 200 OK |

---

## 4. Dependencies & Module Ownership Rules

1. **Vendor SDK Isolation (Rule 8)**:
   - Business logic never imports `@google/generative-ai`, `openai`, `@anthropic-ai/sdk`, or `langchain` directly.
   - All AI calls route exclusively through the `AIProvider` interface injected via `AI_PROVIDER_TOKEN`.

2. **Cross-Module API Discipline (Rule 4)**:
   - `AiPlannerService` and `AiCoachService` call `QuestService`, `BossService`, and `CharacterService` via public service methods. They never read or write another module's database tables or repositories.

3. **Staging & Non-Commit Law (Rule 10)**:
   - Generated plans stay in `ai_generated_plans` until approved. The backend never auto-commits quests.

4. **Non-Monetization / No Billing Scaffolding (SRS §2.5 / ADR 0001)**:
   - Per ADR 0001, ARISE does **NOT** build billing, payment processing, or plan tiers here.
   - `AiQuotaService` includes a lightweight check against the `feature_flags` table as forward-compatible infrastructure. This is purely for operational feature toggles, **not monetization**.

---

## 5. Offline-First Contract & Behavior (Rule 6)

AI features are inherently online-only.
- If the AI provider is unreachable or returns a network failure, the backend throws HTTP 503 `AI_OFFLINE_UNAVAILABLE`.
- The system **never fakes a successful AI response while offline**, and does **not** queue raw AI inference calls into the general offline sync queue.
- Once an AI plan is approved online, the resulting `quests` are standard entities and will synchronize to local client storage via the sync engine.
