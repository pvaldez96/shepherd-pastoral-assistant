/// Immutable CalendarEvent entity for domain layer
///
/// This is separate from the Drift database CalendarEvent class to maintain
/// clean architecture separation between domain and data layers.
class CalendarEventEntity {
  final String id;
  final String userId;

  // Core fields
  final String title;
  final String? description;
  final String? location;

  // DateTime fields
  final DateTime startDateTime;
  final DateTime endDateTime;

  // Event type
  final String eventType;

  // Recurring
  final bool isRecurring;
  final String? recurrencePattern; // JSON string

  // Travel
  final int? travelTimeMinutes;

  // Energy
  final String energyDrain;

  // Flexibility
  final bool isMoveable;

  // Preparation
  final bool requiresPreparation;
  final int? preparationBufferHours;

  // Relationships
  final String? personId;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const CalendarEventEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.location,
    required this.startDateTime,
    required this.endDateTime,
    required this.eventType,
    this.isRecurring = false,
    this.recurrencePattern,
    this.travelTimeMinutes,
    this.energyDrain = 'medium',
    this.isMoveable = true,
    this.requiresPreparation = false,
    this.preparationBufferHours,
    this.personId,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy of this event with updated fields
  CalendarEventEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? eventType,
    bool? isRecurring,
    String? recurrencePattern,
    int? travelTimeMinutes,
    String? energyDrain,
    bool? isMoveable,
    bool? requiresPreparation,
    int? preparationBufferHours,
    String? personId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return CalendarEventEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      eventType: eventType ?? this.eventType,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
      energyDrain: energyDrain ?? this.energyDrain,
      isMoveable: isMoveable ?? this.isMoveable,
      requiresPreparation: requiresPreparation ?? this.requiresPreparation,
      preparationBufferHours: preparationBufferHours ?? this.preparationBufferHours,
      personId: personId ?? this.personId,
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
      'location': location,
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'event_type': eventType,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'travel_time_minutes': travelTimeMinutes,
      'energy_drain': energyDrain,
      'is_moveable': isMoveable,
      'requires_preparation': requiresPreparation,
      'preparation_buffer_hours': preparationBufferHours,
      'person_id': personId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory CalendarEventEntity.fromJson(Map<String, dynamic> json) {
    return CalendarEventEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startDateTime: DateTime.parse(json['start_datetime'] as String),
      endDateTime: DateTime.parse(json['end_datetime'] as String),
      eventType: json['event_type'] as String,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as String?,
      travelTimeMinutes: json['travel_time_minutes'] as int?,
      energyDrain: json['energy_drain'] as String? ?? 'medium',
      isMoveable: json['is_moveable'] as bool? ?? true,
      requiresPreparation: json['requires_preparation'] as bool? ?? false,
      preparationBufferHours: json['preparation_buffer_hours'] as int?,
      personId: json['person_id'] as String?,
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

    return other is CalendarEventEntity &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.location == location &&
        other.startDateTime == startDateTime &&
        other.endDateTime == endDateTime &&
        other.eventType == eventType &&
        other.isRecurring == isRecurring &&
        other.recurrencePattern == recurrencePattern &&
        other.travelTimeMinutes == travelTimeMinutes &&
        other.energyDrain == energyDrain &&
        other.isMoveable == isMoveable &&
        other.requiresPreparation == requiresPreparation &&
        other.preparationBufferHours == preparationBufferHours &&
        other.personId == personId &&
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
      location,
      startDateTime,
      endDateTime,
      eventType,
      isRecurring,
      recurrencePattern,
      travelTimeMinutes,
      energyDrain,
      isMoveable,
      requiresPreparation,
      preparationBufferHours,
      personId,
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
    return 'CalendarEventEntity(id: $id, title: $title, eventType: $eventType, start: $startDateTime)';
  }

  /// Calculate event duration in minutes
  int get durationMinutes {
    return endDateTime.difference(startDateTime).inMinutes;
  }

  /// Calculate event duration in hours (rounded)
  double get durationHours {
    return durationMinutes / 60.0;
  }

  /// Check if event is happening now
  bool get isHappeningNow {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  /// Check if event is in the past
  bool get isPast {
    return endDateTime.isBefore(DateTime.now());
  }

  /// Check if event is upcoming (starts in the future)
  bool get isUpcoming {
    return startDateTime.isAfter(DateTime.now());
  }

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return startDateTime.isAfter(today) && startDateTime.isBefore(tomorrow);
  }

  /// Check if event needs sync
  bool get needsSync => syncStatus == 'pending';

  /// Check if event has conflict
  bool get hasConflict => syncStatus == 'conflict';

  /// Get the start time for preparation (if requires preparation)
  DateTime? get preparationStartTime {
    if (!requiresPreparation || preparationBufferHours == null) {
      return null;
    }
    return startDateTime.subtract(Duration(hours: preparationBufferHours!));
  }

  /// Get the time including travel (for departure calculation)
  DateTime? get departureTime {
    if (travelTimeMinutes == null || travelTimeMinutes == 0) {
      return startDateTime;
    }
    return startDateTime.subtract(Duration(minutes: travelTimeMinutes!));
  }

  /// Check if event has high energy drain
  bool get isHighEnergy => energyDrain == 'high';

  /// Check if this event conflicts with another
  bool conflictsWith(CalendarEventEntity other) {
    // No conflict if same event
    if (id == other.id) return false;

    // Check for time overlap
    return startDateTime.isBefore(other.endDateTime) &&
        endDateTime.isAfter(other.startDateTime);
  }
}