// lib/data/local/tables/tasks_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'users_table.dart';

/// Tasks table - mirrors Supabase tasks table with offline-first sync metadata
///
/// This table stores task management data for pastors including task details,
/// scheduling, categorization, productivity features, and relationships to other
/// entities (people, events, sermons). All fields mirror the Supabase schema
/// to ensure seamless synchronization.
///
/// Key Features:
/// - Flexible categorization (sermon_prep, pastoral_care, admin, personal, worship_planning)
/// - Priority levels (low, medium, high, urgent)
/// - Status tracking (not_started, in_progress, done, deleted)
/// - Productivity features (energy_level, requires_focus)
/// - Time tracking (estimated vs actual duration)
/// - Relationships (person_id, calendar_event_id, sermon_id, parent_task_id)
/// - Soft delete pattern (status='deleted', deleted_at timestamp)
///
/// Reference: supabase/migrations/0002_tasks_table.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('Task')
class Tasks extends Table {
  // ============================================================================
  // PRIMARY KEY
  // ============================================================================

  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  /// Must match Supabase UUID format for seamless sync
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  // ============================================================================
  // FOREIGN KEY - USER RELATIONSHIP
  // ============================================================================

  /// Foreign key to users table - establishes multi-tenant isolation
  /// Every task belongs to exactly one user (the pastor who created it)
  /// ON DELETE CASCADE: When user is deleted, their tasks are automatically deleted
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();

  // ============================================================================
  // CORE TASK INFORMATION
  // ============================================================================

  /// Task title - required, non-empty string
  /// Example: "Prepare Sunday sermon outline", "Visit hospitalized member"
  /// Constraint: Must have at least one non-whitespace character (validated in app layer)
  TextColumn get title => text()();

  /// Optional detailed task description
  /// Can include notes, instructions, context, or any additional information
  /// Nullable - simple tasks may not need description
  TextColumn get description => text().nullable()();

  // ============================================================================
  // SCHEDULING - DUE DATE AND TIME
  // ============================================================================

  /// Optional due date (DATE only, no time component)
  /// Stored as DateTime in Dart, but only date part is significant
  /// Use for tasks with specific deadlines
  /// Nullable - not all tasks have due dates
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Optional due time (TIME only, stored as text in HH:MM format)
  /// Stored as TEXT in SQLite: '09:30', '14:00', '23:45'
  /// Paired with due_date to create full datetime
  /// Example: due_date = 2025-12-15, due_time = '10:30' -> Due at Dec 15, 2025 10:30 AM
  /// Nullable - many tasks have date but no specific time
  TextColumn get dueTime => text().nullable()();

  // ============================================================================
  // TIME TRACKING
  // ============================================================================

  /// Estimated duration to complete task (in minutes)
  /// Example: 120 = 2 hours, 45 = 45 minutes
  /// Used for:
  /// - Calendar blocking suggestions
  /// - Workload estimation
  /// - Scheduling optimization
  /// Nullable - not all tasks have time estimates
  /// Constraint: Must be positive integer if set (validated in app layer)
  IntColumn get estimatedDurationMinutes => integer().nullable()();

  /// Actual duration spent on task (in minutes)
  /// Tracked after task completion
  /// Used for:
  /// - Improving future estimates
  /// - Time audit and productivity analysis
  /// - Reporting (how much time spent on sermon prep vs admin)
  /// Nullable - only set after task is completed and tracked
  /// Constraint: Must be positive integer if set (validated in app layer)
  IntColumn get actualDurationMinutes => integer().nullable()();

  // ============================================================================
  // TASK CATEGORIZATION
  // ============================================================================

  /// Task category - required field for organization and filtering
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'sermon_prep': Sermon preparation tasks (research, outlining, writing)
  /// - 'pastoral_care': Caring for congregation (visits, calls, counseling)
  /// - 'admin': Administrative tasks (budgets, reports, emails)
  /// - 'personal': Personal development (reading, prayer, exercise)
  /// - 'worship_planning': Worship service planning (music, liturgy, order of service)
  ///
  /// Category enables:
  /// - Filtered task views ("Show all sermon prep tasks")
  /// - Time allocation tracking ("Am I spending enough time on pastoral care?")
  /// - Workload balancing suggestions
  TextColumn get category => text()();

  /// Task priority - helps with task ordering and urgency
  /// Valid values (enforced in app layer):
  /// - 'low': Can wait, no immediate deadline
  /// - 'medium': Normal priority (default)
  /// - 'high': Important, should be done soon
  /// - 'urgent': Critical, needs immediate attention
  /// Default: 'medium'
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  /// Task status - lifecycle state of the task
  /// Valid values (enforced in app layer):
  /// - 'not_started': Task created but not yet begun (default)
  /// - 'in_progress': Currently working on task
  /// - 'done': Task completed (completed_at timestamp required)
  /// - 'deleted': Task soft-deleted (deleted_at timestamp required)
  ///
  /// Status transitions:
  /// - not_started -> in_progress -> done
  /// - Any status -> deleted (soft delete)
  /// Default: 'not_started'
  TextColumn get status => text().withDefault(const Constant('not_started'))();

