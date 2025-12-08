# Shepherd Database Schema Diagram

## Entity Relationship Diagram (ERD)

```
┌─────────────────────────────────────────────────────────────────┐
│                             USERS                               │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                UUID                                      │
│ UQ  email             TEXT                                      │
│     name              TEXT                                      │
│     church_name       TEXT (nullable)                           │
│     timezone          TEXT (default: 'America/Chicago')         │
│     created_at        TIMESTAMPTZ                               │
│     updated_at        TIMESTAMPTZ (auto-updated via trigger)    │
├─────────────────────────────────────────────────────────────────┤
│ Indexes:                                                        │
│   - idx_users_email (B-tree on email)                           │
├─────────────────────────────────────────────────────────────────┤
│ Constraints:                                                    │
│   - users_email_format (email regex validation)                 │
│   - users_name_not_empty (non-whitespace name required)         │
├─────────────────────────────────────────────────────────────────┤
│ RLS Policies:                                                   │
│   - Users can view their own profile (SELECT)                   │
│   - Users can create their own profile (INSERT)                 │
│   - Users can update their own profile (UPDATE)                 │
│   - Users can delete their own profile (DELETE)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 1:1
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        USER_SETTINGS                            │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                                UUID                      │
│ FK  user_id                           UUID → users(id)          │
│ UQ  (user_id)                                                   │
│                                                                 │
│ Contact Frequency Settings:                                    │
│     elder_contact_frequency_days      INTEGER (default: 30)     │
│     member_contact_frequency_days     INTEGER (default: 90)     │
│     crisis_contact_frequency_days     INTEGER (default: 3)      │
│                                                                 │
│ Sermon Preparation:                                             │
│     weekly_sermon_prep_hours          INTEGER (default: 8)      │
│                                                                 │
│ Workload Management:                                            │
│     max_daily_hours                   INTEGER (default: 10)     │
│     min_focus_block_minutes           INTEGER (default: 120)    │
│                                                                 │
│ Focus Time Preferences:                                         │
│     preferred_focus_hours_start       TIME (default: '12:00')   │
│     preferred_focus_hours_end         TIME (default: '17:00')   │
│                                                                 │
│ Notifications:                                                  │
│     notification_preferences          JSONB (default: {})       │
│                                                                 │
│ Offline/Sync:                                                   │
│     offline_cache_days                INTEGER (default: 90)     │
│                                                                 │
│ Archive Settings:                                               │
│     auto_archive_enabled              BOOLEAN (default: TRUE)   │
│     archive_tasks_after_days          INTEGER (default: 90)     │
│     archive_events_after_days         INTEGER (default: 365)    │
│     archive_logs_after_days           INTEGER (default: 730)    │
│                                                                 │
│ Timestamps:                                                     │
│     created_at                        TIMESTAMPTZ               │
│     updated_at                        TIMESTAMPTZ (auto)        │
├─────────────────────────────────────────────────────────────────┤
│ Indexes:                                                        │
│   - idx_user_settings_user_id (B-tree on user_id)               │
├─────────────────────────────────────────────────────────────────┤
│ Constraints:                                                    │
│   - settings_elder_frequency_positive (> 0)                     │
│   - settings_member_frequency_positive (> 0)                    │
│   - settings_crisis_frequency_positive (> 0)                    │
│   - settings_sermon_hours_valid (0-168 hours)                   │
│   - settings_max_daily_hours_valid (1-24 hours)                 │
│   - settings_min_focus_minutes_valid (1-1440 minutes)           │
│   - settings_focus_hours_valid (end > start)                    │
│   - settings_offline_cache_positive (> 0)                       │
│   - settings_archive_days_positive (all > 0)                    │
├─────────────────────────────────────────────────────────────────┤
│ Foreign Keys:                                                   │
│   - user_id → users(id) ON DELETE CASCADE                       │
├─────────────────────────────────────────────────────────────────┤
│ RLS Policies:                                                   │
│   - Users can view their own settings (SELECT)                  │
│   - Users can create their own settings (INSERT)                │
│   - Users can update their own settings (UPDATE)                │
│   - Users can delete their own settings (DELETE)                │
└─────────────────────────────────────────────────────────────────┘
```

## Relationship Details

### Users ← User Settings (1:1)

- **Relationship Type**: One-to-One
- **Foreign Key**: `user_settings.user_id` → `users.id`
- **Delete Behavior**: CASCADE (deleting user deletes their settings)
- **Uniqueness**: Each user can have exactly ONE settings record
- **Enforcement**: UNIQUE constraint on `user_settings.user_id`

## Data Flow

### User Registration Flow

```
1. Create User Record
   INSERT INTO users (id, email, name, church_name, timezone)
   VALUES (uuid_generate_v4(), ?, ?, ?, ?)
   ↓
2. Create Default Settings (Optional)
   INSERT INTO user_settings (user_id)
   VALUES (?)
   -- All settings use default values from schema
```

### User Login Flow

