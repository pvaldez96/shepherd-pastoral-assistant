# Calendar Events Database Implementation Summary

**Date:** December 9, 2025
**Feature:** Complete calendar events database implementation for Shepherd pastoral assistant app

## Files Created

### 1. Supabase Migration Files

**Location:** `c:\Users\Valdez\pastorapp\supabase\migrations\`

- **0003_calendar_events.sql** - Complete up migration with:
  - calendar_events table creation
  - Row-level security (RLS) policies
  - 7 optimized indexes including full-text search
  - Automatic updated_at trigger
  - Comprehensive constraints and validation
  - Test data and verification queries

- **0003_calendar_events_down.sql** - Complete rollback migration

### 2. Drift (SQLite) Table Definition

**Location:** `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\tables\`

- **calendar_events_table.dart** - Complete SQLite mirror with:
  - Exact schema matching Supabase
  - Sync metadata columns (syncStatus, localUpdatedAt, serverUpdatedAt, version)
  - Comprehensive inline documentation
  - DateTime fields stored as Unix milliseconds
  - JSON fields stored as TEXT

### 3. Data Access Object (DAO)

**Location:** `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\daos\`

- **calendar_events_dao.dart** - Comprehensive DAO with 40+ methods:
  - Basic CRUD operations
  - Date-based queries (today, week, month, custom ranges)
  - Event type filtering
  - Person relationship queries
  - Conflict detection
  - Search capabilities
  - Sync support
  - Reactive streams (watch methods)
  - Analytics and statistics

### 4. Database Configuration Updates

**Location:** `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\`

- **database.dart** - Updated to include:
  - CalendarEvents table import
  - CalendarEventsDao import
  - Schema version incremented to 3
  - Migration logic for version 2 → 3

---

## Schema Overview

### Supabase Table: calendar_events

```sql
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Core fields
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,

  -- Date/time
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,

  -- Categorization
  event_type TEXT NOT NULL CHECK (event_type IN (
    'service', 'meeting', 'pastoral_visit', 'personal',
    'work', 'family', 'blocked_time'
  )),

  -- Recurring events
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern JSONB,

  -- Time management
  travel_time_minutes INTEGER,
  energy_drain TEXT DEFAULT 'medium' CHECK (energy_drain IN ('low', 'medium', 'high')),
  is_moveable BOOLEAN DEFAULT TRUE,

  -- Preparation
  requires_preparation BOOLEAN DEFAULT FALSE,
  preparation_buffer_hours INTEGER,

  -- Relationships
  person_id UUID, -- FK to people(id) - will be added when people table exists

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### SQLite Table: calendar_events (Drift)

Mirrors Supabase schema exactly with additions:
- All datetime fields stored as INTEGER (Unix milliseconds)
- JSONB stored as TEXT
- Sync metadata: syncStatus, localUpdatedAt, serverUpdatedAt, version

---

## Indexes Created

1. **idx_calendar_user_date** - Primary calendar query index (user_id, start_datetime)
2. **idx_calendar_user_range** - Range query index (user_id, start_datetime, end_datetime)
3. **idx_calendar_user_event_type** - Event type filtering (user_id, event_type)
4. **idx_calendar_person** - Person relationship lookups (person_id)
5. **idx_calendar_search_gin** - Full-text search on title and description
6. **idx_calendar_user_upcoming** - Partial index for future events only
7. **idx_calendar_recurring** - Partial index for recurring events

**Expected Performance:**
- Simple queries: < 5ms for tables with < 10,000 rows
- Complex range queries: < 50ms for 100,000+ rows
- Full-text search: < 100ms

---

## RLS Policies (Supabase)

All policies enforce multi-tenant isolation (`user_id = auth.uid()`):

1. **"Users can view their own calendar events"** - SELECT policy
2. **"Users can create their own calendar events"** - INSERT policy
3. **"Users can update their own calendar events"** - UPDATE policy
4. **"Users can delete their own calendar events"** - DELETE policy

---

## Key DAO Methods

### Basic CRUD
- `getAllEvents(userId)` - Get all events for user
- `getEventById(id)` - Get single event
- `insertEvent(event)` - Create new event
- `updateEvent(event)` - Update existing event
- `deleteEvent(id)` - Hard delete event

### Date-Based Queries
- `getEventsForDate(userId, date)` - Events for specific date
- `getEventsInRange(userId, startDate, endDate)` - Events in date range
- `getTodayEvents(userId)` - Today's events
- `getWeekEvents(userId)` - This week's events
- `getMonthEvents(userId, year, month)` - Month's events
- `getUpcomingEvents(userId, limit)` - Next N events

### Event Type Queries
- `getEventsByType(userId, eventType)` - Filter by event type

### Relationship Queries
- `getEventsByPerson(personId)` - Events for specific person

### Conflict Detection
- `findConflictingEvents(userId, proposedStart, proposedEnd, excludeEventId)` - Detect scheduling conflicts

### Search & Filter
- `searchEvents(userId, query)` - Search by title
- `getEventsRequiringPreparation(userId, futureOnly)` - Events needing prep
- `getRecurringEvents(userId)` - Recurring events only
- `getFixedEvents(userId, startDate, endDate)` - Non-moveable events

