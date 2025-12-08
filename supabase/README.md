# Shepherd Supabase Database Setup

This directory contains the Supabase database configuration and migrations for the Shepherd pastoral assistant application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Applying Migrations](#applying-migrations)
- [Generating TypeScript Types](#generating-typescript-types)
- [Database Schema](#database-schema)
- [Row Level Security](#row-level-security)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Prerequisites

1. **Install Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Verify Installation**
   ```bash
   supabase --version
   ```

3. **Create a Supabase Account**
   - Go to https://supabase.com
   - Sign up for a free account
   - Create a new project in the Supabase dashboard

## Initial Setup

### Option 1: Initialize a New Supabase Project (Local Development)

```bash
# Navigate to project root
cd C:\Users\Valdez\pastorapp

# Initialize Supabase (creates config.toml and sets up local environment)
supabase init

# Start local Supabase instance (PostgreSQL + Studio)
supabase start

# Output will provide:
# - API URL (http://localhost:54321)
# - GraphQL URL
# - DB URL (postgresql://postgres:postgres@localhost:54322/postgres)
# - Studio URL (http://localhost:54323)
# - Anon Key
# - Service Role Key
```

### Option 2: Link to an Existing Supabase Project (Production)

```bash
# Navigate to project root
cd C:\Users\Valdez\pastorapp

# Login to Supabase
supabase login

# Link to your remote project
# Replace 'your-project-ref' with your actual Supabase project reference ID
# Found in: Project Settings > General > Reference ID
supabase link --project-ref your-project-ref

# You'll be prompted for your database password
```

## Applying Migrations

### Local Development

```bash
# Apply all pending migrations to local database
supabase db push

# Or reset the database and apply all migrations from scratch
supabase db reset
```

### Production Deployment

```bash
# Push migrations to remote Supabase project
supabase db push --linked

# Or use the Supabase dashboard:
# 1. Go to Database > Migrations
# 2. Upload migration file manually
# 3. Execute migration
```

## Generating TypeScript Types

Supabase can automatically generate TypeScript types from your database schema.

```bash
# Generate types for local database
supabase gen types typescript --local > lib/database.types.ts

# Generate types for linked remote database
supabase gen types typescript --linked > lib/database.types.ts

# Or specify the project reference directly
supabase gen types typescript --project-id your-project-ref > lib/database.types.ts
```

## Database Schema

### Tables

#### `users`
Stores core user profile information for pastors using Shepherd.

| Column       | Type         | Constraints                  | Description                           |
|--------------|--------------|------------------------------|---------------------------------------|
| id           | UUID         | PRIMARY KEY                  | User unique identifier (client-gen)   |
| email        | TEXT         | UNIQUE, NOT NULL             | User email address                    |
| name         | TEXT         | NOT NULL                     | Pastor full name                      |
| church_name  | TEXT         |                              | Name of the church                    |
| timezone     | TEXT         | DEFAULT 'America/Chicago'    | IANA timezone identifier              |
| created_at   | TIMESTAMPTZ  | DEFAULT NOW()                | Record creation timestamp             |
| updated_at   | TIMESTAMPTZ  | DEFAULT NOW()                | Last update timestamp (auto-updated)  |

**Indexes:**
- `idx_users_email` on `email` - Accelerates login lookups

#### `user_settings`
Stores personalized configuration for each user's Shepherd experience.

| Column                           | Type         | Default       | Description                                  |
|----------------------------------|--------------|---------------|----------------------------------------------|
| id                               | UUID         | uuid_gen_v4() | Settings unique identifier                   |
| user_id                          | UUID         | REQUIRED      | Foreign key to users (ONE-TO-ONE)            |
| elder_contact_frequency_days     | INTEGER      | 30            | Default days between elder contacts          |
| member_contact_frequency_days    | INTEGER      | 90            | Default days between member contacts         |
| crisis_contact_frequency_days    | INTEGER      | 3             | Default days between crisis follow-ups       |
| weekly_sermon_prep_hours         | INTEGER      | 8             | Weekly sermon preparation hours              |
| max_daily_hours                  | INTEGER      | 10            | Maximum daily work hours                     |
| min_focus_block_minutes          | INTEGER      | 120           | Minimum uninterrupted focus block (minutes)  |
| preferred_focus_hours_start      | TIME         | 12:00         | Preferred focus time start                   |
| preferred_focus_hours_end        | TIME         | 17:00         | Preferred focus time end                     |
| notification_preferences         | JSONB        | {}            | Flexible notification settings               |
| offline_cache_days               | INTEGER      | 90            | Days of data to cache offline                |
| auto_archive_enabled             | BOOLEAN      | TRUE          | Enable automatic archiving                   |
| archive_tasks_after_days         | INTEGER      | 90            | Days before archiving tasks                  |
| archive_events_after_days        | INTEGER      | 365           | Days before archiving events                 |
| archive_logs_after_days          | INTEGER      | 730           | Days before archiving logs (2 years)         |
| created_at                       | TIMESTAMPTZ  | NOW()         | Record creation timestamp                    |
| updated_at                       | TIMESTAMPTZ  | NOW()         | Last update timestamp (auto-updated)         |

**Indexes:**
- `idx_user_settings_user_id` on `user_id` - Accelerates settings retrieval

**Constraints:**
- Contact frequencies must be positive integers
- Sermon prep hours: 0-168 (max 1 week)
- Max daily hours: 1-24
- Min focus block: 1-1440 minutes (max 24 hours)
- Focus hours end must be after start
- All archive settings must be positive

## Row Level Security

All tables have Row Level Security (RLS) enabled with the following policies:

### Users Table Policies

| Policy Name                       | Operation | Rule                          |
|-----------------------------------|-----------|-------------------------------|
| Users can view their own profile  | SELECT    | `id = auth.uid()`             |
| Users can create their own profile| INSERT    | `id = auth.uid()`             |
| Users can update their own profile| UPDATE    | `id = auth.uid()`             |
| Users can delete their own profile| DELETE    | `id = auth.uid()`             |

### User Settings Table Policies

| Policy Name                        | Operation | Rule                          |
|------------------------------------|-----------|-------------------------------|
| Users can view their own settings  | SELECT    | `user_id = auth.uid()`        |
| Users can create their own settings| INSERT    | `user_id = auth.uid()`        |
| Users can update their own settings| UPDATE    | `user_id = auth.uid()`        |
| Users can delete their own settings| DELETE    | `user_id = auth.uid()`        |

**Security Notes:**
- `auth.uid()` returns the authenticated user's UUID from Supabase Auth
- Without authentication, all queries return empty results (RLS blocks access)
- Each user can ONLY access their own data (multi-tenant isolation)
- Cross-user data leakage is prevented at the database level

## Development Workflow

### Creating New Migrations

```bash
# Create a new migration file
supabase migration new migration_name

# This creates: supabase/migrations/YYYYMMDDHHMMSS_migration_name.sql
# Edit the file with your schema changes
```

### Migration Best Practices

1. **One logical change per migration** - Don't mix unrelated schema changes
2. **Always include comments** - Explain WHY, not just WHAT
3. **Test with sample data** - Verify constraints and RLS policies work
4. **Include down migrations** - Make migrations reversible
5. **Use transactions** - Wrap migrations in BEGIN/COMMIT for atomicity

### Example Migration Template

```sql
-- Migration: YYYYMMDDHHMMSS_description.sql
-- Purpose: [Clear explanation of what and why]
-- Dependencies: [Other migrations if any]

BEGIN;

-- Your schema changes here
-- Include inline comments for complex logic

COMMIT;
```

## Testing

### Test RLS Policies

```sql
-- Test as authenticated user
SET request.jwt.claims.sub = 'user-uuid-here';

-- Should return only that user's data
SELECT * FROM users WHERE id = 'user-uuid-here';

-- Should return empty (RLS blocks other users)
SELECT * FROM users WHERE id = 'different-user-uuid';
```

### Test Constraints

```sql
-- Should fail: invalid email format
INSERT INTO users (id, email, name)
VALUES (uuid_generate_v4(), 'invalid-email', 'Test User');

-- Should fail: empty name
INSERT INTO users (id, email, name)
VALUES (uuid_generate_v4(), 'test@example.com', '   ');

-- Should fail: focus end before start
INSERT INTO user_settings (user_id, preferred_focus_hours_start, preferred_focus_hours_end)
VALUES ('user-id', '17:00', '12:00');
```

### Test Triggers

```sql
-- Insert a user
INSERT INTO users (id, email, name)
VALUES (uuid_generate_v4(), 'test@example.com', 'Test User');

-- Wait a second, then update
SELECT pg_sleep(1);
UPDATE users SET name = 'Updated Name' WHERE email = 'test@example.com';

-- Verify updated_at changed
SELECT created_at, updated_at FROM users WHERE email = 'test@example.com';
-- updated_at should be > created_at
```

## Troubleshooting

### Common Issues

**Issue: "relation does not exist"**
- Ensure migrations have been applied: `supabase db push`
- Check migration status: `supabase migration list`

**Issue: "permission denied"**
- Check RLS policies are correctly configured
- Verify `auth.uid()` matches the user_id you're querying

**Issue: "duplicate key value violates unique constraint"**
- Email must be unique across all users
- Each user can only have ONE user_settings record

**Issue: "check constraint violated"**
- Review constraint requirements in schema documentation above
- Common issues: negative values, invalid time ranges, out-of-bounds numbers

### Useful Commands

```bash
# View migration history
supabase migration list

# Check database status
supabase status

# View database logs
supabase db logs

# Open Supabase Studio (GUI)
supabase studio open

# Stop local Supabase
supabase stop

# Reset local database (WARNING: deletes all data)
supabase db reset
```

### Database Connection String

For direct PostgreSQL access:

```bash
# Local development
postgresql://postgres:postgres@localhost:54322/postgres

# Remote (from Supabase dashboard)
# Project Settings > Database > Connection String
```

## Performance Expectations

Based on Shepherd's technical specification:

- **Simple queries** (single user lookup): < 100ms
- **Complex queries** (dashboard aggregations): < 500ms
- **Indexes** ensure efficient lookups on:
  - `users.email` for authentication
  - `user_settings.user_id` for settings retrieval

## Security Checklist

Before deploying to production:

- [ ] All tables have RLS enabled
- [ ] All tables have policies for SELECT, INSERT, UPDATE, DELETE
- [ ] Policies use `auth.uid()` for user isolation
- [ ] Test unauthorized access attempts (should return empty)
- [ ] Test cross-user data access (should be blocked)
- [ ] Verify constraints prevent invalid data
- [ ] Confirm triggers update `updated_at` correctly
- [ ] Review migration for SQL injection vulnerabilities
- [ ] Ensure sensitive data is not logged

## Next Steps

After initial setup:

1. **Add remaining tables** from shepherd_technical_specification.md:
   - contacts
   - tasks
   - events
   - sermon_plans
   - prayer_requests
   - time_logs
   - sync_metadata (for offline-first architecture)

2. **Set up Supabase Auth**
   - Configure email/password authentication
   - Set up OAuth providers (Google, Microsoft)
   - Customize email templates

3. **Configure Storage**
   - Set up buckets for file uploads (sermon documents, attachments)
   - Configure RLS policies for storage

4. **Enable Realtime** (if needed)
   - Configure realtime subscriptions for live updates
   - Set up presence tracking

5. **Create Drift (SQLite) mirrors**
   - Mirror all Supabase tables in Drift for offline-first support
   - Add sync metadata columns (_sync_status, _last_synced_at, _dirty)

## Support

- **Supabase Documentation**: https://supabase.com/docs
- **Supabase CLI Reference**: https://supabase.com/docs/guides/cli
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Shepherd Technical Specification**: shepherd_technical_specification.md

---

**Version**: 1.0.0
**Last Updated**: 2025-12-06
**Migration Count**: 1
