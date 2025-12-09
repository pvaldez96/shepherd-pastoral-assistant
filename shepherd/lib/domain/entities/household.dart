/// Immutable Household entity for domain layer
///
/// Represents a family grouping for people
class HouseholdEntity {
  final String id;
  final String userId;

  // Core fields
  final String name;
  final String? address;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata
  final String syncStatus;
  final int localUpdatedAt;
  final int? serverUpdatedAt;
  final int version;

  const HouseholdEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    required this.localUpdatedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create a copy with updated fields
  HouseholdEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? localUpdatedAt,
    int? serverUpdatedAt,
    int? version,
  }) {
    return HouseholdEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
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
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'local_updated_at': localUpdatedAt,
      'server_updated_at': serverUpdatedAt,
      'version': version,
    };
  }

  /// Create from JSON
  factory HouseholdEntity.fromJson(Map<String, dynamic> json) {
    return HouseholdEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
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

    return other is HouseholdEntity &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.address == address &&
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
      name,
      address,
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
    return 'HouseholdEntity(id: $id, name: $name)';
  }

  /// Check if household needs sync
  bool get needsSync => syncStatus == 'pending';
}
