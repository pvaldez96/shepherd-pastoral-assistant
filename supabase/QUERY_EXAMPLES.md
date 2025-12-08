# Shepherd Database Query Examples

This document provides common query patterns for the Shepherd database with performance notes and best practices.

## User Registration

### Create New User

```sql
-- Create user profile
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  uuid_generate_v4(),
  'pastor@example.com',
  'John Doe',
  'First Community Church',
  'America/Chicago'
)
RETURNING *;

-- Expected performance: < 10ms (single row insert)
```

### Create User with Default Settings

```sql
-- Create user and settings in a transaction
BEGIN;

-- Insert user
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'pastor@example.com',
  'John Doe',
  'First Community Church',
  'America/Chicago'
);

-- Insert default settings
INSERT INTO user_settings (user_id)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');

COMMIT;

-- Expected performance: < 20ms (two inserts in transaction)
```

## User Authentication

### Login by Email

```sql
-- Query purpose: Find user by email for authentication
-- Expected performance: < 100ms (uses idx_users_email)
-- Indexes required: idx_users_email

SELECT
  id,
  email,
  name,
  church_name,
  timezone,
  created_at
FROM users
WHERE email = 'pastor@example.com';

-- EXPLAIN ANALYZE output:
-- Index Scan using idx_users_email on users (cost=0.15..8.17 rows=1)
-- Execution time: ~2ms
```

### Get User Profile with Settings

```sql
-- Query purpose: Load complete user profile for dashboard
-- Expected performance: < 100ms (both tables indexed)
-- Indexes required: idx_users_email, idx_user_settings_user_id

SELECT
  u.id,
  u.email,
  u.name,
  u.church_name,
  u.timezone,
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
FROM users u
LEFT JOIN user_settings us ON u.id = us.user_id
WHERE u.email = 'pastor@example.com';

-- EXPLAIN ANALYZE output:
-- Nested Loop Left Join
--   -> Index Scan using idx_users_email on users
--   -> Index Scan using idx_user_settings_user_id on user_settings
-- Execution time: ~3ms
```

## Settings Management

### Get User Settings

```sql
-- Query purpose: Retrieve settings for authenticated user
-- Expected performance: < 100ms (uses idx_user_settings_user_id)
-- Indexes required: idx_user_settings_user_id
-- RLS: Automatically filters by auth.uid()

SELECT
  elder_contact_frequency_days,
  member_contact_frequency_days,
  crisis_contact_frequency_days,
  weekly_sermon_prep_hours,
  max_daily_hours,
  min_focus_block_minutes,
  preferred_focus_hours_start,
  preferred_focus_hours_end,
  notification_preferences,
  offline_cache_days,
  auto_archive_enabled,
  archive_tasks_after_days,
  archive_events_after_days,
  archive_logs_after_days
FROM user_settings
WHERE user_id = auth.uid();

-- In production with RLS:
-- RLS policy automatically adds: WHERE user_id = auth.uid()
-- User cannot query other users' settings
```

### Update Contact Frequencies

```sql
-- Query purpose: Update contact frequency preferences
-- Expected performance: < 50ms (single row update with index)
-- RLS: Prevents updating other users' settings

UPDATE user_settings
SET
  elder_contact_frequency_days = 14,
  member_contact_frequency_days = 60,
  crisis_contact_frequency_days = 1
  -- updated_at automatically set by trigger
WHERE user_id = auth.uid()
RETURNING *;

-- Trigger automatically updates updated_at
-- RLS ensures user can only update their own settings
```

### Update Focus Time Preferences

```sql
-- Query purpose: Set preferred focus hours
-- Expected performance: < 50ms
-- Constraint: preferred_focus_hours_end > preferred_focus_hours_start

UPDATE user_settings
SET
  preferred_focus_hours_start = '09:00',
  preferred_focus_hours_end = '12:00',
  min_focus_block_minutes = 180  -- 3-hour blocks
WHERE user_id = auth.uid()
RETURNING
  preferred_focus_hours_start,
  preferred_focus_hours_end,
  min_focus_block_minutes;

-- Constraint validation ensures end > start
-- Invalid update (end before start) will raise error
```

