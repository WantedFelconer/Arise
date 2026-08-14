# Calendar Module

## Purpose
Merged scheduling view integrating internal quest deadlines and Google Calendar.

## Responsibilities
- Aggregate quests and gate sessions on a calendar view (FR-CAL-001)
- Two-way sync with Google Calendar via integration provider (FR-CAL-002)

## Public API
- `GET /api/v1/calendar/events`

## Database Tables
- None (or reads via public service / event contracts)

## Events Emitted / Consumed
- Documented during sprint implementation.
