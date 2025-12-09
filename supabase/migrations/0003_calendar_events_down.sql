-- Migration Rollback: 0003_calendar_events_down.sql
-- Purpose: Rollback calendar_events table creation
-- Reverts changes from 0003_calendar_events.sql

BEGIN;

-- Drop trigger
DROP TRIGGER IF EXISTS set_calendar_events_updated_at ON calendar_events;

-- Drop RLS policies
DROP POLICY IF EXISTS "Users can delete their own calendar events" ON calendar_events;
DROP POLICY IF EXISTS "Users can update their own calendar events" ON calendar_events;
DROP POLICY IF EXISTS "Users can create their own calendar events" ON calendar_events;
DROP POLICY IF EXISTS "Users can view their own calendar events" ON calendar_events;

-- Drop indexes (explicit for clarity, though CASCADE would handle it)
DROP INDEX IF EXISTS idx_calendar_recurring;
DROP INDEX IF EXISTS idx_calendar_user_upcoming;
DROP INDEX IF EXISTS idx_calendar_search_gin;
DROP INDEX IF EXISTS idx_calendar_person;
DROP INDEX IF EXISTS idx_calendar_user_event_type;
DROP INDEX IF EXISTS idx_calendar_user_range;
DROP INDEX IF EXISTS idx_calendar_user_date;

-- Drop table (CASCADE will drop foreign key constraints from child tables)
DROP TABLE IF EXISTS calendar_events CASCADE;

COMMIT;