# Screen Time Module (`modules/screen-time`)

## Purpose
Collects batch application usage sessions from client devices, computes server-authoritative Mana modifiers per category/app, detects distraction patterns, and enables user overrides per §6.10 (FR-SCREEN-001, FR-SCREEN-002).

## Anti-Cheat Architecture (Rule 7, NFR-008)
- The client submits raw usage data (`appPackage`, `durationS`, `occurredAt`).
- The backend evaluates the Mana impact strictly via `RpgEngine.calculateScreenTimeManaImpact` against config/user category tables.
- Any client-submitted `manaDelta` is explicitly ignored.

## PII Minimization (NFR-009)
- Stores only app package identifiers and durations — NEVER screen content, URLs, keystrokes, or active window text.

## Endpoints
- `POST /api/v1/screen-time/sessions`: Batch ingestion.
- `GET /api/v1/screen-time/insights`: Distraction and usage analysis.
- `GET /api/v1/screen-time/categories`: Config categories and overrides.
- `PUT /api/v1/screen-time/categories/:appPackage`: Set user override.
