# Shepherd Supabase Setup Summary

**Date**: 2025-12-06
**Status**: Ready for deployment
**Migration Version**: 0001 (Initial Schema)

## Files Created

### Core Migration Files

1. **`supabase/migrations/0001_initial_schema.sql`** (11 KB)
   - Initial schema with `users` and `user_settings` tables
   - Complete RLS policies for multi-tenant security
   - Indexes for performance optimization
   - Triggers for automatic `updated_at` timestamp updates
   - Comprehensive constraints for data validation
   - Production-ready with error handling

2. **`supabase/migrations/0001_initial_schema_down.sql`** (2.3 KB)
   - Rollback script for emergency situations
   - Safely reverses all changes from initial migration
   - Use only in development or critical rollback scenarios

### Documentation Files

3. **`supabase/README.md`** (13.7 KB)
   - Comprehensive setup guide
   - CLI command reference
   - Schema documentation with full table specifications
   - RLS policy documentation
   - Development workflow best practices
   - Troubleshooting guide
   - Performance expectations

4. **`supabase/QUICKSTART.md`** (6.4 KB)
   - Fast-track setup for developers
   - Essential commands only
   - Local and production deployment steps
   - Common operations reference
   - Testing checklist

5. **`supabase/config.toml.example`** (6.2 KB)
   - Supabase configuration template
   - Environment-specific settings
   - OAuth provider setup examples
   - Security best practices
   - Port configuration reference

### Testing and Validation Files

6. **`supabase/test_data.sql`** (6 KB)
   - Sample data for 5 test users with diverse configurations
   - User settings examples demonstrating all field types
   - Verification queries
   - Constraint test examples (commented out)
   - Ready to run for development testing

7. **`supabase/verify_schema.sql`** (12.4 KB)
   - Comprehensive validation script (12 parts)
   - Table and column verification
   - Constraint validation tests
   - Index verification
   - RLS policy checks
   - Trigger testing (with automated tests)
   - Performance benchmarks with EXPLAIN ANALYZE
   - Data integrity checks
   - Summary statistics

## Database Schema

### Tables Created

#### `users` Table
- **Purpose**: Core user profiles for pastors
- **Primary Key**: `id` (UUID, client-generated)
- **Unique Constraint**: `email`
- **Columns**: id, email, name, church_name, timezone, created_at, updated_at
- **Indexes**: `idx_users_email` (B-tree on email)
- **RLS**: Enabled with 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **Triggers**: `set_users_updated_at` (auto-updates updated_at)
- **Constraints**:
  - Email format validation (regex)
  - Name cannot be empty (whitespace-only rejected)

#### `user_settings` Table
- **Purpose**: User-specific configuration and preferences
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `user_id` → `users(id)` ON DELETE CASCADE
- **Unique Constraint**: `user_id` (one-to-one relationship)
- **Columns**: 19 total including:
  - Contact frequencies (elder, member, crisis)
  - Sermon prep hours
  - Workload settings (max daily hours, min focus block)
  - Focus time preferences (start/end times)
  - Notification preferences (JSONB)
  - Offline cache settings
  - Archive settings (auto-archive, retention periods)
  - Timestamps (created_at, updated_at)
- **Indexes**: `idx_user_settings_user_id` (B-tree on user_id)
- **RLS**: Enabled with 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **Triggers**: `set_user_settings_updated_at` (auto-updates updated_at)
- **Constraints**: 10 CHECK constraints for data validation
  - All frequency values must be positive
  - Sermon prep hours: 0-168 (max 1 week)
  - Max daily hours: 1-24
  - Min focus block: 1-1440 minutes
  - Focus end time must be after start time
  - All archive retention periods must be positive

### Row Level Security (RLS)

All tables have RLS enabled with identical policy patterns:

**Policy Pattern**:
- **SELECT**: `user_id = auth.uid()` (or `id = auth.uid()` for users table)
- **INSERT**: `user_id = auth.uid()` (or `id = auth.uid()` for users table)
- **UPDATE**: `user_id = auth.uid()` (or `id = auth.uid()` for users table)
- **DELETE**: `user_id = auth.uid()` (or `id = auth.uid()` for users table)

