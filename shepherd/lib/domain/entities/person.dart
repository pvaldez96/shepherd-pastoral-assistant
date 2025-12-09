/// Immutable Person entity for domain layer
///
/// This is separate from the Drift database Person class to maintain
/// clean architecture separation between domain and data layers.
class PersonEntity {
  final String id;
  final String userId;

  // Core fields
  final String name;
  final String? email;
  final String? phone;

  // Category - determines contact frequency threshold
  final String category;

  // Household grouping
  final String? householdId;

  // Contact tracking
  final DateTime? lastContactDate;
  final int? contactFrequencyOverrideDays;

  // Additional info
  final String? notes;
  final List<String> tags;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const PersonEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    required this.category,
    this.householdId,
    this.lastContactDate,
    this.contactFrequencyOverrideDays,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy of this person with updated fields
  PersonEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? category,
    String? householdId,
    DateTime? lastContactDate,
    int? contactFrequencyOverrideDays,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      householdId: householdId ?? this.householdId,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      contactFrequencyOverrideDays: contactFrequencyOverrideDays ?? this.contactFrequencyOverrideDays,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
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
      'name': name,
      'email': email,
      'phone': phone,
      'category': category,
      'household_id': householdId,
      'last_contact_date': lastContactDate?.toIso8601String(),
      'contact_frequency_override_days': contactFrequencyOverrideDays,
      'notes': notes,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory PersonEntity.fromJson(Map<String, dynamic> json) {
    return PersonEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      category: json['category'] as String,
      householdId: json['household_id'] as String?,
      lastContactDate: json['last_contact_date'] != null
          ? DateTime.parse(json['last_contact_date'] as String)
          : null,
      contactFrequencyOverrideDays: json['contact_frequency_override_days'] as int?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
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

    return other is PersonEntity &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.category == category &&
        other.householdId == householdId &&
        other.lastContactDate == lastContactDate &&
        other.contactFrequencyOverrideDays == contactFrequencyOverrideDays &&
        other.notes == notes &&
        _listEquals(other.tags, tags) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.syncStatus == syncStatus &&
        other.localUpdatedAt == localUpdatedAt &&
        other.serverUpdatedAt == serverUpdatedAt &&
        other.version == version;
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      name,
      email,
      phone,
      category,
      householdId,
      lastContactDate,
      contactFrequencyOverrideDays,
      notes,
      Object.hashAll(tags),
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
    return 'PersonEntity(id: $id, name: $name, category: $category)';
  }

  /// Check if person needs sync
  bool get needsSync => syncStatus == 'pending';

  /// Check if person has conflict
  bool get hasConflict => syncStatus == 'conflict';

  /// Calculate days since last contact
  int? get daysSinceLastContact {
    if (lastContactDate == null) return null;
    return DateTime.now().difference(lastContactDate!).inDays;
  }

  /// Get the contact frequency threshold for this person's category
  /// Returns the override if set, otherwise uses category defaults
  int getContactThreshold({
    int elderDefault = 30,
    int memberDefault = 90,
    int crisisDefault = 3,
    int visitorDefault = 14,
    int leadershipDefault = 30,
    int familyDefault = 7,
    int otherDefault = 90,
  }) {
    if (contactFrequencyOverrideDays != null) {
      return contactFrequencyOverrideDays!;
    }

    switch (category) {
      case 'elder':
        return elderDefault;
      case 'member':
        return memberDefault;
      case 'crisis':
        return crisisDefault;
      case 'visitor':
        return visitorDefault;
      case 'leadership':
        return leadershipDefault;
      case 'family':
        return familyDefault;
      case 'other':
      default:
        return otherDefault;
    }
  }

  /// Check if contact is overdue based on category threshold
  bool isOverdue({
    int elderDefault = 30,
    int memberDefault = 90,
    int crisisDefault = 3,
    int visitorDefault = 14,
    int leadershipDefault = 30,
    int familyDefault = 7,
    int otherDefault = 90,
  }) {
    final days = daysSinceLastContact;
    if (days == null) return true; // Never contacted = overdue

    final threshold = getContactThreshold(
      elderDefault: elderDefault,
      memberDefault: memberDefault,
      crisisDefault: crisisDefault,
      visitorDefault: visitorDefault,
      leadershipDefault: leadershipDefault,
      familyDefault: familyDefault,
      otherDefault: otherDefault,
    );

    return days > threshold;
  }

  /// Get days until contact is due (negative means overdue)
  int? getDaysUntilDue({
    int elderDefault = 30,
    int memberDefault = 90,
    int crisisDefault = 3,
    int visitorDefault = 14,
    int leadershipDefault = 30,
    int familyDefault = 7,
    int otherDefault = 90,
  }) {
    final days = daysSinceLastContact;
    if (days == null) return null;

    final threshold = getContactThreshold(
      elderDefault: elderDefault,
      memberDefault: memberDefault,
      crisisDefault: crisisDefault,
      visitorDefault: visitorDefault,
      leadershipDefault: leadershipDefault,
      familyDefault: familyDefault,
      otherDefault: otherDefault,
    );

    return threshold - days;
  }

  /// Valid category values
  static const List<String> validCategories = [
    'elder',
    'member',
    'visitor',
    'leadership',
    'crisis',
    'family',
    'other',
  ];

  /// Get display name for category
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'elder':
        return 'Elder';
      case 'member':
        return 'Member';
      case 'visitor':
        return 'Visitor';
      case 'leadership':
        return 'Leadership';
      case 'crisis':
        return 'Crisis';
      case 'family':
        return 'Family';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}
