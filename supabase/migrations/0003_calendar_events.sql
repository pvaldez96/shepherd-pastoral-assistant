-- Migration: 0003_calendar_events.sql
-- Purpose: Add calendar_events table for calendar and scheduling management
-- Creates calendar_events table with RLS policies, indexes, triggers, and full-text search
-- Dependencies: 0001_initial_schema.sql (users table, update_updated_at_column function)
--               0003_people_table.sql (people table for person_id FK) - NOTE: FK will be added when people table exists

-- Up Migration
BEGIN;

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Calendar Events Table
-- Stores calendar events for pastors with time management features including
-- energy tracking, preparation buffers, and relationship to people/tasks
-- ----------------------------------------------------------------------------
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Core event information
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,

  -- Date and time (TIMESTAMPTZ includes timezone information)
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,

  -- Event categorization
  event_type TEXT NOT NULL CHECK (event_type IN (
    'service', 'meeting', 'pastoral_visit', 'personal',
    'work', 'family', 'blocked_time'
  )),

  -- Recurring events support
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern JSONB, -- Stores recurrence rules (RRULE format or custom JSON)

  -- Time management features
  travel_time_minutes INTEGER,

  -- Energy and productivity tracking
  energy_drain TEXT DEFAULT 'medium' CHECK (energy_drain IN (
    'low', 'medium', 'high'
  )),

  -- Scheduling flexibility
  is_moveable BOOLEAN DEFAULT TRUE,

  -- Preparation time tracking
  requires_preparation BOOLEAN DEFAULT FALSE,
  preparation_buffer_hours INTEGER,

  -- Relationships to other entities
  -- NOTE: Foreign key constraint for people table will be added when that table is created
  -- in migration 0003_people_table.sql (or adjusted numbering)
  person_id UUID, -- TODO: Add FK constraint when people table exists: REFERENCES people(id) ON DELETE SET NULL

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT calendar_events_title_not_empty CHECK (length(trim(title)) > 0),
  CONSTRAINT calendar_events_end_after_start CHECK (end_datetime > start_datetime),
  CONSTRAINT calendar_events_travel_time_positive CHECK (
    travel_time_minutes IS NULL OR travel_time_minutes > 0
  ),
  CONSTRAINT calendar_events_prep_buffer_positive CHECK (
    preparation_buffer_hours IS NULL OR preparation_buffer_hours > 0
  ),
  -- Ensure preparation_buffer_hours is only set when requires_preparation is true
  CONSTRAINT calendar_events_prep_buffer_requires_flag CHECK (
    (preparation_buffer_hours IS NULL AND NOT requires_preparation) OR
    (preparation_buffer_hours IS NOT NULL AND requires_preparation) OR
    (preparation_buffer_hours IS NULL AND requires_preparation)
  )
);

-- Add comments for documentation
COMMENT ON TABLE calendar_events IS 'Calendar events with time management and energy tracking for pastors';
COMMENT ON COLUMN calendar_events.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN calendar_events.user_id IS 'Foreign key to users table (multi-tenant isolation)';
COMMENT ON COLUMN calendar_events.title IS 'Event title (required, non-empty)';
COMMENT ON COLUMN calendar_events.description IS 'Optional detailed event description';
COMMENT ON COLUMN calendar_events.location IS 'Event location (address, room, or virtual link)';
COMMENT ON COLUMN calendar_events.start_datetime IS 'Event start date and time (with timezone)';
COMMENT ON COLUMN calendar_events.end_datetime IS 'Event end date and time (with timezone, must be after start)';
COMMENT ON COLUMN calendar_events.event_type IS 'Event category: service, meeting, pastoral_visit, personal, work, family, blocked_time';
COMMENT ON COLUMN calendar_events.is_recurring IS 'Whether event repeats (default: false)';
COMMENT ON COLUMN calendar_events.recurrence_pattern IS 'JSONB recurrence rules (RRULE or custom format)';
COMMENT ON COLUMN calendar_events.travel_time_minutes IS 'Travel time buffer before event (in minutes)';
COMMENT ON COLUMN calendar_events.energy_drain IS 'Energy cost of event: low, medium, high (for recovery planning)';
COMMENT ON COLUMN calendar_events.is_moveable IS 'Whether event can be rescheduled (default: true)';
COMMENT ON COLUMN calendar_events.requires_preparation IS 'Whether event needs prep time (default: false)';
COMMENT ON COLUMN calendar_events.preparation_buffer_hours IS 'Hours needed for preparation (only if requires_preparation=true)';
COMMENT ON COLUMN calendar_events.person_id IS 'Optional link to person (e.g., meeting with specific member)';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Composite index for most common query pattern: user's events in date range
-- Supports queries like: WHERE user_id = X AND start_datetime BETWEEN Y AND Z
-- This is the PRIMARY index for calendar views (day/week/month)
CREATE INDEX idx_calendar_user_date ON calendar_events(user_id, start_datetime);
COMMENT ON INDEX idx_calendar_user_date IS 'Accelerates date range queries for calendar views (primary calendar index)';

