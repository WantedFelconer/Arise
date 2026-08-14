# Fitness Module (`modules/fitness`)

## Purpose
Collects manual/ingested fitness metrics (steps, workout, sleep, water, weight, heart rate, calories) and awards character progression stats (Fitness, Health) and Mana recovery upon reaching daily thresholds per §6.17 (FR-FIT-001, FR-FIT-002).

## Config-Driven Progression (C-9, Rule 5)
- Evaluates activity against `src/config/fitness_thresholds.json`.
- Activity exceeding thresholds grants XP to specific stats (`fitness`, `health`) and restores Mana via `CharacterService`.

## Endpoints
- `POST /api/v1/fitness/logs`: Log fitness activity.
- `GET /api/v1/fitness/logs`: List fitness logs.
- `GET /api/v1/fitness/summary`: Aggregated fitness totals.