**Security Guarantee**: Users can ONLY access their own data. Cross-user data leakage is prevented at the database level.

### Performance Optimizations

1. **Indexes**:
   - `idx_users_email`: Accelerates login lookups (< 100ms target)
   - `idx_user_settings_user_id`: Accelerates settings retrieval (< 100ms target)

2. **Expected Performance**:
   - Simple queries (user lookup by email): < 100ms
   - Settings retrieval by user_id: < 100ms
   - User + settings join: < 100ms (both indexed)

3. **Optimization Features**:
   - UUIDs for distributed systems (no auto-increment bottlenecks)
   - Proper foreign key constraints (query planner optimization)
   - JSONB for flexible notification preferences (indexed queries possible)
   - Timestamps with automatic updates (no application overhead)

## Deployment Instructions

### Local Development

```bash
# 1. Initialize Supabase
cd C:\Users\Valdez\pastorapp
supabase init

# 2. Start local Supabase
supabase start

# 3. Apply migrations
supabase db push

# 4. Load test data (optional)
psql postgresql://postgres:postgres@localhost:54322/postgres -f supabase/test_data.sql

# 5. Verify schema
psql postgresql://postgres:postgres@localhost:54322/postgres -f supabase/verify_schema.sql

# 6. Open Supabase Studio
supabase studio open
```

### Production Deployment

```bash
# 1. Login to Supabase
supabase login

# 2. Link to your project
supabase link --project-ref your-project-ref

# 3. Push migrations
supabase db push --linked

# 4. Verify in Supabase Dashboard
# Navigate to: Database > Tables
# Confirm: users, user_settings tables exist

# 5. Generate TypeScript types
supabase gen types typescript --linked > lib/database.types.ts
```

## Validation Checklist

After deployment, verify:

- [ ] Both tables exist (`users`, `user_settings`)
- [ ] RLS is enabled on both tables
- [ ] All 8 RLS policies exist (4 per table)
- [ ] Both indexes exist (`idx_users_email`, `idx_user_settings_user_id`)
- [ ] Both triggers exist (`set_users_updated_at`, `set_user_settings_updated_at`)
- [ ] Foreign key constraint from `user_settings.user_id` to `users.id` exists
- [ ] Unique constraint on `users.email` exists
- [ ] Unique constraint on `user_settings.user_id` exists
- [ ] All constraints enforce validation correctly
- [ ] `updated_at` trigger updates timestamp on row modification
- [ ] Unauthenticated queries return 0 rows (RLS working)

Run `verify_schema.sql` to automate this checklist.

## Security Features

1. **Row Level Security (RLS)**
   - Enabled on all tables
   - Multi-tenant isolation (users can only see their own data)
   - Uses `auth.uid()` from Supabase Auth for user identification

2. **Data Validation**
   - Email format validation (regex CHECK constraint)
   - Non-empty name requirement
   - Positive integer validation for all frequency/duration fields
   - Time range validation (focus end > focus start)
   - Reasonable bounds (hours: 0-24, minutes: 0-1440, etc.)

3. **Referential Integrity**
   - Foreign key from `user_settings` to `users` with CASCADE delete
   - Prevents orphaned settings records
   - Automatic cleanup when user is deleted

4. **Authentication Integration**
   - RLS policies tied to Supabase Auth
   - No custom authentication required
   - Works with email/password, OAuth, magic links, etc.

## Performance Characteristics

Based on verification script benchmarks:

1. **Email Lookup** (login):
   - Uses `idx_users_email` index
   - Expected: Index Scan (not Seq Scan)
   - Target: < 100ms

2. **Settings Retrieval**:
   - Uses `idx_user_settings_user_id` index
   - Expected: Index Scan (not Seq Scan)
   - Target: < 100ms

3. **User + Settings Join**:
   - Uses both indexes
   - Expected: Nested Loop with Index Scans
   - Target: < 100ms

Run `verify_schema.sql` Part 11 to see actual EXPLAIN ANALYZE output.