  // ============================================================================
  // PRODUCTIVITY FEATURES
  // ============================================================================

  /// Whether task requires dedicated focus time (no interruptions)
  /// Used for smart scheduling to find uninterrupted time blocks
  /// Examples of focus tasks:
  /// - Writing sermon manuscript (requires_focus = true)
  /// - Deep study/exegesis (requires_focus = true)
  /// - Quick admin emails (requires_focus = false)
  /// Default: false
  BoolColumn get requiresFocus => boolean().withDefault(const Constant(false))();

  /// Energy level required to complete task effectively
  /// Valid values (enforced in app layer):
  /// - 'low': Can be done when tired (filing, simple emails)
  /// - 'medium': Normal energy level (default)
  /// - 'high': Requires peak mental energy (sermon writing, strategic planning)
  ///
  /// Used for smart scheduling:
  /// - Schedule high-energy tasks during peak focus hours
  /// - Save low-energy tasks for end of day
  /// - Match task energy to pastor's energy patterns
  /// Default: 'medium'
  TextColumn get energyLevel => text().withDefault(const Constant('medium'))();

  // ============================================================================
  // RELATIONSHIPS TO OTHER ENTITIES
  // ============================================================================

  /// Optional foreign key to people table (when implemented)
  /// Links task to specific person (e.g., "Visit John Smith in hospital")
  /// Use cases:
  /// - Pastoral care tasks for specific members
  /// - Meeting preparations for specific leaders
  /// Nullable - not all tasks relate to specific people
  /// Note: FK constraint will be added in migration 0003_people_table.sql
  TextColumn get personId => text().nullable()();

  /// Optional foreign key to calendar_events table (when implemented)
  /// Links task to specific calendar event
  /// Use cases:
  /// - Preparation tasks for specific events
  /// - Follow-up tasks after meetings
  /// Nullable - not all tasks relate to events
  /// Note: FK constraint will be added in migration 0004_calendar_events_table.sql
  TextColumn get calendarEventId => text().nullable()();

  /// Optional foreign key to sermons table (when implemented)
  /// Links task to specific sermon
  /// Use cases:
  /// - Sermon preparation tasks (research, outlining, writing)
  /// - All tasks for a sermon can be grouped together
  /// Nullable - not all tasks relate to sermons
  /// Note: FK constraint will be added in migration 0005_sermons_table.sql
  TextColumn get sermonId => text().nullable()();

  /// Optional parent task ID for creating task hierarchies (subtasks)
  /// Self-referencing foreign key to tasks table
  /// Enables task breakdown:
  /// - Parent: "Prepare Sunday sermon"
  ///   - Subtask: "Research passage context"
  ///   - Subtask: "Create outline"
  ///   - Subtask: "Write manuscript"
  /// Nullable - top-level tasks have no parent
  /// ON DELETE CASCADE: When parent task is deleted, subtasks are also deleted
  TextColumn get parentTaskId => text().nullable()();

  // ============================================================================
  // STATUS TIMESTAMPS
  // ============================================================================

  /// Timestamp when task was marked as done
  /// NULL until task status changes to 'done'
  /// Constraint (enforced in app layer):
  /// - Must be NULL when status != 'done'
  /// - Must be NOT NULL when status = 'done'
  /// Used for:
  /// - Completion tracking
  /// - Productivity analytics
  /// - Auto-archiving completed tasks
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Timestamp when task was soft-deleted
  /// NULL for active tasks
  /// Constraint (enforced in app layer):
  /// - Must be NULL when status != 'deleted'
  /// - Must be NOT NULL when status = 'deleted'
  /// Soft delete pattern allows:
  /// - Task recovery ("undo delete")
  /// - Audit trail of deleted tasks
  /// - Auto-purge after retention period
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Timestamp when task record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when task record was last updated (Unix milliseconds)
  /// Should be updated on every modification
  /// Used for conflict resolution during sync
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  // ============================================================================
  // SYNC METADATA - Required for offline-first architecture
  // Reference: shepherd_technical_specification.md Section 9 (lines 2907-2910)
  // ============================================================================

  /// Sync status: 'synced', 'pending', or 'conflict'
  /// - synced: Record matches server state exactly
  /// - pending: Local changes not yet pushed to Supabase (requires sync)
  /// - conflict: Both local and server have conflicting changes (requires user resolution)
  ///
  /// Sync workflow:
  /// 1. User modifies task -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new tasks need to be synced)
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
