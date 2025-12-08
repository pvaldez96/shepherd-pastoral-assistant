// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _churchNameMeta =
      const VerificationMeta('churchName');
  @override
  late final GeneratedColumn<String> churchName = GeneratedColumn<String>(
      'church_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('America/Chicago'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
      'local_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        name,
        churchName,
        timezone,
        createdAt,
        updatedAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('church_name')) {
      context.handle(
          _churchNameMeta,
          churchName.isAcceptableOrUnknown(
              data['church_name']!, _churchNameMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      churchName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}church_name']),
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_updated_at']),
      serverUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_updated_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  final String id;

  /// User's email address - unique identifier for authentication
  /// Must be unique across all users
  final String email;

  /// User's full name or display name
  final String name;

  /// Name of the church the pastor serves
  /// Nullable - may not be set initially
  final String? churchName;

  /// Timezone for scheduling and notifications
  /// Default: America/Chicago (Central Time)
  /// Format: IANA timezone string (e.g., 'America/New_York', 'Europe/London')
  final String timezone;

  /// Timestamp when the record was created (Unix milliseconds)
  /// Automatically set on insert
  final int createdAt;

  /// Timestamp when the record was last updated (Unix milliseconds)
  /// Should be updated on every modification
  final int updatedAt;

  /// Sync status: 'synced', 'pending', or 'conflict'
  /// - synced: Record matches server state
  /// - pending: Local changes not yet pushed to server
  /// - conflict: Both local and server have conflicting changes
  final String syncStatus;

  /// Unix timestamp (milliseconds) when record was last modified locally
  /// Used to detect local changes and order sync operations
  final int? localUpdatedAt;

  /// Unix timestamp (milliseconds) of last known server state
  /// Used to detect server-side changes and resolve conflicts
  final int? serverUpdatedAt;

  /// Version counter for optimistic locking
  /// Incremented on each update, used to detect concurrent modifications
  final int version;
  const User(
      {required this.id,
      required this.email,
      required this.name,
      this.churchName,
      required this.timezone,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || churchName != null) {
      map['church_name'] = Variable<String>(churchName);
    }
    map['timezone'] = Variable<String>(timezone);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      churchName: churchName == null && nullToAbsent
          ? const Value.absent()
          : Value(churchName),
      timezone: Value(timezone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      version: Value(version),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      churchName: serializer.fromJson<String?>(json['churchName']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<int?>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'churchName': serializer.toJson<String?>(churchName),
      'timezone': serializer.toJson<String>(timezone),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<int?>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  User copyWith(
          {String? id,
          String? email,
          String? name,
          Value<String?> churchName = const Value.absent(),
          String? timezone,
          int? createdAt,
          int? updatedAt,
          String? syncStatus,
          Value<int?> localUpdatedAt = const Value.absent(),
          Value<int?> serverUpdatedAt = const Value.absent(),
          int? version}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        churchName: churchName.present ? churchName.value : this.churchName,
        timezone: timezone ?? this.timezone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt:
            localUpdatedAt.present ? localUpdatedAt.value : this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        version: version ?? this.version,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      churchName:
          data.churchName.present ? data.churchName.value : this.churchName,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('churchName: $churchName, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      email,
      name,
      churchName,
      timezone,
      createdAt,
      updatedAt,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.churchName == this.churchName &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.version == this.version);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  final Value<String?> churchName;
  final Value<String> timezone;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncStatus;
  final Value<int?> localUpdatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.churchName = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String name,
    this.churchName = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : email = Value(email),
        name = Value(name);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? churchName,
    Expression<String>? timezone,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? localUpdatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (churchName != null) 'church_name': churchName,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? name,
      Value<String?>? churchName,
      Value<String>? timezone,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? syncStatus,
      Value<int?>? localUpdatedAt,
      Value<int?>? serverUpdatedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      churchName: churchName ?? this.churchName,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (churchName.present) {
      map['church_name'] = Variable<String>(churchName.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('churchName: $churchName, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _elderContactFrequencyDaysMeta =
      const VerificationMeta('elderContactFrequencyDays');
  @override
  late final GeneratedColumn<int> elderContactFrequencyDays =
      GeneratedColumn<int>('elder_contact_frequency_days', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(30));
  static const VerificationMeta _memberContactFrequencyDaysMeta =
      const VerificationMeta('memberContactFrequencyDays');
  @override
  late final GeneratedColumn<int> memberContactFrequencyDays =
      GeneratedColumn<int>('member_contact_frequency_days', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(90));
  static const VerificationMeta _crisisContactFrequencyDaysMeta =
      const VerificationMeta('crisisContactFrequencyDays');
  @override
  late final GeneratedColumn<int> crisisContactFrequencyDays =
      GeneratedColumn<int>('crisis_contact_frequency_days', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(3));
  static const VerificationMeta _weeklySermonPrepHoursMeta =
      const VerificationMeta('weeklySermonPrepHours');
  @override
  late final GeneratedColumn<int> weeklySermonPrepHours = GeneratedColumn<int>(
      'weekly_sermon_prep_hours', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  static const VerificationMeta _maxDailyHoursMeta =
      const VerificationMeta('maxDailyHours');
  @override
  late final GeneratedColumn<int> maxDailyHours = GeneratedColumn<int>(
      'max_daily_hours', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _minFocusBlockMinutesMeta =
      const VerificationMeta('minFocusBlockMinutes');
  @override
  late final GeneratedColumn<int> minFocusBlockMinutes = GeneratedColumn<int>(
      'min_focus_block_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(120));
  static const VerificationMeta _preferredFocusHoursStartMeta =
      const VerificationMeta('preferredFocusHoursStart');
  @override
  late final GeneratedColumn<String> preferredFocusHoursStart =
      GeneratedColumn<String>('preferred_focus_hours_start', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preferredFocusHoursEndMeta =
      const VerificationMeta('preferredFocusHoursEnd');
  @override
  late final GeneratedColumn<String> preferredFocusHoursEnd =
      GeneratedColumn<String>('preferred_focus_hours_end', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notificationPreferencesMeta =
      const VerificationMeta('notificationPreferences');
  @override
  late final GeneratedColumn<String> notificationPreferences =
      GeneratedColumn<String>('notification_preferences', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _offlineCacheDaysMeta =
      const VerificationMeta('offlineCacheDays');
  @override
  late final GeneratedColumn<int> offlineCacheDays = GeneratedColumn<int>(
      'offline_cache_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(90));
  static const VerificationMeta _autoArchiveEnabledMeta =
      const VerificationMeta('autoArchiveEnabled');
  @override
  late final GeneratedColumn<int> autoArchiveEnabled = GeneratedColumn<int>(
      'auto_archive_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _archiveTasksAfterDaysMeta =
      const VerificationMeta('archiveTasksAfterDays');
  @override
  late final GeneratedColumn<int> archiveTasksAfterDays = GeneratedColumn<int>(
      'archive_tasks_after_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(90));
  static const VerificationMeta _archiveEventsAfterDaysMeta =
      const VerificationMeta('archiveEventsAfterDays');
  @override
  late final GeneratedColumn<int> archiveEventsAfterDays = GeneratedColumn<int>(
      'archive_events_after_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(365));
  static const VerificationMeta _archiveLogsAfterDaysMeta =
      const VerificationMeta('archiveLogsAfterDays');
  @override
  late final GeneratedColumn<int> archiveLogsAfterDays = GeneratedColumn<int>(
      'archive_logs_after_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(730));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
      'local_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        elderContactFrequencyDays,
        memberContactFrequencyDays,
        crisisContactFrequencyDays,
        weeklySermonPrepHours,
        maxDailyHours,
        minFocusBlockMinutes,
        preferredFocusHoursStart,
        preferredFocusHoursEnd,
        notificationPreferences,
        offlineCacheDays,
        autoArchiveEnabled,
        archiveTasksAfterDays,
        archiveEventsAfterDays,
        archiveLogsAfterDays,
        createdAt,
        updatedAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('elder_contact_frequency_days')) {
      context.handle(
          _elderContactFrequencyDaysMeta,
          elderContactFrequencyDays.isAcceptableOrUnknown(
              data['elder_contact_frequency_days']!,
              _elderContactFrequencyDaysMeta));
    }
    if (data.containsKey('member_contact_frequency_days')) {
      context.handle(
          _memberContactFrequencyDaysMeta,
          memberContactFrequencyDays.isAcceptableOrUnknown(
              data['member_contact_frequency_days']!,
              _memberContactFrequencyDaysMeta));
    }
    if (data.containsKey('crisis_contact_frequency_days')) {
      context.handle(
          _crisisContactFrequencyDaysMeta,
          crisisContactFrequencyDays.isAcceptableOrUnknown(
              data['crisis_contact_frequency_days']!,
              _crisisContactFrequencyDaysMeta));
    }
    if (data.containsKey('weekly_sermon_prep_hours')) {
      context.handle(
          _weeklySermonPrepHoursMeta,
          weeklySermonPrepHours.isAcceptableOrUnknown(
              data['weekly_sermon_prep_hours']!, _weeklySermonPrepHoursMeta));
    }
    if (data.containsKey('max_daily_hours')) {
      context.handle(
          _maxDailyHoursMeta,
          maxDailyHours.isAcceptableOrUnknown(
              data['max_daily_hours']!, _maxDailyHoursMeta));
    }
    if (data.containsKey('min_focus_block_minutes')) {
      context.handle(
          _minFocusBlockMinutesMeta,
          minFocusBlockMinutes.isAcceptableOrUnknown(
              data['min_focus_block_minutes']!, _minFocusBlockMinutesMeta));
    }
    if (data.containsKey('preferred_focus_hours_start')) {
      context.handle(
          _preferredFocusHoursStartMeta,
          preferredFocusHoursStart.isAcceptableOrUnknown(
              data['preferred_focus_hours_start']!,
              _preferredFocusHoursStartMeta));
    }
    if (data.containsKey('preferred_focus_hours_end')) {
      context.handle(
          _preferredFocusHoursEndMeta,
          preferredFocusHoursEnd.isAcceptableOrUnknown(
              data['preferred_focus_hours_end']!, _preferredFocusHoursEndMeta));
    }
    if (data.containsKey('notification_preferences')) {
      context.handle(
          _notificationPreferencesMeta,
          notificationPreferences.isAcceptableOrUnknown(
              data['notification_preferences']!, _notificationPreferencesMeta));
    }
    if (data.containsKey('offline_cache_days')) {
      context.handle(
          _offlineCacheDaysMeta,
          offlineCacheDays.isAcceptableOrUnknown(
              data['offline_cache_days']!, _offlineCacheDaysMeta));
    }
    if (data.containsKey('auto_archive_enabled')) {
      context.handle(
          _autoArchiveEnabledMeta,
          autoArchiveEnabled.isAcceptableOrUnknown(
              data['auto_archive_enabled']!, _autoArchiveEnabledMeta));
    }
    if (data.containsKey('archive_tasks_after_days')) {
      context.handle(
          _archiveTasksAfterDaysMeta,
          archiveTasksAfterDays.isAcceptableOrUnknown(
              data['archive_tasks_after_days']!, _archiveTasksAfterDaysMeta));
    }
    if (data.containsKey('archive_events_after_days')) {
      context.handle(
          _archiveEventsAfterDaysMeta,
          archiveEventsAfterDays.isAcceptableOrUnknown(
              data['archive_events_after_days']!, _archiveEventsAfterDaysMeta));
    }
    if (data.containsKey('archive_logs_after_days')) {
      context.handle(
          _archiveLogsAfterDaysMeta,
          archiveLogsAfterDays.isAcceptableOrUnknown(
              data['archive_logs_after_days']!, _archiveLogsAfterDaysMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userId},
      ];
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      elderContactFrequencyDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}elder_contact_frequency_days'])!,
      memberContactFrequencyDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}member_contact_frequency_days'])!,
      crisisContactFrequencyDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}crisis_contact_frequency_days'])!,
      weeklySermonPrepHours: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}weekly_sermon_prep_hours'])!,
      maxDailyHours: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_daily_hours'])!,
      minFocusBlockMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}min_focus_block_minutes'])!,
      preferredFocusHoursStart: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_focus_hours_start']),
      preferredFocusHoursEnd: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_focus_hours_end']),
      notificationPreferences: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notification_preferences']),
      offlineCacheDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}offline_cache_days'])!,
      autoArchiveEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_archive_enabled'])!,
      archiveTasksAfterDays: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}archive_tasks_after_days'])!,
      archiveEventsAfterDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archive_events_after_days'])!,
      archiveLogsAfterDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}archive_logs_after_days'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_updated_at']),
      serverUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_updated_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  /// Primary key - UUID generated on client
  final String id;

  /// Foreign key to users table - establishes 1:1 relationship
  /// ON DELETE CASCADE: When user is deleted, their settings are automatically deleted
  final String userId;

  /// Target days between contacts with church elders
  /// Default: 30 days (monthly check-ins)
  final int elderContactFrequencyDays;

  /// Target days between contacts with regular members
  /// Default: 90 days (quarterly check-ins)
  final int memberContactFrequencyDays;

  /// Target days between contacts with members in crisis
  /// Default: 3 days (frequent support during difficult times)
  final int crisisContactFrequencyDays;

  /// Target hours per week for sermon preparation
  /// Default: 8 hours (one full workday equivalent)
  final int weeklySermonPrepHours;

  /// Maximum hours to schedule in a single day (prevents overwork)
  /// Default: 10 hours
  final int maxDailyHours;

  /// Minimum duration (minutes) for deep focus blocks
  /// Default: 120 minutes (2 hours for sermon prep, study, writing)
  final int minFocusBlockMinutes;

  /// Start time for preferred focus hours
  /// Stored as TEXT in format 'HH:MM' (24-hour format)
  /// Example: '08:00' for 8:00 AM
  /// Nullable - user may not have set preference
  final String? preferredFocusHoursStart;

  /// End time for preferred focus hours
  /// Stored as TEXT in format 'HH:MM' (24-hour format)
  /// Example: '12:00' for 12:00 PM
  /// Nullable - user may not have set preference
  final String? preferredFocusHoursEnd;

  /// JSON-encoded notification preferences
  /// Stores complex nested structure as JSON string in SQLite
  /// Example: {"email": true, "push": true, "sms": false, "dailyDigest": "08:00"}
  ///
  /// Expected structure:
  /// {
  ///   "email": bool,
  ///   "push": bool,
  ///   "sms": bool,
  ///   "dailyDigest": string (time in HH:MM format),
  ///   "upcomingEvents": bool,
  ///   "overdueContacts": bool
  /// }
  final String? notificationPreferences;

  /// Number of days of data to cache for offline access
  /// Default: 90 days (3 months of recent data)
  /// Determines how much historical data to sync to local device
  final int offlineCacheDays;

  /// Enable automatic archiving of old records
  /// Stored as INTEGER: 1 = enabled, 0 = disabled
  /// Default: 1 (enabled)
  final int autoArchiveEnabled;

  /// Days after completion before tasks are auto-archived
  /// Default: 90 days (archive completed tasks after 3 months)
  final int archiveTasksAfterDays;

  /// Days after event date before events are auto-archived
  /// Default: 365 days (archive past events after 1 year)
  final int archiveEventsAfterDays;

  /// Days after creation before contact logs are auto-archived
  /// Default: 730 days (archive logs after 2 years)
  final int archiveLogsAfterDays;

  /// Timestamp when settings were created (Unix milliseconds)
  final int createdAt;

  /// Timestamp when settings were last updated (Unix milliseconds)
  final int updatedAt;

  /// Sync status: 'synced', 'pending', or 'conflict'
  final String syncStatus;

  /// Unix timestamp (milliseconds) when record was last modified locally
  final int? localUpdatedAt;

  /// Unix timestamp (milliseconds) of last known server state
  final int? serverUpdatedAt;

  /// Version counter for optimistic locking
  final int version;
  const UserSetting(
      {required this.id,
      required this.userId,
      required this.elderContactFrequencyDays,
      required this.memberContactFrequencyDays,
      required this.crisisContactFrequencyDays,
      required this.weeklySermonPrepHours,
      required this.maxDailyHours,
      required this.minFocusBlockMinutes,
      this.preferredFocusHoursStart,
      this.preferredFocusHoursEnd,
      this.notificationPreferences,
      required this.offlineCacheDays,
      required this.autoArchiveEnabled,
      required this.archiveTasksAfterDays,
      required this.archiveEventsAfterDays,
      required this.archiveLogsAfterDays,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['elder_contact_frequency_days'] =
        Variable<int>(elderContactFrequencyDays);
    map['member_contact_frequency_days'] =
        Variable<int>(memberContactFrequencyDays);
    map['crisis_contact_frequency_days'] =
        Variable<int>(crisisContactFrequencyDays);
    map['weekly_sermon_prep_hours'] = Variable<int>(weeklySermonPrepHours);
    map['max_daily_hours'] = Variable<int>(maxDailyHours);
    map['min_focus_block_minutes'] = Variable<int>(minFocusBlockMinutes);
    if (!nullToAbsent || preferredFocusHoursStart != null) {
      map['preferred_focus_hours_start'] =
          Variable<String>(preferredFocusHoursStart);
    }
    if (!nullToAbsent || preferredFocusHoursEnd != null) {
      map['preferred_focus_hours_end'] =
          Variable<String>(preferredFocusHoursEnd);
    }
    if (!nullToAbsent || notificationPreferences != null) {
      map['notification_preferences'] =
          Variable<String>(notificationPreferences);
    }
    map['offline_cache_days'] = Variable<int>(offlineCacheDays);
    map['auto_archive_enabled'] = Variable<int>(autoArchiveEnabled);
    map['archive_tasks_after_days'] = Variable<int>(archiveTasksAfterDays);
    map['archive_events_after_days'] = Variable<int>(archiveEventsAfterDays);
    map['archive_logs_after_days'] = Variable<int>(archiveLogsAfterDays);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      userId: Value(userId),
      elderContactFrequencyDays: Value(elderContactFrequencyDays),
      memberContactFrequencyDays: Value(memberContactFrequencyDays),
      crisisContactFrequencyDays: Value(crisisContactFrequencyDays),
      weeklySermonPrepHours: Value(weeklySermonPrepHours),
      maxDailyHours: Value(maxDailyHours),
      minFocusBlockMinutes: Value(minFocusBlockMinutes),
      preferredFocusHoursStart: preferredFocusHoursStart == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredFocusHoursStart),
      preferredFocusHoursEnd: preferredFocusHoursEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredFocusHoursEnd),
      notificationPreferences: notificationPreferences == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationPreferences),
      offlineCacheDays: Value(offlineCacheDays),
      autoArchiveEnabled: Value(autoArchiveEnabled),
      archiveTasksAfterDays: Value(archiveTasksAfterDays),
      archiveEventsAfterDays: Value(archiveEventsAfterDays),
      archiveLogsAfterDays: Value(archiveLogsAfterDays),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      version: Value(version),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      elderContactFrequencyDays:
          serializer.fromJson<int>(json['elderContactFrequencyDays']),
      memberContactFrequencyDays:
          serializer.fromJson<int>(json['memberContactFrequencyDays']),
      crisisContactFrequencyDays:
          serializer.fromJson<int>(json['crisisContactFrequencyDays']),
      weeklySermonPrepHours:
          serializer.fromJson<int>(json['weeklySermonPrepHours']),
      maxDailyHours: serializer.fromJson<int>(json['maxDailyHours']),
      minFocusBlockMinutes:
          serializer.fromJson<int>(json['minFocusBlockMinutes']),
      preferredFocusHoursStart:
          serializer.fromJson<String?>(json['preferredFocusHoursStart']),
      preferredFocusHoursEnd:
          serializer.fromJson<String?>(json['preferredFocusHoursEnd']),
      notificationPreferences:
          serializer.fromJson<String?>(json['notificationPreferences']),
      offlineCacheDays: serializer.fromJson<int>(json['offlineCacheDays']),
      autoArchiveEnabled: serializer.fromJson<int>(json['autoArchiveEnabled']),
      archiveTasksAfterDays:
          serializer.fromJson<int>(json['archiveTasksAfterDays']),
      archiveEventsAfterDays:
          serializer.fromJson<int>(json['archiveEventsAfterDays']),
      archiveLogsAfterDays:
          serializer.fromJson<int>(json['archiveLogsAfterDays']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<int?>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'elderContactFrequencyDays':
          serializer.toJson<int>(elderContactFrequencyDays),
      'memberContactFrequencyDays':
          serializer.toJson<int>(memberContactFrequencyDays),
      'crisisContactFrequencyDays':
          serializer.toJson<int>(crisisContactFrequencyDays),
      'weeklySermonPrepHours': serializer.toJson<int>(weeklySermonPrepHours),
      'maxDailyHours': serializer.toJson<int>(maxDailyHours),
      'minFocusBlockMinutes': serializer.toJson<int>(minFocusBlockMinutes),
      'preferredFocusHoursStart':
          serializer.toJson<String?>(preferredFocusHoursStart),
      'preferredFocusHoursEnd':
          serializer.toJson<String?>(preferredFocusHoursEnd),
      'notificationPreferences':
          serializer.toJson<String?>(notificationPreferences),
      'offlineCacheDays': serializer.toJson<int>(offlineCacheDays),
      'autoArchiveEnabled': serializer.toJson<int>(autoArchiveEnabled),
      'archiveTasksAfterDays': serializer.toJson<int>(archiveTasksAfterDays),
      'archiveEventsAfterDays': serializer.toJson<int>(archiveEventsAfterDays),
      'archiveLogsAfterDays': serializer.toJson<int>(archiveLogsAfterDays),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<int?>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  UserSetting copyWith(
          {String? id,
          String? userId,
          int? elderContactFrequencyDays,
          int? memberContactFrequencyDays,
          int? crisisContactFrequencyDays,
          int? weeklySermonPrepHours,
          int? maxDailyHours,
          int? minFocusBlockMinutes,
          Value<String?> preferredFocusHoursStart = const Value.absent(),
          Value<String?> preferredFocusHoursEnd = const Value.absent(),
          Value<String?> notificationPreferences = const Value.absent(),
          int? offlineCacheDays,
          int? autoArchiveEnabled,
          int? archiveTasksAfterDays,
          int? archiveEventsAfterDays,
          int? archiveLogsAfterDays,
          int? createdAt,
          int? updatedAt,
          String? syncStatus,
          Value<int?> localUpdatedAt = const Value.absent(),
          Value<int?> serverUpdatedAt = const Value.absent(),
          int? version}) =>
      UserSetting(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        elderContactFrequencyDays:
            elderContactFrequencyDays ?? this.elderContactFrequencyDays,
        memberContactFrequencyDays:
            memberContactFrequencyDays ?? this.memberContactFrequencyDays,
        crisisContactFrequencyDays:
            crisisContactFrequencyDays ?? this.crisisContactFrequencyDays,
        weeklySermonPrepHours:
            weeklySermonPrepHours ?? this.weeklySermonPrepHours,
        maxDailyHours: maxDailyHours ?? this.maxDailyHours,
        minFocusBlockMinutes: minFocusBlockMinutes ?? this.minFocusBlockMinutes,
        preferredFocusHoursStart: preferredFocusHoursStart.present
            ? preferredFocusHoursStart.value
            : this.preferredFocusHoursStart,
        preferredFocusHoursEnd: preferredFocusHoursEnd.present
            ? preferredFocusHoursEnd.value
            : this.preferredFocusHoursEnd,
        notificationPreferences: notificationPreferences.present
            ? notificationPreferences.value
            : this.notificationPreferences,
        offlineCacheDays: offlineCacheDays ?? this.offlineCacheDays,
        autoArchiveEnabled: autoArchiveEnabled ?? this.autoArchiveEnabled,
        archiveTasksAfterDays:
            archiveTasksAfterDays ?? this.archiveTasksAfterDays,
        archiveEventsAfterDays:
            archiveEventsAfterDays ?? this.archiveEventsAfterDays,
        archiveLogsAfterDays: archiveLogsAfterDays ?? this.archiveLogsAfterDays,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt:
            localUpdatedAt.present ? localUpdatedAt.value : this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        version: version ?? this.version,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      elderContactFrequencyDays: data.elderContactFrequencyDays.present
          ? data.elderContactFrequencyDays.value
          : this.elderContactFrequencyDays,
      memberContactFrequencyDays: data.memberContactFrequencyDays.present
          ? data.memberContactFrequencyDays.value
          : this.memberContactFrequencyDays,
      crisisContactFrequencyDays: data.crisisContactFrequencyDays.present
          ? data.crisisContactFrequencyDays.value
          : this.crisisContactFrequencyDays,
      weeklySermonPrepHours: data.weeklySermonPrepHours.present
          ? data.weeklySermonPrepHours.value
          : this.weeklySermonPrepHours,
      maxDailyHours: data.maxDailyHours.present
          ? data.maxDailyHours.value
          : this.maxDailyHours,
      minFocusBlockMinutes: data.minFocusBlockMinutes.present
          ? data.minFocusBlockMinutes.value
          : this.minFocusBlockMinutes,
      preferredFocusHoursStart: data.preferredFocusHoursStart.present
          ? data.preferredFocusHoursStart.value
          : this.preferredFocusHoursStart,
      preferredFocusHoursEnd: data.preferredFocusHoursEnd.present
          ? data.preferredFocusHoursEnd.value
          : this.preferredFocusHoursEnd,
      notificationPreferences: data.notificationPreferences.present
          ? data.notificationPreferences.value
          : this.notificationPreferences,
      offlineCacheDays: data.offlineCacheDays.present
          ? data.offlineCacheDays.value
          : this.offlineCacheDays,
      autoArchiveEnabled: data.autoArchiveEnabled.present
          ? data.autoArchiveEnabled.value
          : this.autoArchiveEnabled,
      archiveTasksAfterDays: data.archiveTasksAfterDays.present
          ? data.archiveTasksAfterDays.value
          : this.archiveTasksAfterDays,
      archiveEventsAfterDays: data.archiveEventsAfterDays.present
          ? data.archiveEventsAfterDays.value
          : this.archiveEventsAfterDays,
      archiveLogsAfterDays: data.archiveLogsAfterDays.present
          ? data.archiveLogsAfterDays.value
          : this.archiveLogsAfterDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('elderContactFrequencyDays: $elderContactFrequencyDays, ')
          ..write('memberContactFrequencyDays: $memberContactFrequencyDays, ')
          ..write('crisisContactFrequencyDays: $crisisContactFrequencyDays, ')
          ..write('weeklySermonPrepHours: $weeklySermonPrepHours, ')
          ..write('maxDailyHours: $maxDailyHours, ')
          ..write('minFocusBlockMinutes: $minFocusBlockMinutes, ')
          ..write('preferredFocusHoursStart: $preferredFocusHoursStart, ')
          ..write('preferredFocusHoursEnd: $preferredFocusHoursEnd, ')
          ..write('notificationPreferences: $notificationPreferences, ')
          ..write('offlineCacheDays: $offlineCacheDays, ')
          ..write('autoArchiveEnabled: $autoArchiveEnabled, ')
          ..write('archiveTasksAfterDays: $archiveTasksAfterDays, ')
          ..write('archiveEventsAfterDays: $archiveEventsAfterDays, ')
          ..write('archiveLogsAfterDays: $archiveLogsAfterDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        elderContactFrequencyDays,
        memberContactFrequencyDays,
        crisisContactFrequencyDays,
        weeklySermonPrepHours,
        maxDailyHours,
        minFocusBlockMinutes,
        preferredFocusHoursStart,
        preferredFocusHoursEnd,
        notificationPreferences,
        offlineCacheDays,
        autoArchiveEnabled,
        archiveTasksAfterDays,
        archiveEventsAfterDays,
        archiveLogsAfterDays,
        createdAt,
        updatedAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        version
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.elderContactFrequencyDays == this.elderContactFrequencyDays &&
          other.memberContactFrequencyDays == this.memberContactFrequencyDays &&
          other.crisisContactFrequencyDays == this.crisisContactFrequencyDays &&
          other.weeklySermonPrepHours == this.weeklySermonPrepHours &&
          other.maxDailyHours == this.maxDailyHours &&
          other.minFocusBlockMinutes == this.minFocusBlockMinutes &&
          other.preferredFocusHoursStart == this.preferredFocusHoursStart &&
          other.preferredFocusHoursEnd == this.preferredFocusHoursEnd &&
          other.notificationPreferences == this.notificationPreferences &&
          other.offlineCacheDays == this.offlineCacheDays &&
          other.autoArchiveEnabled == this.autoArchiveEnabled &&
          other.archiveTasksAfterDays == this.archiveTasksAfterDays &&
          other.archiveEventsAfterDays == this.archiveEventsAfterDays &&
          other.archiveLogsAfterDays == this.archiveLogsAfterDays &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.version == this.version);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> elderContactFrequencyDays;
  final Value<int> memberContactFrequencyDays;
  final Value<int> crisisContactFrequencyDays;
  final Value<int> weeklySermonPrepHours;
  final Value<int> maxDailyHours;
  final Value<int> minFocusBlockMinutes;
  final Value<String?> preferredFocusHoursStart;
  final Value<String?> preferredFocusHoursEnd;
  final Value<String?> notificationPreferences;
  final Value<int> offlineCacheDays;
  final Value<int> autoArchiveEnabled;
  final Value<int> archiveTasksAfterDays;
  final Value<int> archiveEventsAfterDays;
  final Value<int> archiveLogsAfterDays;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncStatus;
  final Value<int?> localUpdatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.elderContactFrequencyDays = const Value.absent(),
    this.memberContactFrequencyDays = const Value.absent(),
    this.crisisContactFrequencyDays = const Value.absent(),
    this.weeklySermonPrepHours = const Value.absent(),
    this.maxDailyHours = const Value.absent(),
    this.minFocusBlockMinutes = const Value.absent(),
    this.preferredFocusHoursStart = const Value.absent(),
    this.preferredFocusHoursEnd = const Value.absent(),
    this.notificationPreferences = const Value.absent(),
    this.offlineCacheDays = const Value.absent(),
    this.autoArchiveEnabled = const Value.absent(),
    this.archiveTasksAfterDays = const Value.absent(),
    this.archiveEventsAfterDays = const Value.absent(),
    this.archiveLogsAfterDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.elderContactFrequencyDays = const Value.absent(),
    this.memberContactFrequencyDays = const Value.absent(),
    this.crisisContactFrequencyDays = const Value.absent(),
    this.weeklySermonPrepHours = const Value.absent(),
    this.maxDailyHours = const Value.absent(),
    this.minFocusBlockMinutes = const Value.absent(),
    this.preferredFocusHoursStart = const Value.absent(),
    this.preferredFocusHoursEnd = const Value.absent(),
    this.notificationPreferences = const Value.absent(),
    this.offlineCacheDays = const Value.absent(),
    this.autoArchiveEnabled = const Value.absent(),
    this.archiveTasksAfterDays = const Value.absent(),
    this.archiveEventsAfterDays = const Value.absent(),
    this.archiveLogsAfterDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserSetting> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? elderContactFrequencyDays,
    Expression<int>? memberContactFrequencyDays,
    Expression<int>? crisisContactFrequencyDays,
    Expression<int>? weeklySermonPrepHours,
    Expression<int>? maxDailyHours,
    Expression<int>? minFocusBlockMinutes,
    Expression<String>? preferredFocusHoursStart,
    Expression<String>? preferredFocusHoursEnd,
    Expression<String>? notificationPreferences,
    Expression<int>? offlineCacheDays,
    Expression<int>? autoArchiveEnabled,
    Expression<int>? archiveTasksAfterDays,
    Expression<int>? archiveEventsAfterDays,
    Expression<int>? archiveLogsAfterDays,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? localUpdatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (elderContactFrequencyDays != null)
        'elder_contact_frequency_days': elderContactFrequencyDays,
      if (memberContactFrequencyDays != null)
        'member_contact_frequency_days': memberContactFrequencyDays,
      if (crisisContactFrequencyDays != null)
        'crisis_contact_frequency_days': crisisContactFrequencyDays,
      if (weeklySermonPrepHours != null)
        'weekly_sermon_prep_hours': weeklySermonPrepHours,
      if (maxDailyHours != null) 'max_daily_hours': maxDailyHours,
      if (minFocusBlockMinutes != null)
        'min_focus_block_minutes': minFocusBlockMinutes,
      if (preferredFocusHoursStart != null)
        'preferred_focus_hours_start': preferredFocusHoursStart,
      if (preferredFocusHoursEnd != null)
        'preferred_focus_hours_end': preferredFocusHoursEnd,
      if (notificationPreferences != null)
        'notification_preferences': notificationPreferences,
      if (offlineCacheDays != null) 'offline_cache_days': offlineCacheDays,
      if (autoArchiveEnabled != null)
        'auto_archive_enabled': autoArchiveEnabled,
      if (archiveTasksAfterDays != null)
        'archive_tasks_after_days': archiveTasksAfterDays,
      if (archiveEventsAfterDays != null)
        'archive_events_after_days': archiveEventsAfterDays,
      if (archiveLogsAfterDays != null)
        'archive_logs_after_days': archiveLogsAfterDays,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<int>? elderContactFrequencyDays,
      Value<int>? memberContactFrequencyDays,
      Value<int>? crisisContactFrequencyDays,
      Value<int>? weeklySermonPrepHours,
      Value<int>? maxDailyHours,
      Value<int>? minFocusBlockMinutes,
      Value<String?>? preferredFocusHoursStart,
      Value<String?>? preferredFocusHoursEnd,
      Value<String?>? notificationPreferences,
      Value<int>? offlineCacheDays,
      Value<int>? autoArchiveEnabled,
      Value<int>? archiveTasksAfterDays,
      Value<int>? archiveEventsAfterDays,
      Value<int>? archiveLogsAfterDays,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? syncStatus,
      Value<int?>? localUpdatedAt,
      Value<int?>? serverUpdatedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      elderContactFrequencyDays:
          elderContactFrequencyDays ?? this.elderContactFrequencyDays,
      memberContactFrequencyDays:
          memberContactFrequencyDays ?? this.memberContactFrequencyDays,
      crisisContactFrequencyDays:
          crisisContactFrequencyDays ?? this.crisisContactFrequencyDays,
      weeklySermonPrepHours:
          weeklySermonPrepHours ?? this.weeklySermonPrepHours,
      maxDailyHours: maxDailyHours ?? this.maxDailyHours,
      minFocusBlockMinutes: minFocusBlockMinutes ?? this.minFocusBlockMinutes,
      preferredFocusHoursStart:
          preferredFocusHoursStart ?? this.preferredFocusHoursStart,
      preferredFocusHoursEnd:
          preferredFocusHoursEnd ?? this.preferredFocusHoursEnd,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      offlineCacheDays: offlineCacheDays ?? this.offlineCacheDays,
      autoArchiveEnabled: autoArchiveEnabled ?? this.autoArchiveEnabled,
      archiveTasksAfterDays:
          archiveTasksAfterDays ?? this.archiveTasksAfterDays,
      archiveEventsAfterDays:
          archiveEventsAfterDays ?? this.archiveEventsAfterDays,
      archiveLogsAfterDays: archiveLogsAfterDays ?? this.archiveLogsAfterDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (elderContactFrequencyDays.present) {
      map['elder_contact_frequency_days'] =
          Variable<int>(elderContactFrequencyDays.value);
    }
    if (memberContactFrequencyDays.present) {
      map['member_contact_frequency_days'] =
          Variable<int>(memberContactFrequencyDays.value);
    }
    if (crisisContactFrequencyDays.present) {
      map['crisis_contact_frequency_days'] =
          Variable<int>(crisisContactFrequencyDays.value);
    }
    if (weeklySermonPrepHours.present) {
      map['weekly_sermon_prep_hours'] =
          Variable<int>(weeklySermonPrepHours.value);
    }
    if (maxDailyHours.present) {
      map['max_daily_hours'] = Variable<int>(maxDailyHours.value);
    }
    if (minFocusBlockMinutes.present) {
      map['min_focus_block_minutes'] =
          Variable<int>(minFocusBlockMinutes.value);
    }
    if (preferredFocusHoursStart.present) {
      map['preferred_focus_hours_start'] =
          Variable<String>(preferredFocusHoursStart.value);
    }
    if (preferredFocusHoursEnd.present) {
      map['preferred_focus_hours_end'] =
          Variable<String>(preferredFocusHoursEnd.value);
    }
    if (notificationPreferences.present) {
      map['notification_preferences'] =
          Variable<String>(notificationPreferences.value);
    }
    if (offlineCacheDays.present) {
      map['offline_cache_days'] = Variable<int>(offlineCacheDays.value);
    }
    if (autoArchiveEnabled.present) {
      map['auto_archive_enabled'] = Variable<int>(autoArchiveEnabled.value);
    }
    if (archiveTasksAfterDays.present) {
      map['archive_tasks_after_days'] =
          Variable<int>(archiveTasksAfterDays.value);
    }
    if (archiveEventsAfterDays.present) {
      map['archive_events_after_days'] =
          Variable<int>(archiveEventsAfterDays.value);
    }
    if (archiveLogsAfterDays.present) {
      map['archive_logs_after_days'] =
          Variable<int>(archiveLogsAfterDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('elderContactFrequencyDays: $elderContactFrequencyDays, ')
          ..write('memberContactFrequencyDays: $memberContactFrequencyDays, ')
          ..write('crisisContactFrequencyDays: $crisisContactFrequencyDays, ')
          ..write('weeklySermonPrepHours: $weeklySermonPrepHours, ')
          ..write('maxDailyHours: $maxDailyHours, ')
          ..write('minFocusBlockMinutes: $minFocusBlockMinutes, ')
          ..write('preferredFocusHoursStart: $preferredFocusHoursStart, ')
          ..write('preferredFocusHoursEnd: $preferredFocusHoursEnd, ')
          ..write('notificationPreferences: $notificationPreferences, ')
          ..write('offlineCacheDays: $offlineCacheDays, ')
          ..write('autoArchiveEnabled: $autoArchiveEnabled, ')
          ..write('archiveTasksAfterDays: $archiveTasksAfterDays, ')
          ..write('archiveEventsAfterDays: $archiveEventsAfterDays, ')
          ..write('archiveLogsAfterDays: $archiveLogsAfterDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _affectedTableMeta =
      const VerificationMeta('affectedTable');
  @override
  late final GeneratedColumn<String> affectedTable = GeneratedColumn<String>(
      'affected_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        affectedTable,
        recordId,
        operation,
        payload,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('affected_table')) {
      context.handle(
          _affectedTableMeta,
          affectedTable.isAcceptableOrUnknown(
              data['affected_table']!, _affectedTableMeta));
    } else if (isInserting) {
      context.missing(_affectedTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      affectedTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}affected_table'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  /// Auto-incrementing primary key
  /// SQLite AUTOINCREMENT ensures IDs are never reused (safe for queue ordering)
  final int id;

  /// Name of the table affected by this operation
  /// Examples: 'users', 'user_settings', 'tasks', 'calendar_events', 'people'
  /// Used to route the operation to the correct sync handler
  final String affectedTable;

  /// UUID of the record affected by this operation
  /// Points to the id field in the target table
  /// Used to identify which record to sync
  final String recordId;

  /// Type of database operation to perform
  /// Valid values: 'insert', 'update', 'delete'
  /// - insert: Create new record on server
  /// - update: Modify existing record on server
  /// - delete: Remove record from server (soft or hard delete)
  final String operation;

  /// JSON-encoded payload containing the data to sync
  ///
  /// For INSERT and UPDATE operations:
  /// Contains the full record data (or delta) to send to server
  /// Example: {"title": "Visit Mrs. Johnson", "status": "done", "completed_at": "2025-01-15T10:30:00Z"}
  ///
  /// For DELETE operations:
  /// May be empty or contain metadata about the deletion
  /// Example: {"deleted_at": "2025-01-15T10:30:00Z"}
  ///
  /// The payload excludes sync metadata fields (_sync_status, _local_updated_at, etc.)
  /// as those are for local use only
  final String? payload;

  /// Unix timestamp (milliseconds) when this queue entry was created
  /// Used to:
  /// 1. Maintain FIFO ordering (process oldest first)
  /// 2. Calculate operation age for retry backoff
  /// 3. Identify stale operations that may need cleanup
  final int createdAt;

  /// Number of times this operation has been attempted
  /// Default: 0 (incremented before each retry attempt)
  ///
  /// Retry strategy:
  /// - 0-3 retries: Immediate retry on next sync cycle
  /// - 4-10 retries: Exponential backoff (wait longer between attempts)
  /// - 10+ retries: Flag for manual review (may indicate data conflict or API issue)
  final int retryCount;

  /// Error message from the last failed sync attempt
  /// Nullable - empty for operations not yet attempted or successful
  ///
  /// Examples:
  /// - "Network error: No internet connection"
  /// - "Conflict: Record was modified on server"
  /// - "Validation error: Invalid email format"
  /// - "Auth error: User session expired"
  ///
  /// Used for debugging and user-facing error messages
  final String? lastError;
  const SyncQueueEntry(
      {required this.id,
      required this.affectedTable,
      required this.recordId,
      required this.operation,
      this.payload,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['affected_table'] = Variable<String>(affectedTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      affectedTable: Value(affectedTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      affectedTable: serializer.fromJson<String>(json['affectedTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'affectedTable': serializer.toJson<String>(affectedTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueEntry copyWith(
          {int? id,
          String? affectedTable,
          String? recordId,
          String? operation,
          Value<String?> payload = const Value.absent(),
          int? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      SyncQueueEntry(
        id: id ?? this.id,
        affectedTable: affectedTable ?? this.affectedTable,
        recordId: recordId ?? this.recordId,
        operation: operation ?? this.operation,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      affectedTable: data.affectedTable.present
          ? data.affectedTable.value
          : this.affectedTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('affectedTable: $affectedTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, affectedTable, recordId, operation,
      payload, createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.affectedTable == this.affectedTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> affectedTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String?> payload;
  final Value<int> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.affectedTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String affectedTable,
    required String recordId,
    required String operation,
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : affectedTable = Value(affectedTable),
        recordId = Value(recordId),
        operation = Value(operation);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? affectedTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (affectedTable != null) 'affected_table': affectedTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? affectedTable,
      Value<String>? recordId,
      Value<String>? operation,
      Value<String?>? payload,
      Value<int>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      affectedTable: affectedTable ?? this.affectedTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (affectedTable.present) {
      map['affected_table'] = Variable<String>(affectedTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('affectedTable: $affectedTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueTimeMeta =
      const VerificationMeta('dueTime');
  @override
  late final GeneratedColumn<String> dueTime = GeneratedColumn<String>(
      'due_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>('estimated_duration_minutes', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _actualDurationMinutesMeta =
      const VerificationMeta('actualDurationMinutes');
  @override
  late final GeneratedColumn<int> actualDurationMinutes = GeneratedColumn<int>(
      'actual_duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not_started'));
  static const VerificationMeta _requiresFocusMeta =
      const VerificationMeta('requiresFocus');
  @override
  late final GeneratedColumn<bool> requiresFocus = GeneratedColumn<bool>(
      'requires_focus', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_focus" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _energyLevelMeta =
      const VerificationMeta('energyLevel');
  @override
  late final GeneratedColumn<String> energyLevel = GeneratedColumn<String>(
      'energy_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _calendarEventIdMeta =
      const VerificationMeta('calendarEventId');
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
      'calendar_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sermonIdMeta =
      const VerificationMeta('sermonId');
  @override
  late final GeneratedColumn<String> sermonId = GeneratedColumn<String>(
      'sermon_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentTaskIdMeta =
      const VerificationMeta('parentTaskId');
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
      'parent_task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
      'local_updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().millisecondsSinceEpoch);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
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
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('due_time')) {
      context.handle(_dueTimeMeta,
          dueTime.isAcceptableOrUnknown(data['due_time']!, _dueTimeMeta));
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
          _estimatedDurationMinutesMeta,
          estimatedDurationMinutes.isAcceptableOrUnknown(
              data['estimated_duration_minutes']!,
              _estimatedDurationMinutesMeta));
    }
    if (data.containsKey('actual_duration_minutes')) {
      context.handle(
          _actualDurationMinutesMeta,
          actualDurationMinutes.isAcceptableOrUnknown(
              data['actual_duration_minutes']!, _actualDurationMinutesMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('requires_focus')) {
      context.handle(
          _requiresFocusMeta,
          requiresFocus.isAcceptableOrUnknown(
              data['requires_focus']!, _requiresFocusMeta));
    }
    if (data.containsKey('energy_level')) {
      context.handle(
          _energyLevelMeta,
          energyLevel.isAcceptableOrUnknown(
              data['energy_level']!, _energyLevelMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
          _calendarEventIdMeta,
          calendarEventId.isAcceptableOrUnknown(
              data['calendar_event_id']!, _calendarEventIdMeta));
    }
    if (data.containsKey('sermon_id')) {
      context.handle(_sermonIdMeta,
          sermonId.isAcceptableOrUnknown(data['sermon_id']!, _sermonIdMeta));
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
          _parentTaskIdMeta,
          parentTaskId.isAcceptableOrUnknown(
              data['parent_task_id']!, _parentTaskIdMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      dueTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_time']),
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estimated_duration_minutes']),
      actualDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}actual_duration_minutes']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requiresFocus: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}requires_focus'])!,
      energyLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}energy_level'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      calendarEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}calendar_event_id']),
      sermonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sermon_id']),
      parentTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_task_id']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_updated_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  /// Primary key - UUID generated on client
  /// Uses TEXT in SQLite to store UUID strings
  /// Must match Supabase UUID format for seamless sync
  final String id;

  /// Foreign key to users table - establishes multi-tenant isolation
  /// Every task belongs to exactly one user (the pastor who created it)
  /// ON DELETE CASCADE: When user is deleted, their tasks are automatically deleted
  final String userId;

  /// Task title - required, non-empty string
  /// Example: "Prepare Sunday sermon outline", "Visit hospitalized member"
  /// Constraint: Must have at least one non-whitespace character (validated in app layer)
  final String title;

  /// Optional detailed task description
  /// Can include notes, instructions, context, or any additional information
  /// Nullable - simple tasks may not need description
  final String? description;

  /// Optional due date (DATE only, no time component)
  /// Stored as DateTime in Dart, but only date part is significant
  /// Use for tasks with specific deadlines
  /// Nullable - not all tasks have due dates
  final DateTime? dueDate;

  /// Optional due time (TIME only, stored as text in HH:MM format)
  /// Stored as TEXT in SQLite: '09:30', '14:00', '23:45'
  /// Paired with due_date to create full datetime
  /// Example: due_date = 2025-12-15, due_time = '10:30' -> Due at Dec 15, 2025 10:30 AM
  /// Nullable - many tasks have date but no specific time
  final String? dueTime;

  /// Estimated duration to complete task (in minutes)
  /// Example: 120 = 2 hours, 45 = 45 minutes
  /// Used for:
  /// - Calendar blocking suggestions
  /// - Workload estimation
  /// - Scheduling optimization
  /// Nullable - not all tasks have time estimates
  /// Constraint: Must be positive integer if set (validated in app layer)
  final int? estimatedDurationMinutes;

  /// Actual duration spent on task (in minutes)
  /// Tracked after task completion
  /// Used for:
  /// - Improving future estimates
  /// - Time audit and productivity analysis
  /// - Reporting (how much time spent on sermon prep vs admin)
  /// Nullable - only set after task is completed and tracked
  /// Constraint: Must be positive integer if set (validated in app layer)
  final int? actualDurationMinutes;

  /// Task category - required field for organization and filtering
  /// Valid values (enforced in app layer, matches Supabase CHECK constraint):
  /// - 'sermon_prep': Sermon preparation tasks (research, outlining, writing)
  /// - 'pastoral_care': Caring for congregation (visits, calls, counseling)
  /// - 'admin': Administrative tasks (budgets, reports, emails)
  /// - 'personal': Personal development (reading, prayer, exercise)
  /// - 'worship_planning': Worship service planning (music, liturgy, order of service)
  ///
  /// Category enables:
  /// - Filtered task views ("Show all sermon prep tasks")
  /// - Time allocation tracking ("Am I spending enough time on pastoral care?")
  /// - Workload balancing suggestions
  final String category;

  /// Task priority - helps with task ordering and urgency
  /// Valid values (enforced in app layer):
  /// - 'low': Can wait, no immediate deadline
  /// - 'medium': Normal priority (default)
  /// - 'high': Important, should be done soon
  /// - 'urgent': Critical, needs immediate attention
  /// Default: 'medium'
  final String priority;

  /// Task status - lifecycle state of the task
  /// Valid values (enforced in app layer):
  /// - 'not_started': Task created but not yet begun (default)
  /// - 'in_progress': Currently working on task
  /// - 'done': Task completed (completed_at timestamp required)
  /// - 'deleted': Task soft-deleted (deleted_at timestamp required)
  ///
  /// Status transitions:
  /// - not_started -> in_progress -> done
  /// - Any status -> deleted (soft delete)
  /// Default: 'not_started'
  final String status;

  /// Whether task requires dedicated focus time (no interruptions)
  /// Used for smart scheduling to find uninterrupted time blocks
  /// Examples of focus tasks:
  /// - Writing sermon manuscript (requires_focus = true)
  /// - Deep study/exegesis (requires_focus = true)
  /// - Quick admin emails (requires_focus = false)
  /// Default: false
  final bool requiresFocus;

  /// Energy level required to complete task effectively
  /// Valid values (enforced in app layer):
  /// - 'low': Can be done when tired (filing, simple emails)
  /// - 'medium': Normal energy level (default)
  /// - 'high': Requires peak mental energy (sermon writing, strategic planning)
  ///
  /// Used for smart scheduling:
  /// - Schedule high-energy tasks during peak focus hours
  /// - Save low-energy tasks for end of day
  /// - Match task energy to pastor's energy patterns
  /// Default: 'medium'
  final String energyLevel;

  /// Optional foreign key to people table (when implemented)
  /// Links task to specific person (e.g., "Visit John Smith in hospital")
  /// Use cases:
  /// - Pastoral care tasks for specific members
  /// - Meeting preparations for specific leaders
  /// Nullable - not all tasks relate to specific people
  /// Note: FK constraint will be added in migration 0003_people_table.sql
  final String? personId;

  /// Optional foreign key to calendar_events table (when implemented)
  /// Links task to specific calendar event
  /// Use cases:
  /// - Preparation tasks for specific events
  /// - Follow-up tasks after meetings
  /// Nullable - not all tasks relate to events
  /// Note: FK constraint will be added in migration 0004_calendar_events_table.sql
  final String? calendarEventId;

  /// Optional foreign key to sermons table (when implemented)
  /// Links task to specific sermon
  /// Use cases:
  /// - Sermon preparation tasks (research, outlining, writing)
  /// - All tasks for a sermon can be grouped together
  /// Nullable - not all tasks relate to sermons
  /// Note: FK constraint will be added in migration 0005_sermons_table.sql
  final String? sermonId;

  /// Optional parent task ID for creating task hierarchies (subtasks)
  /// Self-referencing foreign key to tasks table
  /// Enables task breakdown:
  /// - Parent: "Prepare Sunday sermon"
  ///   - Subtask: "Research passage context"
  ///   - Subtask: "Create outline"
  ///   - Subtask: "Write manuscript"
  /// Nullable - top-level tasks have no parent
  /// ON DELETE CASCADE: When parent task is deleted, subtasks are also deleted
  final String? parentTaskId;

  /// Timestamp when task was marked as done
  /// NULL until task status changes to 'done'
  /// Constraint (enforced in app layer):
  /// - Must be NULL when status != 'done'
  /// - Must be NOT NULL when status = 'done'
  /// Used for:
  /// - Completion tracking
  /// - Productivity analytics
  /// - Auto-archiving completed tasks
  final DateTime? completedAt;

  /// Timestamp when task was soft-deleted
  /// NULL for active tasks
  /// Constraint (enforced in app layer):
  /// - Must be NULL when status != 'deleted'
  /// - Must be NOT NULL when status = 'deleted'
  /// Soft delete pattern allows:
  /// - Task recovery ("undo delete")
  /// - Audit trail of deleted tasks
  /// - Auto-purge after retention period
  final DateTime? deletedAt;

  /// Timestamp when task record was created (Unix milliseconds)
  /// Automatically set on insert
  final int createdAt;

  /// Timestamp when task record was last updated (Unix milliseconds)
  /// Should be updated on every modification
  /// Used for conflict resolution during sync
  final int updatedAt;

  /// Sync status: 'synced', 'pending', or 'conflict'
  /// - synced: Record matches server state exactly
  /// - pending: Local changes not yet pushed to Supabase (requires sync)
  /// - conflict: Both local and server have conflicting changes (requires user resolution)
  ///
  /// Sync workflow:
  /// 1. User modifies task -> syncStatus = 'pending'
  /// 2. Sync engine uploads to Supabase -> syncStatus = 'synced'
  /// 3. If server has newer version -> syncStatus = 'conflict'
  /// Default: 'pending' (new tasks need to be synced)
  final String syncStatus;

  /// Unix timestamp (milliseconds) when record was last modified locally
  /// Updated on every local modification
  /// Used to:
  /// - Detect local changes that need syncing
  /// - Order sync operations (oldest changes first)
  /// - Resolve conflicts (compare with serverUpdatedAt)
  final int localUpdatedAt;

  /// Unix timestamp (milliseconds) of last known server state
  /// Updated when successfully synced with Supabase
  /// Used to:
  /// - Detect server-side changes during sync
  /// - Resolve conflicts (if localUpdatedAt > serverUpdatedAt, local wins)
  /// Nullable - not set until first successful sync
  final int? serverUpdatedAt;

  /// Version counter for optimistic locking
  /// Incremented on each update (local or remote)
  /// Used to:
  /// - Detect concurrent modifications
  /// - Prevent lost updates (compare versions before overwriting)
  /// - Resolve three-way conflicts
  /// Default: 1 (initial version)
  final int version;
  const Task(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      this.dueDate,
      this.dueTime,
      this.estimatedDurationMinutes,
      this.actualDurationMinutes,
      required this.category,
      required this.priority,
      required this.status,
      required this.requiresFocus,
      required this.energyLevel,
      this.personId,
      this.calendarEventId,
      this.sermonId,
      this.parentTaskId,
      this.completedAt,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || dueTime != null) {
      map['due_time'] = Variable<String>(dueTime);
    }
    if (!nullToAbsent || estimatedDurationMinutes != null) {
      map['estimated_duration_minutes'] =
          Variable<int>(estimatedDurationMinutes);
    }
    if (!nullToAbsent || actualDurationMinutes != null) {
      map['actual_duration_minutes'] = Variable<int>(actualDurationMinutes);
    }
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['requires_focus'] = Variable<bool>(requiresFocus);
    map['energy_level'] = Variable<String>(energyLevel);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    if (!nullToAbsent || sermonId != null) {
      map['sermon_id'] = Variable<String>(sermonId);
    }
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<String>(parentTaskId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dueTime: dueTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dueTime),
      estimatedDurationMinutes: estimatedDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationMinutes),
      actualDurationMinutes: actualDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationMinutes),
      category: Value(category),
      priority: Value(priority),
      status: Value(status),
      requiresFocus: Value(requiresFocus),
      energyLevel: Value(energyLevel),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      sermonId: sermonId == null && nullToAbsent
          ? const Value.absent()
          : Value(sermonId),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      version: Value(version),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      dueTime: serializer.fromJson<String?>(json['dueTime']),
      estimatedDurationMinutes:
          serializer.fromJson<int?>(json['estimatedDurationMinutes']),
      actualDurationMinutes:
          serializer.fromJson<int?>(json['actualDurationMinutes']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      requiresFocus: serializer.fromJson<bool>(json['requiresFocus']),
      energyLevel: serializer.fromJson<String>(json['energyLevel']),
      personId: serializer.fromJson<String?>(json['personId']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      sermonId: serializer.fromJson<String?>(json['sermonId']),
      parentTaskId: serializer.fromJson<String?>(json['parentTaskId']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'dueTime': serializer.toJson<String?>(dueTime),
      'estimatedDurationMinutes':
          serializer.toJson<int?>(estimatedDurationMinutes),
      'actualDurationMinutes': serializer.toJson<int?>(actualDurationMinutes),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'requiresFocus': serializer.toJson<bool>(requiresFocus),
      'energyLevel': serializer.toJson<String>(energyLevel),
      'personId': serializer.toJson<String?>(personId),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'sermonId': serializer.toJson<String?>(sermonId),
      'parentTaskId': serializer.toJson<String?>(parentTaskId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Task copyWith(
          {String? id,
          String? userId,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> dueTime = const Value.absent(),
          Value<int?> estimatedDurationMinutes = const Value.absent(),
          Value<int?> actualDurationMinutes = const Value.absent(),
          String? category,
          String? priority,
          String? status,
          bool? requiresFocus,
          String? energyLevel,
          Value<String?> personId = const Value.absent(),
          Value<String?> calendarEventId = const Value.absent(),
          Value<String?> sermonId = const Value.absent(),
          Value<String?> parentTaskId = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          String? syncStatus,
          int? localUpdatedAt,
          Value<int?> serverUpdatedAt = const Value.absent(),
          int? version}) =>
      Task(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        dueTime: dueTime.present ? dueTime.value : this.dueTime,
        estimatedDurationMinutes: estimatedDurationMinutes.present
            ? estimatedDurationMinutes.value
            : this.estimatedDurationMinutes,
        actualDurationMinutes: actualDurationMinutes.present
            ? actualDurationMinutes.value
            : this.actualDurationMinutes,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        requiresFocus: requiresFocus ?? this.requiresFocus,
        energyLevel: energyLevel ?? this.energyLevel,
        personId: personId.present ? personId.value : this.personId,
        calendarEventId: calendarEventId.present
            ? calendarEventId.value
            : this.calendarEventId,
        sermonId: sermonId.present ? sermonId.value : this.sermonId,
        parentTaskId:
            parentTaskId.present ? parentTaskId.value : this.parentTaskId,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        version: version ?? this.version,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueTime: data.dueTime.present ? data.dueTime.value : this.dueTime,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
      actualDurationMinutes: data.actualDurationMinutes.present
          ? data.actualDurationMinutes.value
          : this.actualDurationMinutes,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      requiresFocus: data.requiresFocus.present
          ? data.requiresFocus.value
          : this.requiresFocus,
      energyLevel:
          data.energyLevel.present ? data.energyLevel.value : this.energyLevel,
      personId: data.personId.present ? data.personId.value : this.personId,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      sermonId: data.sermonId.present ? data.sermonId.value : this.sermonId,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('actualDurationMinutes: $actualDurationMinutes, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('requiresFocus: $requiresFocus, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('personId: $personId, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('sermonId: $sermonId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
        version
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.dueTime == this.dueTime &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.actualDurationMinutes == this.actualDurationMinutes &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.requiresFocus == this.requiresFocus &&
          other.energyLevel == this.energyLevel &&
          other.personId == this.personId &&
          other.calendarEventId == this.calendarEventId &&
          other.sermonId == this.sermonId &&
          other.parentTaskId == this.parentTaskId &&
          other.completedAt == this.completedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.version == this.version);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueDate;
  final Value<String?> dueTime;
  final Value<int?> estimatedDurationMinutes;
  final Value<int?> actualDurationMinutes;
  final Value<String> category;
  final Value<String> priority;
  final Value<String> status;
  final Value<bool> requiresFocus;
  final Value<String> energyLevel;
  final Value<String?> personId;
  final Value<String?> calendarEventId;
  final Value<String?> sermonId;
  final Value<String?> parentTaskId;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncStatus;
  final Value<int> localUpdatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.requiresFocus = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.personId = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.sermonId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
    required String category,
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.requiresFocus = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.personId = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.sermonId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        title = Value(title),
        category = Value(category);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<String>? dueTime,
    Expression<int>? estimatedDurationMinutes,
    Expression<int>? actualDurationMinutes,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<bool>? requiresFocus,
    Expression<String>? energyLevel,
    Expression<String>? personId,
    Expression<String>? calendarEventId,
    Expression<String>? sermonId,
    Expression<String>? parentTaskId,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? localUpdatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (dueTime != null) 'due_time': dueTime,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (actualDurationMinutes != null)
        'actual_duration_minutes': actualDurationMinutes,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (requiresFocus != null) 'requires_focus': requiresFocus,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (personId != null) 'person_id': personId,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (sermonId != null) 'sermon_id': sermonId,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (completedAt != null) 'completed_at': completedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime?>? dueDate,
      Value<String?>? dueTime,
      Value<int?>? estimatedDurationMinutes,
      Value<int?>? actualDurationMinutes,
      Value<String>? category,
      Value<String>? priority,
      Value<String>? status,
      Value<bool>? requiresFocus,
      Value<String>? energyLevel,
      Value<String?>? personId,
      Value<String?>? calendarEventId,
      Value<String?>? sermonId,
      Value<String?>? parentTaskId,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? localUpdatedAt,
      Value<int?>? serverUpdatedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueTime.present) {
      map['due_time'] = Variable<String>(dueTime.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] =
          Variable<int>(estimatedDurationMinutes.value);
    }
    if (actualDurationMinutes.present) {
      map['actual_duration_minutes'] =
          Variable<int>(actualDurationMinutes.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requiresFocus.present) {
      map['requires_focus'] = Variable<bool>(requiresFocus.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<String>(energyLevel.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (sermonId.present) {
      map['sermon_id'] = Variable<String>(sermonId.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('actualDurationMinutes: $actualDurationMinutes, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('requiresFocus: $requiresFocus, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('personId: $personId, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('sermonId: $sermonId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, userSettings, syncQueue, tasks];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_settings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tasks', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  required String email,
  required String name,
  Value<String?> churchName,
  Value<String> timezone,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int?> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> name,
  Value<String?> churchName,
  Value<String> timezone,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int?> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserSettingsTable, List<UserSetting>>
      _userSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userSettings,
          aliasName: $_aliasNameGenerator(db.users.id, db.userSettings.userId));

  $$UserSettingsTableProcessedTableManager get userSettingsRefs {
    final manager = $$UserSettingsTableTableManager($_db, $_db.userSettings)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.users.id, db.tasks.userId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get churchName => $composableBuilder(
      column: $table.churchName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  Expression<bool> userSettingsRefs(
      Expression<bool> Function($$UserSettingsTableFilterComposer f) f) {
    final $$UserSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userSettings,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserSettingsTableFilterComposer(
              $db: $db,
              $table: $db.userSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get churchName => $composableBuilder(
      column: $table.churchName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get churchName => $composableBuilder(
      column: $table.churchName, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> userSettingsRefs<T extends Object>(
      Expression<T> Function($$UserSettingsTableAnnotationComposer a) f) {
    final $$UserSettingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userSettings,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserSettingsTableAnnotationComposer(
              $db: $db,
              $table: $db.userSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool userSettingsRefs, bool tasksRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> churchName = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int?> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            name: name,
            churchName: churchName,
            timezone: timezone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String email,
            required String name,
            Value<String?> churchName = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int?> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            name: name,
            churchName: churchName,
            timezone: timezone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {userSettingsRefs = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userSettingsRefs) db.userSettings,
                if (tasksRefs) db.tasks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userSettingsRefs)
                    await $_getPrefetchedData<User, $UsersTable, UserSetting>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._userSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .userSettingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (tasksRefs)
                    await $_getPrefetchedData<User, $UsersTable, Task>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool userSettingsRefs, bool tasksRefs})>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> id,
  required String userId,
  Value<int> elderContactFrequencyDays,
  Value<int> memberContactFrequencyDays,
  Value<int> crisisContactFrequencyDays,
  Value<int> weeklySermonPrepHours,
  Value<int> maxDailyHours,
  Value<int> minFocusBlockMinutes,
  Value<String?> preferredFocusHoursStart,
  Value<String?> preferredFocusHoursEnd,
  Value<String?> notificationPreferences,
  Value<int> offlineCacheDays,
  Value<int> autoArchiveEnabled,
  Value<int> archiveTasksAfterDays,
  Value<int> archiveEventsAfterDays,
  Value<int> archiveLogsAfterDays,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int?> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<int> elderContactFrequencyDays,
  Value<int> memberContactFrequencyDays,
  Value<int> crisisContactFrequencyDays,
  Value<int> weeklySermonPrepHours,
  Value<int> maxDailyHours,
  Value<int> minFocusBlockMinutes,
  Value<String?> preferredFocusHoursStart,
  Value<String?> preferredFocusHoursEnd,
  Value<String?> notificationPreferences,
  Value<int> offlineCacheDays,
  Value<int> autoArchiveEnabled,
  Value<int> archiveTasksAfterDays,
  Value<int> archiveEventsAfterDays,
  Value<int> archiveLogsAfterDays,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int?> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$UserSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting> {
  $$UserSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.userSettings.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elderContactFrequencyDays => $composableBuilder(
      column: $table.elderContactFrequencyDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get memberContactFrequencyDays => $composableBuilder(
      column: $table.memberContactFrequencyDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get crisisContactFrequencyDays => $composableBuilder(
      column: $table.crisisContactFrequencyDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weeklySermonPrepHours => $composableBuilder(
      column: $table.weeklySermonPrepHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDailyHours => $composableBuilder(
      column: $table.maxDailyHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minFocusBlockMinutes => $composableBuilder(
      column: $table.minFocusBlockMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredFocusHoursStart => $composableBuilder(
      column: $table.preferredFocusHoursStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredFocusHoursEnd => $composableBuilder(
      column: $table.preferredFocusHoursEnd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationPreferences => $composableBuilder(
      column: $table.notificationPreferences,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get offlineCacheDays => $composableBuilder(
      column: $table.offlineCacheDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoArchiveEnabled => $composableBuilder(
      column: $table.autoArchiveEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get archiveTasksAfterDays => $composableBuilder(
      column: $table.archiveTasksAfterDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get archiveEventsAfterDays => $composableBuilder(
      column: $table.archiveEventsAfterDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get archiveLogsAfterDays => $composableBuilder(
      column: $table.archiveLogsAfterDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elderContactFrequencyDays => $composableBuilder(
      column: $table.elderContactFrequencyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get memberContactFrequencyDays => $composableBuilder(
      column: $table.memberContactFrequencyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get crisisContactFrequencyDays => $composableBuilder(
      column: $table.crisisContactFrequencyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weeklySermonPrepHours => $composableBuilder(
      column: $table.weeklySermonPrepHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDailyHours => $composableBuilder(
      column: $table.maxDailyHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minFocusBlockMinutes => $composableBuilder(
      column: $table.minFocusBlockMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredFocusHoursStart => $composableBuilder(
      column: $table.preferredFocusHoursStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredFocusHoursEnd => $composableBuilder(
      column: $table.preferredFocusHoursEnd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationPreferences => $composableBuilder(
      column: $table.notificationPreferences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get offlineCacheDays => $composableBuilder(
      column: $table.offlineCacheDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoArchiveEnabled => $composableBuilder(
      column: $table.autoArchiveEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get archiveTasksAfterDays => $composableBuilder(
      column: $table.archiveTasksAfterDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get archiveEventsAfterDays => $composableBuilder(
      column: $table.archiveEventsAfterDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get archiveLogsAfterDays => $composableBuilder(
      column: $table.archiveLogsAfterDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get elderContactFrequencyDays => $composableBuilder(
      column: $table.elderContactFrequencyDays, builder: (column) => column);

  GeneratedColumn<int> get memberContactFrequencyDays => $composableBuilder(
      column: $table.memberContactFrequencyDays, builder: (column) => column);

  GeneratedColumn<int> get crisisContactFrequencyDays => $composableBuilder(
      column: $table.crisisContactFrequencyDays, builder: (column) => column);

  GeneratedColumn<int> get weeklySermonPrepHours => $composableBuilder(
      column: $table.weeklySermonPrepHours, builder: (column) => column);

  GeneratedColumn<int> get maxDailyHours => $composableBuilder(
      column: $table.maxDailyHours, builder: (column) => column);

  GeneratedColumn<int> get minFocusBlockMinutes => $composableBuilder(
      column: $table.minFocusBlockMinutes, builder: (column) => column);

  GeneratedColumn<String> get preferredFocusHoursStart => $composableBuilder(
      column: $table.preferredFocusHoursStart, builder: (column) => column);

  GeneratedColumn<String> get preferredFocusHoursEnd => $composableBuilder(
      column: $table.preferredFocusHoursEnd, builder: (column) => column);

  GeneratedColumn<String> get notificationPreferences => $composableBuilder(
      column: $table.notificationPreferences, builder: (column) => column);

  GeneratedColumn<int> get offlineCacheDays => $composableBuilder(
      column: $table.offlineCacheDays, builder: (column) => column);

  GeneratedColumn<int> get autoArchiveEnabled => $composableBuilder(
      column: $table.autoArchiveEnabled, builder: (column) => column);

  GeneratedColumn<int> get archiveTasksAfterDays => $composableBuilder(
      column: $table.archiveTasksAfterDays, builder: (column) => column);

  GeneratedColumn<int> get archiveEventsAfterDays => $composableBuilder(
      column: $table.archiveEventsAfterDays, builder: (column) => column);

  GeneratedColumn<int> get archiveLogsAfterDays => $composableBuilder(
      column: $table.archiveLogsAfterDays, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (UserSetting, $$UserSettingsTableReferences),
    UserSetting,
    PrefetchHooks Function({bool userId})> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> elderContactFrequencyDays = const Value.absent(),
            Value<int> memberContactFrequencyDays = const Value.absent(),
            Value<int> crisisContactFrequencyDays = const Value.absent(),
            Value<int> weeklySermonPrepHours = const Value.absent(),
            Value<int> maxDailyHours = const Value.absent(),
            Value<int> minFocusBlockMinutes = const Value.absent(),
            Value<String?> preferredFocusHoursStart = const Value.absent(),
            Value<String?> preferredFocusHoursEnd = const Value.absent(),
            Value<String?> notificationPreferences = const Value.absent(),
            Value<int> offlineCacheDays = const Value.absent(),
            Value<int> autoArchiveEnabled = const Value.absent(),
            Value<int> archiveTasksAfterDays = const Value.absent(),
            Value<int> archiveEventsAfterDays = const Value.absent(),
            Value<int> archiveLogsAfterDays = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int?> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            userId: userId,
            elderContactFrequencyDays: elderContactFrequencyDays,
            memberContactFrequencyDays: memberContactFrequencyDays,
            crisisContactFrequencyDays: crisisContactFrequencyDays,
            weeklySermonPrepHours: weeklySermonPrepHours,
            maxDailyHours: maxDailyHours,
            minFocusBlockMinutes: minFocusBlockMinutes,
            preferredFocusHoursStart: preferredFocusHoursStart,
            preferredFocusHoursEnd: preferredFocusHoursEnd,
            notificationPreferences: notificationPreferences,
            offlineCacheDays: offlineCacheDays,
            autoArchiveEnabled: autoArchiveEnabled,
            archiveTasksAfterDays: archiveTasksAfterDays,
            archiveEventsAfterDays: archiveEventsAfterDays,
            archiveLogsAfterDays: archiveLogsAfterDays,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String userId,
            Value<int> elderContactFrequencyDays = const Value.absent(),
            Value<int> memberContactFrequencyDays = const Value.absent(),
            Value<int> crisisContactFrequencyDays = const Value.absent(),
            Value<int> weeklySermonPrepHours = const Value.absent(),
            Value<int> maxDailyHours = const Value.absent(),
            Value<int> minFocusBlockMinutes = const Value.absent(),
            Value<String?> preferredFocusHoursStart = const Value.absent(),
            Value<String?> preferredFocusHoursEnd = const Value.absent(),
            Value<String?> notificationPreferences = const Value.absent(),
            Value<int> offlineCacheDays = const Value.absent(),
            Value<int> autoArchiveEnabled = const Value.absent(),
            Value<int> archiveTasksAfterDays = const Value.absent(),
            Value<int> archiveEventsAfterDays = const Value.absent(),
            Value<int> archiveLogsAfterDays = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int?> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            userId: userId,
            elderContactFrequencyDays: elderContactFrequencyDays,
            memberContactFrequencyDays: memberContactFrequencyDays,
            crisisContactFrequencyDays: crisisContactFrequencyDays,
            weeklySermonPrepHours: weeklySermonPrepHours,
            maxDailyHours: maxDailyHours,
            minFocusBlockMinutes: minFocusBlockMinutes,
            preferredFocusHoursStart: preferredFocusHoursStart,
            preferredFocusHoursEnd: preferredFocusHoursEnd,
            notificationPreferences: notificationPreferences,
            offlineCacheDays: offlineCacheDays,
            autoArchiveEnabled: autoArchiveEnabled,
            archiveTasksAfterDays: archiveTasksAfterDays,
            archiveEventsAfterDays: archiveEventsAfterDays,
            archiveLogsAfterDays: archiveLogsAfterDays,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserSettingsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserSettingsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (UserSetting, $$UserSettingsTableReferences),
    UserSetting,
    PrefetchHooks Function({bool userId})>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String affectedTable,
  required String recordId,
  required String operation,
  Value<String?> payload,
  Value<int> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> affectedTable,
  Value<String> recordId,
  Value<String> operation,
  Value<String?> payload,
  Value<int> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affectedTable => $composableBuilder(
      column: $table.affectedTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affectedTable => $composableBuilder(
      column: $table.affectedTable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get affectedTable => $composableBuilder(
      column: $table.affectedTable, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntry,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> affectedTable = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            affectedTable: affectedTable,
            recordId: recordId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String affectedTable,
            required String recordId,
            required String operation,
            Value<String?> payload = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            affectedTable: affectedTable,
            recordId: recordId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntry,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  required String userId,
  required String title,
  Value<String?> description,
  Value<DateTime?> dueDate,
  Value<String?> dueTime,
  Value<int?> estimatedDurationMinutes,
  Value<int?> actualDurationMinutes,
  required String category,
  Value<String> priority,
  Value<String> status,
  Value<bool> requiresFocus,
  Value<String> energyLevel,
  Value<String?> personId,
  Value<String?> calendarEventId,
  Value<String?> sermonId,
  Value<String?> parentTaskId,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime?> dueDate,
  Value<String?> dueTime,
  Value<int?> estimatedDurationMinutes,
  Value<int?> actualDurationMinutes,
  Value<String> category,
  Value<String> priority,
  Value<String> status,
  Value<bool> requiresFocus,
  Value<String> energyLevel,
  Value<String?> personId,
  Value<String?> calendarEventId,
  Value<String?> sermonId,
  Value<String?> parentTaskId,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> syncStatus,
  Value<int> localUpdatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(db.tasks.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualDurationMinutes => $composableBuilder(
      column: $table.actualDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresFocus => $composableBuilder(
      column: $table.requiresFocus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sermonId => $composableBuilder(
      column: $table.sermonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualDurationMinutes => $composableBuilder(
      column: $table.actualDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresFocus => $composableBuilder(
      column: $table.requiresFocus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sermonId => $composableBuilder(
      column: $table.sermonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => column);

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes, builder: (column) => column);

  GeneratedColumn<int> get actualDurationMinutes => $composableBuilder(
      column: $table.actualDurationMinutes, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get requiresFocus => $composableBuilder(
      column: $table.requiresFocus, builder: (column) => column);

  GeneratedColumn<String> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId, builder: (column) => column);

  GeneratedColumn<String> get sermonId =>
      $composableBuilder(column: $table.sermonId, builder: (column) => column);

  GeneratedColumn<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool userId})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> dueTime = const Value.absent(),
            Value<int?> estimatedDurationMinutes = const Value.absent(),
            Value<int?> actualDurationMinutes = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> requiresFocus = const Value.absent(),
            Value<String> energyLevel = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> calendarEventId = const Value.absent(),
            Value<String?> sermonId = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            dueTime: dueTime,
            estimatedDurationMinutes: estimatedDurationMinutes,
            actualDurationMinutes: actualDurationMinutes,
            category: category,
            priority: priority,
            status: status,
            requiresFocus: requiresFocus,
            energyLevel: energyLevel,
            personId: personId,
            calendarEventId: calendarEventId,
            sermonId: sermonId,
            parentTaskId: parentTaskId,
            completedAt: completedAt,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String userId,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> dueTime = const Value.absent(),
            Value<int?> estimatedDurationMinutes = const Value.absent(),
            Value<int?> actualDurationMinutes = const Value.absent(),
            required String category,
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> requiresFocus = const Value.absent(),
            Value<String> energyLevel = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> calendarEventId = const Value.absent(),
            Value<String?> sermonId = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> localUpdatedAt = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            dueTime: dueTime,
            estimatedDurationMinutes: estimatedDurationMinutes,
            actualDurationMinutes: actualDurationMinutes,
            category: category,
            priority: priority,
            status: status,
            requiresFocus: requiresFocus,
            energyLevel: energyLevel,
            personId: personId,
            calendarEventId: calendarEventId,
            sermonId: sermonId,
            parentTaskId: parentTaskId,
            completedAt: completedAt,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$TasksTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
