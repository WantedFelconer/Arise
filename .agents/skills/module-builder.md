---
name: module-builder
description: Use this skill when implementing a single feature module or engine assigned by the sprint-orchestrator. Scaffolds the module per the Clean Architecture template, implements it against its SRS slice only, and reports completion back to the sprint ledger.
role: builder
---

# Skill: Module Builder

## When to use this
When you've been handed exactly one ticket (one module or one engine) by the orchestrator, or directly by a human following the same pattern.

## Inputs to load (and nothing more)
- `.agents/rules/arise_flutter.md`
- The SRS excerpt for **this module only**: its Functional Requirements subsection (e.g., `FR-<MODULE>-<NNN>`), its rows in the Data Model, its API Specification endpoints, and its game engine / reward cascade contracts if applicable.
- Any explicitly-listed upstream dependency output (e.g., `core/rpg-engine.ts` method signatures) — not that dependency's full implementation history.
- The previous sprint's handoff digest, only if this module depends on something built in a prior sprint.

## What you do

1. **Scaffold the folder structure** exactly per `arise_flutter.md` Section 1.3 (backend: `<module>.module.ts` + `controller/service/repository/validation/dto/events/types/tests/README.md`, with routing expressed as NestJS controller decorators — no standalone `routes/` file; frontend: `presentation/application/domain/infrastructure`).
2. **Implement strictly within this module's boundary.** If the SRS slice references another module's data (e.g., Quest referencing Boss), call that module's public service method or listen for its domain event — never import its repository directly.
3. **Route all progression math through the centralized engine(s)** (`core/rpg-engine.ts`) rather than computing it locally. If the engine is missing a method you need, add the method to the engine in `core/` rather than duplicating the calculation here.
4. **Emit and consume in-process domain events consistently** with exact payload contracts documented in the module's `README.md`.
5. **Write tests** covering: the module's core business rules, its API contract, and — if the SRS lists an Acceptance Criterion or Use Case that this module is responsible for — a test that directly demonstrates that AC/UC passes.
6. **Write the module README** (purpose, responsibilities, public API, dependencies, DB tables, events emitted/consumed, extension points) before marking the ticket done.
7. **Flag assumptions, don't silently resolve them.** If the SRS slice is ambiguous or underspecifies something (a default value, an edge case), implement the most reasonable interpretation, but write it explicitly into the README's "extension points / open questions" area and into your completion note — the integration-reviewer and the human owner need to see these, not just inherit them silently.
8. **Report completion** as a one-line update to `docs/sprint-tracking/sprint-N.md` (module, status=done, one-line summary, any flagged assumptions) — this is what the orchestrator and reviewer read, not your full session transcript.

## Anti-patterns to avoid
- Hand-building an `express.Router()` or raw `app.use()` middleware for a module's routes instead of a NestJS `@Controller()` + `<module>.module.ts` (per `arise_flutter.md` rule 11).
- Reaching into another module's repository "just this once" for convenience.
- Computing an XP/Mana/streak/damage value inline instead of calling `core/rpg-engine.ts` or `core/reward-cascade.ts`.
- Marking a ticket done without tests or without a README.
- Silently guessing at an ambiguous requirement instead of flagging it in the completion note.
