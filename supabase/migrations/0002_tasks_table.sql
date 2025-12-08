-- Migration: 0002_tasks_table.sql
-- Purpose: Add tasks table for task management
-- Creates tasks table with RLS policies, indexes, and triggers
-- Dependencies: 0001_initial_schema.sql (users table, update_updated_at_column function)

-- Up Migration
BEGIN;

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tasks Table
-- Stores tasks for pastors with productivity features like energy levels,
-- focus requirements, and flexible categorization
-- ----------------------------------------------------------------------------
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Core task information
  title TEXT NOT NULL,
  description TEXT,

  -- Scheduling
  due_date DATE,
  due_time TIME,

  -- Time tracking
  estimated_duration_minutes INTEGER,
  actual_duration_minutes INTEGER,

  -- Task categorization and properties
  category TEXT NOT NULL CHECK (category IN (
    'sermon_prep', 'pastoral_care', 'admin',
    'personal', 'worship_planning'
  )),

  priority TEXT DEFAULT 'medium' CHECK (priority IN (
    'low', 'medium', 'high', 'urgent'
  )),

  status TEXT DEFAULT 'not_started' CHECK (status IN (
    'not_started', 'in_progress', 'done', 'deleted'
  )),

  -- Productivity features
  requires_focus BOOLEAN DEFAULT FALSE,
  energy_level TEXT DEFAULT 'medium' CHECK (energy_level IN (
    'low', 'medium', 'high'
  )),

  -- Relationships to other entities
  -- NOTE: Foreign key constraints for people, calendar_events, and sermons tables
  -- are temporarily omitted as those tables don't exist yet. They will be added
  -- in future migrations when those tables are created.
  person_id UUID, -- TODO: Add FK constraint in migration 0003_people_table.sql
  calendar_event_id UUID, -- TODO: Add FK constraint in migration 0004_calendar_events_table.sql
  sermon_id UUID, -- TODO: Add FK constraint in migration 0005_sermons_table.sql

  -- Self-referencing foreign key for subtasks (this is safe to add now)
  parent_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,

  -- Status timestamps
  completed_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT tasks_title_not_empty CHECK (length(trim(title)) > 0),
  CONSTRAINT tasks_estimated_duration_positive CHECK (
    estimated_duration_minutes IS NULL OR estimated_duration_minutes > 0
  ),
  CONSTRAINT tasks_actual_duration_positive CHECK (
    actual_duration_minutes IS NULL OR actual_duration_minutes > 0
  ),
  -- Ensure completed_at is only set when status is 'done'
  CONSTRAINT tasks_completed_at_requires_done_status CHECK (
    (completed_at IS NULL AND status != 'done') OR
    (completed_at IS NOT NULL AND status = 'done')
  ),
  -- Ensure deleted_at is only set when status is 'deleted'
  CONSTRAINT tasks_deleted_at_requires_deleted_status CHECK (
    (deleted_at IS NULL AND status != 'deleted') OR
    (deleted_at IS NOT NULL AND status = 'deleted')
  )
);

-- Add comments for documentation
COMMENT ON TABLE tasks IS 'Task management with productivity features for pastors';
COMMENT ON COLUMN tasks.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN tasks.user_id IS 'Foreign key to users table (multi-tenant isolation)';
COMMENT ON COLUMN tasks.title IS 'Task title (required, non-empty)';
COMMENT ON COLUMN tasks.description IS 'Optional detailed task description';
COMMENT ON COLUMN tasks.due_date IS 'Optional due date (DATE only, no time)';
COMMENT ON COLUMN tasks.due_time IS 'Optional due time (TIME only, paired with due_date)';
COMMENT ON COLUMN tasks.estimated_duration_minutes IS 'Estimated time to complete (in minutes)';
COMMENT ON COLUMN tasks.actual_duration_minutes IS 'Actual time spent (in minutes, tracked after completion)';
COMMENT ON COLUMN tasks.category IS 'Task category: sermon_prep, pastoral_care, admin, personal, worship_planning';
COMMENT ON COLUMN tasks.priority IS 'Task priority: low, medium, high, urgent';
COMMENT ON COLUMN tasks.status IS 'Task status: not_started, in_progress, done, deleted';
COMMENT ON COLUMN tasks.requires_focus IS 'Whether task requires dedicated focus time (no interruptions)';
COMMENT ON COLUMN tasks.energy_level IS 'Energy level required: low, medium, high (for smart scheduling)';
COMMENT ON COLUMN tasks.person_id IS 'Optional link to person (e.g., pastoral care task for specific member)';
COMMENT ON COLUMN tasks.calendar_event_id IS 'Optional link to calendar event (task tied to specific event)';
COMMENT ON COLUMN tasks.sermon_id IS 'Optional link to sermon (e.g., sermon prep tasks)';
COMMENT ON COLUMN tasks.parent_task_id IS 'Optional parent task for creating subtasks/hierarchies';
COMMENT ON COLUMN tasks.completed_at IS 'Timestamp when task was marked as done (NULL if not completed)';
COMMENT ON COLUMN tasks.deleted_at IS 'Timestamp when task was soft-deleted (NULL if active)';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Composite index for common query pattern: user's tasks filtered by status and due date
-- Supports queries like: WHERE user_id = X AND status = 'not_started' ORDER BY due_date
CREATE INDEX idx_tasks_user_status_due ON tasks(user_id, status, due_date);
COMMENT ON INDEX idx_tasks_user_status_due IS 'Accelerates dashboard queries filtering tasks by user, status, and due date';

