-- Verification Script for 0002_tasks_table.sql
-- Run this after applying the migration to verify everything works correctly

-- ============================================================================
-- 1. VERIFY TABLE STRUCTURE
-- ============================================================================

-- Check if tasks table exists and has correct columns
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'tasks'
ORDER BY ordinal_position;

-- Expected columns:
-- id, user_id, title, description, due_date, due_time,
-- estimated_duration_minutes, actual_duration_minutes, category, priority,
-- status, requires_focus, energy_level, person_id, calendar_event_id,
-- sermon_id, parent_task_id, completed_at, deleted_at, created_at, updated_at

-- ============================================================================
-- 2. VERIFY CONSTRAINTS
-- ============================================================================

-- Check CHECK constraints
SELECT
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'tasks'::regclass
  AND contype = 'c'
ORDER BY conname;

-- Expected constraints:
-- tasks_title_not_empty, tasks_estimated_duration_positive,
-- tasks_actual_duration_positive, tasks_completed_at_requires_done_status,
-- tasks_deleted_at_requires_deleted_status, plus enum checks

-- ============================================================================
-- 3. VERIFY INDEXES
-- ============================================================================

-- Check all indexes on tasks table
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'tasks'
ORDER BY indexname;

-- Expected indexes:
-- tasks_pkey, idx_tasks_user_status_due, idx_tasks_user_category,
-- idx_tasks_person, idx_tasks_sermon, idx_tasks_event,
-- idx_tasks_title_gin, idx_tasks_user_active

-- ============================================================================
-- 4. VERIFY RLS POLICIES
-- ============================================================================

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'tasks';

-- Should return: tasks | t (true)

-- Check RLS policies
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'tasks'
ORDER BY policyname;

-- Expected policies:
-- "Users can view their own tasks" (SELECT)
-- "Users can create their own tasks" (INSERT)
-- "Users can update their own tasks" (UPDATE)
-- "Users can delete their own tasks" (DELETE)

-- ============================================================================
-- 5. VERIFY TRIGGERS
-- ============================================================================

-- Check triggers on tasks table
SELECT
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'tasks'
ORDER BY trigger_name;

-- Expected: set_tasks_updated_at (BEFORE UPDATE)

-- ============================================================================
-- 6. TEST DATA INSERTION (Requires authenticated user)
-- ============================================================================

-- Test 1: Insert a valid task
-- This should succeed if you're authenticated
INSERT INTO tasks (
  user_id,
  title,
  category,
  priority,
  status,
  due_date,
  estimated_duration_minutes,
  requires_focus,
  energy_level
) VALUES (
  auth.uid(), -- Replace with actual user UUID for testing
  'Test Task - Verify Migration',
  'admin',
  'medium',
  'not_started',
  CURRENT_DATE + INTERVAL '7 days',
  60,
  FALSE,
  'medium'
)
RETURNING id, title, category, created_at;

-- Test 2: Query inserted task
SELECT
  id,
  title,
  category,
  priority,
  status,
  due_date,
  created_at
FROM tasks
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 5;

-- Test 3: Update task status to 'done'
-- Replace 'your-task-id' with actual task ID from Test 1
UPDATE tasks
SET
  status = 'done',
  completed_at = NOW()
WHERE id = 'your-task-id' -- Replace with actual ID
  AND user_id = auth.uid()
RETURNING id, title, status, completed_at, updated_at;

-- Verify updated_at changed automatically (should be > created_at)

-- Test 4: Soft delete the task
UPDATE tasks
SET
  status = 'deleted',
  deleted_at = NOW()
WHERE id = 'your-task-id' -- Replace with actual ID
  AND user_id = auth.uid()
RETURNING id, title, status, deleted_at;

-- ============================================================================
-- 7. TEST CONSTRAINTS (Expected to fail)
-- ============================================================================

-- Test 5: Attempt to insert task with empty title (should fail)
-- INSERT INTO tasks (user_id, title, category)
-- VALUES (auth.uid(), '   ', 'admin');
-- Expected error: violates check constraint "tasks_title_not_empty"

-- Test 6: Attempt to insert task with invalid category (should fail)
-- INSERT INTO tasks (user_id, title, category)
-- VALUES (auth.uid(), 'Invalid Category Test', 'invalid');
-- Expected error: violates check constraint (category enum)

-- Test 7: Attempt to set completed_at without done status (should fail)
-- INSERT INTO tasks (user_id, title, category, status, completed_at)
-- VALUES (auth.uid(), 'Invalid Completion', 'admin', 'not_started', NOW());
-- Expected error: violates check constraint "tasks_completed_at_requires_done_status"

-- ============================================================================
-- 8. TEST FULL-TEXT SEARCH
-- ============================================================================

-- Insert sample tasks for search testing
INSERT INTO tasks (user_id, title, category) VALUES
  (auth.uid(), 'Prepare Sunday sermon on grace', 'sermon_prep'),
  (auth.uid(), 'Visit sick members at hospital', 'pastoral_care'),
  (auth.uid(), 'Review sermon outline from last week', 'sermon_prep');

-- Test full-text search
SELECT
  id,
  title,
  category,
  ts_rank(to_tsvector('english', title), to_tsquery('english', 'sermon')) AS rank
FROM tasks
WHERE user_id = auth.uid()
  AND to_tsvector('english', title) @@ to_tsquery('english', 'sermon')
ORDER BY rank DESC;

-- Should return tasks containing "sermon" ranked by relevance

-- ============================================================================
-- 9. TEST QUERY PERFORMANCE
-- ============================================================================

-- Test composite index usage
EXPLAIN ANALYZE
SELECT
  id,
  title,
  priority,
  due_date,
  category
FROM tasks
WHERE user_id = auth.uid()
  AND status = 'not_started'
  AND due_date IS NOT NULL
ORDER BY due_date ASC
LIMIT 20;

-- Expected: Should use idx_tasks_user_status_due index
-- Expected: Index Scan (not Seq Scan)
-- Expected performance: < 5ms for small datasets

-- ============================================================================
-- 10. CLEANUP TEST DATA (Optional)
-- ============================================================================

-- Delete all test tasks created during verification
-- DELETE FROM tasks
-- WHERE user_id = auth.uid()
--   AND title LIKE '%Test%'
--   OR title LIKE '%Verify%';

-- ============================================================================
-- VERIFICATION COMPLETE
-- ============================================================================

-- Summary checklist:
-- [ ] Table created with all 21 columns
-- [ ] All CHECK constraints present (9 total)
-- [ ] All indexes created (8 total including primary key)
-- [ ] RLS enabled on tasks table
-- [ ] All 4 RLS policies created (SELECT, INSERT, UPDATE, DELETE)
-- [ ] Trigger set_tasks_updated_at created
-- [ ] Can insert valid tasks
-- [ ] Can update tasks (status, completed_at, deleted_at)
-- [ ] Invalid data rejected by constraints
-- [ ] Full-text search works on titles
-- [ ] Composite index used in queries (check EXPLAIN ANALYZE)
-- [ ] updated_at automatically updates on modifications
