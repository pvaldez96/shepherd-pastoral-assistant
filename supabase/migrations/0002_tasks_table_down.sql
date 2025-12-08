-- Migration: 0002_tasks_table_down.sql
-- Purpose: Rollback tasks table creation
-- Reverses changes made in 0002_tasks_table.sql

BEGIN;

-- Drop trigger
DROP TRIGGER IF EXISTS set_tasks_updated_at ON tasks;

-- Drop RLS policies
DROP POLICY IF EXISTS "Users can delete their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can update their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can create their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can view their own tasks" ON tasks;

-- Drop indexes (explicit for clarity, though CASCADE would handle it)
DROP INDEX IF EXISTS idx_tasks_user_active;
DROP INDEX IF EXISTS idx_tasks_title_gin;
DROP INDEX IF EXISTS idx_tasks_event;
DROP INDEX IF EXISTS idx_tasks_sermon;
DROP INDEX IF EXISTS idx_tasks_person;
DROP INDEX IF EXISTS idx_tasks_user_category;
DROP INDEX IF EXISTS idx_tasks_user_status_due;

-- Drop table (CASCADE will drop foreign key constraints from child tables)
DROP TABLE IF EXISTS tasks CASCADE;

COMMIT;
