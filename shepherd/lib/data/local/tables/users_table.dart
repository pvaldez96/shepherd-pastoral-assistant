// lib/data/local/tables/users_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Users table - mirrors Supabase users table with offline-first sync metadata
///
/// This table stores core user profile information including authentication details,
/// church affiliation, and timezone preferences. All fields mirror the Supabase schema
/// to ensure seamless synchronization.
///
/// Reference: shepherd_technical_specification.md Section 4 - Data Model (lines 291-302)
@DataClassName('User')
class Users extends Table {
  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  /// User's email address - unique identifier for authentication
  /// Must be unique across all users
  TextColumn get email => text().unique()();

  /// User's full name or display name
  TextColumn get name => text()();

  /// Name of the church the pastor serves
  /// Nullable - may not be set initially
  TextColumn get churchName => text().nullable()();

  /// Timezone for scheduling and notifications
  /// Default: America/Chicago (Central Time)
  /// Format: IANA timezone string (e.g., 'America/New_York', 'Europe/London')
  TextColumn get timezone => text().withDefault(const Constant('America/Chicago'))();

  /// Timestamp when the record was created (Unix milliseconds)
  /// Automatically set on insert
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when the record was last updated (Unix milliseconds)
  /// Should be updated on every modification
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  // ============================================================================
  // SYNC METADATA - Required for offline-first architecture
  // Reference: shepherd_technical_specification.md Section 9 (lines 2907-2910)
  // ============================================================================

  /// Sync status: 'synced', 'pending', or 'conflict'
  /// - synced: Record matches server state
  /// - pending: Local changes not yet pushed to server
  /// - conflict: Both local and server have conflicting changes
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Unix timestamp (milliseconds) when record was last modified locally
  /// Used to detect local changes and order sync operations
  IntColumn get localUpdatedAt => integer().nullable()();

  /// Unix timestamp (milliseconds) of last known server state
  /// Used to detect server-side changes and resolve conflicts
  IntColumn get serverUpdatedAt => integer().nullable()();

  /// Version counter for optimistic locking
  /// Incremented on each update, used to detect concurrent modifications
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
