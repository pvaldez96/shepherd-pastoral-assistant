/// Immutable PersonMilestone entity for domain layer
///
/// Represents important dates for a person (birthday, anniversary, surgery, etc.)
class PersonMilestoneEntity {
  final String id;
  final String personId;

  // Milestone details
  final String milestoneType;
  final DateTime date;
  final String? description;
  final int notifyDaysBefore;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const PersonMilestoneEntity({
    required this.id,
    required this.personId,
    required this.milestoneType,
    required this.date,
    this.description,
    this.notifyDaysBefore = 2,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy with updated fields
  PersonMilestoneEntity copyWith({
    String? id,
    String? personId,
    String? milestoneType,
    DateTime? date,
    String? description,
    int? notifyDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return PersonMilestoneEntity(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      milestoneType: milestoneType ?? this.milestoneType,
      date: date ?? this.date,
      description: description ?? this.description,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
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
      'person_id': personId,
      'milestone_type': milestoneType,
      'date': date.toIso8601String(),
      'description': description,
      'notify_days_before': notifyDaysBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory PersonMilestoneEntity.fromJson(Map<String, dynamic> json) {
    return PersonMilestoneEntity(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      milestoneType: json['milestone_type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      notifyDaysBefore: json['notify_days_before'] as int? ?? 2,
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

    return other is PersonMilestoneEntity &&
        other.id == id &&
        other.personId == personId &&
        other.milestoneType == milestoneType &&
        other.date == date &&
        other.description == description &&
        other.notifyDaysBefore == notifyDaysBefore &&
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
      personId,
      milestoneType,
      date,
      description,
      notifyDaysBefore,
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
    return 'PersonMilestoneEntity(id: $id, personId: $personId, type: $milestoneType, date: $date)';
  }

  /// Check if milestone needs sync
  bool get needsSync => syncStatus == 'pending';

  /// Valid milestone types
  static const List<String> validMilestoneTypes = [
    'birthday',
    'anniversary',
    'surgery',
    'other',
  ];

  /// Get display name for milestone type
  static String getTypeDisplayName(String type) {
    switch (type) {
      case 'birthday':
        return 'Birthday';
      case 'anniversary':
        return 'Anniversary';
      case 'surgery':
        return 'Surgery';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  /// Get icon name for milestone type (Material icon names)
  static String getTypeIconName(String type) {
    switch (type) {
      case 'birthday':
        return 'cake';
      case 'anniversary':
        return 'favorite';
      case 'surgery':
        return 'local_hospital';
      case 'other':
        return 'event';
      default:
        return 'event';
    }
  }

  /// Check if this milestone is upcoming (within notification window)
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get this year's occurrence of the milestone
    var thisYearDate = DateTime(now.year, date.month, date.day);

    // If this year's date has passed, check next year
    if (thisYearDate.isBefore(today)) {
      thisYearDate = DateTime(now.year + 1, date.month, date.day);
    }

    final daysUntil = thisYearDate.difference(today).inDays;
    return daysUntil >= 0 && daysUntil <= notifyDaysBefore;
  }

  /// Get next occurrence date
  DateTime get nextOccurrence {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var thisYearDate = DateTime(now.year, date.month, date.day);

    if (thisYearDate.isBefore(today)) {
      return DateTime(now.year + 1, date.month, date.day);
    }

    return thisYearDate;
  }

  /// Get days until next occurrence
  int get daysUntilNextOccurrence {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextOccurrence.difference(today).inDays;
  }
}
