You are executing ARISE SPRINT A0 — Post-Generation Frontend Audit & UI/UX Correction. This is a FRESH Antigravity session. Do not carry over any prior conversation history — load artifacts, not transcripts.

============================================================
IMPORTANT
============================================================
The backend has already been generated.
The Flutter frontend already exists.
Do NOT regenerate the project.
Do NOT rebuild the frontend from scratch.
Do NOT create a second architecture.
Do NOT begin implementing backend features.

Your responsibility in this sprint is to audit and improve the EXISTING Flutter client so it is ready to become the real ARISE MVP client.

============================================================
1. LOAD CONTEXT
============================================================
Load:

1. `.agents/rules/arise_flutter.md`
2. `SPRINT_PLAN.md`
3. `ARISE_SRS.md` — only for the relevant frontend/UI requirements (Section 11 Screen ↔ API Mapping, and the UI-affecting FR/NFR items). Do not load the entire SRS.
4. The existing Flutter repository (the real source under `client_web/`)
5. The previously generated backend — only for API/domain contract inspection

Act according to:

- `.agents/skills/sprint-orchestrator.md`
- Use `module-builder.md` for bounded implementation tickets
- Use `integration-reviewer.md` at completion

Do not load the entire historical conversation.

============================================================
2. PRIMARY OBJECTIVE
============================================================
Perform a senior-level frontend audit.

The goal is NOT to make the application look radically different.

The goal is to determine:

1. What is already good?
2. What is visually inconsistent?
3. What layouts are fragile?
4. What screens are incomplete?
5. What UI elements are misleading because they currently display fake/local data?
6. What interactions are placeholders?
7. What accessibility/usability problems exist?
8. What architecture problems will prevent offline-first integration?
9. What components should become reusable?
10. What screens need small but important UX corrections before data integration?

The existing ARISE visual identity must be preserved.

The design direction remains:

- immersive
- minimal

============================================================
3. KNOWN INHERITED STATE TO VERIFY
============================================================
The current Flutter project contains:

- `InMemoryPlayerRepository`
- `InMemoryQuestRepository`
- `InMemoryTokenStorage`
- an `ApiClient` that does not actually make HTTP requests

These are placeholders. Confirm their exact file locations, callers, and behavior during the audit. Do not assume anything about them — verify from the source.

============================================================
4. AUDIT OUTPUT
============================================================
Produce a written audit report at `docs/frontend-audit/A0-FRONTEND-AUDIT.md` that answers every question in section 2 with specific file/line references, plus a prioritized correction list.

The audit must classify every finding into:

- **Critical** — blocks real data integration or offline-first (architecture/layer violations, hardcoded fake data on a primary path, placeholder repositories on a primary path)
- **High** — misleading UI, fragile layouts, incomplete screens, accessibility blockers
- **Medium** — visual inconsistency, reusable-component opportunities, small UX corrections
- **Low** — polish

For each accepted correction, open a ticket in `docs/sprint-tracking/integration-A0.md` and implement it via `module-builder` as a bounded ticket.

============================================================
5. WHAT THIS SPRINT MAY DO
============================================================
- Fix identified UX/UI defects
- Replace fake/local data with loading/empty/error states where the real data does not yet exist (do NOT silently keep displaying fake data as if it were real)
- Refactor toward the required `presentation → application → domain ← infrastructure` layering, including surfacing (but not necessarily fixing) layer violations
- Make small, justified UI corrections that preserve the ARISE design language

============================================================
6. WHAT THIS SPRINT MUST NOT DO
============================================================
- Implement APIs, real networking, or backend integration (that is A2+)
- Build the local database or persistent command queue (that is A1)
- Regenerate or rebuild the project
- Add a second architecture
- Make unauthorized visual redesigns
- Implement quest/character/boss/gate/AI business logic

============================================================
DEFINITION OF DONE
============================================================
- [ ] `docs/frontend-audit/A0-FRONTEND-AUDIT.md` written — answers all 10 questions with file/line evidence
- [ ] Every finding classified Critical/High/Medium/Low
- [ ] Accepted corrections implemented as bounded tickets in `docs/sprint-tracking/integration-A0.md`, all `done`
- [ ] No remaining primary-path dependency on `InMemoryPlayerRepository` / `InMemoryQuestRepository` / `InMemoryTokenStorage` for display (loading/empty/error states in their place where real data is not yet wired)
- [ ] ARISE visual identity preserved
- [ ] `integration-reviewer` has run: UX correctness, no-regression, and architecture-layer audit
- [ ] `docs/sprint-tracking/integration-A0.md` handoff written for Sprint A1

Stop here. Sprint A1 starts in a fresh session, loading only the patched rules + its own context + this handoff digest.
