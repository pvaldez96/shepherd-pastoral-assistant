// lib/data/local/tables/calendar_events_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Calendar Events table - mirrors Supabase calendar_events table with offline-first sync metadata
///
/// This table stores calendar and scheduling data for pastors including event details,
/// date/time information, event categorization, time management features (travel time,
/// energy drain, preparation buffers), and relationships to people.
///
/// Key Features:
/// - Flexible event categorization (service, meeting, pastoral_visit, personal, work, family, blocked_time)
/// - Date/time tracking with timezone support (stored as milliseconds since epoch)
/// - Recurring events support (via recurrence_pattern JSONB)
/// - Time management features (travel_time, energy_drain, preparation_buffer)
/// - Scheduling flexibility tracking (is_moveable)
/// - Relationships (person_id for person-specific events)
///
/// Reference: supabase/migrations/0003_calendar_events.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('CalendarEvent')
class CalendarEvents extends Table {
  // ============================================================================
  // PRIMARY KEY
  // ============================================================================

  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  /// Must match Supabase UUID format for seamless sync
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  // ============================================================================
  // FOREIGN KEY - USER RELATIONSHIP
  // ============================================================================

  /// Foreign key to users table - establishes multi-tenant isolation
  /// Every event belongs to exactly one user (the pastor who created it)
  /// Note: Foreign keys are enforced at the application layer for web compatibility
  /// IndexedDB doesn't support CASCADE constraints, so cleanup is handled manually
  TextColumn get userId => text()();

  // ============================================================================
  // CORE EVENT INFORMATION
  // ============================================================================

  /// Event title - required, non-empty string
  /// Example: "Sunday Worship Service", "Board Meeting", "Hospital Visit"
  /// Constraint: Must have at least one non-whitespace character (validated in app layer)
  TextColumn get title => text()();

  /// Optional detailed event description
  /// Can include agenda, notes, context, or any additional information
  /// Nullable - simple events may not need description
  TextColumn get description => text().nullable()();

  /// Optional event location
  /// Can be physical address, room name, or virtual meeting link
  /// Examples: "Main Sanctuary", "Conference Room A", "https://zoom.us/j/123456"
  /// Nullable - some events don't have specific locations
  TextColumn get location => text().nullable()();

  // ============================================================================
  // DATE AND TIME
  // ============================================================================

  /// Event start date and time (stored as Unix milliseconds)
  /// Represents the exact moment the event begins (with timezone)
  /// In Dart: DateTime.fromMillisecondsSinceEpoch(startDatetime)
  /// Required - every event must have a start time
  IntColumn get startDatetime => integer()();

  /// Event end date and time (stored as Unix milliseconds)
  /// Represents the exact moment the event ends (with timezone)
  /// In Dart: DateTime.fromMillisecondsSinceEpoch(endDatetime)
  /// Required - every event must have an end time
  /// Constraint: Must be after start_datetime (validated in app layer)
  IntColumn get endDatetime => integer()();

  // ============================================================================
  // EVENT CATEGORIZATION
  // ============================================================================

  /// Event type/category - required field for organization and filtering
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'service': Worship services (Sunday service, midweek service)
  /// - 'meeting': Meetings (staff meetings, committee meetings, counseling)
  /// - 'pastoral_visit': Pastoral care visits (hospital, home visits)
  /// - 'personal': Personal time (family time, personal appointments)
  /// - 'work': General work time (office hours, admin time)
  /// - 'family': Family commitments (dinner, kids activities)
  /// - 'blocked_time': Dedicated work blocks (sermon prep, deep work)
  ///
  /// Event type enables:
  /// - Filtered calendar views ("Show only pastoral visits")
  /// - Time allocation tracking ("How much time on meetings vs pastoral care?")
  /// - Calendar color coding
  /// - Workload balancing suggestions
  TextColumn get eventType => text()();

  // ============================================================================
  // RECURRING EVENTS
  // ============================================================================

  /// Whether this event repeats on a schedule
  /// If true, recurrence_pattern contains the recurrence rules
  /// Examples:
  /// - Sunday worship service (weekly, every Sunday at 10am)
  /// - Monthly board meeting (monthly, first Tuesday at 7pm)
  /// Default: false (one-time event)
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// Recurrence pattern (JSON string)
  /// Stores recurrence rules in RRULE format or custom JSON structure
  /// Example formats:
  /// - RRULE: "FREQ=WEEKLY;BYDAY=SU" (every Sunday)
  /// - Custom JSON: {"frequency": "weekly", "days": ["sunday"], "count": 52}
  /// Nullable - only set when is_recurring = true
  /// In Supabase this is JSONB, here stored as TEXT and parsed as JSON
  TextColumn get recurrencePattern => text().nullable()();

  // ============================================================================
  // TIME MANAGEMENT FEATURES
  // ============================================================================

