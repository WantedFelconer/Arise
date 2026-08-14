import fs from 'fs';
import path from 'path';

interface ModuleConfig {
  name: string;
  pascalName: string;
  camelName: string;
  purpose: string;
  responsibilities: string[];
  endpoints: string[];
  tables: string[];
}

const modules: ModuleConfig[] = [
  {
    name: 'character',
    pascalName: 'Character',
    camelName: 'character',
    purpose: 'Manages user character state, level, stats, titles, rank, and inventory counters.',
    responsibilities: [
      'Fetch character progression and stats (FR-CHAR-001..004)',
      'Manage title equipping and cosmetic ranks (FR-CHAR-005)',
      'Provide read-only projection of total XP and current Mana',
    ],
    endpoints: [
      'GET /api/v1/character',
      'GET /api/v1/character/stats',
      'PATCH /api/v1/character/title',
    ],
    tables: ['characters', 'xp_transactions', 'mana_transactions'],
  },
  {
    name: 'quests',
    pascalName: 'Quest',
    camelName: 'quest',
    purpose: 'Core task and quest management supporting nesting, RRULE recurrence, and status transitions.',
    responsibilities: [
      'Quest CRUD and filtering (FR-QST-001..004)',
      'RRULE-based recurrence calculation (FR-QST-005)',
      'Trigger reward cascade on quest completion (FR-QST-011)',
      'Soft delete and restore (FR-QST-010)',
    ],
    endpoints: [
      'GET /api/v1/quests',
      'POST /api/v1/quests',
      'GET /api/v1/quests/:id',
      'PATCH /api/v1/quests/:id',
      'DELETE /api/v1/quests/:id',
      'POST /api/v1/quests/:id/complete',
    ],
    tables: ['quests'],
  },
  {
    name: 'bosses',
    pascalName: 'Boss',
    camelName: 'boss',
    purpose: 'Project-level milestones represented as Boss entities with depleteable HP bars.',
    responsibilities: [
      'Boss CRUD and progress tracking (FR-BOSS-001)',
      'Apply boss damage from linked quest completions (FR-BOSS-002)',
      'Handle boss defeat events and rewards (FR-BOSS-003)',
    ],
    endpoints: [
      'GET /api/v1/bosses',
      'POST /api/v1/bosses',
      'GET /api/v1/bosses/:id',
      'PATCH /api/v1/bosses/:id',
    ],
    tables: ['bosses'],
  },
  {
    name: 'dungeons',
    pascalName: 'Dungeon',
    camelName: 'dungeon',
    purpose: 'Long-horizon containers (e.g. semesters, quarters) grouping related Boss projects.',
    responsibilities: [
      'Dungeon CRUD and milestone status (FR-DUNG-001..003)',
      'Compute dungeon completion upon all child bosses defeated',
    ],
    endpoints: [
      'GET /api/v1/dungeons',
      'POST /api/v1/dungeons',
      'GET /api/v1/dungeons/:id',
    ],
    tables: ['dungeons'],
  },
  {
    name: 'gates',
    pascalName: 'Gate',
    camelName: 'gate',
    purpose: 'Focus session expeditions replacing traditional pomodoro timers with game stakes.',
    responsibilities: [
      'Start, pause, resume, and track focus sessions (FR-GATE-001..002)',
      'Compute stability and handle collapse penalties (FR-GATE-003)',
      'Trigger reward cascade on session completion (FR-GATE-004)',
      'Record focus metrics and historical stats (FR-GATE-005)',
    ],
    endpoints: [
      'POST /api/v1/gate/sessions',
      'PATCH /api/v1/gate/sessions/:id',
      'POST /api/v1/gate/sessions/:id/complete',
      'GET /api/v1/gate/stats',
    ],
    tables: ['gate_sessions'],
  },
  {
    name: 'ai',
    pascalName: 'Ai',
    camelName: 'ai',
    purpose: 'Intelligence layer providing AI plan drafting, coaching nudges, and vendor abstraction.',
    responsibilities: [
      'Abstract AI providers (Gemini, OpenAI, Claude) behind AIProvider interface (SRS §10.1)',
      'Generate draft quest plans with user approval requirement (FR-AIP-001..006, C-10)',
      'Provide daily schedule proposals and weekly reflection reviews (FR-COACH-001..007)',
      'Enforce per-user daily AI call quotas (SRS §10.5)',
    ],
    endpoints: [
      'POST /api/v1/ai/plan',
      'GET /api/v1/ai/plan/:jobId',
      'POST /api/v1/ai/plan/:jobId/approve',
      'POST /api/v1/ai/coach/daily',
      'POST /api/v1/ai/coach/weekly-review',
    ],
    tables: [],
  },
  {
    name: 'screen-time',
    pascalName: 'ScreenTime',
    camelName: 'screenTime',
    purpose: 'Monitors app categorization and computes server-authoritative Mana modifiers.',
    responsibilities: [
      'Ingest client app usage session logs (FR-SCREEN-001)',
      'Compute server-authoritative Mana impact per app category (FR-SCREEN-002)',
      'Identify peak distraction periods (FR-SCREEN-003)',
    ],
    endpoints: [
      'POST /api/v1/screen-time/sessions',
      'GET /api/v1/screen-time/insights',
    ],
    tables: [],
  },
  {
    name: 'reminders',
    pascalName: 'Reminder',
    camelName: 'reminder',
    purpose: 'Manages task deadlines, wellness reminders, and behavioral intervention schedules.',
    responsibilities: [
      'Create and schedule quest, habit, and wellness reminders (FR-REM-001)',
      'Support behavioral intervention reminders with delay timers (FR-REM-002)',
      'Throttle and batch reminder dispatching (FR-REM-004)',
    ],
    endpoints: [
      'GET /api/v1/reminders',
      'POST /api/v1/reminders',
      'PATCH /api/v1/reminders/:id',
      'DELETE /api/v1/reminders/:id',
    ],
    tables: ['reminders'],
  },
  {
    name: 'notes',
    pascalName: 'Note',
    camelName: 'note',
    purpose: 'Personal knowledge capture and baseline Notion integration.',
    responsibilities: [
      'Note CRUD with folders and tags (FR-NOTE-001)',
      'Sync individual notes with Notion pages (FR-NOTE-004)',
    ],
    endpoints: [
      'GET /api/v1/notes',
      'POST /api/v1/notes',
      'GET /api/v1/notes/:id',
      'PATCH /api/v1/notes/:id',
      'POST /api/v1/notes/:id/sync-notion',
    ],
    tables: ['notes'],
  },
  {
    name: 'fitness',
    pascalName: 'Fitness',
    camelName: 'fitness',
    purpose: 'Logs daily physical activities, steps, sleep, and feeds character stats.',
    responsibilities: [
      'Track steps, exercise, water intake, and sleep duration (FR-FIT-001)',
      'Feed logged activity into character stats and Mana recovery (FR-FIT-002)',
    ],
    endpoints: [
      'GET /api/v1/fitness/logs',
      'POST /api/v1/fitness/logs',
    ],
    tables: [],
  },
  {
    name: 'calendar',
    pascalName: 'Calendar',
    camelName: 'calendar',
    purpose: 'Merged scheduling view integrating internal quest deadlines and Google Calendar.',
    responsibilities: [
      'Aggregate quests and gate sessions on a calendar view (FR-CAL-001)',
      'Two-way sync with Google Calendar via integration provider (FR-CAL-002)',
    ],
    endpoints: [
      'GET /api/v1/calendar/events',
    ],
    tables: [],
  },
  {
    name: 'analytics',
    pascalName: 'Analytics',
    camelName: 'analytics',
    purpose: 'Aggregates productivity metrics, focus duration, and progression reports.',
    responsibilities: [
      'Aggregate daily, weekly, monthly, and yearly reports (FR-ANLY-001)',
      'Generate monthly narrative reflections (FR-ANLY-002)',
      'Cache analytics snapshots in Redis (NFR-CACHE-1)',
    ],
    endpoints: [
      'GET /api/v1/analytics/daily',
      'GET /api/v1/analytics/monthly',
    ],
    tables: [],
  },
  {
    name: 'achievements',
    pascalName: 'Achievement',
    camelName: 'achievement',
    purpose: 'Tracks and evaluates milestone unlocks, badge triggers, and title rewards.',
    responsibilities: [
      'Evaluate achievement trigger conditions against domain events (FR-ACH-001)',
      'Unlock achievements and award cosmetic titles/coins (FR-ACH-002)',
    ],
    endpoints: [
      'GET /api/v1/achievements',
      'GET /api/v1/achievements/unlocked',
    ],
    tables: [],
  },
  {
    name: 'notifications',
    pascalName: 'Notification',
    camelName: 'notification',
    purpose: 'In-app notification center and push notification dispatching via FCM.',
    responsibilities: [
      'Manage in-app notification center with read/unread flags (FR-NOTIF-002)',
      'Dispatch push notifications for reminders and coach nudges (FR-NOTIF-001)',
    ],
    endpoints: [
      'GET /api/v1/notifications',
      'PATCH /api/v1/notifications/:id/read',
    ],
    tables: [],
  },
  {
    name: 'integrations',
    pascalName: 'Integration',
    camelName: 'integration',
    purpose: 'Manages third-party OAuth connections for Notion, Google Calendar, and Health.',
    responsibilities: [
      'OAuth handshake and secure token storage for external providers (FR-INT-001)',
      'Disconnect and credential revocation (FR-INT-002)',
    ],
    endpoints: [
      'POST /api/v1/integrations/:provider/connect',
      'DELETE /api/v1/integrations/:provider',
    ],
    tables: [],
  },
  {
    name: 'settings',
    pascalName: 'Setting',
    camelName: 'setting',
    purpose: 'User preferences, circadian profile selection, difficulty mode, and data export/import.',
    responsibilities: [
      'Update user preferences and difficulty mode (FR-SET-001, FR-DIFF-001..003)',
      'Export and import complete user data in JSON format (FR-SET-002, NFR-PRIV-1)',
    ],
    endpoints: [
      'GET /api/v1/settings',
      'PATCH /api/v1/settings',
      'POST /api/v1/settings/export',
    ],
    tables: [],
  },
  {
    name: 'admin',
    pascalName: 'Admin',
    camelName: 'admin',
    purpose: 'System administration, config table management, and audit log inspection.',
    responsibilities: [
      'Manage XP curves and game balance configuration (SRS §17.3 rule 1)',
      'Audit log inspection for anti-cheat review (FR-VALID-003)',
    ],
    endpoints: [
      'GET /api/v1/admin/configs',
      'GET /api/v1/admin/audit-logs',
    ],
    tables: [],
  },
];