-- Index for filtering tasks by user and category
-- Supports queries like: WHERE user_id = X AND category = 'sermon_prep'
CREATE INDEX idx_tasks_user_category ON tasks(user_id, category);
COMMENT ON INDEX idx_tasks_user_category IS 'Accelerates category-based task filtering per user';

-- Index for person-related task lookups
-- Supports queries like: WHERE person_id = X (for pastoral care workflows)
CREATE INDEX idx_tasks_person ON tasks(person_id);
COMMENT ON INDEX idx_tasks_person IS 'Accelerates person-related task lookups (for pastoral care)';

-- Index for sermon-related task lookups
-- Supports queries like: WHERE sermon_id = X (for sermon prep workflows)
CREATE INDEX idx_tasks_sermon ON tasks(sermon_id);
COMMENT ON INDEX idx_tasks_sermon IS 'Accelerates sermon-related task lookups (for sermon prep)';

-- Index for calendar event-related task lookups
-- Supports queries like: WHERE calendar_event_id = X
CREATE INDEX idx_tasks_event ON tasks(calendar_event_id);
COMMENT ON INDEX idx_tasks_event IS 'Accelerates calendar event-related task lookups';

-- Full-text search index on task title using GIN
-- Supports queries like: WHERE to_tsvector('english', title) @@ to_tsquery('sermon')
CREATE INDEX idx_tasks_title_gin ON tasks USING gin(to_tsvector('english', title));
COMMENT ON INDEX idx_tasks_title_gin IS 'Enables full-text search on task titles';

-- Partial index for active (non-deleted) tasks per user
-- Supports queries like: WHERE user_id = X AND deleted_at IS NULL
CREATE INDEX idx_tasks_user_active ON tasks(user_id, due_date) WHERE deleted_at IS NULL;
COMMENT ON INDEX idx_tasks_user_active IS 'Optimized index for active tasks (excludes soft-deleted tasks)';

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATED_AT
-- ============================================================================

-- Trigger for tasks table (reuses existing update_updated_at_column function)
CREATE TRIGGER set_tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER set_tasks_updated_at ON tasks IS 'Automatically updates updated_at timestamp on task modification';

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on tasks table
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- Tasks Table RLS Policies
-- All policies enforce multi-tenant isolation: users can only access their own tasks
-- ----------------------------------------------------------------------------

-- SELECT: Users can only view their own tasks
CREATE POLICY "Users can view their own tasks"
  ON tasks
  FOR SELECT
  USING (user_id = auth.uid());

-- INSERT: Users can only create tasks for themselves
CREATE POLICY "Users can create their own tasks"
  ON tasks
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- UPDATE: Users can only update their own tasks
CREATE POLICY "Users can update their own tasks"
  ON tasks
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- DELETE: Users can delete their own tasks (hard delete for emergencies)
-- Note: Soft delete is preferred (UPDATE status = 'deleted', deleted_at = NOW())
CREATE POLICY "Users can delete their own tasks"
  ON tasks
  FOR DELETE
  USING (user_id = auth.uid());

COMMENT ON POLICY "Users can view their own tasks" ON tasks IS 'Multi-tenant isolation: SELECT only own tasks';
COMMENT ON POLICY "Users can create their own tasks" ON tasks IS 'Multi-tenant isolation: INSERT only own tasks';
COMMENT ON POLICY "Users can update their own tasks" ON tasks IS 'Multi-tenant isolation: UPDATE only own tasks';
COMMENT ON POLICY "Users can delete their own tasks" ON tasks IS 'Multi-tenant isolation: DELETE only own tasks (soft delete preferred)';

