// lib/data/local/tasks_dao_example.dart

/// Example usage patterns for TasksDao
///
/// This file demonstrates how to use the TasksDao for common task management operations.
/// Use these examples as a reference when implementing task features in the Shepherd app.
///
/// IMPORTANT: This is a reference file only. Do not import or use in production code.

import 'package:uuid/uuid.dart';
import 'database.dart';
import 'package:drift/drift.dart' as drift;

// Example 1: Creating a new task
Future<void> exampleCreateTask() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  const uuid = Uuid();

  // Simple task
  final task = TasksCompanion(
    id: drift.Value(uuid.v4()),
    userId: const drift.Value('user-uuid-here'),
    title: const drift.Value('Prepare Sunday sermon'),
    category: const drift.Value('sermon_prep'),
    priority: const drift.Value('high'),
    status: const drift.Value('not_started'),
    dueDate: drift.Value(DateTime(2025, 12, 15)),
    estimatedDurationMinutes: const drift.Value(120),
    requiresFocus: const drift.Value(true),
    energyLevel: const drift.Value('high'),
    description: const drift.Value('Research John 3:16, create outline'),
  );

  await tasksDao.insertTask(task);
}

// Example 2: Retrieving tasks by status
Future<void> exampleGetTasksByStatus() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Get all not-started tasks
  final notStartedTasks = await tasksDao.getTasksByStatus(userId, 'not_started');

  // Get all in-progress tasks
  final inProgressTasks = await tasksDao.getTasksByStatus(userId, 'in_progress');

  // Get completed tasks
  final completedTasks = await tasksDao.getTasksByStatus(userId, 'done');

  print('Not started: ${notStartedTasks.length}');
  print('In progress: ${inProgressTasks.length}');
  print('Completed: ${completedTasks.length}');
}

// Example 3: Getting today's tasks
Future<void> exampleGetTodayTasks() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  final todayTasks = await tasksDao.getTodayTasks(userId);

  for (final task in todayTasks) {
    print('${task.title} - ${task.priority} priority');
  }
}

// Example 4: Getting overdue tasks
Future<void> exampleGetOverdueTasks() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  final overdueTasks = await tasksDao.getOverdueTasks(userId);

  if (overdueTasks.isNotEmpty) {
    print('WARNING: ${overdueTasks.length} overdue tasks!');
    for (final task in overdueTasks) {
      final daysOverdue = DateTime.now().difference(task.dueDate!).inDays;
      print('  - ${task.title} (${daysOverdue} days overdue)');
    }
  }
}

// Example 5: Filtering by category
Future<void> exampleGetTasksByCategory() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Get all sermon prep tasks
  final sermonTasks = await tasksDao.getTasksByCategory(userId, 'sermon_prep');

  // Get all pastoral care tasks
  final pastoralTasks = await tasksDao.getTasksByCategory(userId, 'pastoral_care');

  // Get all admin tasks
  final adminTasks = await tasksDao.getTasksByCategory(userId, 'admin');

  print('Sermon prep: ${sermonTasks.length}');
  print('Pastoral care: ${pastoralTasks.length}');
  print('Admin: ${adminTasks.length}');
}

// Example 6: Updating a task
Future<void> exampleUpdateTask() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final taskId = 'task-uuid-here';

  // Get existing task
  final task = await tasksDao.getTaskById(taskId);

  if (task != null) {
    // Update task properties
    final updatedTask = task.copyWith(
      status: 'in_progress',
      priority: 'urgent',
      syncStatus: 'pending',
      localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      version: task.version + 1,
    );

    await tasksDao.updateTask(updatedTask);
  }
}

// Example 7: Marking task as completed
Future<void> exampleCompleteTask() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final taskId = 'task-uuid-here';

  // Simple completion (sets status='done', completed_at=now)
  await tasksDao.markTaskAsCompleted(taskId);

  // Or with actual duration tracking
  final task = await tasksDao.getTaskById(taskId);
  if (task != null) {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      status: 'done',
      completedAt: drift.Value(now),
      actualDurationMinutes: const drift.Value(90), // Actual time spent
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: task.version + 1,
    );
    await tasksDao.updateTask(updatedTask);
  }
}

// Example 8: Soft deleting a task
Future<void> exampleDeleteTask() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final taskId = 'task-uuid-here';

  // Soft delete (sets status='deleted', deleted_at=now)
  await tasksDao.deleteTask(taskId);

  // Task is still in database but won't appear in queries
  // Can be recovered by updating status back to active state
}

// Example 9: Searching tasks
Future<void> exampleSearchTasks() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Search by title
  final results = await tasksDao.searchTasks(userId, 'sermon');

  print('Found ${results.length} tasks matching "sermon"');
  for (final task in results) {
    print('  - ${task.title}');
  }
}