### Update Notification Preferences

```sql
-- Query purpose: Update notification settings (JSONB)
-- Expected performance: < 50ms
-- JSONB allows flexible structure

UPDATE user_settings
SET notification_preferences = '{
  "email": true,
  "push": true,
  "sms": false,
  "daily_digest": true,
  "digest_time": "08:00",
  "task_reminders": true,
  "prayer_reminders": true,
  "contact_reminders": true
}'::jsonb
WHERE user_id = auth.uid()
RETURNING notification_preferences;

-- JSONB stored as binary (more efficient than text)
-- Can query nested values: notification_preferences->>'email'
```

### Merge Notification Preferences

```sql
-- Query purpose: Update specific notification preferences without replacing all
-- Uses JSONB merge operator (||)

UPDATE user_settings
SET notification_preferences = notification_preferences || '{
  "push": false,
  "digest_time": "07:00"
}'::jsonb
WHERE user_id = auth.uid()
RETURNING notification_preferences;

-- Only specified keys are updated, others remain unchanged
-- Example: If current = {"email": true, "push": true}
--          After merge = {"email": true, "push": false, "digest_time": "07:00"}
```

### Query Notification Preference

```sql
-- Query purpose: Check if push notifications are enabled
-- Uses JSONB operators

SELECT
  (notification_preferences->>'push')::boolean AS push_enabled,
  (notification_preferences->>'email')::boolean AS email_enabled,
  notification_preferences->>'digest_time' AS digest_time
FROM user_settings
WHERE user_id = auth.uid();

-- Operators:
-- -> returns JSONB
-- ->> returns TEXT
-- Cast TEXT to BOOLEAN for boolean values
```

### Update Archive Settings

```sql
-- Query purpose: Configure automatic archiving
-- Expected performance: < 50ms

UPDATE user_settings
SET
  auto_archive_enabled = TRUE,
  archive_tasks_after_days = 180,     -- 6 months
  archive_events_after_days = 730,    -- 2 years
  archive_logs_after_days = 1095      -- 3 years
WHERE user_id = auth.uid()
RETURNING
  auto_archive_enabled,
  archive_tasks_after_days,
  archive_events_after_days,
  archive_logs_after_days;

-- All archive_*_after_days must be positive (constraint)
```

## User Profile Management

### Update User Profile

```sql
-- Query purpose: Update user name and church
-- Expected performance: < 50ms
-- RLS: Users can only update their own profile

UPDATE users
SET
  name = 'John David Doe',
  church_name = 'First Community Baptist Church'
  -- updated_at automatically set by trigger
WHERE id = auth.uid()
RETURNING *;

-- Trigger automatically updates updated_at
-- Constraint ensures name is not empty (whitespace only)
```

### Update Timezone

```sql
-- Query purpose: Change user's timezone
-- Expected performance: < 50ms
-- Important for time-sensitive features

UPDATE users
SET timezone = 'America/New_York'
WHERE id = auth.uid()
RETURNING timezone;

-- Use IANA timezone identifiers
-- Examples: America/Chicago, America/New_York, America/Los_Angeles, Europe/London
```

### Delete User Account

```sql
-- Query purpose: Delete user and all associated data
-- Expected performance: < 100ms
-- CASCADE automatically deletes user_settings

DELETE FROM users
WHERE id = auth.uid()
RETURNING email, name;

-- Foreign key ON DELETE CASCADE ensures:
-- 1. user_settings record is automatically deleted
-- 2. Future: all contacts, tasks, events, etc. are deleted
-- 3. No orphaned records remain
```

## Administrative Queries

These queries are for database administration and reporting (not exposed to users via RLS).

### Count Users by Timezone

