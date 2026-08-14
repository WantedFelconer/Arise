---
name: integration-reviewer
description: Use this skill after all tickets in a sprint are marked done. Audits cross-module boundaries and event contracts, runs the sprint's Acceptance Criteria and Use Cases as a checklist, and produces the compact handoff digest the next sprint depends on.
role: reviewer
---

# Skill: Integration Reviewer

## When to use this
At the end of every sprint, once the `sprint-orchestrator`'s ledger shows every ticket as `done` — and before the sprint is declared complete.

## Inputs to load
- `.agents/rules/arise_flutter.md`
- `docs/sprint-tracking/sprint-N.md` (the ledger — includes each builder's flagged assumptions)
- Each module's `README.md` produced this sprint (the interface contract)
- This sprint's Acceptance Criteria and Use Cases from `SPRINT_PLAN.md`

## What you do

1. **Boundary audit.** For each module built this sprint, confirm it does not import another module's `repository/` or internal `service/` methods, and that all cross-module reactions go through the in-process domain event bus or public service APIs. Flag any violation as a defect to fix before sign-off, not a note for later.
2. **Event contract audit.** Cross-check every event emitted or consumed this sprint against module READMEs and the domain event bus definitions for exact name and payload field match.
3. **Anti-cheat / authority audit.** For every module touching XP, Mana, Energy, Boss HP, streaks, achievements, or quotas, confirm the backend recomputes rather than trusts client-submitted values (FR-VALID-1..3 / Rule 6). This is the single most important check — a violation here undermines the entire progression system's integrity.
4. **Acceptance Criteria & Use Case walkthrough.** Run through this sprint's assigned ACs and UCs (per `SPRINT_PLAN.md`) as a literal checklist. Each either passes with evidence (a test, a demonstrable flow) or is logged as an open gap — never silently assumed to pass.
5. **Resolve or escalate flagged assumptions.** Review every "flagged assumption" builders logged in the ledger. Resolve the ones you can from the SRS/rule file; escalate ambiguous ones to the human owner rather than picking silently.
6. **Write the handoff digest** at `docs/sprint-tracking/sprint-N-handoff.md`. Keep it to roughly one page: modules built, each module's public API (method/endpoint signatures, not implementation), events emitted/consumed, config files introduced, and a short "known gaps / carried-forward assumptions" list. This digest — not this sprint's chat history — is what the next sprint's `sprint-orchestrator` loads.
7. **Only then** mark the sprint complete in `SPRINT_PLAN.md`'s tracking area.

## Anti-patterns to avoid
- Writing a handoff digest that just links back to full session transcripts instead of summarizing the interface contract — this defeats the entire point of context budgeting across sprints.
- Treating an AC/UC as "probably fine" without a concrete check.
- Deferring an anti-cheat/boundary violation to "clean up next sprint" — these compound and get harder to fix the longer they're load-bearing for other modules.