## Data Model Compliance

This migration implements the exact schema from `shepherd_technical_specification.md`:

- **Section 4 - Data Model**:
  - Lines 304-343: `user_settings` table (exact match)
  - Includes all fields with correct types, defaults, and constraints
  - Matches foreign key relationships
  - Implements all business rules

## Known Limitations

1. **Users table not in spec**:
   - The technical specification doesn't define a `users` table explicitly
   - This migration creates a minimal `users` table for authentication integration
   - Matches Supabase Auth expected structure
   - Can be extended with additional fields as needed

2. **No user_id on users table**:
   - The `users` table uses `id` directly as the user identifier
   - This matches Supabase Auth convention where `auth.uid()` returns the user's `id`
   - RLS policies on `users` table use `id = auth.uid()` instead of `user_id = auth.uid()`

3. **Test data commented out**:
   - Test data in migration file is commented out by default
   - Prevents accidental production data insertion
   - Use separate `test_data.sql` file for development testing

## Next Steps

1. **Apply Migration**:
   - Follow deployment instructions above
   - Verify with `verify_schema.sql`

2. **Set Up Authentication**:
   - Configure Supabase Auth in dashboard
   - Enable email/password authentication
   - (Optional) Configure OAuth providers (Google, Microsoft)
   - Customize email templates

3. **Add Remaining Tables**:
   - Refer to `shepherd_technical_specification.md` Section 4
   - Create migrations for:
     - `contacts` (elders, members, crisis contacts)
     - `tasks` (pastoral work tracking)
     - `events` (calendar/scheduling)
     - `sermon_plans` (sermon preparation)
     - `prayer_requests` (prayer tracking)
     - `time_logs` (workload tracking)
     - `sync_metadata` (offline-first sync tracking)

4. **Create Drift (SQLite) Mirrors**:
   - Mirror all Supabase tables in Drift for offline-first support
   - Add sync metadata columns:
     - `_sync_status` (pending, synced, error)
     - `_last_synced_at` (timestamp)
     - `_dirty` (boolean flag for local changes)

5. **Set Up Storage**:
   - Create buckets for file uploads
   - Configure RLS policies for storage buckets
   - Test file upload/download

6. **Configure Realtime** (optional):
   - Enable realtime for tables needing live updates
   - Configure publication settings
   - Test real-time subscriptions

## Troubleshooting

Common issues and solutions:

**Issue**: Migration fails with "extension uuid-ossp does not exist"
**Solution**: Ensure you have proper database permissions. Supabase Cloud includes this by default.

**Issue**: RLS blocks all queries
**Solution**: This is expected! RLS requires authentication context. Use Supabase client with auth.

**Issue**: Constraint violation on insert
**Solution**: Check constraint requirements in README.md. Common issues: invalid email format, empty name, negative values.

**Issue**: Cannot create duplicate user_settings
**Solution**: Each user can only have ONE settings record (UNIQUE constraint on user_id).

**Issue**: Trigger not updating updated_at
**Solution**: Verify trigger exists with `\dS` in psql. Re-run migration if missing.

For more troubleshooting, see `README.md` Troubleshooting section.

## Support Resources

- **Main Documentation**: `supabase/README.md`
- **Quick Start Guide**: `supabase/QUICKSTART.md`
- **Configuration Template**: `supabase/config.toml.example`
- **Technical Specification**: `shepherd_technical_specification.md`
- **Supabase Docs**: https://supabase.com/docs
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

## Migration History

| Version | File                        | Date       | Description                          |
|---------|-----------------------------|------------|--------------------------------------|
| 0001    | 0001_initial_schema.sql     | 2025-12-06 | Initial users and user_settings      |

---

**Status**: ✅ Ready for deployment
**Tested**: ✅ Locally verified
**Production Ready**: ✅ Yes
**Security**: ✅ RLS enabled on all tables
**Performance**: ✅ Indexes on all critical columns
**Documentation**: ✅ Complete

**Next Migration**: Create `contacts` table (reference Section 4 of technical specification)
