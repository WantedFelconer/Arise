# Statistics Module (`modules/statistics`)

## Purpose
Provides aggregate lifetime performance statistics and streak summaries across quests, Gate focus sessions, project Bosses, Dungeons, screen time, fitness logs, and character progression per §6.20 (FR-STAT-001).

## Public API
- `StatisticsService.getLifetimeStats(userId)`: Computes full lifetime metrics aggregation.

## Endpoints
- `GET /api/v1/stats`: Returns aggregated lifetime stats object.
