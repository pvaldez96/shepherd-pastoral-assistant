// Database Verification Test Script
// This file tests that the database initialization fix works correctly on web

import 'package:uuid/uuid.dart';
import 'database.dart';
import 'package:drift/drift.dart';

/// Test script to verify database initialization on web
///
/// Run this to confirm:
/// 1. Database initializes without errors
/// 2. onCreate migration runs and creates all tables
/// 3. Tables can accept inserts
/// 4. Queries return data correctly
Future<void> testDatabaseInitialization() async {
  print('========================================');
  print('DATABASE INITIALIZATION TEST');
  print('========================================\n');

  try {
    // Step 1: Create database instance
    print('Step 1: Creating database instance...');
    final db = AppDatabase();
    print('✅ Database instance created\n');

    // Step 2: Initialize database (triggers onCreate on web)
    print('Step 2: Initializing database (this triggers onCreate)...');
    await db.ensureInitialized();
    print('✅ Database initialized successfully\n');

    // Step 3: Test inserting a user
    print('Step 3: Testing user insertion...');
    final userId = const Uuid().v4();
    await db.into(db.users).insert(
      UsersCompanion(
        id: Value(userId),
        email: const Value('test@shepherd.app'),
        name: const Value('Test Pastor'),
        churchName: const Value('Test Church'),
        timezone: const Value('America/Chicago'),
      ),
    );
    print('✅ User inserted successfully\n');

    // Step 4: Test querying the user
    print('Step 4: Querying inserted user...');
    final user = await db.getUserByEmail('test@shepherd.app');
    if (user != null) {
      print('✅ User retrieved: ${user.name} (${user.email})');
      print('   Church: ${user.churchName}');
      print('   Timezone: ${user.timezone}\n');
    } else {
      print('❌ User not found after insert\n');
      return;
    }

    // Step 5: Test inserting user settings
    print('Step 5: Testing user settings insertion...');
    await db.into(db.userSettings).insert(
      UserSettingsCompanion(
        id: Value(const Uuid().v4()),
        userId: Value(userId),
        weeklySermonPrepHours: const Value(10),
        maxDailyHours: const Value(8),
      ),
    );
    print('✅ User settings inserted successfully\n');

    // Step 6: Test inserting a task
    print('Step 6: Testing task insertion...');
    final taskId = const Uuid().v4();
    await db.tasksDao.insertTask(
      TasksCompanion(
        id: Value(taskId),
        userId: Value(userId),
        title: const Value('Test Sermon Preparation'),
        description: const Value('Prepare Sunday sermon on John 3:16'),
        category: const Value('sermon_prep'),
        priority: const Value('high'),
        status: const Value('not_started'),
        requiresFocus: const Value(true),
        energyLevel: const Value('high'),
      ),
    );
    print('✅ Task inserted successfully\n');

    // Step 7: Test querying tasks
    print('Step 7: Querying all tasks...');
    final tasks = await db.tasksDao.getAllTasks(userId);
    if (tasks.isNotEmpty) {
      print('✅ Found ${tasks.length} task(s):');
      for (final task in tasks) {
        print('   - ${task.title}');
        print('     Category: ${task.category}');
        print('     Priority: ${task.priority}');
        print('     Status: ${task.status}\n');
      }
    } else {
      print('❌ No tasks found after insert\n');
      return;
    }

    // Step 8: Test sync queue
    print('Step 8: Testing sync queue insertion...');
    await db.into(db.syncQueue).insert(
      SyncQueueCompanion(
        affectedTable: const Value('tasks'),
        recordId: Value(taskId),
        operation: const Value('insert'),
        payload: const Value('{"title": "Test task"}'),
      ),
    );
    print('✅ Sync queue entry inserted successfully\n');

    // Step 9: Query sync queue
    print('Step 9: Querying sync queue...');
    final syncEntries = await db.getPendingSyncQueue();
    if (syncEntries.isNotEmpty) {
      print('✅ Found ${syncEntries.length} sync queue entry(ies):');
      for (final entry in syncEntries) {
        print('   - Table: ${entry.affectedTable}');
        print('     Operation: ${entry.operation}');
        print('     Record ID: ${entry.recordId}\n');
      }
    } else {
      print('❌ No sync queue entries found\n');
      return;
    }

    // Step 10: Test DAO methods
    print('Step 10: Testing DAO methods...');
    final tasksByStatus = await db.tasksDao.getTasksByStatus(userId, 'not_started');
    final tasksByCategory = await db.tasksDao.getTasksByCategory(userId, 'sermon_prep');
    print('✅ Tasks by status (not_started): ${tasksByStatus.length}');
    print('✅ Tasks by category (sermon_prep): ${tasksByCategory.length}\n');

    // Step 11: Test update
    print('Step 11: Testing task update...');
    await db.tasksDao.markTaskAsInProgress(taskId);
    final updatedTask = await db.tasksDao.getTaskById(taskId);
    if (updatedTask != null && updatedTask.status == 'in_progress') {
      print('✅ Task status updated to: ${updatedTask.status}\n');
    } else {
      print('❌ Task update failed\n');
      return;
    }

    // Step 12: Test soft delete
    print('Step 12: Testing soft delete...');
    await db.tasksDao.deleteTask(taskId);
    final deletedTask = await db.tasksDao.getTaskById(taskId);
    if (deletedTask == null) {
      print('✅ Task soft-deleted (filtered from queries)\n');
    } else {
      print('❌ Soft delete failed\n');
      return;
    }

    // Step 13: Cleanup
    print('Step 13: Cleaning up test data...');
    await db.clearAllData();
    print('✅ Test data cleared\n');

    print('========================================');
    print('✅ ALL TESTS PASSED!');
    print('Database is working correctly on web');
    print('========================================\n');
  } catch (e, stackTrace) {
    print('========================================');
    print('❌ TEST FAILED!');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    print('========================================\n');
  }
}