-- Composite index for date range queries with end_datetime
-- Supports queries like: WHERE user_id = X AND start_datetime <= Y AND end_datetime >= Z
-- Useful for finding events that overlap a specific time period
CREATE INDEX idx_calendar_user_range ON calendar_events(user_id, start_datetime, end_datetime);
COMMENT ON INDEX idx_calendar_user_range IS 'Accelerates overlapping time range queries (event conflicts, availability)';

-- Index for filtering events by type per user
-- Supports queries like: WHERE user_id = X AND event_type = 'service'
CREATE INDEX idx_calendar_user_event_type ON calendar_events(user_id, event_type);
COMMENT ON INDEX idx_calendar_user_event_type IS 'Accelerates event type filtering per user';

-- Index for person-related event lookups
-- Supports queries like: WHERE person_id = X (for pastoral care workflows)
CREATE INDEX idx_calendar_person ON calendar_events(person_id);
COMMENT ON INDEX idx_calendar_person IS 'Accelerates person-related event lookups';

-- Full-text search index on event title and description using GIN
-- Supports queries like: WHERE to_tsvector('english', title || ' ' || COALESCE(description, '')) @@ to_tsquery('meeting')
CREATE INDEX idx_calendar_search_gin ON calendar_events
  USING gin(to_tsvector('english', title || ' ' || COALESCE(description, '')));
COMMENT ON INDEX idx_calendar_search_gin IS 'Enables full-text search on event titles and descriptions';

-- Partial index for upcoming events (future events only, excludes past)
-- Supports queries like: WHERE user_id = X AND start_datetime > NOW()
-- Significantly reduces index size by excluding historical events
CREATE INDEX idx_calendar_user_upcoming ON calendar_events(user_id, start_datetime)
  WHERE start_datetime > NOW();
COMMENT ON INDEX idx_calendar_user_upcoming IS 'Optimized index for upcoming events (excludes past events)';

-- Index for recurring events
-- Supports queries like: WHERE user_id = X AND is_recurring = TRUE
CREATE INDEX idx_calendar_recurring ON calendar_events(user_id) WHERE is_recurring = TRUE;
COMMENT ON INDEX idx_calendar_recurring IS 'Accelerates recurring event queries';

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATED_AT
-- ============================================================================

-- Trigger for calendar_events table (reuses existing update_updated_at_column function)
CREATE TRIGGER set_calendar_events_updated_at
  BEFORE UPDATE ON calendar_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER set_calendar_events_updated_at ON calendar_events IS 'Automatically updates updated_at timestamp on event modification';

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on calendar_events table
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- Calendar Events Table RLS Policies
-- All policies enforce multi-tenant isolation: users can only access their own events
-- ----------------------------------------------------------------------------

-- SELECT: Users can only view their own events
CREATE POLICY "Users can view their own calendar events"
  ON calendar_events
  FOR SELECT
  USING (user_id = auth.uid());

