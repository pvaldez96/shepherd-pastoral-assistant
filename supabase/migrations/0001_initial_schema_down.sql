-- Migration Rollback: 0001_initial_schema_down.sql
-- Purpose: Rollback initial schema migration
-- WARNING: This will delete all data in users and user_settings tables
-- Use only in development or emergency rollback scenarios

BEGIN;

-- ============================================================================
-- DROP RLS POLICIES
-- ============================================================================

-- User Settings Table Policies
DROP POLICY IF EXISTS "Users can delete their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can create their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can view their own settings" ON user_settings;

-- Users Table Policies
DROP POLICY IF EXISTS "Users can delete their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can create their own profile" ON users;
DROP POLICY IF EXISTS "Users can view their own profile" ON users;

-- ============================================================================
-- DROP TRIGGERS
-- ============================================================================

DROP TRIGGER IF EXISTS set_user_settings_updated_at ON user_settings;
DROP TRIGGER IF EXISTS set_users_updated_at ON users;

-- ============================================================================
-- DROP FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS update_updated_at_column();

-- ============================================================================
-- DROP INDEXES
-- ============================================================================

-- Note: Indexes will be automatically dropped with tables, but explicit for clarity
DROP INDEX IF EXISTS idx_user_settings_user_id;
DROP INDEX IF EXISTS idx_users_email;

-- ============================================================================
-- DROP TABLES
-- ============================================================================

-- Drop in reverse order of dependencies (child before parent)
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS users CASCADE;

COMMIT;