### Sync Support
- `getPendingEvents()` - Events awaiting sync
- `markEventAsSynced(id, serverUpdatedAt)` - Mark as synced
- `markEventAsConflicted(id)` - Mark as conflicted
- `getConflictedEvents()` - Get all conflicts
- `resolveConflict(id, resolved)` - Resolve conflict

### Reactive Streams
- `watchAllEvents(userId)` - Stream of all events
- `watchEventsForDate(userId, date)` - Stream for specific date
- `watchEventsInRange(userId, startDate, endDate)` - Stream for range
- `watchEventsByType(userId, eventType)` - Stream by type
- `watchTodayEvents(userId)` - Stream of today's events

### Analytics
- `countEventsByType(userId)` - Count by event type
- `getEventLoadForDate(userId, date)` - Total hours scheduled
- `getEventLoadForWeek(userId, weekStart)` - Hours per day for week
- `getEnergyExpenditureSummary(userId, startDate, endDate)` - Energy breakdown

---

## Next Steps

### 1. Run Build Runner

Generate Drift code:

```bash
cd shepherd
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `calendar_events_dao.g.dart`
- Updated `database.g.dart`

### 2. Apply Supabase Migration

```bash
cd ..
supabase db push
```

Or apply manually in Supabase dashboard.

### 3. Verify Supabase Deployment

Run verification queries (see section below).

### 4. Test Local Database

Create a simple test to verify:

```dart
final db = AppDatabase();
await db.ensureInitialized();

// Test insert
final event = CalendarEventsCompanion(
  id: Value(Uuid().v4()),
  userId: Value('test-user-id'),
  title: const Value('Test Event'),
  startDatetime: Value(DateTime.now().millisecondsSinceEpoch),
  endDatetime: Value(DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch),
  eventType: const Value('meeting'),
);
await db.calendarEventsDao.insertEvent(event);

// Test query
final events = await db.calendarEventsDao.getTodayEvents('test-user-id');
print('Today\'s events: ${events.length}');
```

---

## Supabase Verification Queries

### 1. Verify Table Created

```sql
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'calendar_events'
ORDER BY ordinal_position;
```

### 2. Verify RLS Enabled

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'calendar_events';
```

### 3. Verify RLS Policies

```sql
SELECT
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'calendar_events';
```

### 4. Verify Indexes

```sql
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'calendar_events'
ORDER BY indexname;
```

### 5. Verify Trigger

```sql
SELECT
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'calendar_events';
```

### 6. Test INSERT (with authenticated user)

```sql
-- This should succeed (user inserting their own event)
INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
VALUES (auth.uid(), 'Test Event', 'meeting', NOW(), NOW() + INTERVAL '1 hour')
RETURNING id, title, created_at;
```

### 7. Test RLS Isolation

```sql
-- This should return 0 rows (cannot access other users' events)
SELECT * FROM calendar_events WHERE user_id != auth.uid();
```

### 8. Test Full-Text Search

```sql
SELECT
  id,
  title,
  ts_rank(
    to_tsvector('english', title || ' ' || COALESCE(description, '')),
    to_tsquery('meeting')
  ) AS rank
FROM calendar_events
WHERE user_id = auth.uid()
  AND to_tsvector('english', title || ' ' || COALESCE(description, ''))
      @@ to_tsquery('meeting')
ORDER BY rank DESC;
```

### 9. Test Conflict Detection

```sql
-- Find events that overlap with proposed time slot
SELECT id, title, start_datetime, end_datetime
FROM calendar_events
WHERE user_id = auth.uid()
  AND start_datetime < '2025-12-15 16:00:00'  -- Before proposed end
  AND end_datetime > '2025-12-15 14:00:00'    -- After proposed start
ORDER BY start_datetime;
```

### 10. Test Constraint Violations

```sql
-- Should fail: empty title
INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
VALUES (auth.uid(), '   ', 'meeting', NOW(), NOW() + INTERVAL '1 hour');

-- Should fail: end before start
INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
VALUES (auth.uid(), 'Test', 'meeting', '2025-12-15 15:00:00', '2025-12-15 14:00:00');

-- Should fail: invalid event_type
INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime)
VALUES (auth.uid(), 'Test', 'invalid_type', NOW(), NOW() + INTERVAL '1 hour');

-- Should fail: negative travel time
INSERT INTO calendar_events (user_id, title, event_type, start_datetime, end_datetime, travel_time_minutes)
VALUES (auth.uid(), 'Test', 'meeting', NOW(), NOW() + INTERVAL '1 hour', -30);
```

### 11. Performance Test (EXPLAIN ANALYZE)

```sql
EXPLAIN ANALYZE
SELECT id, title, start_datetime, end_datetime, event_type
FROM calendar_events
WHERE user_id = auth.uid()
  AND start_datetime >= NOW()
  AND start_datetime <= NOW() + INTERVAL '30 days'
ORDER BY start_datetime ASC;
```