```
1. Authenticate via Supabase Auth
   ↓
2. Query user profile
   SELECT * FROM users WHERE id = auth.uid()
   -- RLS ensures only authenticated user's data is returned
   ↓
3. Query user settings
   SELECT * FROM user_settings WHERE user_id = auth.uid()
   -- RLS ensures only authenticated user's settings are returned
```

### Settings Update Flow

```
1. Update user settings
   UPDATE user_settings
   SET elder_contact_frequency_days = ?,
       notification_preferences = ?
   WHERE user_id = auth.uid()
   ↓
2. Trigger fires: set_user_settings_updated_at
   -- Automatically sets updated_at = NOW()
   ↓
3. RLS validates: user_id = auth.uid()
   -- Prevents updating other users' settings
```

## Security Model

### Row Level Security (RLS)

All tables enforce multi-tenant isolation:

```sql
-- Pattern for all policies
USING (user_id = auth.uid())  -- For SELECT, UPDATE, DELETE
WITH CHECK (user_id = auth.uid())  -- For INSERT, UPDATE

-- For users table (no user_id column)
USING (id = auth.uid())  -- User is accessing their own record
WITH CHECK (id = auth.uid())
```

### Authentication Integration

```
Supabase Auth
     ↓
auth.uid() returns authenticated user's UUID
     ↓
RLS policies filter all queries by user_id
     ↓
Users can ONLY access their own data
```

## Index Strategy

### Users Table Indexes

1. **Primary Key Index** (automatic)
   - Column: `id`
   - Type: B-tree
   - Purpose: Fast lookups by user ID

2. **Email Index** (explicit)
   - Name: `idx_users_email`
   - Column: `email`
   - Type: B-tree
   - Purpose: Fast login lookups
   - Query: `SELECT * FROM users WHERE email = ?`

### User Settings Table Indexes

1. **Primary Key Index** (automatic)
   - Column: `id`
   - Type: B-tree
   - Purpose: Fast lookups by settings ID

2. **User ID Index** (explicit)
   - Name: `idx_user_settings_user_id`
   - Column: `user_id`
   - Type: B-tree
   - Purpose: Fast settings retrieval by user
   - Query: `SELECT * FROM user_settings WHERE user_id = ?`

3. **Foreign Key Index** (same as user_id index)
   - Improves JOIN performance
   - Ensures referential integrity checks are fast

## Trigger System

### Automatic Timestamp Updates

```sql
-- Function (shared by both tables)
CREATE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
users.set_users_updated_at
  → Fires BEFORE UPDATE on users
  → Sets updated_at = NOW()

user_settings.set_user_settings_updated_at
  → Fires BEFORE UPDATE on user_settings
  → Sets updated_at = NOW()
```

**Benefit**: Application doesn't need to track updated_at, reducing bugs and ensuring consistency.

## Data Types Reference

### UUID

- **Purpose**: Distributed-friendly primary keys
- **Generation**: Client-generated (Dart: `Uuid.v4()`, SQL: `uuid_generate_v4()`)
- **Benefits**: No ID collision in offline-first architecture

### TIMESTAMPTZ

- **Purpose**: Timezone-aware timestamps
- **Storage**: UTC internally, converted to user's timezone on retrieval
- **Benefits**: Accurate time tracking across timezones

### JSONB

- **Purpose**: Flexible notification preferences
- **Storage**: Binary JSON (faster than TEXT JSON)
- **Benefits**: Queryable, indexable, schema-flexible
- **Example**:
  ```json
  {
    "email": true,
    "push": true,
    "sms": false,
    "daily_digest": true,
    "digest_time": "08:00"
  }
  ```

### TIME

- **Purpose**: Time-of-day without date
- **Format**: `HH:MM:SS` (24-hour)
- **Example**: `'12:00'` for noon
- **Use Case**: Focus time preferences (independent of date)

## Future Schema Extensions

Tables to be added in subsequent migrations (from technical specification):

1. **contacts** - Elder, member, and crisis contact management
2. **tasks** - Pastoral work tracking with priorities and deadlines
3. **events** - Calendar and scheduling (meetings, services, etc.)
4. **sermon_plans** - Sermon preparation workflow
5. **prayer_requests** - Prayer request tracking and follow-up
6. **time_logs** - Workload and time tracking
7. **sync_metadata** - Offline-first sync coordination

All future tables will follow the same patterns:
- UUID primary keys (client-generated)
- `user_id` foreign key to users
- `created_at` and `updated_at` timestamps
- RLS policies for multi-tenant isolation
- Indexes on foreign keys and common filters
- Constraints for data validation

## SQLite Mirror (Offline-First)

For the mobile app, all tables will be mirrored in SQLite with additional sync metadata:

```dart
class UserSettings extends Table {
  // ... all PostgreSQL columns ...

  // Sync metadata (SQLite only)
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}
```

**Sync Flow**:
1. User modifies data offline → `isDirty = true`, `syncStatus = 'pending'`
2. App comes online → syncs dirty records to Supabase
3. Sync succeeds → `isDirty = false`, `syncStatus = 'synced'`, `lastSyncedAt = NOW()`

---

**Schema Version**: 0001
**Last Updated**: 2025-12-06
**Status**: Production Ready
