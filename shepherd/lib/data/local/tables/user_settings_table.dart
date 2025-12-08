// lib/data/local/tables/user_settings_table.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'users_table.dart';

/// User Settings table - stores user preferences and configuration
///
/// This table contains all configurable preferences for the Shepherd app including:
/// - Contact frequency targets for different member types
/// - Sermon preparation time allocation
/// - Daily scheduling limits and focus time windows
/// - Notification preferences
/// - Offline cache and auto-archive settings
///
/// One settings record per user (1:1 relationship with users table)
///
/// Reference: shepherd_technical_specification.md Section 4 - Data Model (lines 304-343)
@DataClassName('UserSetting')
class UserSettings extends Table {
  /// Primary key - UUID generated on client
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  /// Foreign key to users table - establishes 1:1 relationship
  /// ON DELETE CASCADE: When user is deleted, their settings are automatically deleted
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();

  // ============================================================================
  // CONTACT FREQUENCY DEFAULTS (days between contacts)
  // Reference: Technical spec lines 310-312
  // ============================================================================

  /// Target days between contacts with church elders
  /// Default: 30 days (monthly check-ins)
  IntColumn get elderContactFrequencyDays => integer().withDefault(const Constant(30))();

  /// Target days between contacts with regular members
  /// Default: 90 days (quarterly check-ins)
  IntColumn get memberContactFrequencyDays => integer().withDefault(const Constant(90))();

  /// Target days between contacts with members in crisis
  /// Default: 3 days (frequent support during difficult times)
  IntColumn get crisisContactFrequencyDays => integer().withDefault(const Constant(3))();

  // ============================================================================
  // SERMON PREPARATION SETTINGS
  // Reference: Technical spec lines 314-315
  // ============================================================================

  /// Target hours per week for sermon preparation
  /// Default: 8 hours (one full workday equivalent)
  IntColumn get weeklySermonPrepHours => integer().withDefault(const Constant(8))();

  // ============================================================================
  // DAILY SCHEDULING LIMITS
  // Reference: Technical spec lines 317-319
  // ============================================================================

  /// Maximum hours to schedule in a single day (prevents overwork)
  /// Default: 10 hours
  IntColumn get maxDailyHours => integer().withDefault(const Constant(10))();

  /// Minimum duration (minutes) for deep focus blocks
  /// Default: 120 minutes (2 hours for sermon prep, study, writing)
  IntColumn get minFocusBlockMinutes => integer().withDefault(const Constant(120))();

  /// Start time for preferred focus hours
  /// Stored as TEXT in format 'HH:MM' (24-hour format)
  /// Example: '08:00' for 8:00 AM
  /// Nullable - user may not have set preference
  TextColumn get preferredFocusHoursStart => text().nullable()();

  /// End time for preferred focus hours
  /// Stored as TEXT in format 'HH:MM' (24-hour format)
  /// Example: '12:00' for 12:00 PM
  /// Nullable - user may not have set preference
  TextColumn get preferredFocusHoursEnd => text().nullable()();

  // ============================================================================
  // NOTIFICATION PREFERENCES
  // Reference: Technical spec lines 321-322
  // ============================================================================

  /// JSON-encoded notification preferences
  /// Stores complex nested structure as JSON string in SQLite
  /// Example: {"email": true, "push": true, "sms": false, "dailyDigest": "08:00"}
  ///
  /// Expected structure:
  /// {
  ///   "email": bool,
  ///   "push": bool,
  ///   "sms": bool,
  ///   "dailyDigest": string (time in HH:MM format),
  ///   "upcomingEvents": bool,
  ///   "overdueContacts": bool
  /// }
  TextColumn get notificationPreferences => text().nullable()();

  // ============================================================================
  // OFFLINE AND ARCHIVE SETTINGS
  // Reference: Technical spec lines 324-328
  // ============================================================================

  /// Number of days of data to cache for offline access
  /// Default: 90 days (3 months of recent data)
  /// Determines how much historical data to sync to local device
  IntColumn get offlineCacheDays => integer().withDefault(const Constant(90))();

  /// Enable automatic archiving of old records
  /// Stored as INTEGER: 1 = enabled, 0 = disabled
  /// Default: 1 (enabled)
  IntColumn get autoArchiveEnabled => integer().withDefault(const Constant(1))();

  /// Days after completion before tasks are auto-archived
  /// Default: 90 days (archive completed tasks after 3 months)
  IntColumn get archiveTasksAfterDays => integer().withDefault(const Constant(90))();

  /// Days after event date before events are auto-archived
  /// Default: 365 days (archive past events after 1 year)
  IntColumn get archiveEventsAfterDays => integer().withDefault(const Constant(365))();

  /// Days after creation before contact logs are auto-archived
  /// Default: 730 days (archive logs after 2 years)
  IntColumn get archiveLogsAfterDays => integer().withDefault(const Constant(730))();

  // ============================================================================
  // TIMESTAMPS
  // ============================================================================

  /// Timestamp when settings were created (Unix milliseconds)
  IntColumn get createdAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  /// Timestamp when settings were last updated (Unix milliseconds)
  IntColumn get updatedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  // ============================================================================
  // SYNC METADATA - Required for offline-first architecture
  // Reference: shepherd_technical_specification.md Section 9 (lines 2907-2910)
  // ============================================================================

  /// Sync status: 'synced', 'pending', or 'conflict'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Unix timestamp (milliseconds) when record was last modified locally
  IntColumn get localUpdatedAt => integer().nullable()();

  /// Unix timestamp (milliseconds) of last known server state
  IntColumn get serverUpdatedAt => integer().nullable()();

  /// Version counter for optimistic locking
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId}, // Each user can only have one settings record
  ];
}