// Example 10: Using reactive streams (for Flutter UI)
void exampleWatchTasks() {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Watch all tasks (updates UI automatically when tasks change)
  tasksDao.watchAllTasks(userId).listen((tasks) {
    print('Tasks updated: ${tasks.length} total');
  });

  // Watch tasks by status
  tasksDao.watchTasksByStatus(userId, 'not_started').listen((tasks) {
    print('Active tasks: ${tasks.length}');
  });

  // Watch specific task
  tasksDao.watchTask('task-uuid-here').listen((task) {
    if (task != null) {
      print('Task updated: ${task.title} - ${task.status}');
    }
  });
}

// Example 11: Getting tasks by relationship
Future<void> exampleGetRelatedTasks() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;

  // Get tasks related to a specific person
  final personTasks = await tasksDao.getTasksByPerson('person-uuid-here');
  print('Tasks for this person: ${personTasks.length}');

  // Get tasks related to a sermon
  final sermonTasks = await tasksDao.getTasksBySermon('sermon-uuid-here');
  print('Sermon prep tasks: ${sermonTasks.length}');

  // Get tasks related to an event
  final eventTasks = await tasksDao.getTasksByEvent('event-uuid-here');
  print('Event prep tasks: ${eventTasks.length}');

  // Get subtasks
  final subtasks = await tasksDao.getSubtasks('parent-task-uuid-here');
  print('Subtasks: ${subtasks.length}');
}

// Example 12: Getting tasks by productivity features
Future<void> exampleGetTasksByFeatures() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Get tasks that require focus
  final focusTasks = await tasksDao.getFocusTasks(userId);
  print('Focus tasks: ${focusTasks.length}');

  // Get high-energy tasks (for peak productivity hours)
  final highEnergyTasks = await tasksDao.getTasksByEnergyLevel(userId, 'high');
  print('High-energy tasks: ${highEnergyTasks.length}');

  // Get low-energy tasks (for end of day)
  final lowEnergyTasks = await tasksDao.getTasksByEnergyLevel(userId, 'low');
  print('Low-energy tasks: ${lowEnergyTasks.length}');
}

// Example 13: Sync operations
Future<void> exampleSyncOperations() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;

  // Get all tasks pending sync to server
  final pendingTasks = await tasksDao.getPendingTasks();
  print('${pendingTasks.length} tasks need syncing');

  // After successful sync to server
  for (final task in pendingTasks) {
    await tasksDao.markTaskAsSynced(
      task.id,
      DateTime.now().millisecondsSinceEpoch, // Server's updated_at
    );
  }

  // Handle sync conflicts
  final conflictedTasks = await tasksDao.getConflictedTasks();
  for (final task in conflictedTasks) {
    print('Conflict in task: ${task.title}');
    // Show conflict resolution UI to user
  }
}

// Example 14: Analytics and statistics
Future<void> exampleAnalytics() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  final userId = 'user-uuid-here';

  // Count tasks by status
  final notStartedCount = await tasksDao.countTasksByStatus(userId, 'not_started');
  final inProgressCount = await tasksDao.countTasksByStatus(userId, 'in_progress');
  final completedCount = await tasksDao.countTasksByStatus(userId, 'done');

  print('Task breakdown:');
  print('  Not started: $notStartedCount');
  print('  In progress: $inProgressCount');
  print('  Completed: $completedCount');

  // Count tasks by category
  final sermonCount = await tasksDao.countTasksByCategory(userId, 'sermon_prep');
  final pastoralCount = await tasksDao.countTasksByCategory(userId, 'pastoral_care');

  print('\nCategory breakdown:');
  print('  Sermon prep: $sermonCount');
  print('  Pastoral care: $pastoralCount');

  // Get completion rate for last 30 days
  final startDate = DateTime.now().subtract(const Duration(days: 30));
  final endDate = DateTime.now();
  final completionStats = await tasksDao.getCompletionRate(userId, startDate, endDate);

  print('\nLast 30 days:');
  print('  Total tasks: ${completionStats['total']}');
  print('  Completed: ${completionStats['completed']}');
  print('  Completion rate: ${completionStats['rate']}%');
}

