---
name: backend-ai-features
description: Integrates advanced AI engine components, vector database processing, embedding workflows, and LLM orchestration features.
---


## 11. AI Architecture

### 11.1 Provider Abstraction (recap)

All AI capability is accessed through the `AIProvider` interface (Section 3.9). Concrete providers (`OpenAIProvider`, `GeminiProvider`, `ClaudeProvider`) are selected by configuration; business modules (AI Planner, AI Coach, Inbox Triage, Natural Language Input) depend only on the interface, never on a vendor SDK.

### 11.2 AI Quest Planner Pipeline

1. **Context assembly** — the backend assembles: user's raw planning input, relevant existing Quests/Bosses/Dungeons, the user's learned per-category speed model (Section 11.4), current Mana/Energy, and Difficulty Mode.
2. **Prompt construction** — a structured prompt requesting a JSON plan: Main Quests, Subquests, time estimates, priorities, recommended schedule, XP rewards, dependencies.
3. **Provider call** — via `AIProvider.generatePlan()`, run as a background job (not a blocking HTTP request) given potential latency.
4. **Draft persistence** — stored with `status = pending_approval`; never auto-materialized into real Quests (constraint C-10 / FR-AIPLAN-4).
5. **User review** — client renders the draft as editable Quests/Subquests; user can add, remove, re-time, re-prioritize.
6. **Approval** — on approval, the backend materializes real Quest rows and emits `QuestCreated` events per item.

### 11.3 AI Coach Flows

- **Daily Planning**: given today's available hours, propose an ordered schedule from Active Quests, weighted by deadline, priority, Eisenhower quadrant, and current Energy curve.
- **Weekly Review**: prompt the user (what went well / what didn't / goals), and, combined with Analytics, produce a short reflective summary.
- **Monthly Reflection**: distinct from Weekly Review — longer-horizon narrative pulling from `analytics_snapshots`.
- **Overload Detection**: compares total estimated-minutes scheduled today/this week against a realistic capacity model; if exceeded, proposes specific Quests to move.
- **Procrastination Detection**: flags a Quest postponed beyond a configurable threshold count and offers to break it down or reschedule.
- **Rescheduling Suggestion**: triggered on a missed deadline; proposes new dates for affected Quests, requiring user approval before applying.

### 11.4 AI Memory (Learned User Model)

The AI Coach persists a lightweight, structured "learned model" per user — **not** a black-box embedding, but explicit fields the system can reason about and the user could, in principle, inspect: preferred study/work time windows, average actual-vs-estimated duration ratio per Quest category/tag, favorite session durations, and subjects/categories worked on most. This model is built from `FR-QUEST-6` actual-duration data and Gate session history, and is fed back into `FR-AIPLAN-5` estimate calibration.

### 11.5 AI Guardrails

- The AI never writes progression-affecting state directly (XP, Level, Boss HP); it only proposes Quests/schedules, which flow through the same validated creation/completion paths as manually-created ones.
- AI-generated plans always require explicit user approval before activation (C-10).
- If the AI provider is unreachable, the system degrades gracefully to manual entry — it never blocks core productivity functionality on AI availability (FR-AIPLAN-6).

---