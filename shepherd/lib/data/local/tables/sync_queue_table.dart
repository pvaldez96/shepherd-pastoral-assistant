// lib/data/local/tables/sync_queue_table.dart

import 'package:drift/drift.dart';

/// Sync Queue table - tracks pending operations for offline-first sync
///
/// This table acts as a persistent queue for all database operations that need
/// to be synchronized with the Supabase server. When the app is offline or sync
/// fails, operations are queued here for retry.
///
/// Queue Processing:
/// 1. Operations are added when local changes are made
/// 2. Sync engine processes queue in FIFO order (oldest first)
/// 3. Successfully synced operations are deleted from queue
/// 4. Failed operations increment retry_count and log error
/// 5. Operations with excessive retries may need manual intervention
///
/// Reference: shepherd_technical_specification.md Section 9 (lines 2913-2922)
@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  /// Auto-incrementing primary key
  /// SQLite AUTOINCREMENT ensures IDs are never reused (safe for queue ordering)
  IntColumn get id => integer().autoIncrement()();

  /// Name of the table affected by this operation
  /// Examples: 'users', 'user_settings', 'tasks', 'calendar_events', 'people'
  /// Used to route the operation to the correct sync handler
  TextColumn get affectedTable => text()();

  /// UUID of the record affected by this operation
  /// Points to the id field in the target table
  /// Used to identify which record to sync
  TextColumn get recordId => text()();

  /// Type of database operation to perform
  /// Valid values: 'insert', 'update', 'delete'
  /// - insert: Create new record on server
  /// - update: Modify existing record on server
  /// - delete: Remove record from server (soft or hard delete)
  TextColumn get operation => text()();

  /// JSON-encoded payload containing the data to sync
  ///
  /// For INSERT and UPDATE operations:
  /// Contains the full record data (or delta) to send to server
  /// Example: {"title": "Visit Mrs. Johnson", "status": "done", "completed_at": "2025-01-15T10:30:00Z"}
  ///
  /// For DELETE operations:
  /// May be empty or contain metadata about the deletion
  /// Example: {"deleted_at": "2025-01-15T10:30:00Z"}
  ///
  /// The payload excludes sync metadata fields (_sync_status, _local_updated_at, etc.)
  /// as those are for local use only
  TextColumn get payload => text().nullable()();

  /// Unix timestamp (milliseconds) when this queue entry was created
  /// Used to:
  /// 1. Maintain FIFO ordering (process oldest first)
  /// 2. Calculate operation age for retry backoff
  /// 3. Identify stale operations that may need cleanup
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Number of times this operation has been attempted
  /// Default: 0 (incremented before each retry attempt)
  ///
  /// Retry strategy:
  /// - 0-3 retries: Immediate retry on next sync cycle
  /// - 4-10 retries: Exponential backoff (wait longer between attempts)
  /// - 10+ retries: Flag for manual review (may indicate data conflict or API issue)
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Error message from the last failed sync attempt
  /// Nullable - empty for operations not yet attempted or successful
  ///
  /// Examples:
  /// - "Network error: No internet connection"
  /// - "Conflict: Record was modified on server"
  /// - "Validation error: Invalid email format"
  /// - "Auth error: User session expired"
  ///
  /// Used for debugging and user-facing error messages
  TextColumn get lastError => text().nullable()();

  // Note: No need to override primaryKey when using autoIncrement()
  // Drift automatically sets the auto-increment column as primary key
}