Expected: Index Scan using `idx_calendar_user_date` or `idx_calendar_user_upcoming`

### 12. Calculate Event Load

```sql
-- Total hours scheduled for a specific date
SELECT
  DATE(start_datetime) AS event_date,
  COUNT(*) AS event_count,
  SUM(EXTRACT(EPOCH FROM (end_datetime - start_datetime)) / 3600) AS total_hours
FROM calendar_events
WHERE user_id = auth.uid()
  AND start_datetime >= '2025-12-09 00:00:00'
  AND start_datetime < '2025-12-10 00:00:00'
GROUP BY DATE(start_datetime);
```

---

## Implementation Checklist

- [x] Create Supabase migration file (0003_calendar_events.sql)
- [x] Create Supabase rollback file (0003_calendar_events_down.sql)
- [x] Create Drift table definition (calendar_events_table.dart)
- [x] Create comprehensive DAO (calendar_events_dao.dart)
- [x] Update database.dart configuration
- [x] Add CalendarEvents to tables list
- [x] Add CalendarEventsDao to DAOs list
- [x] Update schema version to 3
- [x] Add migration logic for version 2 → 3
- [ ] Run build_runner to generate code
- [ ] Apply Supabase migration
- [ ] Verify Supabase deployment
- [ ] Test local database operations
- [ ] Test sync functionality

---

## File Paths Reference

All file paths are absolute:

- **Supabase Migrations:**
  - `c:\Users\Valdez\pastorapp\supabase\migrations\0003_calendar_events.sql`
  - `c:\Users\Valdez\pastorapp\supabase\migrations\0003_calendar_events_down.sql`

- **Drift Table:**
  - `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\tables\calendar_events_table.dart`

- **DAO:**
  - `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\daos\calendar_events_dao.dart`

- **Database Configuration:**
  - `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\database.dart`

---

## Notes

1. **People Table Dependency**: The `person_id` foreign key constraint will be added when the people table is created in a future migration.

2. **DateTime Handling**:
   - Supabase: Uses TIMESTAMPTZ (timezone-aware)
   - SQLite: Stores as INTEGER (Unix milliseconds since epoch)
   - Convert using: `DateTime.fromMillisecondsSinceEpoch(value)` and `dateTime.millisecondsSinceEpoch`

3. **JSON Handling**:
   - Supabase: Uses JSONB for recurrence_pattern
   - SQLite: Stores as TEXT, parse/stringify as needed

4. **Sync Workflow**:
   - User creates/modifies event → syncStatus = 'pending'
   - Sync engine uploads to Supabase → syncStatus = 'synced'
   - Conflict detected → syncStatus = 'conflict', manual resolution required

5. **Offline-First Architecture**: All operations execute locally first, then sync to Supabase when online. Calendar works fully offline.

---

## Common Usage Examples

### Creating an Event

```dart
final event = CalendarEventsCompanion(
  id: Value(Uuid().v4()),
  userId: Value(currentUserId),
  title: const Value('Sunday Worship Service'),
  description: const Value('Weekly worship service'),
  location: const Value('Main Sanctuary'),
  startDatetime: Value(DateTime(2025, 12, 14, 10, 0).millisecondsSinceEpoch),
  endDatetime: Value(DateTime(2025, 12, 14, 11, 30).millisecondsSinceEpoch),
  eventType: const Value('service'),
  energyDrain: const Value('high'),
  isMoveable: const Value(false),
  requiresPreparation: const Value(true),
  preparationBufferHours: const Value(8),
  travelTimeMinutes: const Value(15),
);

await db.calendarEventsDao.insertEvent(event);
```

### Checking for Conflicts

```dart
final proposed Start = DateTime(2025, 12, 15, 14, 0);
final proposedEnd = DateTime(2025, 12, 15, 16, 0);

final conflicts = await db.calendarEventsDao.findConflictingEvents(
  currentUserId,
  proposedStart,
  proposedEnd,
);

if (conflicts.isNotEmpty) {
  print('Warning: ${conflicts.length} scheduling conflicts detected');
  for (final conflict in conflicts) {
    print('  - ${conflict.title} at ${DateTime.fromMillisecondsSinceEpoch(conflict.startDatetime)}');
  }
}
```

### Watching Today's Events

```dart
StreamBuilder<List<CalendarEvent>>(
  stream: db.calendarEventsDao.watchTodayEvents(currentUserId),
  builder: (context, snapshot) {
    final events = snapshot.data ?? [];
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final start = DateTime.fromMillisecondsSinceEpoch(event.startDatetime);
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${event.eventType} at ${start.hour}:${start.minute}'),
        );
      },
    );
  },
)
```

---

## Production Deployment Checklist

Before deploying to production:

1. Review all migration SQL for safety
2. Backup Supabase database
3. Test migration in staging environment
4. Verify RLS policies prevent data leakage
5. Test performance with realistic data volumes
6. Verify sync logic handles conflicts correctly
7. Test offline functionality
8. Monitor error logs after deployment

---

**Implementation Status:** Complete - Ready for code generation and testing
**Next Action:** Run `flutter pub run build_runner build --delete-conflicting-outputs`