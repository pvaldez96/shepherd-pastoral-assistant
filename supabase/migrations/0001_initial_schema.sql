-- Migration: 0001_initial_schema.sql
-- Purpose: Initial schema for Shepherd pastoral assistant application
-- Creates users and user_settings tables with RLS policies, indexes, and triggers
-- Dependencies: None (initial migration)

-- Up Migration
BEGIN;

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

-- Enable UUID generation (required for client-generated UUIDs and defaults)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Users Table
-- Stores core user profile information for pastors using Shepherd
-- ----------------------------------------------------------------------------
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  church_name TEXT,
  timezone TEXT DEFAULT 'America/Chicago' NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT users_name_not_empty CHECK (length(trim(name)) > 0)
);

-- Add comments for documentation
COMMENT ON TABLE users IS 'Core user profiles for pastors using Shepherd';
COMMENT ON COLUMN users.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN users.email IS 'User email address (unique, used for authentication)';
COMMENT ON COLUMN users.name IS 'Pastor full name';
COMMENT ON COLUMN users.church_name IS 'Name of the church the pastor serves';
COMMENT ON COLUMN users.timezone IS 'IANA timezone identifier (default: America/Chicago)';

-- ----------------------------------------------------------------------------
-- User Settings Table
-- Stores personalized configuration for each user's Shepherd experience
-- ----------------------------------------------------------------------------
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Contact frequency defaults (days)
  elder_contact_frequency_days INTEGER DEFAULT 30 NOT NULL,
  member_contact_frequency_days INTEGER DEFAULT 90 NOT NULL,
  crisis_contact_frequency_days INTEGER DEFAULT 3 NOT NULL,

  -- Sermon prep
  weekly_sermon_prep_hours INTEGER DEFAULT 8 NOT NULL,

  -- Workload
  max_daily_hours INTEGER DEFAULT 10 NOT NULL,
  min_focus_block_minutes INTEGER DEFAULT 120 NOT NULL,

  -- Focus time preferences
  preferred_focus_hours_start TIME DEFAULT '12:00' NOT NULL,
  preferred_focus_hours_end TIME DEFAULT '17:00' NOT NULL,

  -- Notification preferences (JSONB for flexible structure)
  notification_preferences JSONB DEFAULT '{}' NOT NULL,

  -- Offline data scope
  offline_cache_days INTEGER DEFAULT 90 NOT NULL,

  -- Archive settings
  auto_archive_enabled BOOLEAN DEFAULT TRUE NOT NULL,
  archive_tasks_after_days INTEGER DEFAULT 90 NOT NULL,
  archive_events_after_days INTEGER DEFAULT 365 NOT NULL,
  archive_logs_after_days INTEGER DEFAULT 730 NOT NULL,

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  UNIQUE(user_id),
  CONSTRAINT settings_elder_frequency_positive CHECK (elder_contact_frequency_days > 0),
  CONSTRAINT settings_member_frequency_positive CHECK (member_contact_frequency_days > 0),
  CONSTRAINT settings_crisis_frequency_positive CHECK (crisis_contact_frequency_days > 0),
  CONSTRAINT settings_sermon_hours_valid CHECK (weekly_sermon_prep_hours >= 0 AND weekly_sermon_prep_hours <= 168),
  CONSTRAINT settings_max_daily_hours_valid CHECK (max_daily_hours > 0 AND max_daily_hours <= 24),
  CONSTRAINT settings_min_focus_minutes_valid CHECK (min_focus_block_minutes > 0 AND min_focus_block_minutes <= 1440),
  CONSTRAINT settings_focus_hours_valid CHECK (preferred_focus_hours_end > preferred_focus_hours_start),
  CONSTRAINT settings_offline_cache_positive CHECK (offline_cache_days > 0),
  CONSTRAINT settings_archive_days_positive CHECK (
    archive_tasks_after_days > 0 AND
    archive_events_after_days > 0 AND
    archive_logs_after_days > 0
  )
);

