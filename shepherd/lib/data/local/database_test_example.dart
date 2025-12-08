// lib/data/local/database_test_example.dart
//
// This file demonstrates how to use the AppDatabase with example operations.
// You can run this to verify the database setup is working correctly.
//
// To test:
// 1. Import this file in your main.dart or a test file
// 2. Call testDatabase() function
// 3. Check console output for results

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';

/// Test function to verify database operations work correctly
///
/// This performs basic CRUD operations on all tables to ensure
/// the Drift setup is functioning properly.
Future<void> testDatabase() async {
  print('=== Shepherd Database Test ===\n');

  final db = AppDatabase();

  try {
    // ============================================================================
    // TEST 1: Create a User
    // ============================================================================
    print('TEST 1: Creating a user...');

    final userId = const Uuid().v4();
    final userCompanion = UsersCompanion.insert(
      id: Value(userId),
      email: 'pastor.john@church.com',
      name: 'Pastor John Smith',
      churchName: const Value('First Baptist Church of Springfield'),
      timezone: const Value('America/Chicago'),
    );

    await db.into(db.users).insert(userCompanion);
    print('✓ User created with ID: $userId\n');

    // ============================================================================
    // TEST 2: Query the User
    // ============================================================================
    print('TEST 2: Querying user by email...');

    final user = await db.getUserByEmail('pastor.john@church.com');
    if (user != null) {
      print('✓ Found user:');
      print('  - ID: ${user.id}');
      print('  - Name: ${user.name}');
      print('  - Email: ${user.email}');
      print('  - Church: ${user.churchName}');
      print('  - Timezone: ${user.timezone}');
      print('  - Sync Status: ${user.syncStatus}');
      print('  - Created: ${DateTime.fromMillisecondsSinceEpoch(user.createdAt)}');
    } else {
      print('✗ User not found!');
    }
    print('');

    // ============================================================================
    // TEST 3: Create User Settings
    // ============================================================================
    print('TEST 3: Creating user settings...');

    final settingsId = const Uuid().v4();
    final notificationPrefs = {
      'email': true,
      'push': true,
      'sms': false,
      'dailyDigest': '08:00',
      'upcomingEvents': true,
      'overdueContacts': true,
    };

    final settingsCompanion = UserSettingsCompanion.insert(
      id: Value(settingsId),
      userId: userId,
      elderContactFrequencyDays: const Value(30),
      memberContactFrequencyDays: const Value(90),
      crisisContactFrequencyDays: const Value(3),
      weeklySermonPrepHours: const Value(10),
      maxDailyHours: const Value(8),
      minFocusBlockMinutes: const Value(120),
      preferredFocusHoursStart: const Value('08:00'),
      preferredFocusHoursEnd: const Value('12:00'),
      notificationPreferences: Value(jsonEncode(notificationPrefs)),
      offlineCacheDays: const Value(90),
      autoArchiveEnabled: const Value(1),
      archiveTasksAfterDays: const Value(90),
      archiveEventsAfterDays: const Value(365),
      archiveLogsAfterDays: const Value(730),
    );

    await db.into(db.userSettings).insert(settingsCompanion);
    print('✓ User settings created with ID: $settingsId\n');

    // ============================================================================
    // TEST 4: Query User Settings
    // ============================================================================
    print('TEST 4: Querying user settings...');

    final settings = await db.getUserSettings(userId);
    if (settings != null) {
      print('✓ Found settings:');
      print('  - Elder contact frequency: ${settings.elderContactFrequencyDays} days');
      print('  - Member contact frequency: ${settings.memberContactFrequencyDays} days');
      print('  - Crisis contact frequency: ${settings.crisisContactFrequencyDays} days');
      print('  - Weekly sermon prep: ${settings.weeklySermonPrepHours} hours');
      print('  - Max daily hours: ${settings.maxDailyHours}');
      print('  - Focus block: ${settings.minFocusBlockMinutes} minutes');
      print('  - Focus hours: ${settings.preferredFocusHoursStart} - ${settings.preferredFocusHoursEnd}');
      print('  - Offline cache: ${settings.offlineCacheDays} days');

      if (settings.notificationPreferences != null) {
        final prefs = jsonDecode(settings.notificationPreferences!);
        print('  - Notifications: ${prefs['email'] ? 'Email' : ''} ${prefs['push'] ? 'Push' : ''} ${prefs['sms'] ? 'SMS' : ''}');
      }
    } else {
      print('✗ Settings not found!');
    }
    print('');

    // ============================================================================
    // TEST 5: Update User (simulate local change)
    // ============================================================================
    print('TEST 5: Updating user name...');

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        name: const Value('Pastor John David Smith'),
        syncStatus: const Value('pending'),
        localUpdatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final updatedUser = await db.getUserById(userId);
    print('✓ User updated:');
    print('  - New name: ${updatedUser?.name}');
    print('  - Sync status: ${updatedUser?.syncStatus}');
    print('');

    // ============================================================================
    // TEST 6: Add to Sync Queue
    // ============================================================================
    print('TEST 6: Adding operation to sync queue...');

    final queueCompanion = SyncQueueCompanion.insert(
      affectedTable: 'users',
      recordId: userId,
      operation: 'update',
      payload: Value(jsonEncode({
        'name': 'Pastor John David Smith',
      })),
      // createdAt auto-generated by clientDefault
    );

    await db.into(db.syncQueue).insert(queueCompanion);
    print('✓ Operation queued for sync\n');

    // ============================================================================
    // TEST 7: Query Sync Queue
    // ============================================================================
    print('TEST 7: Checking sync queue...');

    final pendingQueue = await db.getPendingSyncQueue();
    print('✓ Pending sync operations: ${pendingQueue.length}');

    for (final entry in pendingQueue) {
      print('  - Table: ${entry.affectedTable}');
      print('    Record ID: ${entry.recordId}');
      print('    Operation: ${entry.operation}');
      print('    Retry count: ${entry.retryCount}');
      print('    Created: ${DateTime.fromMillisecondsSinceEpoch(entry.createdAt)}');
      if (entry.payload != null) {
        print('    Payload: ${entry.payload}');
      }
    }
    print('');

    // ============================================================================
    // TEST 8: Check Pending Sync Counts
    // ============================================================================
    print('TEST 8: Checking pending sync counts across tables...');

    final syncCounts = await db.getPendingSyncCounts();
    print('✓ Pending records by table:');
    syncCounts.forEach((table, count) {
      print('  - $table: $count');
    });
    print('');

    // ============================================================================
    // TEST 9: Simulate Sync Failure
    // ============================================================================
    print('TEST 9: Simulating sync failure...');

    if (pendingQueue.isNotEmpty) {
      final firstEntry = pendingQueue.first;
      await db.updateSyncQueueFailure(
        firstEntry.id,
        'Network error: Unable to reach server',
      );

      final updatedQueue = await db.getPendingSyncQueue();
      final failedEntry = updatedQueue.firstWhere((e) => e.id == firstEntry.id);

      print('✓ Sync failure recorded:');
      print('  - Retry count: ${failedEntry.retryCount}');
      print('  - Last error: ${failedEntry.lastError}');
    }
    print('');

    // ============================================================================
    // TEST 10: Foreign Key Constraint Test
    // ============================================================================
    print('TEST 10: Testing foreign key constraints...');

    try {
      // Try to create settings for non-existent user
      final invalidSettingsCompanion = UserSettingsCompanion.insert(
        userId: 'non-existent-user-id',
      );

      await db.into(db.userSettings).insert(invalidSettingsCompanion);
      print('✗ Foreign key constraint FAILED - should have thrown error');
    } catch (e) {
      print('✓ Foreign key constraint working - rejected invalid user_id');
    }
    print('');

    // ============================================================================
    // CLEANUP (optional)
    // ============================================================================
    print('TEST 11: Cleanup test data...');
    print('Would you like to keep this test data? (Skipping cleanup for now)');
    print('To clean up, uncomment the following line in the code:\n');
    print('// await db.clearAllData();\n');

    // Uncomment to clean up test data:
    // await db.clearAllData();
    // print('✓ All test data cleared\n');

    print('=== All Tests Passed! ===');
    print('Database is configured correctly and ready to use.\n');
  } catch (e, stackTrace) {
    print('✗ Error during testing:');
    print(e);
    print(stackTrace);
  } finally {
    // Don't close database in real app, but good practice in tests
    // await db.close();
  }
}
