// lib/data/local/tables/people_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// People table - mirrors Supabase people table with offline-first sync metadata
///
/// This table stores the contact database for pastoral care with categories,
/// pastoral care tracking, household relationships, and flexible tagging.
///
/// Key Features:
/// - Contact information (name, email, phone)
/// - Categorization (elder, member, visitor, leadership, crisis, family, other)
/// - Household relationships
/// - Automatic pastoral care tracking (last_contact_date)
/// - Contact frequency overrides per person
/// - Flexible tagging system
/// - Notes for additional context
///
/// Reference: supabase/migrations/0004_people.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('Person')
class People extends Table {
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
  /// Every person belongs to exactly one user (the pastor who created it)
  /// Note: Foreign keys are enforced at the application layer for web compatibility
  /// IndexedDB doesn't support CASCADE constraints, so cleanup is handled manually
  TextColumn get userId => text()();

  // ============================================================================
  // PERSONAL INFORMATION
  // ============================================================================

  /// Person's name - required, non-empty string
  /// Example: "John Smith", "Mary Johnson", "Rev. David Williams"
  /// Constraint: Must have at least one non-whitespace character (validated in app layer)
  TextColumn get name => text()();

  /// Optional email address
  /// Example: "john.smith@example.com"
  /// Nullable - not all contacts have email
  TextColumn get email => text().nullable()();

  /// Optional phone number
  /// Example: "(555) 123-4567", "555-123-4567", "+1-555-123-4567"
  /// Format not enforced - can be stored in any format user prefers
  /// Nullable - not all contacts have phone
  TextColumn get phone => text().nullable()();

  // ============================================================================
  // CATEGORIZATION
  // ============================================================================

  /// Person category - required field for pastoral care organization
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'elder': Church elders requiring regular check-ins
  /// - 'member': Regular church members
  /// - 'visitor': Visitors to the church
  /// - 'leadership': Leadership team members
  /// - 'crisis': People in crisis needing frequent contact
  /// - 'family': Pastor's family members
  /// - 'other': Other contacts not fitting above categories
  ///
  /// Category enables:
  /// - Different contact frequency thresholds (from user_settings)
  /// - Filtered views ("Show all elders", "Show people in crisis")
  /// - Pastoral care prioritization
  TextColumn get category => text()();

  // ============================================================================
  // HOUSEHOLD RELATIONSHIP
  // ============================================================================

  /// Optional foreign key to households table
  /// Links person to a family/household grouping
  /// Use cases:
  /// - Track entire families together
  /// - Avoid duplicate pastoral care contacts to same household
  /// - Organize by family units
  /// Nullable - not all people belong to tracked households
  /// ON DELETE SET NULL: If household is deleted, person remains but household link is removed
  TextColumn get householdId => text().nullable()();

  // ============================================================================
  // PASTORAL CARE TRACKING
  // ============================================================================

  /// Date of most recent contact with this person
  /// Automatically updated by trigger when contact_log entry is inserted
  /// Used to:
  /// - Calculate days since last contact
  /// - Identify people needing attention (overdue contacts)
  /// - Dashboard warnings for overdue pastoral care
  /// Nullable - new contacts may not have been contacted yet
  DateTimeColumn get lastContactDate => dateTime().nullable()();

  /// Override default contact frequency for this specific person (in days)
  /// Overrides category-based frequency from user_settings
  /// Example: Elder category default is 30 days, but this specific elder is set to 14 days
  /// Use cases:
  /// - People in temporary crisis needing more frequent contact
  /// - Leaders requiring more frequent check-ins
  /// - People requesting less frequent contact
  /// Nullable - uses category default if not overridden
  /// Constraint: Must be positive integer if set (validated in app layer)
  IntColumn get contactFrequencyOverrideDays => integer().nullable()();

  // ============================================================================
  // ADDITIONAL INFORMATION
  // ============================================================================

  /// Free-form notes about the person
  /// Can include:
  /// - Prayer requests
  /// - Health concerns
  /// - Family situation
  /// - Pastoral care context
  /// - Any other relevant information
  /// Nullable - not all contacts need notes
  TextColumn get notes => text().nullable()();

  /// Array of tags for flexible organization
  /// Stored as TEXT in SQLite (JSON-encoded array), TEXT[] in Supabase
  /// Examples: ["prayer_team", "small_group_leader", "sunday_school"]
  /// Use cases:
  /// - Filter by role or involvement
  /// - Track ministry participation
  /// - Flexible grouping beyond categories
  /// Default: empty array
  /// Note: In Drift/SQLite, this is stored as TEXT and requires JSON encoding/decoding
  /// The app layer handles conversion between List<String> and JSON string
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  // ============================================================================
  // AUDIT TIMESTAMPS
  // ============================================================================

  /// Timestamp when person record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when person record was last updated (Unix milliseconds)
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
  /// 1. User modifies person -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new people need to be synced)
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