```sql
-- Query purpose: Analyze user distribution across timezones
-- Run as database admin (bypasses RLS)

SELECT
  timezone,
  COUNT(*) AS user_count
FROM users
GROUP BY timezone
ORDER BY user_count DESC;

-- Useful for understanding user geographic distribution
```

### Users Without Settings

```sql
-- Query purpose: Find users who haven't configured settings
-- Run as database admin

SELECT
  u.id,
  u.email,
  u.name,
  u.created_at
FROM users u
LEFT JOIN user_settings us ON u.id = us.user_id
WHERE us.id IS NULL
ORDER BY u.created_at DESC;

-- May indicate incomplete registration flow
-- Consider auto-creating default settings on user creation
```

### Average Settings Values

```sql
-- Query purpose: Analyze typical settings configurations
-- Run as database admin

SELECT
  AVG(elder_contact_frequency_days) AS avg_elder_frequency,
  AVG(member_contact_frequency_days) AS avg_member_frequency,
  AVG(crisis_contact_frequency_days) AS avg_crisis_frequency,
  AVG(weekly_sermon_prep_hours) AS avg_sermon_hours,
  AVG(max_daily_hours) AS avg_daily_hours,
  AVG(min_focus_block_minutes) AS avg_focus_minutes,
  AVG(offline_cache_days) AS avg_cache_days,
  COUNT(CASE WHEN auto_archive_enabled THEN 1 END)::FLOAT / COUNT(*) AS archive_enabled_pct
FROM user_settings;

-- Helps determine if default values are appropriate
-- Can inform product decisions about feature usage
```

### Recent User Activity

```sql
-- Query purpose: Find recently updated user profiles
-- Run as database admin

SELECT
  u.email,
  u.name,
  u.created_at,
  u.updated_at,
  (u.updated_at - u.created_at) AS time_since_creation,
  CASE
    WHEN u.updated_at > u.created_at THEN 'Updated'
    ELSE 'Never updated'
  END AS update_status
FROM users u
ORDER BY u.updated_at DESC
LIMIT 20;

-- Identifies active users
-- Helps track onboarding completion
```

## Performance Testing Queries

### Test Email Index

```sql
-- Query purpose: Verify idx_users_email is being used
-- Should show "Index Scan using idx_users_email"

EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'pastor@example.com';

-- Expected plan:
-- Index Scan using idx_users_email on users (cost=0.15..8.17 rows=1)
-- Actual time: 0.015..0.016ms
-- Planning time: 0.050ms
-- Execution time: 0.035ms
```

### Test User Settings Join

```sql
-- Query purpose: Verify efficient join between users and settings
-- Should show "Nested Loop" with two index scans

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
  u.email,
  us.elder_contact_frequency_days
FROM users u
JOIN user_settings us ON u.id = us.user_id
WHERE u.email = 'pastor@example.com';

-- Expected plan:
-- Nested Loop (cost=0.30..16.35 rows=1)
--   -> Index Scan using idx_users_email on users u
--   -> Index Scan using idx_user_settings_user_id on user_settings us
-- Execution time: < 1ms
```

## Common Mistakes to Avoid

### Mistake 1: Not Using RLS Context

```sql
-- WRONG: Direct query without auth context
SELECT * FROM users WHERE email = 'other.pastor@example.com';
-- Result: Empty (RLS blocks access unless id = auth.uid())

-- RIGHT: Query with proper auth context (handled by Supabase client)
-- In application code, Supabase client automatically sets auth context
```

### Mistake 2: Trying to Update Other Users

```sql
-- WRONG: Attempting to update another user's settings
UPDATE user_settings
SET elder_contact_frequency_days = 14
WHERE user_id = 'some-other-user-id';
-- Result: 0 rows updated (RLS prevents cross-user updates)

-- RIGHT: Update your own settings
UPDATE user_settings
SET elder_contact_frequency_days = 14
WHERE user_id = auth.uid();
-- Result: 1 row updated
```

