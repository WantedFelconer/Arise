# Settings Module (`modules/settings`)

## Purpose
Manages user preferences, difficulty mode selection (Casual vs Hardcore), full data portability JSON export, and account deletion with 30-day PII purge lifecycle per §6.23 (FR-SET-001, FR-SET-002) and §6.24 (FR-MODE-001..003).

## Features
- **Preferences**: Theme, sound, haptics, notification toggles, language, privacy.
- **Difficulty Modes**: Config-driven parameters for XP rewards, Gate collapse penalties, and Boss recovery (non-retroactive).
- **Full Data Export**: GDPR/CCPA compliant JSON archive containing all user-owned domain records.
- **Account Erasure**: Soft-deletes user (`deletedAt`), invalidates sessions, and enqueues a 30-day permanent PII purge job in `jobs/account-purge.job.ts` (NFR-009, NFR-010).

## Endpoints
- `GET /api/v1/settings`: Get user settings.
- `PATCH /api/v1/settings`: Update settings.
- `GET /api/v1/settings/difficulty-mode`: Get current mode.
- `PUT /api/v1/settings/difficulty-mode`: Set mode (`casual` or `hardcore`).
- `GET /api/v1/settings/export`: Full JSON data export.
- `POST /api/v1/settings/account/delete`: Soft-delete account & schedule 30-day purge.
- `POST /api/v1/settings/account/cancel-deletion`: Cancel pending account deletion.