-- Add comments for documentation
COMMENT ON TABLE user_settings IS 'User-specific configuration and preferences';
COMMENT ON COLUMN user_settings.user_id IS 'Foreign key to users table (one-to-one relationship)';
COMMENT ON COLUMN user_settings.elder_contact_frequency_days IS 'Default days between elder contacts';
COMMENT ON COLUMN user_settings.member_contact_frequency_days IS 'Default days between member contacts';
COMMENT ON COLUMN user_settings.crisis_contact_frequency_days IS 'Default days between crisis follow-ups';
COMMENT ON COLUMN user_settings.notification_preferences IS 'JSON object for flexible notification settings';
COMMENT ON COLUMN user_settings.offline_cache_days IS 'Number of days of data to keep in offline cache';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
COMMENT ON INDEX idx_users_email IS 'Accelerates login lookups by email';

-- User settings table indexes
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);
COMMENT ON INDEX idx_user_settings_user_id IS 'Accelerates settings retrieval by user_id';

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATED_AT
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates updated_at timestamp on row modification';

-- Trigger for users table
CREATE TRIGGER set_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for user_settings table
CREATE TRIGGER set_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- Users Table RLS Policies
-- ----------------------------------------------------------------------------

-- SELECT: Users can only view their own profile
CREATE POLICY "Users can view their own profile"
  ON users
  FOR SELECT
  USING (id = auth.uid());

-- INSERT: Users can create their own profile during registration
CREATE POLICY "Users can create their own profile"
  ON users
  FOR INSERT
  WITH CHECK (id = auth.uid());

-- UPDATE: Users can only update their own profile
CREATE POLICY "Users can update their own profile"
  ON users
  FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- DELETE: Users can delete their own profile
CREATE POLICY "Users can delete their own profile"
  ON users
  FOR DELETE
  USING (id = auth.uid());

-- ----------------------------------------------------------------------------
-- User Settings Table RLS Policies
-- ----------------------------------------------------------------------------

-- SELECT: Users can only view their own settings
CREATE POLICY "Users can view their own settings"
  ON user_settings
  FOR SELECT
  USING (user_id = auth.uid());

-- INSERT: Users can create their own settings
CREATE POLICY "Users can create their own settings"
  ON user_settings
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- UPDATE: Users can only update their own settings
CREATE POLICY "Users can update their own settings"
  ON user_settings
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- DELETE: Users can delete their own settings
CREATE POLICY "Users can delete their own settings"
  ON user_settings
  FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================================
-- TEST DATA (Comment out for production deployment)
-- ============================================================================

-- Example test data insertion (uncomment for development/testing)
-- INSERT INTO users (id, email, name, church_name, timezone) VALUES
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'john.doe@example.com', 'John Doe', 'First Community Church', 'America/New_York'),
--   ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'jane.smith@example.com', 'Jane Smith', 'Grace Fellowship', 'America/Los_Angeles');
--
-- INSERT INTO user_settings (user_id) VALUES
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
--   ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22');

COMMIT;

-- ============================================================================
-- DOWN MIGRATION
-- ============================================================================

-- Uncomment the following section to create a separate down migration file
-- or use for rollback reference

/*
BEGIN;

-- Drop RLS policies
DROP POLICY IF EXISTS "Users can delete their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can create their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can view their own settings" ON user_settings;

DROP POLICY IF EXISTS "Users can delete their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can create their own profile" ON users;
DROP POLICY IF EXISTS "Users can view their own profile" ON users;

-- Drop triggers
DROP TRIGGER IF EXISTS set_user_settings_updated_at ON user_settings;
DROP TRIGGER IF EXISTS set_users_updated_at ON users;

-- Drop function
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop indexes (will be automatically dropped with tables, but explicit for clarity)
DROP INDEX IF EXISTS idx_user_settings_user_id;
DROP INDEX IF EXISTS idx_users_email;

-- Drop tables (CASCADE will drop foreign key constraints)
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS users CASCADE;

COMMIT;
*/