### Mistake 3: Inserting Duplicate Settings

```sql
-- WRONG: Creating second settings record for same user
INSERT INTO user_settings (user_id)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
-- Error: duplicate key value violates unique constraint "user_settings_user_id_key"

-- RIGHT: Use UPSERT (INSERT ... ON CONFLICT)
INSERT INTO user_settings (user_id, elder_contact_frequency_days)
VALUES (auth.uid(), 14)
ON CONFLICT (user_id)
DO UPDATE SET elder_contact_frequency_days = EXCLUDED.elder_contact_frequency_days
RETURNING *;
```

### Mistake 4: Invalid Focus Hours

```sql
-- WRONG: End time before start time
UPDATE user_settings
SET
  preferred_focus_hours_start = '17:00',
  preferred_focus_hours_end = '12:00'
WHERE user_id = auth.uid();
-- Error: violates check constraint "settings_focus_hours_valid"

-- RIGHT: End time after start time
UPDATE user_settings
SET
  preferred_focus_hours_start = '12:00',
  preferred_focus_hours_end = '17:00'
WHERE user_id = auth.uid();
```

### Mistake 5: Negative Frequency Values

```sql
-- WRONG: Negative contact frequency
UPDATE user_settings
SET elder_contact_frequency_days = -5
WHERE user_id = auth.uid();
-- Error: violates check constraint "settings_elder_frequency_positive"

-- RIGHT: Positive frequency
UPDATE user_settings
SET elder_contact_frequency_days = 14
WHERE user_id = auth.uid();
```

## Batch Operations

### Create Multiple Users (Admin Only)

```sql
-- Query purpose: Bulk user creation for testing
-- Run as database admin (bypasses RLS)

INSERT INTO users (id, email, name, church_name, timezone)
VALUES
  (uuid_generate_v4(), 'pastor1@example.com', 'Pastor One', 'Church One', 'America/Chicago'),
  (uuid_generate_v4(), 'pastor2@example.com', 'Pastor Two', 'Church Two', 'America/New_York'),
  (uuid_generate_v4(), 'pastor3@example.com', 'Pastor Three', 'Church Three', 'America/Los_Angeles')
RETURNING id, email, name;

-- Expected performance: < 50ms (3 inserts)
-- Use for test data creation
```

### Create Settings for All Users Without Settings

```sql
-- Query purpose: Backfill default settings for existing users
-- Run as database admin

INSERT INTO user_settings (user_id)
SELECT u.id
FROM users u
LEFT JOIN user_settings us ON u.id = us.user_id
WHERE us.id IS NULL;

-- Creates default settings for all users missing them
-- Useful after schema migration or data import
```

## Transaction Examples

### Atomic User Creation

```sql
-- Query purpose: Create user and settings together (all or nothing)
-- Ensures data consistency

BEGIN;

-- Step 1: Create user
INSERT INTO users (id, email, name, church_name, timezone)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'new.pastor@example.com',
  'New Pastor',
  'New Church',
  'America/Chicago'
);

-- Step 2: Create settings with custom values
INSERT INTO user_settings (
  user_id,
  elder_contact_frequency_days,
  member_contact_frequency_days,
  notification_preferences
)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  14,
  60,
  '{"email": true, "push": true}'::jsonb
);

COMMIT;

-- If any step fails, entire transaction rolls back
-- Prevents user without settings or settings without user
```

---

**Performance Notes**:
- All queries targeting single users by ID or email: < 100ms
- Batch operations: < 10ms per row
- Join queries (users + settings): < 100ms
- Administrative aggregations: < 500ms (grows with user count)

**RLS Reminder**: All user-facing queries automatically filtered by `auth.uid()` through RLS policies. This ensures multi-tenant security without application-level filtering.

**Index Usage**: EXPLAIN ANALYZE any query expected to run frequently or handle large datasets to verify index usage.