-- INSERT: Users can only create events for themselves
CREATE POLICY "Users can create their own calendar events"
  ON calendar_events
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- UPDATE: Users can only update their own events
CREATE POLICY "Users can update their own calendar events"
  ON calendar_events
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- DELETE: Users can delete their own events
CREATE POLICY "Users can delete their own calendar events"
  ON calendar_events
  FOR DELETE
  USING (user_id = auth.uid());

COMMENT ON POLICY "Users can view their own calendar events" ON calendar_events IS 'Multi-tenant isolation: SELECT only own events';
COMMENT ON POLICY "Users can create their own calendar events" ON calendar_events IS 'Multi-tenant isolation: INSERT only own events';
COMMENT ON POLICY "Users can update their own calendar events" ON calendar_events IS 'Multi-tenant isolation: UPDATE only own events';
COMMENT ON POLICY "Users can delete their own calendar events" ON calendar_events IS 'Multi-tenant isolation: DELETE only own events';

-- ============================================================================
-- TEST DATA (Comment out for production deployment)
-- ============================================================================

-- Example test data insertion (uncomment for development/testing)
-- Assumes test user with ID 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' exists from 0001_initial_schema.sql
--
-- INSERT INTO calendar_events (user_id, title, description, location, start_datetime, end_datetime, event_type, energy_drain, is_moveable, requires_preparation, preparation_buffer_hours, travel_time_minutes) VALUES
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sunday Worship Service', 'Weekly worship service', 'Main Sanctuary', '2025-12-14 10:00:00-05', '2025-12-14 11:30:00-05', 'service', 'high', FALSE, TRUE, 8, 15),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Staff Meeting', 'Weekly staff sync meeting', 'Conference Room', '2025-12-09 14:00:00-05', '2025-12-09 15:30:00-05', 'meeting', 'medium', TRUE, FALSE, NULL, 0),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Hospital Visit - Sarah Johnson', 'Visit Sarah at Memorial Hospital room 302', 'Memorial Hospital', '2025-12-10 15:00:00-05', '2025-12-10 16:00:00-05', 'pastoral_visit', 'medium', TRUE, FALSE, NULL, 30),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Family Dinner', 'Dinner with spouse', 'Home', '2025-12-09 18:30:00-05', '2025-12-09 20:00:00-05', 'family', 'low', FALSE, FALSE, NULL, 0),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sermon Preparation Block', 'Deep work time for sermon writing', 'Office', '2025-12-11 09:00:00-05', '2025-12-11 12:00:00-05', 'blocked_time', 'high', TRUE, FALSE, NULL, 0),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Board Meeting', 'Monthly board meeting', 'Fellowship Hall', '2025-12-17 19:00:00-05', '2025-12-17 21:00:00-05', 'meeting', 'medium', FALSE, TRUE, 3, 10);

COMMIT;

-- ============================================================================
-- DOWN MIGRATION (for rollback reference)
-- ============================================================================

-- Uncomment the following section to create a separate down migration file
-- or use for rollback reference
--
-- File: 0003_calendar_events_down.sql

/*
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
*/

-- ============================================================================
-- TESTING QUERIES
-- ============================================================================