const basePath = path.resolve(__dirname, '../src/modules');

for (const mod of modules) {
  const modDir = path.join(basePath, mod.name);
  const subdirs = ['controller', 'service', 'repository', 'validation', 'dto', 'tests'];

  for (const sub of subdirs) {
    fs.mkdirSync(path.join(modDir, sub), { recursive: true });
  }

  // README.md
  const readmeContent = `# ${mod.pascalName} Module

## Purpose
${mod.purpose}

## Responsibilities
${mod.responsibilities.map((r) => `- ${r}`).join('\n')}

## Public API
${mod.endpoints.map((e) => `- \`${e}\``).join('\n')}

## Database Tables
${mod.tables.length > 0 ? mod.tables.map((t) => `- \`${t}\``).join('\n') : '- None (or reads via public service / event contracts)'}

## Events Emitted / Consumed
- Documented during sprint implementation.
`;
  fs.writeFileSync(path.join(modDir, 'README.md'), readmeContent);

  // dto
  const dtoContent = `export interface ${mod.pascalName}Dto {
  id?: string;
  [key: string]: unknown;
}
`;
  fs.writeFileSync(path.join(modDir, 'dto', `${mod.name}.dto.ts`), dtoContent);

  // validation
  const schemaContent = `import { z } from 'zod';

