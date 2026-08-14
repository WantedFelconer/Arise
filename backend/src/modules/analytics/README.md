# Analytics Module (`modules/analytics`)

## Purpose
Generates periodic performance rollups (Daily, Weekly, Monthly, Yearly) over Character XP, Mana, Gate focus time, Screen Time, Quest completion rates, and Fitness metrics, providing permanent storage for monthly summaries per §6.14 (FR-ANLY-001, FR-ANLY-004).

## Ledger Reconciliation
- Recomputes metrics from authoritative transaction ledgers (`xp_transactions`, `mana_transactions`, `quests`, `gate_sessions`, `screen_time_sessions`, `fitness_logs`).
- Stores immutable snapshots in `analytics_snapshots`.

## Endpoints
- `GET /api/v1/analytics/daily?date=YYYY-MM-DD`: Daily report.
- `GET /api/v1/analytics/weekly?startDate=YYYY-MM-DD`: Weekly report.
- `GET /api/v1/analytics/monthly?year=YYYY&month=MM`: Monthly report.
- `GET /api/v1/analytics/yearly?year=YYYY`: Yearly report.
- `GET /api/v1/analytics/snapshots`: List stored snapshots.
- `POST /api/v1/analytics/snapshots/generate`: Manually trigger snapshot generation.
