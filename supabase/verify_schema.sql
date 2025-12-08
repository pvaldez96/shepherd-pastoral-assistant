-- Schema Verification Script for Shepherd Initial Schema
-- Purpose: Comprehensive testing of RLS policies, triggers, constraints, and indexes
-- Usage: Run this after applying 0001_initial_schema.sql and test_data.sql

-- ============================================================================
-- PART 1: VERIFY TABLES EXIST
-- ============================================================================

SELECT 'Checking table existence...' AS status;

SELECT
  table_name,
  (table_schema = 'public') AS in_public_schema,
  (row_security = 'YES') AS rls_enabled
FROM information_schema.tables
WHERE table_name IN ('users', 'user_settings')
ORDER BY table_name;

-- ============================================================================
-- PART 2: VERIFY COLUMNS
-- ============================================================================

SELECT 'Checking users table columns...' AS status;

SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

SELECT 'Checking user_settings table columns...' AS status;

SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'user_settings'
ORDER BY ordinal_position;

-- ============================================================================
-- PART 3: VERIFY CONSTRAINTS
-- ============================================================================

SELECT 'Checking table constraints...' AS status;

SELECT
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name IN ('users', 'user_settings')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- ============================================================================
-- PART 4: VERIFY INDEXES
-- ============================================================================

SELECT 'Checking indexes...' AS status;

SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('users', 'user_settings')
ORDER BY tablename, indexname;

-- ============================================================================
-- PART 5: VERIFY RLS POLICIES
-- ============================================================================

SELECT 'Checking RLS policies...' AS status;

SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('users', 'user_settings')
ORDER BY tablename, cmd, policyname;

-- ============================================================================
-- PART 6: VERIFY TRIGGERS
-- ============================================================================

SELECT 'Checking triggers...' AS status;

SELECT
  event_object_table AS table_name,
  trigger_name,
  event_manipulation AS event,
  action_timing AS timing,
  action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('users', 'user_settings')
ORDER BY event_object_table, trigger_name;

-- ============================================================================
-- PART 7: VERIFY FOREIGN KEYS
-- ============================================================================

SELECT 'Checking foreign key relationships...' AS status;

SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON rc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('users', 'user_settings')
ORDER BY tc.table_name;

-- ============================================================================
-- PART 8: TEST UPDATED_AT TRIGGER
-- ============================================================================

SELECT 'Testing updated_at trigger...' AS status;

-- Create a temporary test user
DO $$
DECLARE
  test_user_id UUID := 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a66';
  original_updated_at TIMESTAMPTZ;
  new_updated_at TIMESTAMPTZ;
BEGIN
  -- Insert test user
  INSERT INTO users (id, email, name, church_name)
  VALUES (test_user_id, 'trigger.test@example.com', 'Trigger Test', 'Test Church');

  -- Get original updated_at
  SELECT updated_at INTO original_updated_at
  FROM users WHERE id = test_user_id;

  -- Wait 1 second
  PERFORM pg_sleep(1);

  -- Update the user
  UPDATE users SET name = 'Trigger Test Updated' WHERE id = test_user_id;

  -- Get new updated_at
  SELECT updated_at INTO new_updated_at
  FROM users WHERE id = test_user_id;

  -- Verify updated_at changed
  IF new_updated_at > original_updated_at THEN
    RAISE NOTICE 'SUCCESS: updated_at trigger works correctly (% -> %)', original_updated_at, new_updated_at;
  ELSE
    RAISE EXCEPTION 'FAILURE: updated_at trigger did not update timestamp';
  END IF;

  -- Cleanup
  DELETE FROM users WHERE id = test_user_id;
END $$;

-- ============================================================================
-- PART 9: TEST CONSTRAINTS
-- ============================================================================

SELECT 'Testing constraints (these should all FAIL - demonstrating validation)...' AS status;

-- Test 1: Invalid email format (should fail)
DO $$
BEGIN
  INSERT INTO users (id, email, name)
  VALUES (uuid_generate_v4(), 'invalid-email', 'Test User');
  RAISE EXCEPTION 'FAILURE: Invalid email constraint did not work';
EXCEPTION
  WHEN check_violation THEN
    RAISE NOTICE 'SUCCESS: Invalid email format rejected';
END $$;

-- Test 2: Empty name (should fail)
DO $$
BEGIN
  INSERT INTO users (id, email, name)
  VALUES (uuid_generate_v4(), 'test@example.com', '   ');
  RAISE EXCEPTION 'FAILURE: Empty name constraint did not work';
EXCEPTION
  WHEN check_violation THEN
    RAISE NOTICE 'SUCCESS: Empty name rejected';
END $$;

-- Test 3: Duplicate email (should fail)
DO $$
BEGIN
  -- Assuming john.doe@example.com exists from test_data.sql
  INSERT INTO users (id, email, name)
  VALUES (uuid_generate_v4(), 'john.doe@example.com', 'Duplicate John');
  RAISE EXCEPTION 'FAILURE: Duplicate email constraint did not work';
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE 'SUCCESS: Duplicate email rejected';
END $$;

-- Test 4: Negative contact frequency (should fail)
DO $$
DECLARE
  test_user_id UUID := uuid_generate_v4();
