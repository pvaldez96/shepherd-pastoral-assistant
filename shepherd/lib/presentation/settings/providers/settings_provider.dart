// lib/presentation/settings/providers/settings_provider.dart

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';

/// Provider for the AppDatabase singleton
/// Reused from task providers
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Stream provider for user settings
///
/// Watches the database for settings changes and automatically updates the UI.
/// Returns the first (and only) settings record for the current user.
///
/// Usage:
/// ```dart
/// final settingsAsync = ref.watch(userSettingsProvider(userId));
/// settingsAsync.when(
///   data: (settings) => SettingsForm(settings: settings),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error loading settings'),
/// );
/// ```
final userSettingsProvider =
    StreamProvider.family<UserSetting?, String>((ref, userId) {
  final database = ref.watch(databaseProvider);

  // Watch for changes to user settings for this specific user
  return (database.select(database.userSettings)
        ..where((s) => s.userId.equals(userId)))
      .watchSingleOrNull();
});

/// Provider for settings operations
///
/// Provides methods to create, update, and save user settings.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SettingsRepository(database);
});

/// Repository for user settings operations
///
/// Handles all CRUD operations for user settings including:
/// - Loading settings for a user
/// - Creating default settings for new users
/// - Updating individual settings
/// - Batch updating all settings
class SettingsRepository {
  final AppDatabase _database;

  SettingsRepository(this._database);

  /// Get or create settings for a user
  ///
  /// If settings don't exist, creates them with default values.
  /// Returns the settings record.
  Future<UserSetting> getOrCreateSettings(String userId) async {
    // Try to get existing settings
    final existing = await (_database.select(_database.userSettings)
          ..where((s) => s.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    // Create default settings
    return await createDefaultSettings(userId);
  }

  /// Create default settings for a user
  ///
  /// Uses default values from the table schema:
  /// - Elder contact: 30 days
  /// - Member contact: 90 days
  /// - Crisis contact: 3 days
  /// - Sermon prep: 8 hours/week
  /// - Max daily hours: 10
  /// - Min focus block: 120 minutes
  Future<UserSetting> createDefaultSettings(String userId) async {
    final companion = UserSettingsCompanion.insert(
      userId: userId,
      // All other fields use table defaults
      syncStatus: const drift.Value('pending'), // Mark for sync
    );

    await _database.into(_database.userSettings).insert(companion);

    // Return the created settings by userId
    return await (_database.select(_database.userSettings)
          ..where((s) => s.userId.equals(userId)))
        .getSingle();
  }

  /// Update user settings
  ///
  /// Accepts a companion object with only the fields to update.
  /// Automatically marks as pending sync and updates timestamp.
  Future<void> updateSettings(
    String settingsId,
    UserSettingsCompanion updates,
  ) async {
    // Ensure sync metadata is updated
    final companionWithSync = updates.copyWith(
      syncStatus: const drift.Value('pending'),
      localUpdatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    );

    await (_database.update(_database.userSettings)
          ..where((s) => s.id.equals(settingsId)))
        .write(companionWithSync);
  }

  /// Update contact frequency thresholds
  Future<void> updateContactFrequencies({
    required String settingsId,
    int? elderContactFrequencyDays,
    int? memberContactFrequencyDays,
    int? crisisContactFrequencyDays,
  }) async {
    final companion = UserSettingsCompanion(
      elderContactFrequencyDays: elderContactFrequencyDays != null
          ? drift.Value(elderContactFrequencyDays)
          : const drift.Value.absent(),
      memberContactFrequencyDays: memberContactFrequencyDays != null
          ? drift.Value(memberContactFrequencyDays)
          : const drift.Value.absent(),
      crisisContactFrequencyDays: crisisContactFrequencyDays != null
          ? drift.Value(crisisContactFrequencyDays)
          : const drift.Value.absent(),
    );

    await updateSettings(settingsId, companion);
  }

  /// Update sermon prep settings
  Future<void> updateSermonPrepSettings({
    required String settingsId,
    int? weeklySermonPrepHours,
  }) async {
    final companion = UserSettingsCompanion(
      weeklySermonPrepHours: weeklySermonPrepHours != null
          ? drift.Value(weeklySermonPrepHours)
          : const drift.Value.absent(),
    );

    await updateSettings(settingsId, companion);
  }

  /// Update workload management settings
  Future<void> updateWorkloadSettings({
    required String settingsId,
    int? maxDailyHours,
    int? minFocusBlockMinutes,
  }) async {
    final companion = UserSettingsCompanion(
      maxDailyHours: maxDailyHours != null
          ? drift.Value(maxDailyHours)
          : const drift.Value.absent(),
      minFocusBlockMinutes: minFocusBlockMinutes != null
          ? drift.Value(minFocusBlockMinutes)
          : const drift.Value.absent(),
    );

    await updateSettings(settingsId, companion);
  }

  /// Update preferred focus hours
  Future<void> updateFocusHours({
    required String settingsId,
    String? preferredFocusHoursStart,
    String? preferredFocusHoursEnd,
  }) async {
    final companion = UserSettingsCompanion(
      preferredFocusHoursStart: preferredFocusHoursStart != null
          ? drift.Value(preferredFocusHoursStart)
          : const drift.Value.absent(),
      preferredFocusHoursEnd: preferredFocusHoursEnd != null
          ? drift.Value(preferredFocusHoursEnd)
          : const drift.Value.absent(),
    );

    await updateSettings(settingsId, companion);
  }
}

// Usage examples:
//
// Load settings for current user:
// ```dart
// final userId = ref.read(authNotifierProvider).user?.id;
// final settingsAsync = ref.watch(userSettingsProvider(userId!));
// ```
//
// Update settings:
// ```dart
// final repository = ref.read(settingsRepositoryProvider);
// await repository.updateContactFrequencies(
//   settingsId: settings.id,
//   elderContactFrequencyDays: 30,
//   memberContactFrequencyDays: 90,
// );
// ```
//
// Get or create settings:
// ```dart
// final repository = ref.read(settingsRepositoryProvider);
// final settings = await repository.getOrCreateSettings(userId);
// ```
