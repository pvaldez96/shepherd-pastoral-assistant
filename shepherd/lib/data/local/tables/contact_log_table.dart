// lib/data/local/tables/contact_log_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Contact Log table - mirrors Supabase contact_log table with offline-first sync metadata
///
/// This table logs all pastoral contacts with people: visits, calls, emails, texts,
/// in-person meetings, and other contact types. Enables automatic pastoral care tracking
/// by updating people.last_contact_date via trigger on Supabase side.
///
/// Key Features:
/// - Contact types: visit, call, email, text, in_person, other
/// - Duration tracking (optional)
/// - Contact notes for context
/// - Immutable logs (created_at only, no updated_at)
/// - Automatic update of people.last_contact_date
///
/// Reference: supabase/migrations/0004_people.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('ContactLog')
class ContactLogTable extends Table {
  // ============================================================================
  // PRIMARY KEY
  // ============================================================================

  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  /// Must match Supabase UUID format for seamless sync
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  // ============================================================================
  // FOREIGN KEYS - USER AND PERSON RELATIONSHIPS
  // ============================================================================

  /// Foreign key to users table - establishes multi-tenant isolation
  /// Every contact log belongs to exactly one user (the pastor who logged it)
  /// Note: Foreign keys are enforced at the application layer for web compatibility
  /// IndexedDB doesn't support CASCADE constraints, so cleanup is handled manually
  TextColumn get userId => text()();

  /// Foreign key to people table
  /// Every contact log belongs to exactly one person
  /// ON DELETE CASCADE: When person is deleted, their contact logs are also deleted
  TextColumn get personId => text()();

  // ============================================================================
  // CONTACT INFORMATION
  // ============================================================================

  /// Date of the contact (DATE only, no time component)
  /// Used for:
  /// - Updating people.last_contact_date
  /// - Calculating days since last contact
  /// - Contact frequency analysis
  /// Example: 2025-12-09 (time portion not significant)
  DateTimeColumn get contactDate => dateTime()();

  /// Type of contact - required field for categorization
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'visit': Home visit, hospital visit, etc.
  /// - 'call': Phone call
  /// - 'email': Email correspondence
  /// - 'text': Text message/SMS
  /// - 'in_person': In-person meeting (at church, office, etc.)
  /// - 'other': Other contact types
  ///
  /// Type affects:
  /// - Contact statistics and reporting
  /// - Contact method preferences analysis
  /// - Time tracking (some types typically take longer)
  TextColumn get contactType => text()();

  /// Optional duration of the contact (in minutes)
  /// Useful for:
  /// - Time tracking and analysis
  /// - Workload reporting
  /// - Understanding time investment per person
  /// Examples:
  /// - Phone call: 15 minutes
  /// - Home visit: 60 minutes
  /// - Hospital visit: 45 minutes
  /// Nullable - not all contacts have tracked duration
  /// Constraint: Must be positive if set (validated in app layer)
  IntColumn get durationMinutes => integer().nullable()();

  /// Optional notes about the contact
  /// Can include:
  /// - Summary of conversation
  /// - Prayer requests mentioned
  /// - Follow-up actions needed
  /// - Context for next contact
  /// Nullable - quick contacts may not need notes
  TextColumn get notes => text().nullable()();

  // ============================================================================
  // AUDIT TIMESTAMP
  // ============================================================================

  /// Timestamp when contact log was created (Unix milliseconds)
  /// Automatically set on insert
  /// Note: Contact logs are immutable - no updated_at field
  /// Once logged, contacts shouldn't be modified (audit trail)
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

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
  /// 1. User logs contact -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new contact logs need to be synced)
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  /// Unix timestamp (milliseconds) when record was last modified locally
  /// For contact logs (immutable), this is the same as createdAt
  /// Kept for consistency with other tables' sync patterns
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
  /// Note: For immutable contact logs, version should always be 1
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'contact_log';
}