BEGIN
  INSERT INTO users (id, email, name)
  VALUES (test_user_id, 'constraint.test@example.com', 'Constraint Test');

  INSERT INTO user_settings (user_id, elder_contact_frequency_days)
  VALUES (test_user_id, -5);

  RAISE EXCEPTION 'FAILURE: Negative contact frequency constraint did not work';
EXCEPTION
  WHEN check_violation THEN
    RAISE NOTICE 'SUCCESS: Negative contact frequency rejected';
    DELETE FROM users WHERE id = test_user_id;
END $$;

-- Test 5: Focus end before start (should fail)
DO $$
DECLARE
  test_user_id UUID := uuid_generate_v4();
BEGIN
  INSERT INTO users (id, email, name)
  VALUES (test_user_id, 'focus.test@example.com', 'Focus Test');

  INSERT INTO user_settings (user_id, preferred_focus_hours_start, preferred_focus_hours_end)
  VALUES (test_user_id, '17:00', '12:00');

  RAISE EXCEPTION 'FAILURE: Focus hours constraint did not work';
EXCEPTION
  WHEN check_violation THEN
    RAISE NOTICE 'SUCCESS: Invalid focus hours rejected';
    DELETE FROM users WHERE id = test_user_id;
END $$;

-- Test 6: Duplicate user_settings (should fail)
DO $$
BEGIN
  -- Assuming user a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 has settings from test_data.sql
  INSERT INTO user_settings (user_id)
  VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
  RAISE EXCEPTION 'FAILURE: Duplicate user_settings constraint did not work';
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE 'SUCCESS: Duplicate user_settings rejected';
END $$;

-- ============================================================================
-- PART 10: TEST RLS POLICIES (Simulated)
-- ============================================================================

SELECT 'Testing RLS policies...' AS status;

-- Note: Full RLS testing requires setting up authentication context
-- This demonstrates the policy structure

-- Simulate authenticated user context
SET LOCAL role postgres;

-- Test 1: Verify user can see their own data
DO $$
DECLARE
  user_count INTEGER;
BEGIN
  -- Simulate auth.uid() returning user ID
  -- In real scenario: SET request.jwt.claim.sub = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

  -- Count users (without auth context, this would return 0 in production)
  SELECT COUNT(*) INTO user_count FROM users;

  IF user_count > 0 THEN
    RAISE NOTICE 'RLS TEST: Found % users (postgres role bypasses RLS)', user_count;
  END IF;

  RAISE NOTICE 'NOTE: Full RLS testing requires Supabase Auth context';
  RAISE NOTICE 'In production, unauthenticated queries return 0 rows';
END $$;

-- ============================================================================
-- PART 11: PERFORMANCE BENCHMARKS
-- ============================================================================

SELECT 'Running performance benchmarks...' AS status;

-- Benchmark 1: Email lookup (should use idx_users_email)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM users WHERE email = 'john.doe@example.com';

-- Benchmark 2: User settings retrieval (should use idx_user_settings_user_id)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM user_settings WHERE user_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- Benchmark 3: Join users with settings
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
  u.email,
  u.name,
  us.elder_contact_frequency_days,
  us.notification_preferences
FROM users u
JOIN user_settings us ON u.id = us.user_id
WHERE u.email = 'john.doe@example.com';

-- ============================================================================
-- PART 12: DATA INTEGRITY CHECKS
-- ============================================================================

SELECT 'Checking data integrity...' AS status;

-- Check for orphaned user_settings (shouldn't exist due to foreign key)
SELECT 'Checking for orphaned user_settings...' AS check_name;
SELECT COUNT(*) AS orphaned_settings_count
FROM user_settings us
LEFT JOIN users u ON us.user_id = u.id
WHERE u.id IS NULL;

-- Check for users without settings (allowed, but worth noting)
SELECT 'Checking for users without settings...' AS check_name;
SELECT
  u.email,
  u.name,
  CASE WHEN us.id IS NULL THEN 'No settings' ELSE 'Has settings' END AS settings_status
FROM users u
LEFT JOIN user_settings us ON u.id = us.user_id;

-- Check timestamp consistency (updated_at should be >= created_at)
SELECT 'Checking timestamp consistency...' AS check_name;
SELECT
  table_name,
  COUNT(*) AS invalid_timestamps
FROM (
  SELECT 'users' AS table_name, id
  FROM users
  WHERE updated_at < created_at

  UNION ALL

  SELECT 'user_settings' AS table_name, id
  FROM user_settings
  WHERE updated_at < created_at
) AS invalid
GROUP BY table_name;

-- ============================================================================
-- SUMMARY
-- ============================================================================

SELECT 'Schema verification complete!' AS status;

SELECT
  (SELECT COUNT(*) FROM users) AS total_users,
  (SELECT COUNT(*) FROM user_settings) AS total_settings,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename IN ('users', 'user_settings')) AS total_policies,
  (SELECT COUNT(*) FROM pg_indexes WHERE tablename IN ('users', 'user_settings')) AS total_indexes,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE event_object_table IN ('users', 'user_settings')) AS total_triggers;