-- ============================================================================
-- TEST DATA (Comment out for production deployment)
-- ============================================================================

-- Example test data insertion (uncomment for development/testing)
-- Assumes test user with ID 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' exists from 0001_initial_schema.sql
--
-- INSERT INTO tasks (user_id, title, description, category, priority, status, due_date, estimated_duration_minutes, requires_focus, energy_level) VALUES
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Prepare Sunday sermon outline', 'Create outline for sermon on John 3:16', 'sermon_prep', 'high', 'not_started', '2025-12-10', 120, TRUE, 'high'),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Visit hospitalized member', 'Visit Sarah at Memorial Hospital room 302', 'pastoral_care', 'urgent', 'not_started', '2025-12-08', 60, FALSE, 'medium'),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Review budget proposal', 'Review Q1 budget with finance committee', 'admin', 'medium', 'not_started', '2025-12-15', 45, FALSE, 'medium'),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Plan worship music', 'Select hymns and songs for Sunday service', 'worship_planning', 'medium', 'in_progress', '2025-12-09', 30, FALSE, 'low'),
--   ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Read devotional book', 'Continue reading "The Pastor" by Eugene Peterson', 'personal', 'low', 'not_started', NULL, 30, FALSE, 'low');

COMMIT;

-- ============================================================================
-- DOWN MIGRATION (for rollback reference)
-- ============================================================================

-- Uncomment the following section to create a separate down migration file
-- or use for rollback reference
--
-- File: 0002_tasks_table_down.sql

/*
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
*/

-- ============================================================================
-- TESTING QUERIES
-- ============================================================================

-- Example queries for testing RLS policies and indexes:
--
-- 1. View all active tasks for authenticated user (tests RLS SELECT policy):
--    SELECT id, title, category, priority, status, due_date
--    FROM tasks
--    WHERE user_id = auth.uid() AND deleted_at IS NULL
--    ORDER BY due_date ASC NULLS LAST;
--
-- 2. Create a new task (tests RLS INSERT policy):
--    INSERT INTO tasks (user_id, title, category, priority, due_date, estimated_duration_minutes)
--    VALUES (auth.uid(), 'Test sermon prep task', 'sermon_prep', 'high', '2025-12-20', 90)
--    RETURNING id, title, created_at;
--
-- 3. Update task status to done (tests RLS UPDATE policy and completed_at constraint):
--    UPDATE tasks
--    SET status = 'done', completed_at = NOW()
--    WHERE id = 'task-uuid-here' AND user_id = auth.uid()
--    RETURNING id, title, status, completed_at;
--
-- 4. Soft delete a task (tests RLS UPDATE policy and deleted_at constraint):
--    UPDATE tasks
--    SET status = 'deleted', deleted_at = NOW()
--    WHERE id = 'task-uuid-here' AND user_id = auth.uid()
--    RETURNING id, title, status, deleted_at;
--
-- 5. Full-text search on task titles (tests GIN index):
--    SELECT id, title, category, ts_rank(to_tsvector('english', title), to_tsquery('sermon')) AS rank
--    FROM tasks
--    WHERE user_id = auth.uid()
--      AND to_tsvector('english', title) @@ to_tsquery('sermon')
--    ORDER BY rank DESC;
--
-- 6. Query performance check (tests composite index usage):
--    EXPLAIN ANALYZE
--    SELECT id, title, priority, due_date
--    FROM tasks
--    WHERE user_id = auth.uid()
--      AND status = 'not_started'
--      AND due_date IS NOT NULL
--    ORDER BY due_date ASC
--    LIMIT 20;
--
-- Expected: Should use idx_tasks_user_status_due index (Index Scan, not Seq Scan)
-- Expected performance: < 5ms for tables with < 10,000 rows
--
-- 7. Test constraint violations:
--    -- Should fail: empty title
--    INSERT INTO tasks (user_id, title, category)
--    VALUES (auth.uid(), '   ', 'admin');
--
--    -- Should fail: invalid category
--    INSERT INTO tasks (user_id, title, category)
--    VALUES (auth.uid(), 'Test task', 'invalid_category');
--
--    -- Should fail: completed_at without done status
--    INSERT INTO tasks (user_id, title, category, status, completed_at)
--    VALUES (auth.uid(), 'Test task', 'admin', 'not_started', NOW());
--
-- 8. Test RLS isolation (should return 0 rows if attempting to access another user's tasks):
--    SELECT * FROM tasks WHERE user_id != auth.uid();
