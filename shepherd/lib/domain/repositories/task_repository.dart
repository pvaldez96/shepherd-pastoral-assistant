import '../entities/task.dart';

/// Repository interface for Task operations
///
/// This defines the contract for task data access without specifying
/// implementation details. Following clean architecture, this allows
/// the domain layer to be independent of data sources.
abstract class TaskRepository {
  /// Get all tasks for the current user
  ///
  /// Returns list of non-deleted tasks ordered by due date.
  /// Uses local database (offline-first).
  Future<List<TaskEntity>> getAllTasks();

  /// Get a single task by ID
  ///
  /// Returns null if task not found or is deleted.
  Future<TaskEntity?> getTaskById(String id);

  /// Create a new task
  ///
  /// - Generates client-side UUID if not provided
  /// - Saves to local database immediately (optimistic update)
  /// - Adds to sync queue for background sync
  /// - Returns the created task with generated ID
  Future<TaskEntity> createTask(TaskEntity task);

  /// Update an existing task
  ///
  /// - Updates local database immediately (optimistic update)
  /// - Increments version for optimistic locking
  /// - Adds to sync queue for background sync
  /// - Throws if task not found
  Future<TaskEntity> updateTask(TaskEntity task);

  /// Delete a task (soft delete)
  ///
  /// - Marks task as deleted (sets deleted_at timestamp)
  /// - Updates status to 'deleted'
  /// - Keeps in database for sync and audit purposes
  /// - Adds to sync queue for background sync
  Future<void> deleteTask(String id);

  /// Watch all tasks with real-time updates
  ///
  /// Returns a stream that emits updated task lists whenever
  /// local database changes. Perfect for reactive UI with Riverpod.
  Stream<List<TaskEntity>> watchTasks();

  /// Watch a single task by ID with real-time updates
  ///
  /// Returns a stream that emits updated task whenever it changes.
  /// Emits null if task is deleted or not found.
  Stream<TaskEntity?> watchTask(String id);

  /// Get tasks by status
  ///
  /// Common statuses: 'not_started', 'in_progress', 'done', 'deleted'
  Future<List<TaskEntity>> getTasksByStatus(String status);

  /// Get overdue tasks
  ///
  /// Returns tasks with due_date in the past and status not 'done'
  Future<List<TaskEntity>> getOverdueTasks();

  /// Get tasks due today
  ///
  /// Returns tasks with due_date = today
  Future<List<TaskEntity>> getTodayTasks();

  /// Get tasks due this week
  ///
  /// Returns tasks with due_date between today and 7 days from now
  Future<List<TaskEntity>> getWeekTasks();

  /// Get tasks by category
  ///
  /// Categories: 'sermon_prep', 'pastoral_care', 'admin', 'personal', 'worship_planning'
  Future<List<TaskEntity>> getTasksByCategory(String category);

  /// Get tasks requiring focus
  ///
  /// Returns tasks with requires_focus = true
  Future<List<TaskEntity>> getFocusTasks();

  /// Get tasks linked to a person
  Future<List<TaskEntity>> getTasksByPerson(String personId);

  /// Get tasks linked to a sermon
  Future<List<TaskEntity>> getTasksBySermon(String sermonId);

  /// Get tasks linked to a calendar event
  Future<List<TaskEntity>> getTasksByEvent(String eventId);

  /// Get subtasks of a parent task
  Future<List<TaskEntity>> getSubtasks(String parentTaskId);

  /// Mark task as complete
  ///
  /// - Sets status to 'done'
  /// - Sets completed_at timestamp
  /// - Logs actual duration if timer was running
  /// - Adds to sync queue
  Future<TaskEntity> completeTask(String id, {int? actualDurationMinutes});

  /// Get tasks that need sync
  ///
  /// Returns tasks with sync_status = 'pending'
  Future<List<TaskEntity>> getPendingTasks();
}
