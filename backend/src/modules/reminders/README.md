# Reminders Module (`modules/reminders`)

## Purpose
Manages scheduling, triggers, behavioral interventions, snooze, and delivery throttling for productivity and wellness reminders per §6.11 (FR-REM-001 through FR-REM-005).

## Features
- **Types**: Quest, deadline, hydration, medication, sleep, prayer, behavioral, custom.
- **Triggers**: ISO timestamp (one-off), daily/weekly time of day + days of week, and behavioral trigger phrases.
- **Throttling & Priority**: Max N (5) dispatches per hour per user, prioritized `deadline > urgent > high > medium > low > custom`.
- **Snooze**: Snooze reminder for N minutes.
- **Worker Execution**: Automated dispatch runs via BullMQ worker (`jobs/reminder-dispatch.job.ts`), avoiding blocking HTTP handlers (§15.2).

## Endpoints
- `GET /api/v1/reminders`: List reminders.
- `POST /api/v1/reminders`: Create reminder.
- `GET /api/v1/reminders/:id`: Get reminder.
- `PATCH /api/v1/reminders/:id`: Update reminder.
- `POST /api/v1/reminders/:id/snooze`: Snooze reminder.
- `DELETE /api/v1/reminders/:id`: Delete reminder.
