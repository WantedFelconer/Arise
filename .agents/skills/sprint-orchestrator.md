---
name: sprint-orchestrator
description: Use this skill when starting or coordinating a sprint. Breaks the sprint's scope into module-sized tickets, sequences them by dependency, assigns them to module-builder agents, and hands off to integration-reviewer when the sprint is complete.
role: orchestrator
---

# Skill: Sprint Orchestrator

## When to use this
At the start of any sprint from `SPRINT_PLAN.md`, or when resuming a sprint that was left partially complete.

## Inputs to load (and nothing more)
- `.agents/rules/arise_flutter.md`
- The **current sprint's section only** from `SPRINT_PLAN.md`
- The previous sprint's `docs/sprint-tracking/sprint-N-1-handoff.md`, if one exists
- The specific SRS excerpt named in that sprint's "SRS sections to load" list — do not load the full `ARISE_SRS.md`

## What you do

1. **Decompose the sprint into module-sized tickets.** One ticket per module or engine listed in the sprint's scope. A ticket should be small enough that a single `module-builder` agent session can complete it without running out of context.
2. **Sequence tickets by dependency**, not by SRS document order. Shared infrastructure, Prisma schema, and `core/rpg-engine.ts` must be ticketed (and completed) before the feature modules that consume them.
3. **Maintain a shared ledger** at `docs/sprint-tracking/sprint-N.md` with one row per ticket: module, status (`not_started`/`in_progress`/`done`/`blocked`), assigned agent session, and a one-line summary once done. This ledger — not chat history — is the source of truth for sprint progress.
4. **Dispatch each ticket** to a `module-builder` agent, giving it: this sprint's relevant SRS excerpt for *that specific module only*, the global rule file, and any prior-module outputs it explicitly depends on (e.g., an engine's public method signatures) — not the whole sprint's context.
5. **Do not let a builder agent silently expand scope** into another module's territory or into a later sprint. If a builder flags a missing dependency, either it's already done (point it to the ledger entry) or it's a real gap — raise it, don't route around it by having the builder implement it inline.
6. **When every ticket in the ledger is `done`**, hand off to the `integration-reviewer` skill for the sprint-closing review and handoff digest. Do not consider a sprint complete until that review has run.

## Anti-patterns to avoid
- Re-reading the entire `ARISE_SRS.md` "just to be safe" — if the sprint's excerpt is insufficient, that's a planning gap to fix in `SPRINT_PLAN.md`, not a reason to re-ingest the whole document every time.
- Assigning a builder agent more than one module at a time when the modules aren't tightly coupled — this is the main cause of context exhaustion and half-finished modules.
- Marking a ticket `done` without a module README and passing tests, per `arise_flutter.md` Section 2.
