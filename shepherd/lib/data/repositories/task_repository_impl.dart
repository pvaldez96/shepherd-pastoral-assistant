import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/database.dart';
import '../local/daos/tasks_dao.dart';

/// Implementation of TaskRepository using Drift local database
///
/// Follows offline-first architecture:
/// 1. All operations work against local SQLite database
/// 2. Changes are queued for background sync to Supabase
/// 3. Optimistic updates - UI updates immediately
///
/// Pattern:
/// - Read from local DB (always fast, works offline)
/// - Write to local DB first (optimistic)
/// - Add to sync queue (background sync handles eventual consistency)
class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  late final TasksDao _tasksDao;

  TaskRepositoryImpl(this._database) {
    _tasksDao = TasksDao(_database);
  }

  /// Helper: Convert Drift Task to domain TaskEntity
  /// Note: Drift stores timestamps as int (milliseconds since epoch)
  TaskEntity _toDomain(Task task) {
    return TaskEntity(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      estimatedDurationMinutes: task.estimatedDurationMinutes,
      actualDurationMinutes: task.actualDurationMinutes,
      category: task.category,
      priority: task.priority,
      status: task.status,
      requiresFocus: task.requiresFocus,
      energyLevel: task.energyLevel,
      personId: task.personId,
      calendarEventId: task.calendarEventId,
      sermonId: task.sermonId,
      parentTaskId: task.parentTaskId,
      completedAt: task.completedAt,
      deletedAt: task.deletedAt,
      createdAt: DateTime.fromMillisecondsSinceEpoch(task.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(task.updatedAt),
      syncStatus: task.syncStatus,
      localUpdatedAt: task.localUpdatedAt,
      serverUpdatedAt: task.serverUpdatedAt,
      version: task.version,
    );
  }

  /// Helper: Convert domain TaskEntity to Drift Task (for updates)
  Task _toData(TaskEntity task) {
    return Task(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      estimatedDurationMinutes: task.estimatedDurationMinutes,
      actualDurationMinutes: task.actualDurationMinutes,
      category: task.category,
      priority: task.priority,
      status: task.status,
      requiresFocus: task.requiresFocus,
      energyLevel: task.energyLevel,
      personId: task.personId,
      calendarEventId: task.calendarEventId,
      sermonId: task.sermonId,
      parentTaskId: task.parentTaskId,
      completedAt: task.completedAt,
      deletedAt: task.deletedAt,
      createdAt: task.createdAt.millisecondsSinceEpoch,
      updatedAt: task.updatedAt.millisecondsSinceEpoch,
      syncStatus: task.syncStatus,
      localUpdatedAt: task.localUpdatedAt,
      serverUpdatedAt: task.serverUpdatedAt,
      version: task.version,
    );
  }

  /// Helper: Convert domain TaskEntity to Drift TasksCompanion (for inserts)
  TasksCompanion _toCompanion(TaskEntity task) {
    return TasksCompanion.insert(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: Value(task.description),
      dueDate: Value(task.dueDate),
      dueTime: Value(task.dueTime),
      estimatedDurationMinutes: Value(task.estimatedDurationMinutes),
      actualDurationMinutes: Value(task.actualDurationMinutes),
      category: task.category,
      priority: Value(task.priority),
      status: Value(task.status),
      requiresFocus: Value(task.requiresFocus),
      energyLevel: Value(task.energyLevel),
      personId: Value(task.personId),
      calendarEventId: Value(task.calendarEventId),
      sermonId: Value(task.sermonId),
      parentTaskId: Value(task.parentTaskId),
      completedAt: Value(task.completedAt),
      deletedAt: Value(task.deletedAt),
      createdAt: Value(task.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(task.updatedAt.millisecondsSinceEpoch),
      syncStatus: Value(task.syncStatus),
      localUpdatedAt: Value(task.localUpdatedAt),
      serverUpdatedAt: Value(task.serverUpdatedAt),
      version: Value(task.version),
    );
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    // TODO: Get userId from auth service
    // For now, using a placeholder
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getAllTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final task = await _tasksDao.getTaskById(id);
    return task != null ? _toDomain(task) : null;
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    final now = DateTime.now();

    // Generate UUID if not provided
    final id = task.id.isEmpty ? _uuid.v4() : task.id;

    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final newTask = task.copyWith(
      id: id,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: 1,
    );

    final companion = _toCompanion(newTask);

    // Insert into local database (optimistic update)
    await _tasksDao.insertTask(companion);

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('create', id);

    return newTask;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final now = DateTime.now();

    // Increment version for optimistic locking
    final updatedTask = task.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: task.version + 1,
    );

    // Convert to Drift Task object
    final driftTask = _toData(updatedTask);

    // Update in local database (optimistic update)
    final success = await _tasksDao.updateTask(driftTask);

    if (!success) {
      throw Exception('Task not found: ${task.id}');
    }

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('update', task.id);

    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    // Soft delete - marks task as deleted without removing from database
    await _tasksDao.deleteTask(id);

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('delete', id);
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _tasksDao.watchAllTasks(userId).map(
          (tasks) => tasks.map(_toDomain).toList(),
        );
  }

  @override
  Stream<TaskEntity?> watchTask(String id) {
    // TasksDao doesn't have watchTaskById, so we watch all and filter
    return _tasksDao.watchAllTasks('current-user-id').map((tasks) {
      try {
        final task = tasks.firstWhere((t) => t.id == id);
        return _toDomain(task);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<List<TaskEntity>> getTasksByStatus(String status) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getTasksByStatus(userId, status);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getOverdueTasks() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getOverdueTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getTodayTasks() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getTodayTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getWeekTasks() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getWeekTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByCategory(String category) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getTasksByCategory(userId, category);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getFocusTasks() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getFocusTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByPerson(String personId) async {
    final tasks = await _tasksDao.getTasksByPerson(personId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksBySermon(String sermonId) async {
    final tasks = await _tasksDao.getTasksBySermon(sermonId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByEvent(String eventId) async {
    final tasks = await _tasksDao.getTasksByEvent(eventId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<TaskEntity>> getSubtasks(String parentTaskId) async {
    final tasks = await _tasksDao.getSubtasks(parentTaskId);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<TaskEntity> completeTask(String id, {int? actualDurationMinutes}) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found: $id');
    }

    final now = DateTime.now();

    final completedTask = task.copyWith(
      status: 'done',
      completedAt: now,
      actualDurationMinutes: actualDurationMinutes ?? task.actualDurationMinutes,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: task.version + 1,
    );

    return updateTask(completedTask);
  }

  @override
  Future<List<TaskEntity>> getPendingTasks() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final tasks = await _tasksDao.getPendingTasks(userId);
    return tasks.map(_toDomain).toList();
  }

  // TODO: Future implementation - add to sync queue
  // Future<void> _addToSyncQueue(String operation, String taskId) async {
  //   await _database.into(_database.syncQueue).insert(
  //     SyncQueueCompanion.insert(
  //       id: _uuid.v4(),
  //       userId: 'current-user-id',
  //       tableName: 'tasks',
  //       recordId: taskId,
  //       operation: operation,
  //       createdAt: DateTime.now(),
  //     ),
  //   );
  // }
}