  /// Travel time buffer before event (in minutes)
  /// Time needed to travel to the event location
  /// Used for:
  /// - Blocking calendar before event start
  /// - Travel time tracking and reimbursement
  /// - Realistic scheduling (don't schedule back-to-back events across town)
  /// Examples: 30 (for hospital across town), 0 (for on-site meeting)
  /// Nullable - not all events require travel
  /// Constraint: Must be positive integer if set (validated in app layer)
  IntColumn get travelTimeMinutes => integer().nullable()();

  /// Energy cost of this event (low, medium, high)
  /// Valid values (enforced in app layer):
  /// - 'low': Low energy drain (routine tasks, familiar interactions)
  /// - 'medium': Normal energy drain (typical meetings, services)
  /// - 'high': High energy drain (difficult conversations, intense work, large groups)
  ///
  /// Used for:
  /// - Energy-aware scheduling (don't stack high-drain events)
  /// - Recovery time planning (schedule low-drain activities after high-drain)
  /// - Burnout prevention (track weekly energy expenditure)
  /// - Suggesting rest/breaks after high-energy events
  /// Default: 'medium'
  TextColumn get energyDrain => text().withDefault(const Constant('medium'))();

  /// Whether this event can be rescheduled
  /// Used for scheduling optimization and conflict resolution
  /// Examples:
  /// - Sunday worship service: is_moveable = false (fixed commitment)
  /// - Staff meeting: is_moveable = true (can reschedule if needed)
  /// - Family dinner: is_moveable = false (personal commitment)
  /// Default: true (most events are flexible)
  BoolColumn get isMoveable => boolean().withDefault(const Constant(true))();

  // ============================================================================
  // PREPARATION TIME TRACKING
  // ============================================================================

  /// Whether this event requires preparation time
  /// If true, should schedule preparation_buffer_hours before the event
  /// Examples:
  /// - Sunday service: requires_preparation = true (sermon prep, worship planning)
  /// - Board meeting: requires_preparation = true (review agenda, prepare reports)
  /// - Coffee chat: requires_preparation = false (casual, no prep needed)
  /// Default: false
  BoolColumn get requiresPreparation => boolean().withDefault(const Constant(false))();

  /// Hours needed for preparation before the event
  /// Only meaningful when requires_preparation = true
  /// Used for:
  /// - Automatic task creation (create prep task N hours before event)
  /// - Scheduling suggestions (block time for prep)
  /// - Workload planning (factor prep time into weekly schedule)
  /// Examples: 8 (for Sunday sermon), 3 (for board meeting), null (if no prep needed)
  /// Nullable - only set when requires_preparation = true
  /// Constraint: Must be positive integer if set (validated in app layer)
  IntColumn get preparationBufferHours => integer().nullable()();

  // ============================================================================
  // RELATIONSHIPS TO OTHER ENTITIES
  // ============================================================================

  /// Optional foreign key to people table (when implemented)
  /// Links event to specific person
  /// Use cases:
  /// - Pastoral visits for specific members ("Visit John Smith in hospital")
  /// - One-on-one meetings ("Coffee with Sarah")
  /// - Person-specific events ("John's birthday celebration")
  /// Nullable - not all events relate to specific people
  /// Note: FK constraint will be added when people table is created
  TextColumn get personId => text().nullable()();

  // ============================================================================
  // TIMESTAMPS
  // ============================================================================

  /// Timestamp when event record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when event record was last updated (Unix milliseconds)
  /// Should be updated on every modification
  /// Used for conflict resolution during sync
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  // ============================================================================
  // SYNC METADATA - Required for offline-first architecture
  // Reference: shepherd_technical_specification.md Section 9 (Offline Functionality)
  // ============================================================================

  /// Sync status: 'synced', 'pending', or 'conflict'
  /// - synced: Record matches server state exactly
  /// - pending: Local changes not yet pushed to Supabase (requires sync)
  /// - conflict: Both local and server have conflicting changes (requires user resolution)
  ///
  /// Sync workflow:
  /// 1. User creates/modifies event -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new events need to be synced)
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  /// Unix timestamp (milliseconds) when record was last modified locally
  /// Updated on every local modification
  /// Used to:
  /// - Detect local changes that need syncing
  /// - Order sync operations (oldest changes first)
  /// - Resolve conflicts (compare with serverUpdatedAt)
  IntColumn get localUpdatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Unix timestamp (milliseconds) of last known server state
  /// Updated when successfully synced with Supabase
  /// Used to:
  /// - Detect server-side changes during sync
  /// - Resolve conflicts (if localUpdatedAt > serverUpdatedAt, local wins)
  /// Nullable - not set until first successful sync
  IntColumn get serverUpdatedAt => integer().nullable()();

  /// Version counter for optimistic locking
  /// Incremented on each update (local or remote)
  /// Used to:
  /// - Detect concurrent modifications
  /// - Prevent lost updates (compare versions before overwriting)
  /// - Resolve three-way conflicts
  /// Default: 1 (initial version)
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}