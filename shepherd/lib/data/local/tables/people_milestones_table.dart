// lib/data/local/tables/people_milestones_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// People Milestones table - mirrors Supabase people_milestones table with offline-first sync metadata
///
/// This table tracks important dates for people: birthdays, anniversaries, surgeries,
/// and other milestones. Enables proactive pastoral care by notifying pastors of
/// upcoming milestones.
///
/// Key Features:
/// - Milestone types: birthday, anniversary, surgery, other
/// - Notification settings (days before milestone)
/// - Optional descriptions for context
/// - Linked to people records
///
/// Reference: supabase/migrations/0004_people.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('PeopleMilestone')
class PeopleMilestones extends Table {
  // ============================================================================
  // PRIMARY KEY
  // ============================================================================

  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  /// Must match Supabase UUID format for seamless sync
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  // ============================================================================
  // FOREIGN KEY - PERSON RELATIONSHIP
  // ============================================================================

  /// Foreign key to people table
  /// Every milestone belongs to exactly one person
  /// Note: Foreign keys are enforced at the application layer for web compatibility
  /// ON DELETE CASCADE: When person is deleted, their milestones are also deleted
  TextColumn get personId => text()();

  // ============================================================================
  // MILESTONE INFORMATION
  // ============================================================================

  /// Milestone type - required field for categorization
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'birthday': Person's birthday (recurring annually)
  /// - 'anniversary': Wedding anniversary or other anniversary (recurring annually)
  /// - 'surgery': Scheduled surgery date (one-time event)
  /// - 'other': Other important dates
  ///
  /// Type affects notification behavior:
  /// - birthday/anniversary: Recurring notifications every year
  /// - surgery/other: One-time notifications
  TextColumn get milestoneType => text()();

  /// Date of the milestone
  /// For recurring events (birthday, anniversary), only month and day are significant
  /// For one-time events (surgery), full date is used
  /// Example: Birthday on March 15 stored as "YYYY-03-15" (year can be birth year or arbitrary)
  DateTimeColumn get date => dateTime()();

  /// Optional description of the milestone
  /// Provides context for the milestone
  /// Examples:
  /// - "80th birthday - planning celebration"
  /// - "Knee replacement surgery at St. Mary's Hospital"
  /// - "25th wedding anniversary"
  /// Nullable - simple milestones may not need description
  TextColumn get description => text().nullable()();

  /// Days before milestone to trigger notification
  /// Allows pastor to plan ahead for pastoral care
  /// Examples:
  /// - Birthday: 2 days before (send card)
  /// - Surgery: 7 days before (schedule visit)
  /// - Anniversary: 1 week before (plan recognition)
  /// Default: 2 days
  /// Constraint: Must be non-negative if set (validated in app layer)
  IntColumn get notifyDaysBefore => integer().withDefault(const Constant(2))();

  // ============================================================================
  // AUDIT TIMESTAMPS
  // ============================================================================

  /// Timestamp when milestone record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when milestone record was last updated (Unix milliseconds)
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
  /// 1. User modifies milestone -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new milestones need to be synced)
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
