-- Migration 001: ARISE Core Schema & Domain Event Store

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Domain Enums
CREATE TYPE difficulty_mode_enum AS ENUM ('casual', 'hardcore');
CREATE TYPE quest_type_enum AS ENUM ('daily', 'main', 'side', 'recurring', 'boss', 'ai_generated');
CREATE TYPE quest_status_enum AS ENUM ('active', 'in_progress', 'completed', 'archived', 'trashed');
CREATE TYPE boss_status_enum AS ENUM ('active', 'defeated');
CREATE TYPE dungeon_status_enum AS ENUM ('active', 'completed');
CREATE TYPE gate_status_enum AS ENUM ('in_progress', 'completed', 'collapsed');
CREATE TYPE capture_type_enum AS ENUM ('text', 'voice', 'photo', 'screenshot');
CREATE TYPE inbox_status_enum AS ENUM ('unsorted', 'triaged', 'converted');
CREATE TYPE reminder_type_enum AS ENUM ('quest', 'habit', 'deadline', 'wellness', 'behavioral');
CREATE TYPE period_enum AS ENUM ('daily', 'weekly', 'monthly', 'yearly');
CREATE TYPE sync_status_enum AS ENUM ('pending', 'syncing', 'synced', 'failed', 'conflict', 'cancelled');

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    difficulty_mode difficulty_mode_enum NOT NULL DEFAULT 'casual',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Characters Table
CREATE TABLE characters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    level INT NOT NULL DEFAULT 1,
    total_xp BIGINT NOT NULL DEFAULT 0,
    mana INT NOT NULL DEFAULT 100,
    energy INT NOT NULL DEFAULT 100,
    coins INT NOT NULL DEFAULT 0,
    gems INT NOT NULL DEFAULT 0,
    active_title_id VARCHAR(100) DEFAULT 'Novice Hunter',
    rank VARCHAR(50) DEFAULT 'E-Rank',
    stats JSONB NOT NULL DEFAULT '{"strength": 10, "agility": 10, "intelligence": 10, "vitality": 10, "perception": 10}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Dungeons Table
CREATE TABLE dungeons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    status dungeon_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bosses Table
CREATE TABLE bosses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dungeon_id UUID REFERENCES dungeons(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    hp_max INT NOT NULL DEFAULT 1000,
    hp_current INT NOT NULL DEFAULT 1000,
    difficulty INT NOT NULL DEFAULT 1,
    deadline TIMESTAMPTZ,
    status boss_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quests Table
CREATE TABLE quests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    boss_id UUID REFERENCES bosses(id) ON DELETE SET NULL,
    parent_quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    quest_type quest_type_enum NOT NULL DEFAULT 'main',
    priority INT NOT NULL DEFAULT 1,
    difficulty INT NOT NULL DEFAULT 1,
    deadline TIMESTAMPTZ,
    estimated_minutes INT NOT NULL DEFAULT 30,
    actual_minutes INT,
    status quest_status_enum NOT NULL DEFAULT 'active',
    eisenhower_quadrant INT CHECK (eisenhower_quadrant BETWEEN 1 AND 4),
    recurrence_rule JSONB,
    tags TEXT[] DEFAULT '{}',
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Quest Dependencies
CREATE TABLE quest_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quest_id UUID NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
    depends_on_quest_id UUID NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
    CONSTRAINT unique_quest_dep UNIQUE (quest_id, depends_on_quest_id),
    CONSTRAINT no_self_dependency CHECK (quest_id <> depends_on_quest_id)
);

-- Habits Table
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    frequency JSONB NOT NULL DEFAULT '{"type": "daily", "days": [1,2,3,4,5,6,7]}'::jsonb,
    skip_allowance INT NOT NULL DEFAULT 1,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    reminder_times TIME[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Habit Logs Table
CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    skipped BOOLEAN NOT NULL DEFAULT FALSE
);

-- Gate Sessions Table
CREATE TABLE gate_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quest_id UUID REFERENCES quests(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    planned_duration_s INT NOT NULL DEFAULT 1500,
    actual_duration_s INT,
    pause_count INT NOT NULL DEFAULT 0,
    exit_reason TEXT,
    status gate_status_enum NOT NULL DEFAULT 'in_progress',
    stability_final NUMERIC(5,2),
    xp_awarded INT,
    mana_delta INT,
    device_id VARCHAR(100) NOT NULL,
    client_event_id UUID UNIQUE NOT NULL
);

-- XP Transactions
CREATE TABLE xp_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    amount INT NOT NULL,
    source_event_type VARCHAR(100) NOT NULL,
    source_event_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Mana Transactions
CREATE TABLE mana_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    delta INT NOT NULL,
    source_event_type VARCHAR(100) NOT NULL,
    source_event_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Screen Time Sessions
CREATE TABLE screen_time_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    app_package VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    duration_s INT NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    mana_modifier_applied INT NOT NULL DEFAULT 0
);

-- Inbox Items Table
CREATE TABLE inbox_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    raw_content TEXT NOT NULL,
    capture_type capture_type_enum NOT NULL DEFAULT 'text',
    status inbox_status_enum NOT NULL DEFAULT 'unsorted',
    ai_suggested_destination JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Note Folders Table
CREATE TABLE note_folders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notes Table
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    folder_id UUID REFERENCES note_folders(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    tags TEXT[] DEFAULT '{}',
    notion_page_id VARCHAR(255),
    sync_status sync_status_enum NOT NULL DEFAULT 'synced',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reminders Table
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type reminder_type_enum NOT NULL,
    trigger_config JSONB NOT NULL,
    message TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Analytics Snapshots Table
CREATE TABLE analytics_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period period_enum NOT NULL,
    period_start DATE NOT NULL,
    metrics JSONB NOT NULL,
    ai_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Domain Event Store (Sync Events Log)
CREATE TABLE sync_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- client idempotency key
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    occurred_at_client TIMESTAMPTZ NOT NULL,
    received_at_server TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sync_status sync_status_enum NOT NULL DEFAULT 'pending',
    retry_count INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 1
);

-- Optimization Indexes
CREATE INDEX idx_quests_user_status ON quests(user_id, status);
CREATE INDEX idx_quests_boss ON quests(boss_id);
CREATE INDEX idx_quests_parent ON quests(parent_quest_id);
CREATE INDEX idx_habits_user ON habits(user_id);
CREATE INDEX idx_gate_sessions_user ON gate_sessions(user_id, status);
CREATE INDEX idx_sync_events_user_rec ON sync_events(user_id, received_at_server DESC);
CREATE INDEX idx_sync_events_idempotency ON sync_events(id, user_id);
