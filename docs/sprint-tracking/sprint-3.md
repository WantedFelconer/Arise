# Sprint 3 Tracking Ledger — Intelligence Layer

**Sprint Goal:** Provider-abstracted AI integrations for plan generation and coaching, with schema validation, auto-retry, staging/approval workflows, tool calling, atomic daily quota budget enforcement, and offline safety.

---

## Ticket Ledger

| Ticket | Module / Component | Status | Assignee | Summary |
|---|---|---|---|---|
| 1 | AI Providers (`ai/providers/`) | `done` | `module-builder` | Verbatim §10.1 `AIProvider` interface, `GeminiAdapter`, `OpenAIAdapter`, `ClaudeAdapter`, `MockAIProvider`, startup DI selection via `AI_PROVIDER`. Zero vendor SDK leaks. |
| 2 | AI Quota & Safety Layer (`ai/quota/`, `ai/utils/`) | `done` | `module-builder` | Atomic per-user daily call budget counter (`AI_DAILY_QUOTA`), UTC midnight reset, mutex lock concurrency protection, `feature_flags` hook scaffolding, and stored-XSS output sanitization. |
| 3 | AI Quest Planner (`ai/planner/`) | `done` | `module-builder` | §10.2 prompt construction, §10.3 JSON schema validation, auto-retry on malformed output, staging in `ai_generated_plans` with zero `quests` rows created, edits, regeneration, and single-transaction nested quest approval ACs. |
| 4 | AI Coach (`ai/coach/`) | `done` | `module-builder` | Multi-turn chat persistence (`ai_conversations`, `ai_messages`), 4 server-scoped read-only tools with anti-spoofing law, medical/legal/financial disclaimers, daily proposals, weekly reviews, and proactive nudges. |
| 5 | AI Module Wiring & Documentation (`modules/ai`) | `done` | `module-builder` | NestJS `AiModule` controller and provider wiring, module `README.md`, full unit and end-to-end integration tests. |
| 6 | Integration Review & Sprint Handoff | `done` | `integration-reviewer` | Boundary isolation audit, anti-spoofing audit, AC checklist verification, `docs/sprint-tracking/sprint-3-handoff.md`. |

---

## Module Completion Notes & Flagged Assumptions
- **Staging Law C-10 / Rule 10**: Verified by literal §19 AC-AIP-003 test asserting 0 rows in `quests` table upon plan generation. Quests only materialize on explicit `POST /ai/plan/:id/approve`.
- **Anti-Spoofing Scoping Law**: Verified by security test asserting that coach tools discard any model-supplied or client-supplied `userId` and use only the authenticated JWT token identity.
- **Provider Abstraction Law (Rule 8)**: Verified by AST and dependency tests asserting zero imports of `@google/generative-ai`, `openai`, `@anthropic-ai/sdk`, or `langchain` outside `ai/providers/`.
- **Offline Law (Rule 6)**: Offline provider failures consistently throw HTTP 503 `AI_OFFLINE_UNAVAILABLE` and are never faked or queued to general offline replay.
- **Forward-Compatible Feature Flag Scaffolding**: Integrated `feature_flags` table checks without introducing any monetization or billing logic per ADR 0001.
