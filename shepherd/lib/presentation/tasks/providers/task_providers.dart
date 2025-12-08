import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/repositories/task_repository_impl.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';

/// Provider for the AppDatabase singleton
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for TaskRepository implementation
///
/// This is the main repository provider that should be used throughout the app.
/// It provides offline-first task operations with automatic sync queue integration.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepositoryImpl(database);
});

/// Stream provider for all tasks
///
/// Watches the local database for changes and automatically updates the UI.
/// Perfect for task list screens.
///
/// Usage:
/// ```dart
/// class TaskListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final tasksAsync = ref.watch(tasksProvider);
///
///     return tasksAsync.when(
///       data: (tasks) => ListView.builder(
///         itemCount: tasks.length,
///         itemBuilder: (context, index) => TaskTile(task: tasks[index]),
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (err, stack) => Text('Error: $err'),
///     );
///   }
/// }
/// ```
final tasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasks();
});

/// Stream provider for a single task by ID
///
/// Watches a specific task and updates when it changes.
///
/// Usage:
/// ```dart
/// class TaskDetailScreen extends ConsumerWidget {
///   final String taskId;
///
///   const TaskDetailScreen({required this.taskId});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final taskAsync = ref.watch(taskProvider(taskId));
///
///     return taskAsync.when(
///       data: (task) {
///         if (task == null) {
///           return Text('Task not found');
///         }
///         return TaskDetailCard(task: task);
///       },
///       loading: () => CircularProgressIndicator(),
///       error: (err, stack) => Text('Error: $err'),
///     );
///   }
/// }
/// ```
final taskProvider = StreamProvider.family<TaskEntity?, String>((ref, id) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTask(id);
});

/// Stream provider for tasks by status
///
/// Filters tasks by their status (not_started, in_progress, done).
///
/// Usage:
/// ```dart
/// final inProgressTasks = ref.watch(tasksByStatusProvider('in_progress'));
/// ```
final tasksByStatusProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, status) {
  final repository = ref.watch(taskRepositoryProvider);

  // Get all tasks and filter by status
  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.status == status).toList(),
      );
});

/// Stream provider for overdue tasks
///
/// Returns tasks that are past their due date and not completed.
///
/// Usage:
/// ```dart
/// final overdueTasks = ref.watch(overdueTasksProvider);
/// ```
final overdueTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  // Get all tasks and filter for overdue
  return repository.watchTasks().map((tasks) => tasks.where((task) {
        if (task.dueDate == null || task.status == 'done' || task.isDeleted) {
          return false;
        }
        return task.dueDate!.isBefore(DateTime.now());
      }).toList());
});

/// Stream provider for today's tasks
///
/// Returns tasks due today.
///
/// Usage:
/// ```dart
/// final todayTasks = ref.watch(todayTasksProvider);
/// ```
final todayTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map((tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.dueDate == null || task.isDeleted) return false;
      return task.dueDate!.isAfter(today) && task.dueDate!.isBefore(tomorrow);
    }).toList();
  });
});

/// Stream provider for this week's tasks
///
/// Returns tasks due within the next 7 days.
///
/// Usage:
/// ```dart
/// final weekTasks = ref.watch(weekTasksProvider);
/// ```
final weekTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map((tasks) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return tasks.where((task) {
      if (task.dueDate == null || task.isDeleted) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(weekFromNow);
    }).toList();
  });
});

/// Stream provider for tasks by category
///
/// Filters tasks by category (sermon_prep, pastoral_care, admin, personal, worship_planning).
///
/// Usage:
/// ```dart
/// final sermonTasks = ref.watch(tasksByCategoryProvider('sermon_prep'));
/// ```
final tasksByCategoryProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, category) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.category == category).toList(),
      );
});

/// Stream provider for tasks requiring focus
///
/// Returns tasks marked as requiring dedicated focus time.
///
/// Usage:
/// ```dart
/// final focusTasks = ref.watch(focusTasksProvider);
/// ```
final focusTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.requiresFocus).toList(),
      );
});

/// Stream provider for tasks linked to a person
///
/// Returns all tasks associated with a specific person.
///
/// Usage:
/// ```dart
/// final personTasks = ref.watch(tasksByPersonProvider(personId));
/// ```
final tasksByPersonProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, personId) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.personId == personId).toList(),
      );
});

/// Stream provider for tasks linked to a sermon
///
/// Returns all tasks associated with a specific sermon.
///
/// Usage:
/// ```dart
/// final sermonTasks = ref.watch(tasksBySermonProvider(sermonId));
/// ```
final tasksBySermonProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, sermonId) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.sermonId == sermonId).toList(),
      );
});

/// Stream provider for tasks needing sync
///
/// Returns tasks with sync_status = 'pending' that need to be synced to Supabase.
/// Useful for sync status indicators and sync queue management.
///
/// Usage:
/// ```dart
/// final pendingSync = ref.watch(pendingTasksProvider);
/// if (pendingSync.value?.isNotEmpty == true) {
///   // Show sync indicator
/// }
/// ```
final pendingTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map(
        (tasks) => tasks.where((task) => task.needsSync).toList(),
      );
});

/// Provider for task statistics
///
/// Returns counts of tasks by status for dashboard widgets.
///
/// Usage:
/// ```dart
/// final stats = ref.watch(taskStatsProvider);
/// stats.when(
///   data: (stats) => Text('${stats['in_progress']} tasks in progress'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error loading stats'),
/// );
/// ```
final taskStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return repository.watchTasks().map((tasks) {
    final activeTask = tasks.where((t) => !t.isDeleted).toList();

    return {
      'total': activeTask.length,
      'not_started': activeTask.where((t) => t.status == 'not_started').length,
      'in_progress': activeTask.where((t) => t.status == 'in_progress').length,
      'done': activeTask.where((t) => t.status == 'done').length,
      'overdue': activeTask.where((t) => t.isOverdue).length,
      'today': activeTask.where((t) {
        if (t.dueDate == null) return false;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return t.dueDate!.isAfter(today) && t.dueDate!.isBefore(tomorrow);
      }).length,
    };
  });
});