// Example 15: Creating a task with subtasks
Future<void> exampleCreateTaskWithSubtasks() async {
  final db = AppDatabase();
  final tasksDao = db.tasksDao;
  const uuid = Uuid();
  final userId = 'user-uuid-here';
  final parentTaskId = uuid.v4();

  // Create parent task
  final parentTask = TasksCompanion(
    id: drift.Value(parentTaskId),
    userId: drift.Value(userId),
    title: const drift.Value('Prepare Sunday sermon on John 3:16'),
    category: const drift.Value('sermon_prep'),
    priority: const drift.Value('high'),
    dueDate: drift.Value(DateTime(2025, 12, 14)),
    estimatedDurationMinutes: const drift.Value(240), // 4 hours total
  );
  await tasksDao.insertTask(parentTask);

  // Create subtasks
  final subtask1 = TasksCompanion(
    id: drift.Value(uuid.v4()),
    userId: drift.Value(userId),
    parentTaskId: drift.Value(parentTaskId),
    title: const drift.Value('Research passage context'),
    category: const drift.Value('sermon_prep'),
    priority: const drift.Value('high'),
    dueDate: drift.Value(DateTime(2025, 12, 10)),
    estimatedDurationMinutes: const drift.Value(60),
  );

  final subtask2 = TasksCompanion(
    id: drift.Value(uuid.v4()),
    userId: drift.Value(userId),
    parentTaskId: drift.Value(parentTaskId),
    title: const drift.Value('Create sermon outline'),
    category: const drift.Value('sermon_prep'),
    priority: const drift.Value('high'),
    dueDate: drift.Value(DateTime(2025, 12, 12)),
    estimatedDurationMinutes: const drift.Value(90),
  );

  final subtask3 = TasksCompanion(
    id: drift.Value(uuid.v4()),
    userId: drift.Value(userId),
    parentTaskId: drift.Value(parentTaskId),
    title: const drift.Value('Write manuscript'),
    category: const drift.Value('sermon_prep'),
    priority: const drift.Value('high'),
    dueDate: drift.Value(DateTime(2025, 12, 13)),
    estimatedDurationMinutes: const drift.Value(90),
  );

  await tasksDao.insertTask(subtask1);
  await tasksDao.insertTask(subtask2);
  await tasksDao.insertTask(subtask3);

  // Later, retrieve all subtasks
  final allSubtasks = await tasksDao.getSubtasks(parentTaskId);
  print('Created ${allSubtasks.length} subtasks for sermon prep');
}

// Example 16: Flutter UI integration with StreamBuilder
/*
class TaskListWidget extends StatelessWidget {
  final String userId;

  const TaskListWidget({required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    final tasksDao = db.tasksDao;

    return StreamBuilder<List<Task>>(
      stream: tasksDao.watchTasksByStatus(userId, 'not_started'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Text('No active tasks');
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('${task.category} - ${task.priority}'),
              trailing: task.dueDate != null
                  ? Text('Due: ${task.dueDate!.month}/${task.dueDate!.day}')
                  : null,
              onTap: () {
                // Navigate to task detail screen
              },
            );
          },
        );
      },
    );
  }
}
*/

/// Summary of TasksDao methods:
///
/// BASIC CRUD:
/// - getAllTasks(userId) - Get all active tasks
/// - getTaskById(id) - Get single task
/// - insertTask(task) - Create new task
/// - updateTask(task) - Update existing task
/// - deleteTask(id) - Soft delete task
/// - hardDeleteTask(id) - Permanently delete task
///
/// STATUS OPERATIONS:
/// - getTasksByStatus(userId, status) - Filter by status
/// - getOverdueTasks(userId) - Get overdue tasks
/// - getTodayTasks(userId) - Get today's tasks
/// - getWeekTasks(userId) - Get this week's tasks
/// - markTaskAsCompleted(id) - Mark as done
/// - markTaskAsInProgress(id) - Mark as in progress
///
/// FILTERING:
/// - getTasksByCategory(userId, category) - Filter by category
/// - getTasksByPriority(userId, priority) - Filter by priority
/// - getFocusTasks(userId) - Get focus-requiring tasks
/// - getTasksByEnergyLevel(userId, level) - Filter by energy level
/// - searchTasks(userId, query) - Search by title
///
/// RELATIONSHIPS:
/// - getTasksByPerson(personId) - Tasks for specific person
/// - getTasksBySermon(sermonId) - Tasks for specific sermon
/// - getTasksByEvent(eventId) - Tasks for specific event
/// - getSubtasks(parentTaskId) - Get child tasks
///
/// SYNC:
/// - getPendingTasks() - Get tasks needing sync
/// - markTaskAsSynced(id, serverUpdatedAt) - Mark as synced
/// - markTaskAsConflicted(id) - Mark as conflicted
/// - getConflictedTasks() - Get tasks with conflicts
/// - batchUpdateSyncStatus(ids, status) - Bulk status update
///
/// REACTIVE STREAMS:
/// - watchAllTasks(userId) - Watch all tasks
/// - watchTasksByStatus(userId, status) - Watch by status
/// - watchTasksByCategory(userId, category) - Watch by category
/// - watchTodayTasks(userId) - Watch today's tasks
/// - watchTask(id) - Watch single task
///
/// ANALYTICS:
/// - countTasksByStatus(userId, status) - Count by status
/// - countTasksByCategory(userId, category) - Count by category
/// - getCompletionRate(userId, startDate, endDate) - Completion percentage