-- Example queries for testing RLS policies and indexes:
--
-- 1. View all events for authenticated user (tests RLS SELECT policy):
--    SELECT id, title, event_type, start_datetime, end_datetime
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--    ORDER BY start_datetime ASC;
--
-- 2. Create a new event (tests RLS INSERT policy):
--    INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
--    VALUES (auth.uid(), 'Test Meeting', 'meeting', '2025-12-20 14:00:00-05', '2025-12-20 15:00:00-05')
--    RETURNING id, title, created_at;
--
-- 3. Update event details (tests RLS UPDATE policy):
--    UPDATE calendar_events
--    SET title = 'Updated Meeting Title', location = 'New Conference Room'
--    WHERE id = 'event-uuid-here' AND user_id = auth.uid()
--    RETURNING id, title, location, updated_at;
--
-- 4. Delete an event (tests RLS DELETE policy):
--    DELETE FROM calendar_events
--    WHERE id = 'event-uuid-here' AND user_id = auth.uid()
--    RETURNING id, title;
--
-- 5. Get events in date range (tests idx_calendar_user_date index):
--    SELECT id, title, start_datetime, end_datetime, event_type
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--      AND start_datetime >= '2025-12-09 00:00:00-05'
--      AND start_datetime < '2025-12-16 00:00:00-05'
--    ORDER BY start_datetime ASC;
--
-- 6. Find event conflicts (tests idx_calendar_user_range index):
--    -- Check if any events overlap with a proposed time slot
--    SELECT id, title, start_datetime, end_datetime
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--      AND start_datetime < '2025-12-15 16:00:00-05'  -- Before new event end
--      AND end_datetime > '2025-12-15 14:00:00-05'    -- After new event start
--    ORDER BY start_datetime;
--
-- 7. Full-text search on events (tests GIN index):
--    SELECT id, title, description,
--           ts_rank(to_tsvector('english', title || ' ' || COALESCE(description, '')),
--                   to_tsquery('sermon')) AS rank
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--      AND to_tsvector('english', title || ' ' || COALESCE(description, ''))
--          @@ to_tsquery('sermon')
--    ORDER BY rank DESC;
--
-- 8. Get upcoming events only (tests idx_calendar_user_upcoming partial index):
--    SELECT id, title, start_datetime, event_type
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--      AND start_datetime > NOW()
--    ORDER BY start_datetime ASC
--    LIMIT 10;
--
-- 9. Filter by event type (tests idx_calendar_user_event_type index):
--    SELECT id, title, start_datetime, location
--    FROM calendar_events
--    WHERE user_id = auth.uid()
--      AND event_type = 'service'
--    ORDER BY start_datetime DESC;
--
-- 10. Query performance check (tests composite index usage):
--     EXPLAIN ANALYZE
--     SELECT id, title, start_datetime, end_datetime, event_type
--     FROM calendar_events
--     WHERE user_id = auth.uid()
--       AND start_datetime >= NOW()
--       AND start_datetime <= NOW() + INTERVAL '30 days'
--     ORDER BY start_datetime ASC;
--
-- Expected: Should use idx_calendar_user_date or idx_calendar_user_upcoming (Index Scan)
-- Expected performance: < 5ms for tables with < 10,000 rows, < 50ms for 100,000+ rows
--
-- 11. Test constraint violations:
--     -- Should fail: empty title
--     INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
--     VALUES (auth.uid(), '   ', 'meeting', NOW(), NOW() + INTERVAL '1 hour');
--
--     -- Should fail: end before start
--     INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
--     VALUES (auth.uid(), 'Test Event', 'meeting', '2025-12-15 15:00:00', '2025-12-15 14:00:00');
--
--     -- Should fail: invalid event_type
--     INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
--     VALUES (auth.uid(), 'Test Event', 'invalid_type', NOW(), NOW() + INTERVAL '1 hour');
--
--     -- Should fail: negative travel time
--     INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime, travel_time_minutes)
--     VALUES (auth.uid(), 'Test Event', 'meeting', NOW(), NOW() + INTERVAL '1 hour', -30);
--
-- 12. Test RLS isolation (should return 0 rows if attempting to access another user's events):
--     SELECT * FROM calendar_events WHERE user_id != auth.uid();
--
-- 13. Calculate event load for a day (total hours scheduled):
--     SELECT DATE(start_datetime) AS event_date,
--            COUNT(*) AS event_count,
--            SUM(EXTRACT(EPOCH FROM (end_datetime - start_datetime)) / 3600) AS total_hours
--     FROM calendar_events
--     WHERE user_id = auth.uid()
--       AND start_datetime >= '2025-12-09 00:00:00'
--       AND start_datetime < '2025-12-10 00:00:00'
--     GROUP BY DATE(start_datetime);