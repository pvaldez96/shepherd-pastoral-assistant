/// Immutable ContactLog entity for domain layer
///
/// Represents a logged contact with a person (call, visit, email, etc.)
class ContactLogEntity {
  final String id;
  final String userId;
  final String personId;

  // Contact details
  final DateTime contactDate;
  final String contactType;
  final int? durationMinutes;
  final String? notes;

  // Timestamps
  final DateTime createdAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const ContactLogEntity({
    required this.id,
    required this.userId,
    required this.personId,
    required this.contactDate,
    required this.contactType,
    this.durationMinutes,
    this.notes,
    required this.createdAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy with updated fields
  ContactLogEntity copyWith({
    String? id,
    String? userId,
    String? personId,
    DateTime? contactDate,
    String? contactType,
    int? durationMinutes,
    String? notes,
    DateTime? createdAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return ContactLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personId: personId ?? this.personId,
      contactDate: contactDate ?? this.contactDate,
      contactType: contactType ?? this.contactType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
      'person_id': personId,
      'contact_date': contactDate.toIso8601String(),
      'contact_type': contactType,
      'duration_minutes': durationMinutes,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory ContactLogEntity.fromJson(Map<String, dynamic> json) {
    return ContactLogEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personId: json['person_id'] as String,
      contactDate: DateTime.parse(json['contact_date'] as String),
      contactType: json['contact_type'] as String,
      durationMinutes: json['duration_minutes'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'pending',
      localUpdatedAt: json['local_updated_at'] as int,
      serverUpdatedAt: json['server_updated_at'] as int?,
      version: json['version'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContactLogEntity &&
        other.id == id &&
        other.userId == userId &&
        other.personId == personId &&
        other.contactDate == contactDate &&
        other.contactType == contactType &&
        other.durationMinutes == durationMinutes &&
        other.notes == notes &&
        other.createdAt == createdAt &&
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
      personId,
      contactDate,
      contactType,
      durationMinutes,
      notes,
      createdAt,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      version,
    ]);
  }

  @override
  String toString() {
    return 'ContactLogEntity(id: $id, personId: $personId, type: $contactType, date: $contactDate)';
  }

  /// Check if contact log needs sync
  bool get needsSync => syncStatus == 'pending';

  /// Valid contact types
  static const List<String> validContactTypes = [
    'visit',
    'call',
    'email',
    'text',
    'in_person',
    'other',
  ];

  /// Get display name for contact type
  static String getTypeDisplayName(String type) {
    switch (type) {
      case 'visit':
        return 'Visit';
      case 'call':
        return 'Phone Call';
      case 'email':
        return 'Email';
      case 'text':
        return 'Text Message';
      case 'in_person':
        return 'In Person';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  /// Get icon name for contact type (Material icon names)
  static String getTypeIconName(String type) {
    switch (type) {
      case 'visit':
        return 'home';
      case 'call':
        return 'phone';
      case 'email':
        return 'email';
      case 'text':
        return 'message';
      case 'in_person':
        return 'person';
      case 'other':
        return 'chat';
      default:
        return 'chat';
    }
  }
}
