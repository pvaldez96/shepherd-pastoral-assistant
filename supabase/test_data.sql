-- Test Data for Shepherd Initial Schema
-- Purpose: Sample data for testing RLS policies, constraints, and triggers
-- Usage: Run this after applying 0001_initial_schema.sql

BEGIN;

-- ============================================================================
-- TEST USERS
-- ============================================================================

-- Test User 1: John Doe (Baptist Church in Central Time)
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'john.doe@example.com',
  'John Doe',
  'First Community Baptist Church',
  'America/Chicago'
);

-- Test User 2: Jane Smith (Methodist Church in Pacific Time)
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'jane.smith@example.com',
  'Jane Smith',
  'Grace Fellowship Methodist',
  'America/Los_Angeles'
);

-- Test User 3: Robert Johnson (Non-denominational in Eastern Time)
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  'robert.johnson@example.com',
  'Robert Johnson',
  'New Life Community Church',
  'America/New_York'
);

-- Test User 4: Maria Garcia (Catholic Church in Mountain Time)
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
  'maria.garcia@example.com',
  'Maria Garcia',
  'St. Mary Catholic Church',
  'America/Denver'
);

-- Test User 5: David Kim (Presbyterian Church, no church name)
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
  'david.kim@example.com',
  'David Kim',
  NULL,
  'America/Chicago'
);

-- ============================================================================
-- TEST USER SETTINGS
-- ============================================================================

-- Settings for User 1: Default settings
INSERT INTO user_settings (user_id)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');

-- Settings for User 2: Custom contact frequencies
INSERT INTO user_settings (
  user_id,
  elder_contact_frequency_days,
  member_contact_frequency_days,
  crisis_contact_frequency_days
)
VALUES (
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  14,  -- More frequent elder contacts
  60,  -- More frequent member contacts
  1    -- Daily crisis follow-ups
);

-- Settings for User 3: Custom sermon prep and workload
INSERT INTO user_settings (
  user_id,
  weekly_sermon_prep_hours,
  max_daily_hours,
  min_focus_block_minutes
)
VALUES (
  'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  12,  -- More sermon prep time
  12,  -- Longer work days
  180  -- 3-hour focus blocks
);

-- Settings for User 4: Custom focus hours and notifications
INSERT INTO user_settings (
  user_id,
  preferred_focus_hours_start,
  preferred_focus_hours_end,
  notification_preferences
)
VALUES (
  'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
  '09:00',
  '12:00',
  '{"email": true, "push": true, "sms": false, "daily_digest": true}'::jsonb
);

-- Settings for User 5: Custom archive settings
INSERT INTO user_settings (
  user_id,
  auto_archive_enabled,
  archive_tasks_after_days,
  archive_events_after_days,
  archive_logs_after_days,
  offline_cache_days
)
VALUES (
  'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
  FALSE,  -- Manual archiving
  180,    -- Longer task retention
  730,    -- 2 years for events
  1095,   -- 3 years for logs
  30      -- Smaller offline cache
);

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all users inserted correctly
SELECT
  id,
  email,
  name,
  church_name,
  timezone,
  created_at,
  updated_at
FROM users
ORDER BY email;

-- Verify all settings inserted correctly
SELECT
  us.user_id,
  u.name,
  us.elder_contact_frequency_days,
  us.member_contact_frequency_days,
  us.crisis_contact_frequency_days,
  us.weekly_sermon_prep_hours,
  us.max_daily_hours,
  us.min_focus_block_minutes,
  us.preferred_focus_hours_start,
  us.preferred_focus_hours_end,
  us.notification_preferences,
  us.offline_cache_days,
  us.auto_archive_enabled
FROM user_settings us
JOIN users u ON us.user_id = u.id
ORDER BY u.email;

-- Verify created_at and updated_at are identical (no updates yet)
SELECT
  email,
  name,
  created_at,
  updated_at,
  (updated_at = created_at) AS timestamps_match
FROM users;

-- ============================================================================
-- CONSTRAINT TESTS (These should FAIL - demonstrating validation works)
-- ============================================================================

-- Uncomment to test constraint violations:

-- FAIL: Invalid email format
-- INSERT INTO users (id, email, name)
-- VALUES (uuid_generate_v4(), 'invalid-email', 'Test User');

-- FAIL: Empty name (whitespace only)
-- INSERT INTO users (id, email, name)
-- VALUES (uuid_generate_v4(), 'test@example.com', '   ');

-- FAIL: Duplicate email
-- INSERT INTO users (id, email, name)
-- VALUES (uuid_generate_v4(), 'john.doe@example.com', 'Duplicate John');

-- FAIL: Negative contact frequency
-- INSERT INTO user_settings (user_id, elder_contact_frequency_days)
-- VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', -5);

-- FAIL: Focus end before start
-- INSERT INTO user_settings (user_id, preferred_focus_hours_start, preferred_focus_hours_end)
-- VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '17:00', '12:00');

-- FAIL: Invalid max daily hours (> 24)
-- INSERT INTO user_settings (user_id, max_daily_hours)
-- VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 30);

-- FAIL: Duplicate user_settings for same user
-- INSERT INTO user_settings (user_id)
-- VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
