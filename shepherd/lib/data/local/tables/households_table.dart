// lib/data/local/tables/households_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Households table - mirrors Supabase households table with offline-first sync metadata
///
/// This table stores family/household groupings for people management. Households
/// allow pastors to organize contacts by family units, making it easier to track
/// pastoral care at the household level.
///
/// Key Features:
/// - Simple household identification (name, address)
/// - Links multiple people records to a single household
/// - Multi-tenant isolation via user_id
///
/// Reference: supabase/migrations/0004_people.sql
/// Reference: shepherd_technical_specification.md Section 4 - Data Model
@DataClassName('Household')
class Households extends Table {
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
  /// Every household belongs to exactly one user (the pastor who created it)
  /// Note: Foreign keys are enforced at the application layer for web compatibility
  /// IndexedDB doesn't support CASCADE constraints, so cleanup is handled manually
  TextColumn get userId => text()();

  // ============================================================================
  // HOUSEHOLD INFORMATION
  // ============================================================================

  /// Household name - required, non-empty string
  /// Example: "Smith Family", "Johnson Household", "The Wilsons"
  /// Constraint: Must have at least one non-whitespace character (validated in app layer)
  TextColumn get name => text()();

  /// Optional household address
  /// Can be full street address or just general location
  /// Example: "123 Main St, Springfield, IL 62701"
  /// Nullable - not all households need address tracking
  TextColumn get address => text().nullable()();

  // ============================================================================
  // AUDIT TIMESTAMPS
  // ============================================================================

  /// Timestamp when household record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when household record was last updated (Unix milliseconds)
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
  /// 1. User modifies household -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new households need to be synced)
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
