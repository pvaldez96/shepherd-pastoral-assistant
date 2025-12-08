/// Immutable Task entity for domain layer
///
/// This is separate from the Drift database Task class to maintain
/// clean architecture separation between domain and data layers.
class TaskEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;

  // Scheduling
  final DateTime? dueDate;
  final String? dueTime;

  // Time tracking
  final int? estimatedDurationMinutes;
  final int? actualDurationMinutes;

  // Classification
  final String category;
  final String priority;
  final String status;

  // Properties
  final bool requiresFocus;
  final String? energyLevel;

  // Relationships
  final String? personId;
  final String? calendarEventId;
  final String? sermonId;
  final String? parentTaskId;

  // Timestamps
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    required this.category,
    this.priority = 'medium',
    this.status = 'not_started',
    this.requiresFocus = false,
    this.energyLevel,
    this.personId,
    this.calendarEventId,
    this.sermonId,
    this.parentTaskId,
    this.completedAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy of this task with updated fields
  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    int? estimatedDurationMinutes,
    int? actualDurationMinutes,
    String? category,
    String? priority,
    String? status,
    bool? requiresFocus,
    String? energyLevel,
    String? personId,
    String? calendarEventId,
    String? sermonId,
    String? parentTaskId,
    DateTime? completedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requiresFocus: requiresFocus ?? this.requiresFocus,
      energyLevel: energyLevel ?? this.energyLevel,
      personId: personId ?? this.personId,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      sermonId: sermonId ?? this.sermonId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      version: version ?? this.version,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'due_time': dueTime,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'category': category,
      'priority': priority,
      'status': status,
      'requires_focus': requiresFocus,
      'energy_level': energyLevel,
      'person_id': personId,
      'calendar_event_id': calendarEventId,
      'sermon_id': sermonId,
      'parent_task_id': parentTaskId,
      'completed_at': completedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      dueTime: json['due_time'] as String?,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      actualDurationMinutes: json['actual_duration_minutes'] as int?,
      category: json['category'] as String,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'not_started',
      requiresFocus: json['requires_focus'] as bool? ?? false,
      energyLevel: json['energy_level'] as String?,
      personId: json['person_id'] as String?,
      calendarEventId: json['calendar_event_id'] as String?,
      sermonId: json['sermon_id'] as String?,
      parentTaskId: json['parent_task_id'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'pending',
      localUpdatedAt: json['local_updated_at'] as int,
      serverUpdatedAt: json['server_updated_at'] as int?,
      version: json['version'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskEntity &&
      other.id == id &&
      other.userId == userId &&
      other.title == title &&
      other.description == description &&
      other.dueDate == dueDate &&
      other.dueTime == dueTime &&
      other.estimatedDurationMinutes == estimatedDurationMinutes &&
      other.actualDurationMinutes == actualDurationMinutes &&
      other.category == category &&
      other.priority == priority &&
      other.status == status &&
      other.requiresFocus == requiresFocus &&
      other.energyLevel == energyLevel &&
      other.personId == personId &&
      other.calendarEventId == calendarEventId &&
      other.sermonId == sermonId &&
      other.parentTaskId == parentTaskId &&
      other.completedAt == completedAt &&
      other.deletedAt == deletedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.syncStatus == syncStatus &&
      other.localUpdatedAt == localUpdatedAt &&
      other.serverUpdatedAt == serverUpdatedAt &&
      other.version == version;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      title,
      description,
      dueDate,
      dueTime,
      estimatedDurationMinutes,
      actualDurationMinutes,
      category,
      priority,
      status,
      requiresFocus,
      energyLevel,
      personId,
      calendarEventId,
      sermonId,
      parentTaskId,
      completedAt,
      deletedAt,
      createdAt,
      updatedAt,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      version,
    ]);
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, status: $status, dueDate: $dueDate)';
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == 'done' || deletedAt != null) {
      return false;
    }
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if task is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Check if task needs sync
  bool get needsSync => syncStatus == 'pending';

  /// Check if task has conflict
  bool get hasConflict => syncStatus == 'conflict';
}