export const ${mod.camelName}Schema = z.object({
  id: z.string().uuid().optional(),
});
`;
  fs.writeFileSync(path.join(modDir, 'validation', `${mod.name}.schema.ts`), schemaContent);

  // repository
  const repoContent = `export interface ${mod.pascalName}Repository {
  findById(id: string): Promise<unknown | null>;
}

export class Prisma${mod.pascalName}Repository implements ${mod.pascalName}Repository {
  async findById(_id: string): Promise<unknown | null> {
    return null;
  }
}
`;
  fs.writeFileSync(path.join(modDir, 'repository', `${mod.name}.repository.ts`), repoContent);

  // service
  const serviceContent = `import { ${mod.pascalName}Repository } from '../repository/${mod.name}.repository';

export class ${mod.pascalName}Service {
  constructor(private readonly repo: ${mod.pascalName}Repository) {}

  async getById(id: string): Promise<unknown> {
    return this.repo.findById(id);
  }
}
`;
  fs.writeFileSync(path.join(modDir, 'service', `${mod.name}.service.ts`), serviceContent);

  // controller
  const controllerContent = `import { Request, Response, NextFunction } from 'express';
import { ${mod.pascalName}Service } from '../service/${mod.name}.service';

export class ${mod.pascalName}Controller {
  constructor(private readonly service: ${mod.pascalName}Service) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
`;
  fs.writeFileSync(path.join(modDir, 'controller', `${mod.name}.controller.ts`), controllerContent);

  // module
  const moduleContent = `import { Module } from '@nestjs/common';

@Module({})
export class ${mod.pascalName}Module {}
`;
  fs.writeFileSync(path.join(modDir, `${mod.name}.module.ts`), moduleContent);

  // test
  const testContent = `import { describe, it, expect } from 'vitest';
import { ${mod.pascalName}Service } from '../service/${mod.name}.service';
import { ${mod.pascalName}Repository } from '../repository/${mod.name}.repository';

describe('${mod.pascalName} Module (Scaffold)', () => {
  const mockRepo: ${mod.pascalName}Repository = {
    findById: async () => ({ id: 'test-id' }),
  };

  it('instantiates service cleanly', async () => {
    const service = new ${mod.pascalName}Service(mockRepo);
    const result = await service.getById('test-id');
    expect(result).toEqual({ id: 'test-id' });
  });
});
`;
  fs.writeFileSync(path.join(modDir, 'tests', `${mod.name}.test.ts`), testContent);
}

// Special AI providers subfolder
const aiProvidersDir = path.join(basePath, 'ai', 'providers');
fs.mkdirSync(aiProvidersDir, { recursive: true });

const aiProviderInterface = `export interface AIPlanningContext {
  goal: string;
  deadline?: string;
  availableHoursPerDay?: number;
  currentProficiency?: string;
  difficultyMode?: 'casual' | 'hardcore';
}

export interface AIPlanDraft {
  title: string;
  description: string;
  quests: Array<{
    title: string;
    description: string;
    estimatedMinutes: number;
    difficulty: string;
    priority: string;
  }>;
}

export interface AIProvider {
  name: string;
  generatePlan(ctx: AIPlanningContext): Promise<AIPlanDraft>;
}
`;
fs.writeFileSync(path.join(aiProvidersDir, 'ai-provider.interface.ts'), aiProviderInterface);

console.log('All modules scaffolded successfully with valid identifiers.');
