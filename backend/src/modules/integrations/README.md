# Integration Module

## Purpose
Manages third-party OAuth connections for Notion, Google Calendar, and Health.

## Responsibilities
- OAuth handshake and secure token storage for external providers (FR-INT-001)
- Disconnect and credential revocation (FR-INT-002)

## Public API
- `POST /api/v1/integrations/:provider/connect`
- `DELETE /api/v1/integrations/:provider`

## Database Tables
- None (or reads via public service / event contracts)

## Events Emitted / Consumed
- Documented during sprint implementation.
