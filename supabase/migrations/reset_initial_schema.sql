-- Reset Script: Clean up existing tables before re-running migration
-- WARNING: This will delete all data in users and user_settings tables!
-- Only use this in development/testing

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

-- Now you can re-run 0001_initial_schema.sql
