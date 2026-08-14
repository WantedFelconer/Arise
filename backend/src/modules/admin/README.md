# Admin Module (`modules/admin`)

## Purpose
Exposes balancing constants, progression curves, penalty tables, and feature flags without requiring application code redeployments per §6.27 (FR-ADMIN-002).

## Endpoints
- `GET /api/v1/admin/config`: Balancing formulas & tables (XP curves, Mana modifiers, Gate rewards, boss damage).
- `GET /api/v1/admin/feature-flags`: Read path for system/user feature flags.
