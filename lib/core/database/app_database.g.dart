// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreferencesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    onboardingCompleted,
    settingsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferencesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreferencesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferencesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreferencesRow extends DataClass
    implements Insertable<UserPreferencesRow> {
  final int id;
  final bool onboardingCompleted;
  final String settingsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserPreferencesRow({
    required this.id,
    required this.onboardingCompleted,
    required this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['settings_json'] = Variable<String>(settingsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      onboardingCompleted: Value(onboardingCompleted),
      settingsJson: Value(settingsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreferencesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferencesRow(
      id: serializer.fromJson<int>(json['id']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreferencesRow copyWith({
    int? id,
    bool? onboardingCompleted,
    String? settingsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserPreferencesRow(
    id: id ?? this.id,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    settingsJson: settingsJson ?? this.settingsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPreferencesRow copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreferencesRow(
      id: data.id.present ? data.id.value : this.id,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesRow(')
          ..write('id: $id, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, onboardingCompleted, settingsJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferencesRow &&
          other.id == this.id &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.settingsJson == this.settingsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreferencesRow> {
  final Value<int> id;
  final Value<bool> onboardingCompleted;
  final Value<String> settingsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    required String settingsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : settingsJson = Value(settingsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserPreferencesRow> custom({
    Expression<int>? id,
    Expression<bool>? onboardingCompleted,
    Expression<String>? settingsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<bool>? onboardingCompleted,
    Value<String>? settingsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PeriodRecordsTable extends PeriodRecords
    with TableInfo<$PeriodRecordsTable, PeriodRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($PeriodRecordsTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($PeriodRecordsTable.$converterendDaten);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    endDate,
    status,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startDate: $PeriodRecordsTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $PeriodRecordsTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PeriodRecordsTable createAlias(String alias) {
    return $PeriodRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterstartDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate, String> $converterendDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
}

class PeriodRecord extends DataClass implements Insertable<PeriodRecord> {
  final String id;
  final CalendarDate startDate;
  final CalendarDate? endDate;
  final String status;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PeriodRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['start_date'] = Variable<String>(
        $PeriodRecordsTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $PeriodRecordsTable.$converterendDaten.toSql(endDate),
      );
    }
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PeriodRecordsCompanion toCompanion(bool nullToAbsent) {
    return PeriodRecordsCompanion(
      id: Value(id),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: Value(status),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PeriodRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodRecord(
      id: serializer.fromJson<String>(json['id']),
      startDate: serializer.fromJson<CalendarDate>(json['startDate']),
      endDate: serializer.fromJson<CalendarDate?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startDate': serializer.toJson<CalendarDate>(startDate),
      'endDate': serializer.toJson<CalendarDate?>(endDate),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PeriodRecord copyWith({
    String? id,
    CalendarDate? startDate,
    Value<CalendarDate?> endDate = const Value.absent(),
    String? status,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PeriodRecord(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    status: status ?? this.status,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PeriodRecord copyWithCompanion(PeriodRecordsCompanion data) {
    return PeriodRecord(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodRecord(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startDate, endDate, status, source, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodRecord &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PeriodRecordsCompanion extends UpdateCompanion<PeriodRecord> {
  final Value<String> id;
  final Value<CalendarDate> startDate;
  final Value<CalendarDate?> endDate;
  final Value<String> status;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PeriodRecordsCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeriodRecordsCompanion.insert({
    required String id,
    required CalendarDate startDate,
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PeriodRecord> custom({
    Expression<String>? id,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? status,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeriodRecordsCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? startDate,
    Value<CalendarDate?>? endDate,
    Value<String>? status,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PeriodRecordsCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $PeriodRecordsTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $PeriodRecordsTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodRecordsCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($DailyLogsTable.$converterlocalDate);
  static const VerificationMeta _flowLevelMeta = const VerificationMeta(
    'flowLevel',
  );
  @override
  late final GeneratedColumn<String> flowLevel = GeneratedColumn<String>(
    'flow_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painLevelMeta = const VerificationMeta(
    'painLevel',
  );
  @override
  late final GeneratedColumn<int> painLevel = GeneratedColumn<int>(
    'pain_level',
    aliasedName,
    true,
    check: () => ComparableExpr(painLevel).isBetweenValues(0, 3),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodNoteMeta = const VerificationMeta(
    'moodNote',
  );
  @override
  late final GeneratedColumn<String> moodNote = GeneratedColumn<String>(
    'mood_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cervicalMucusMeta = const VerificationMeta(
    'cervicalMucus',
  );
  @override
  late final GeneratedColumn<String> cervicalMucus = GeneratedColumn<String>(
    'cervical_mucus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    true,
    check: () => ComparableExpr(sleepQuality).isBetweenValues(0, 3),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ovulationTestMeta = const VerificationMeta(
    'ovulationTest',
  );
  @override
  late final GeneratedColumn<String> ovulationTest = GeneratedColumn<String>(
    'ovulation_test',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexualActivityMeta = const VerificationMeta(
    'sexualActivity',
  );
  @override
  late final GeneratedColumn<bool> sexualActivity = GeneratedColumn<bool>(
    'sexual_activity',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sexual_activity" IN (0, 1))',
    ),
  );
  static const VerificationMeta _protectionMeta = const VerificationMeta(
    'protection',
  );
  @override
  late final GeneratedColumn<String> protection = GeneratedColumn<String>(
    'protection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localDate,
    flowLevel,
    painLevel,
    notes,
    moodNote,
    cervicalMucus,
    weightKg,
    sleepHours,
    sleepQuality,
    ovulationTest,
    sexualActivity,
    protection,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('flow_level')) {
      context.handle(
        _flowLevelMeta,
        flowLevel.isAcceptableOrUnknown(data['flow_level']!, _flowLevelMeta),
      );
    }
    if (data.containsKey('pain_level')) {
      context.handle(
        _painLevelMeta,
        painLevel.isAcceptableOrUnknown(data['pain_level']!, _painLevelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('mood_note')) {
      context.handle(
        _moodNoteMeta,
        moodNote.isAcceptableOrUnknown(data['mood_note']!, _moodNoteMeta),
      );
    }
    if (data.containsKey('cervical_mucus')) {
      context.handle(
        _cervicalMucusMeta,
        cervicalMucus.isAcceptableOrUnknown(
          data['cervical_mucus']!,
          _cervicalMucusMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('ovulation_test')) {
      context.handle(
        _ovulationTestMeta,
        ovulationTest.isAcceptableOrUnknown(
          data['ovulation_test']!,
          _ovulationTestMeta,
        ),
      );
    }
    if (data.containsKey('sexual_activity')) {
      context.handle(
        _sexualActivityMeta,
        sexualActivity.isAcceptableOrUnknown(
          data['sexual_activity']!,
          _sexualActivityMeta,
        ),
      );
    }
    if (data.containsKey('protection')) {
      context.handle(
        _protectionMeta,
        protection.isAcceptableOrUnknown(data['protection']!, _protectionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDate: $DailyLogsTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      flowLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow_level'],
      ),
      painLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pain_level'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      moodNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_note'],
      ),
      cervicalMucus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cervical_mucus'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
      ),
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_quality'],
      ),
      ovulationTest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ovulation_test'],
      ),
      sexualActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sexual_activity'],
      ),
      protection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protection'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterlocalDate =
      const CalendarDateConverter();
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final String id;
  final CalendarDate localDate;
  final String? flowLevel;
  final int? painLevel;
  final String? notes;
  final String? moodNote;
  final String? cervicalMucus;
  final double? weightKg;
  final double? sleepHours;
  final int? sleepQuality;
  final String? ovulationTest;
  final bool? sexualActivity;
  final String? protection;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyLog({
    required this.id,
    required this.localDate,
    this.flowLevel,
    this.painLevel,
    this.notes,
    this.moodNote,
    this.cervicalMucus,
    this.weightKg,
    this.sleepHours,
    this.sleepQuality,
    this.ovulationTest,
    this.sexualActivity,
    this.protection,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['local_date'] = Variable<String>(
        $DailyLogsTable.$converterlocalDate.toSql(localDate),
      );
    }
    if (!nullToAbsent || flowLevel != null) {
      map['flow_level'] = Variable<String>(flowLevel);
    }
    if (!nullToAbsent || painLevel != null) {
      map['pain_level'] = Variable<int>(painLevel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || moodNote != null) {
      map['mood_note'] = Variable<String>(moodNote);
    }
    if (!nullToAbsent || cervicalMucus != null) {
      map['cervical_mucus'] = Variable<String>(cervicalMucus);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || sleepHours != null) {
      map['sleep_hours'] = Variable<double>(sleepHours);
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<int>(sleepQuality);
    }
    if (!nullToAbsent || ovulationTest != null) {
      map['ovulation_test'] = Variable<String>(ovulationTest);
    }
    if (!nullToAbsent || sexualActivity != null) {
      map['sexual_activity'] = Variable<bool>(sexualActivity);
    }
    if (!nullToAbsent || protection != null) {
      map['protection'] = Variable<String>(protection);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      localDate: Value(localDate),
      flowLevel: flowLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(flowLevel),
      painLevel: painLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(painLevel),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      moodNote: moodNote == null && nullToAbsent
          ? const Value.absent()
          : Value(moodNote),
      cervicalMucus: cervicalMucus == null && nullToAbsent
          ? const Value.absent()
          : Value(cervicalMucus),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      sleepHours: sleepHours == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepHours),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      ovulationTest: ovulationTest == null && nullToAbsent
          ? const Value.absent()
          : Value(ovulationTest),
      sexualActivity: sexualActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(sexualActivity),
      protection: protection == null && nullToAbsent
          ? const Value.absent()
          : Value(protection),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      id: serializer.fromJson<String>(json['id']),
      localDate: serializer.fromJson<CalendarDate>(json['localDate']),
      flowLevel: serializer.fromJson<String?>(json['flowLevel']),
      painLevel: serializer.fromJson<int?>(json['painLevel']),
      notes: serializer.fromJson<String?>(json['notes']),
      moodNote: serializer.fromJson<String?>(json['moodNote']),
      cervicalMucus: serializer.fromJson<String?>(json['cervicalMucus']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      sleepHours: serializer.fromJson<double?>(json['sleepHours']),
      sleepQuality: serializer.fromJson<int?>(json['sleepQuality']),
      ovulationTest: serializer.fromJson<String?>(json['ovulationTest']),
      sexualActivity: serializer.fromJson<bool?>(json['sexualActivity']),
      protection: serializer.fromJson<String?>(json['protection']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localDate': serializer.toJson<CalendarDate>(localDate),
      'flowLevel': serializer.toJson<String?>(flowLevel),
      'painLevel': serializer.toJson<int?>(painLevel),
      'notes': serializer.toJson<String?>(notes),
      'moodNote': serializer.toJson<String?>(moodNote),
      'cervicalMucus': serializer.toJson<String?>(cervicalMucus),
      'weightKg': serializer.toJson<double?>(weightKg),
      'sleepHours': serializer.toJson<double?>(sleepHours),
      'sleepQuality': serializer.toJson<int?>(sleepQuality),
      'ovulationTest': serializer.toJson<String?>(ovulationTest),
      'sexualActivity': serializer.toJson<bool?>(sexualActivity),
      'protection': serializer.toJson<String?>(protection),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyLog copyWith({
    String? id,
    CalendarDate? localDate,
    Value<String?> flowLevel = const Value.absent(),
    Value<int?> painLevel = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> moodNote = const Value.absent(),
    Value<String?> cervicalMucus = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> sleepHours = const Value.absent(),
    Value<int?> sleepQuality = const Value.absent(),
    Value<String?> ovulationTest = const Value.absent(),
    Value<bool?> sexualActivity = const Value.absent(),
    Value<String?> protection = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyLog(
    id: id ?? this.id,
    localDate: localDate ?? this.localDate,
    flowLevel: flowLevel.present ? flowLevel.value : this.flowLevel,
    painLevel: painLevel.present ? painLevel.value : this.painLevel,
    notes: notes.present ? notes.value : this.notes,
    moodNote: moodNote.present ? moodNote.value : this.moodNote,
    cervicalMucus: cervicalMucus.present
        ? cervicalMucus.value
        : this.cervicalMucus,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    sleepHours: sleepHours.present ? sleepHours.value : this.sleepHours,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    ovulationTest: ovulationTest.present
        ? ovulationTest.value
        : this.ovulationTest,
    sexualActivity: sexualActivity.present
        ? sexualActivity.value
        : this.sexualActivity,
    protection: protection.present ? protection.value : this.protection,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyLog copyWithCompanion(DailyLogsCompanion data) {
    return DailyLog(
      id: data.id.present ? data.id.value : this.id,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      flowLevel: data.flowLevel.present ? data.flowLevel.value : this.flowLevel,
      painLevel: data.painLevel.present ? data.painLevel.value : this.painLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
      moodNote: data.moodNote.present ? data.moodNote.value : this.moodNote,
      cervicalMucus: data.cervicalMucus.present
          ? data.cervicalMucus.value
          : this.cervicalMucus,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      sleepHours: data.sleepHours.present
          ? data.sleepHours.value
          : this.sleepHours,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      ovulationTest: data.ovulationTest.present
          ? data.ovulationTest.value
          : this.ovulationTest,
      sexualActivity: data.sexualActivity.present
          ? data.sexualActivity.value
          : this.sexualActivity,
      protection: data.protection.present
          ? data.protection.value
          : this.protection,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('painLevel: $painLevel, ')
          ..write('notes: $notes, ')
          ..write('moodNote: $moodNote, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('weightKg: $weightKg, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('ovulationTest: $ovulationTest, ')
          ..write('sexualActivity: $sexualActivity, ')
          ..write('protection: $protection, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localDate,
    flowLevel,
    painLevel,
    notes,
    moodNote,
    cervicalMucus,
    weightKg,
    sleepHours,
    sleepQuality,
    ovulationTest,
    sexualActivity,
    protection,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.id == this.id &&
          other.localDate == this.localDate &&
          other.flowLevel == this.flowLevel &&
          other.painLevel == this.painLevel &&
          other.notes == this.notes &&
          other.moodNote == this.moodNote &&
          other.cervicalMucus == this.cervicalMucus &&
          other.weightKg == this.weightKg &&
          other.sleepHours == this.sleepHours &&
          other.sleepQuality == this.sleepQuality &&
          other.ovulationTest == this.ovulationTest &&
          other.sexualActivity == this.sexualActivity &&
          other.protection == this.protection &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<String> id;
  final Value<CalendarDate> localDate;
  final Value<String?> flowLevel;
  final Value<int?> painLevel;
  final Value<String?> notes;
  final Value<String?> moodNote;
  final Value<String?> cervicalMucus;
  final Value<double?> weightKg;
  final Value<double?> sleepHours;
  final Value<int?> sleepQuality;
  final Value<String?> ovulationTest;
  final Value<bool?> sexualActivity;
  final Value<String?> protection;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.localDate = const Value.absent(),
    this.flowLevel = const Value.absent(),
    this.painLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.moodNote = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.ovulationTest = const Value.absent(),
    this.sexualActivity = const Value.absent(),
    this.protection = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    required String id,
    required CalendarDate localDate,
    this.flowLevel = const Value.absent(),
    this.painLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.moodNote = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.ovulationTest = const Value.absent(),
    this.sexualActivity = const Value.absent(),
    this.protection = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDate = Value(localDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyLog> custom({
    Expression<String>? id,
    Expression<String>? localDate,
    Expression<String>? flowLevel,
    Expression<int>? painLevel,
    Expression<String>? notes,
    Expression<String>? moodNote,
    Expression<String>? cervicalMucus,
    Expression<double>? weightKg,
    Expression<double>? sleepHours,
    Expression<int>? sleepQuality,
    Expression<String>? ovulationTest,
    Expression<bool>? sexualActivity,
    Expression<String>? protection,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDate != null) 'local_date': localDate,
      if (flowLevel != null) 'flow_level': flowLevel,
      if (painLevel != null) 'pain_level': painLevel,
      if (notes != null) 'notes': notes,
      if (moodNote != null) 'mood_note': moodNote,
      if (cervicalMucus != null) 'cervical_mucus': cervicalMucus,
      if (weightKg != null) 'weight_kg': weightKg,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (ovulationTest != null) 'ovulation_test': ovulationTest,
      if (sexualActivity != null) 'sexual_activity': sexualActivity,
      if (protection != null) 'protection': protection,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLogsCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? localDate,
    Value<String?>? flowLevel,
    Value<int?>? painLevel,
    Value<String?>? notes,
    Value<String?>? moodNote,
    Value<String?>? cervicalMucus,
    Value<double?>? weightKg,
    Value<double?>? sleepHours,
    Value<int?>? sleepQuality,
    Value<String?>? ovulationTest,
    Value<bool?>? sexualActivity,
    Value<String?>? protection,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      flowLevel: flowLevel ?? this.flowLevel,
      painLevel: painLevel ?? this.painLevel,
      notes: notes ?? this.notes,
      moodNote: moodNote ?? this.moodNote,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      weightKg: weightKg ?? this.weightKg,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      ovulationTest: ovulationTest ?? this.ovulationTest,
      sexualActivity: sexualActivity ?? this.sexualActivity,
      protection: protection ?? this.protection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $DailyLogsTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (flowLevel.present) {
      map['flow_level'] = Variable<String>(flowLevel.value);
    }
    if (painLevel.present) {
      map['pain_level'] = Variable<int>(painLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (moodNote.present) {
      map['mood_note'] = Variable<String>(moodNote.value);
    }
    if (cervicalMucus.present) {
      map['cervical_mucus'] = Variable<String>(cervicalMucus.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (ovulationTest.present) {
      map['ovulation_test'] = Variable<String>(ovulationTest.value);
    }
    if (sexualActivity.present) {
      map['sexual_activity'] = Variable<bool>(sexualActivity.value);
    }
    if (protection.present) {
      map['protection'] = Variable<String>(protection.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('painLevel: $painLevel, ')
          ..write('notes: $notes, ')
          ..write('moodNote: $moodNote, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('weightKg: $weightKg, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('ovulationTest: $ovulationTest, ')
          ..write('sexualActivity: $sexualActivity, ')
          ..write('protection: $protection, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyMoodsTable extends DailyMoods
    with TableInfo<$DailyMoodsTable, MoodRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyMoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dailyLogIdMeta = const VerificationMeta(
    'dailyLogId',
  );
  @override
  late final GeneratedColumn<String> dailyLogId = GeneratedColumn<String>(
    'daily_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dailyLogId, mood];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_moods';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('daily_log_id')) {
      context.handle(
        _dailyLogIdMeta,
        dailyLogId.isAcceptableOrUnknown(
          data['daily_log_id']!,
          _dailyLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyLogIdMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dailyLogId, mood};
  @override
  MoodRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRecord(
      dailyLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_log_id'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      )!,
    );
  }

  @override
  $DailyMoodsTable createAlias(String alias) {
    return $DailyMoodsTable(attachedDatabase, alias);
  }
}

class MoodRecord extends DataClass implements Insertable<MoodRecord> {
  final String dailyLogId;
  final String mood;
  const MoodRecord({required this.dailyLogId, required this.mood});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['daily_log_id'] = Variable<String>(dailyLogId);
    map['mood'] = Variable<String>(mood);
    return map;
  }

  DailyMoodsCompanion toCompanion(bool nullToAbsent) {
    return DailyMoodsCompanion(
      dailyLogId: Value(dailyLogId),
      mood: Value(mood),
    );
  }

  factory MoodRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRecord(
      dailyLogId: serializer.fromJson<String>(json['dailyLogId']),
      mood: serializer.fromJson<String>(json['mood']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dailyLogId': serializer.toJson<String>(dailyLogId),
      'mood': serializer.toJson<String>(mood),
    };
  }

  MoodRecord copyWith({String? dailyLogId, String? mood}) => MoodRecord(
    dailyLogId: dailyLogId ?? this.dailyLogId,
    mood: mood ?? this.mood,
  );
  MoodRecord copyWithCompanion(DailyMoodsCompanion data) {
    return MoodRecord(
      dailyLogId: data.dailyLogId.present
          ? data.dailyLogId.value
          : this.dailyLogId,
      mood: data.mood.present ? data.mood.value : this.mood,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRecord(')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('mood: $mood')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dailyLogId, mood);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRecord &&
          other.dailyLogId == this.dailyLogId &&
          other.mood == this.mood);
}

class DailyMoodsCompanion extends UpdateCompanion<MoodRecord> {
  final Value<String> dailyLogId;
  final Value<String> mood;
  final Value<int> rowid;
  const DailyMoodsCompanion({
    this.dailyLogId = const Value.absent(),
    this.mood = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyMoodsCompanion.insert({
    required String dailyLogId,
    required String mood,
    this.rowid = const Value.absent(),
  }) : dailyLogId = Value(dailyLogId),
       mood = Value(mood);
  static Insertable<MoodRecord> custom({
    Expression<String>? dailyLogId,
    Expression<String>? mood,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dailyLogId != null) 'daily_log_id': dailyLogId,
      if (mood != null) 'mood': mood,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyMoodsCompanion copyWith({
    Value<String>? dailyLogId,
    Value<String>? mood,
    Value<int>? rowid,
  }) {
    return DailyMoodsCompanion(
      dailyLogId: dailyLogId ?? this.dailyLogId,
      mood: mood ?? this.mood,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dailyLogId.present) {
      map['daily_log_id'] = Variable<String>(dailyLogId.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyMoodsCompanion(')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('mood: $mood, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SymptomRecordsTable extends SymptomRecords
    with TableInfo<$SymptomRecordsTable, SymptomRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyLogIdMeta = const VerificationMeta(
    'dailyLogId',
  );
  @override
  late final GeneratedColumn<String> dailyLogId = GeneratedColumn<String>(
    'daily_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _symptomTypeMeta = const VerificationMeta(
    'symptomType',
  );
  @override
  late final GeneratedColumn<String> symptomType = GeneratedColumn<String>(
    'symptom_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    false,
    check: () => ComparableExpr(intensity).isBetweenValues(0, 3),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyLogId,
    symptomType,
    intensity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SymptomRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daily_log_id')) {
      context.handle(
        _dailyLogIdMeta,
        dailyLogId.isAcceptableOrUnknown(
          data['daily_log_id']!,
          _dailyLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyLogIdMeta);
    }
    if (data.containsKey('symptom_type')) {
      context.handle(
        _symptomTypeMeta,
        symptomType.isAcceptableOrUnknown(
          data['symptom_type']!,
          _symptomTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_symptomTypeMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dailyLogId, symptomType},
  ];
  @override
  SymptomRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dailyLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_log_id'],
      )!,
      symptomType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptom_type'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
      )!,
    );
  }

  @override
  $SymptomRecordsTable createAlias(String alias) {
    return $SymptomRecordsTable(attachedDatabase, alias);
  }
}

class SymptomRecord extends DataClass implements Insertable<SymptomRecord> {
  final String id;
  final String dailyLogId;

  /// A catalog key such as `cramps`, or `custom:<name>`.
  final String symptomType;
  final int intensity;
  const SymptomRecord({
    required this.id,
    required this.dailyLogId,
    required this.symptomType,
    required this.intensity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['daily_log_id'] = Variable<String>(dailyLogId);
    map['symptom_type'] = Variable<String>(symptomType);
    map['intensity'] = Variable<int>(intensity);
    return map;
  }

  SymptomRecordsCompanion toCompanion(bool nullToAbsent) {
    return SymptomRecordsCompanion(
      id: Value(id),
      dailyLogId: Value(dailyLogId),
      symptomType: Value(symptomType),
      intensity: Value(intensity),
    );
  }

  factory SymptomRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomRecord(
      id: serializer.fromJson<String>(json['id']),
      dailyLogId: serializer.fromJson<String>(json['dailyLogId']),
      symptomType: serializer.fromJson<String>(json['symptomType']),
      intensity: serializer.fromJson<int>(json['intensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dailyLogId': serializer.toJson<String>(dailyLogId),
      'symptomType': serializer.toJson<String>(symptomType),
      'intensity': serializer.toJson<int>(intensity),
    };
  }

  SymptomRecord copyWith({
    String? id,
    String? dailyLogId,
    String? symptomType,
    int? intensity,
  }) => SymptomRecord(
    id: id ?? this.id,
    dailyLogId: dailyLogId ?? this.dailyLogId,
    symptomType: symptomType ?? this.symptomType,
    intensity: intensity ?? this.intensity,
  );
  SymptomRecord copyWithCompanion(SymptomRecordsCompanion data) {
    return SymptomRecord(
      id: data.id.present ? data.id.value : this.id,
      dailyLogId: data.dailyLogId.present
          ? data.dailyLogId.value
          : this.dailyLogId,
      symptomType: data.symptomType.present
          ? data.symptomType.value
          : this.symptomType,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomRecord(')
          ..write('id: $id, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('symptomType: $symptomType, ')
          ..write('intensity: $intensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dailyLogId, symptomType, intensity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomRecord &&
          other.id == this.id &&
          other.dailyLogId == this.dailyLogId &&
          other.symptomType == this.symptomType &&
          other.intensity == this.intensity);
}

class SymptomRecordsCompanion extends UpdateCompanion<SymptomRecord> {
  final Value<String> id;
  final Value<String> dailyLogId;
  final Value<String> symptomType;
  final Value<int> intensity;
  final Value<int> rowid;
  const SymptomRecordsCompanion({
    this.id = const Value.absent(),
    this.dailyLogId = const Value.absent(),
    this.symptomType = const Value.absent(),
    this.intensity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SymptomRecordsCompanion.insert({
    required String id,
    required String dailyLogId,
    required String symptomType,
    required int intensity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dailyLogId = Value(dailyLogId),
       symptomType = Value(symptomType),
       intensity = Value(intensity);
  static Insertable<SymptomRecord> custom({
    Expression<String>? id,
    Expression<String>? dailyLogId,
    Expression<String>? symptomType,
    Expression<int>? intensity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyLogId != null) 'daily_log_id': dailyLogId,
      if (symptomType != null) 'symptom_type': symptomType,
      if (intensity != null) 'intensity': intensity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SymptomRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? dailyLogId,
    Value<String>? symptomType,
    Value<int>? intensity,
    Value<int>? rowid,
  }) {
    return SymptomRecordsCompanion(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      symptomType: symptomType ?? this.symptomType,
      intensity: intensity ?? this.intensity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dailyLogId.present) {
      map['daily_log_id'] = Variable<String>(dailyLogId.value);
    }
    if (symptomType.present) {
      map['symptom_type'] = Variable<String>(symptomType.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomRecordsCompanion(')
          ..write('id: $id, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('symptomType: $symptomType, ')
          ..write('intensity: $intensity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomSymptomsTable extends CustomSymptoms
    with TableInfo<$CustomSymptomsTable, CustomSymptom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomSymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_symptoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomSymptom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CustomSymptom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomSymptom(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CustomSymptomsTable createAlias(String alias) {
    return $CustomSymptomsTable(attachedDatabase, alias);
  }
}

class CustomSymptom extends DataClass implements Insertable<CustomSymptom> {
  final String name;
  const CustomSymptom({required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    return map;
  }

  CustomSymptomsCompanion toCompanion(bool nullToAbsent) {
    return CustomSymptomsCompanion(name: Value(name));
  }

  factory CustomSymptom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomSymptom(name: serializer.fromJson<String>(json['name']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'name': serializer.toJson<String>(name)};
  }

  CustomSymptom copyWith({String? name}) =>
      CustomSymptom(name: name ?? this.name);
  CustomSymptom copyWithCompanion(CustomSymptomsCompanion data) {
    return CustomSymptom(name: data.name.present ? data.name.value : this.name);
  }

  @override
  String toString() {
    return (StringBuffer('CustomSymptom(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomSymptom && other.name == this.name);
}

class CustomSymptomsCompanion extends UpdateCompanion<CustomSymptom> {
  final Value<String> name;
  final Value<int> rowid;
  const CustomSymptomsCompanion({
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomSymptomsCompanion.insert({
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomSymptom> custom({
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomSymptomsCompanion copyWith({Value<String>? name, Value<int>? rowid}) {
    return CustomSymptomsCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomSymptomsCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemperatureRecordsTable extends TemperatureRecords
    with TableInfo<$TemperatureRecordsTable, TemperatureRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemperatureRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>(
        $TemperatureRecordsTable.$converterlocalDate,
      );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _measurementMinutesMeta =
      const VerificationMeta('measurementMinutes');
  @override
  late final GeneratedColumn<int> measurementMinutes = GeneratedColumn<int>(
    'measurement_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localDate,
    temperatureCelsius,
    measurementMinutes,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temperature_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemperatureRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureCelsiusMeta);
    }
    if (data.containsKey('measurement_minutes')) {
      context.handle(
        _measurementMinutesMeta,
        measurementMinutes.isAcceptableOrUnknown(
          data['measurement_minutes']!,
          _measurementMinutesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemperatureRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemperatureRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDate: $TemperatureRecordsTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      )!,
      measurementMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurement_minutes'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TemperatureRecordsTable createAlias(String alias) {
    return $TemperatureRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterlocalDate =
      const CalendarDateConverter();
}

class TemperatureRecord extends DataClass
    implements Insertable<TemperatureRecord> {
  final String id;
  final CalendarDate localDate;
  final double temperatureCelsius;

  /// Minutes after local midnight.
  final int? measurementMinutes;
  final String? notes;
  const TemperatureRecord({
    required this.id,
    required this.localDate,
    required this.temperatureCelsius,
    this.measurementMinutes,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['local_date'] = Variable<String>(
        $TemperatureRecordsTable.$converterlocalDate.toSql(localDate),
      );
    }
    map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    if (!nullToAbsent || measurementMinutes != null) {
      map['measurement_minutes'] = Variable<int>(measurementMinutes);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TemperatureRecordsCompanion toCompanion(bool nullToAbsent) {
    return TemperatureRecordsCompanion(
      id: Value(id),
      localDate: Value(localDate),
      temperatureCelsius: Value(temperatureCelsius),
      measurementMinutes: measurementMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementMinutes),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory TemperatureRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemperatureRecord(
      id: serializer.fromJson<String>(json['id']),
      localDate: serializer.fromJson<CalendarDate>(json['localDate']),
      temperatureCelsius: serializer.fromJson<double>(
        json['temperatureCelsius'],
      ),
      measurementMinutes: serializer.fromJson<int?>(json['measurementMinutes']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localDate': serializer.toJson<CalendarDate>(localDate),
      'temperatureCelsius': serializer.toJson<double>(temperatureCelsius),
      'measurementMinutes': serializer.toJson<int?>(measurementMinutes),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  TemperatureRecord copyWith({
    String? id,
    CalendarDate? localDate,
    double? temperatureCelsius,
    Value<int?> measurementMinutes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => TemperatureRecord(
    id: id ?? this.id,
    localDate: localDate ?? this.localDate,
    temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    measurementMinutes: measurementMinutes.present
        ? measurementMinutes.value
        : this.measurementMinutes,
    notes: notes.present ? notes.value : this.notes,
  );
  TemperatureRecord copyWithCompanion(TemperatureRecordsCompanion data) {
    return TemperatureRecord(
      id: data.id.present ? data.id.value : this.id,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      measurementMinutes: data.measurementMinutes.present
          ? data.measurementMinutes.value
          : this.measurementMinutes,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemperatureRecord(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('measurementMinutes: $measurementMinutes, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localDate, temperatureCelsius, measurementMinutes, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemperatureRecord &&
          other.id == this.id &&
          other.localDate == this.localDate &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.measurementMinutes == this.measurementMinutes &&
          other.notes == this.notes);
}

class TemperatureRecordsCompanion extends UpdateCompanion<TemperatureRecord> {
  final Value<String> id;
  final Value<CalendarDate> localDate;
  final Value<double> temperatureCelsius;
  final Value<int?> measurementMinutes;
  final Value<String?> notes;
  final Value<int> rowid;
  const TemperatureRecordsCompanion({
    this.id = const Value.absent(),
    this.localDate = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.measurementMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemperatureRecordsCompanion.insert({
    required String id,
    required CalendarDate localDate,
    required double temperatureCelsius,
    this.measurementMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDate = Value(localDate),
       temperatureCelsius = Value(temperatureCelsius);
  static Insertable<TemperatureRecord> custom({
    Expression<String>? id,
    Expression<String>? localDate,
    Expression<double>? temperatureCelsius,
    Expression<int>? measurementMinutes,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDate != null) 'local_date': localDate,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (measurementMinutes != null) 'measurement_minutes': measurementMinutes,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemperatureRecordsCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? localDate,
    Value<double>? temperatureCelsius,
    Value<int?>? measurementMinutes,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return TemperatureRecordsCompanion(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      measurementMinutes: measurementMinutes ?? this.measurementMinutes,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $TemperatureRecordsTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (measurementMinutes.present) {
      map['measurement_minutes'] = Variable<int>(measurementMinutes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemperatureRecordsCompanion(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('measurementMinutes: $measurementMinutes, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9 * 60),
  );
  static const VerificationMeta _leadDaysMeta = const VerificationMeta(
    'leadDays',
  );
  @override
  late final GeneratedColumn<int> leadDays = GeneratedColumn<int>(
    'lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    label,
    enabled,
    minutes,
    leadDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('lead_days')) {
      context.handle(
        _leadDaysMeta,
        leadDays.isAcceptableOrUnknown(data['lead_days']!, _leadDaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      leadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_days'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRecord extends DataClass implements Insertable<ReminderRecord> {
  final String id;

  /// `period`, `daily`, `fertile` or `custom`.
  final String type;
  final String? label;
  final bool enabled;
  final int minutes;
  final int leadDays;
  const ReminderRecord({
    required this.id,
    required this.type,
    this.label,
    required this.enabled,
    required this.minutes,
    required this.leadDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['minutes'] = Variable<int>(minutes);
    map['lead_days'] = Variable<int>(leadDays);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      type: Value(type),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      enabled: Value(enabled),
      minutes: Value(minutes),
      leadDays: Value(leadDays),
    );
  }

  factory ReminderRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRecord(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      label: serializer.fromJson<String?>(json['label']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      minutes: serializer.fromJson<int>(json['minutes']),
      leadDays: serializer.fromJson<int>(json['leadDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'label': serializer.toJson<String?>(label),
      'enabled': serializer.toJson<bool>(enabled),
      'minutes': serializer.toJson<int>(minutes),
      'leadDays': serializer.toJson<int>(leadDays),
    };
  }

  ReminderRecord copyWith({
    String? id,
    String? type,
    Value<String?> label = const Value.absent(),
    bool? enabled,
    int? minutes,
    int? leadDays,
  }) => ReminderRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label.present ? label.value : this.label,
    enabled: enabled ?? this.enabled,
    minutes: minutes ?? this.minutes,
    leadDays: leadDays ?? this.leadDays,
  );
  ReminderRecord copyWithCompanion(RemindersCompanion data) {
    return ReminderRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      leadDays: data.leadDays.present ? data.leadDays.value : this.leadDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('enabled: $enabled, ')
          ..write('minutes: $minutes, ')
          ..write('leadDays: $leadDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, label, enabled, minutes, leadDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.label == this.label &&
          other.enabled == this.enabled &&
          other.minutes == this.minutes &&
          other.leadDays == this.leadDays);
}

class RemindersCompanion extends UpdateCompanion<ReminderRecord> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> label;
  final Value<bool> enabled;
  final Value<int> minutes;
  final Value<int> leadDays;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.enabled = const Value.absent(),
    this.minutes = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String type,
    this.label = const Value.absent(),
    this.enabled = const Value.absent(),
    this.minutes = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type);
  static Insertable<ReminderRecord> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? label,
    Expression<bool>? enabled,
    Expression<int>? minutes,
    Expression<int>? leadDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (enabled != null) 'enabled': enabled,
      if (minutes != null) 'minutes': minutes,
      if (leadDays != null) 'lead_days': leadDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? label,
    Value<bool>? enabled,
    Value<int>? minutes,
    Value<int>? leadDays,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      minutes: minutes ?? this.minutes,
      leadDays: leadDays ?? this.leadDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (leadDays.present) {
      map['lead_days'] = Variable<int>(leadDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('enabled: $enabled, ')
          ..write('minutes: $minutes, ')
          ..write('leadDays: $leadDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, MedicationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> anchorDate =
      GeneratedColumn<String>(
        'anchor_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($MedicationsTable.$converteranchorDate);
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    scheduleType,
    weekdays,
    intervalDays,
    anchorDate,
    enabled,
    minutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays'],
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      anchorDate: $MedicationsTable.$converteranchorDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor_date'],
        )!,
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converteranchorDate =
      const CalendarDateConverter();
}

class MedicationRecord extends DataClass
    implements Insertable<MedicationRecord> {
  final String id;

  /// Optional by design: a schedule can exist without naming the medication.
  final String? name;

  /// `daily`, `weekly` or `interval`.
  final String scheduleType;

  /// Comma-separated ISO weekdays for weekly schedules.
  final String? weekdays;
  final int? intervalDays;
  final CalendarDate anchorDate;
  final bool enabled;
  final int minutes;
  final DateTime createdAt;
  const MedicationRecord({
    required this.id,
    this.name,
    required this.scheduleType,
    this.weekdays,
    this.intervalDays,
    required this.anchorDate,
    required this.enabled,
    required this.minutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || weekdays != null) {
      map['weekdays'] = Variable<String>(weekdays);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    {
      map['anchor_date'] = Variable<String>(
        $MedicationsTable.$converteranchorDate.toSql(anchorDate),
      );
    }
    map['enabled'] = Variable<bool>(enabled);
    map['minutes'] = Variable<int>(minutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      scheduleType: Value(scheduleType),
      weekdays: weekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdays),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      anchorDate: Value(anchorDate),
      enabled: Value(enabled),
      minutes: Value(minutes),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      weekdays: serializer.fromJson<String?>(json['weekdays']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      anchorDate: serializer.fromJson<CalendarDate>(json['anchorDate']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      minutes: serializer.fromJson<int>(json['minutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'weekdays': serializer.toJson<String?>(weekdays),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'anchorDate': serializer.toJson<CalendarDate>(anchorDate),
      'enabled': serializer.toJson<bool>(enabled),
      'minutes': serializer.toJson<int>(minutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationRecord copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    String? scheduleType,
    Value<String?> weekdays = const Value.absent(),
    Value<int?> intervalDays = const Value.absent(),
    CalendarDate? anchorDate,
    bool? enabled,
    int? minutes,
    DateTime? createdAt,
  }) => MedicationRecord(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    scheduleType: scheduleType ?? this.scheduleType,
    weekdays: weekdays.present ? weekdays.value : this.weekdays,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    anchorDate: anchorDate ?? this.anchorDate,
    enabled: enabled ?? this.enabled,
    minutes: minutes ?? this.minutes,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationRecord copyWithCompanion(MedicationsCompanion data) {
    return MedicationRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('weekdays: $weekdays, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('enabled: $enabled, ')
          ..write('minutes: $minutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    scheduleType,
    weekdays,
    intervalDays,
    anchorDate,
    enabled,
    minutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.scheduleType == this.scheduleType &&
          other.weekdays == this.weekdays &&
          other.intervalDays == this.intervalDays &&
          other.anchorDate == this.anchorDate &&
          other.enabled == this.enabled &&
          other.minutes == this.minutes &&
          other.createdAt == this.createdAt);
}

class MedicationsCompanion extends UpdateCompanion<MedicationRecord> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String> scheduleType;
  final Value<String?> weekdays;
  final Value<int?> intervalDays;
  final Value<CalendarDate> anchorDate;
  final Value<bool> enabled;
  final Value<int> minutes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.minutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required String scheduleType,
    this.weekdays = const Value.absent(),
    this.intervalDays = const Value.absent(),
    required CalendarDate anchorDate,
    this.enabled = const Value.absent(),
    required int minutes,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduleType = Value(scheduleType),
       anchorDate = Value(anchorDate),
       minutes = Value(minutes),
       createdAt = Value(createdAt);
  static Insertable<MedicationRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? scheduleType,
    Expression<String>? weekdays,
    Expression<int>? intervalDays,
    Expression<String>? anchorDate,
    Expression<bool>? enabled,
    Expression<int>? minutes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (weekdays != null) 'weekdays': weekdays,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (enabled != null) 'enabled': enabled,
      if (minutes != null) 'minutes': minutes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String>? scheduleType,
    Value<String?>? weekdays,
    Value<int?>? intervalDays,
    Value<CalendarDate>? anchorDate,
    Value<bool>? enabled,
    Value<int>? minutes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduleType: scheduleType ?? this.scheduleType,
      weekdays: weekdays ?? this.weekdays,
      intervalDays: intervalDays ?? this.intervalDays,
      anchorDate: anchorDate ?? this.anchorDate,
      enabled: enabled ?? this.enabled,
      minutes: minutes ?? this.minutes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<String>(
        $MedicationsTable.$converteranchorDate.toSql(anchorDate.value),
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('weekdays: $weekdays, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('enabled: $enabled, ')
          ..write('minutes: $minutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationLogsTable extends MedicationLogs
    with TableInfo<$MedicationLogsTable, MedicationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> localDate =
      GeneratedColumn<String>(
        'local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($MedicationLogsTable.$converterlocalDate);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    medicationId,
    localDate,
    status,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {medicationId, localDate};
  @override
  MedicationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationLog(
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      localDate: $MedicationLogsTable.$converterlocalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_date'],
        )!,
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $MedicationLogsTable createAlias(String alias) {
    return $MedicationLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterlocalDate =
      const CalendarDateConverter();
}

class MedicationLog extends DataClass implements Insertable<MedicationLog> {
  final String medicationId;
  final CalendarDate localDate;

  /// `taken` or `skipped`.
  final String status;
  final DateTime recordedAt;
  const MedicationLog({
    required this.medicationId,
    required this.localDate,
    required this.status,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medication_id'] = Variable<String>(medicationId);
    {
      map['local_date'] = Variable<String>(
        $MedicationLogsTable.$converterlocalDate.toSql(localDate),
      );
    }
    map['status'] = Variable<String>(status);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  MedicationLogsCompanion toCompanion(bool nullToAbsent) {
    return MedicationLogsCompanion(
      medicationId: Value(medicationId),
      localDate: Value(localDate),
      status: Value(status),
      recordedAt: Value(recordedAt),
    );
  }

  factory MedicationLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationLog(
      medicationId: serializer.fromJson<String>(json['medicationId']),
      localDate: serializer.fromJson<CalendarDate>(json['localDate']),
      status: serializer.fromJson<String>(json['status']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicationId': serializer.toJson<String>(medicationId),
      'localDate': serializer.toJson<CalendarDate>(localDate),
      'status': serializer.toJson<String>(status),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  MedicationLog copyWith({
    String? medicationId,
    CalendarDate? localDate,
    String? status,
    DateTime? recordedAt,
  }) => MedicationLog(
    medicationId: medicationId ?? this.medicationId,
    localDate: localDate ?? this.localDate,
    status: status ?? this.status,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  MedicationLog copyWithCompanion(MedicationLogsCompanion data) {
    return MedicationLog(
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      status: data.status.present ? data.status.value : this.status,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLog(')
          ..write('medicationId: $medicationId, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(medicationId, localDate, status, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationLog &&
          other.medicationId == this.medicationId &&
          other.localDate == this.localDate &&
          other.status == this.status &&
          other.recordedAt == this.recordedAt);
}

class MedicationLogsCompanion extends UpdateCompanion<MedicationLog> {
  final Value<String> medicationId;
  final Value<CalendarDate> localDate;
  final Value<String> status;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const MedicationLogsCompanion({
    this.medicationId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.status = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationLogsCompanion.insert({
    required String medicationId,
    required CalendarDate localDate,
    required String status,
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       localDate = Value(localDate),
       status = Value(status),
       recordedAt = Value(recordedAt);
  static Insertable<MedicationLog> custom({
    Expression<String>? medicationId,
    Expression<String>? localDate,
    Expression<String>? status,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicationId != null) 'medication_id': medicationId,
      if (localDate != null) 'local_date': localDate,
      if (status != null) 'status': status,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationLogsCompanion copyWith({
    Value<String>? medicationId,
    Value<CalendarDate>? localDate,
    Value<String>? status,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return MedicationLogsCompanion(
      medicationId: medicationId ?? this.medicationId,
      localDate: localDate ?? this.localDate,
      status: status ?? this.status,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(
        $MedicationLogsTable.$converterlocalDate.toSql(localDate.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLogsCompanion(')
          ..write('medicationId: $medicationId, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CyclePredictionsTable extends CyclePredictions
    with TableInfo<$CyclePredictionsTable, CyclePredictionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclePredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  predictedStartDate =
      GeneratedColumn<String>(
        'predicted_start_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $CyclePredictionsTable.$converterpredictedStartDaten,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  earliestEstimatedDate =
      GeneratedColumn<String>(
        'earliest_estimated_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $CyclePredictionsTable.$converterearliestEstimatedDaten,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  latestEstimatedDate =
      GeneratedColumn<String>(
        'latest_estimated_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $CyclePredictionsTable.$converterlatestEstimatedDaten,
      );
  static const VerificationMeta _confidenceCategoryMeta =
      const VerificationMeta('confidenceCategory');
  @override
  late final GeneratedColumn<String> confidenceCategory =
      GeneratedColumn<String>(
        'confidence_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _historyCountMeta = const VerificationMeta(
    'historyCount',
  );
  @override
  late final GeneratedColumn<int> historyCount = GeneratedColumn<int>(
    'history_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    calculatedAt,
    algorithmVersion,
    predictedStartDate,
    earliestEstimatedDate,
    latestEstimatedDate,
    confidenceCategory,
    historyCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_predictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CyclePredictionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('confidence_category')) {
      context.handle(
        _confidenceCategoryMeta,
        confidenceCategory.isAcceptableOrUnknown(
          data['confidence_category']!,
          _confidenceCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceCategoryMeta);
    }
    if (data.containsKey('history_count')) {
      context.handle(
        _historyCountMeta,
        historyCount.isAcceptableOrUnknown(
          data['history_count']!,
          _historyCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_historyCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclePredictionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclePredictionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      predictedStartDate: $CyclePredictionsTable.$converterpredictedStartDaten
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}predicted_start_date'],
            ),
          ),
      earliestEstimatedDate: $CyclePredictionsTable
          .$converterearliestEstimatedDaten
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}earliest_estimated_date'],
            ),
          ),
      latestEstimatedDate: $CyclePredictionsTable.$converterlatestEstimatedDaten
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}latest_estimated_date'],
            ),
          ),
      confidenceCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_category'],
      )!,
      historyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_count'],
      )!,
    );
  }

  @override
  $CyclePredictionsTable createAlias(String alias) {
    return $CyclePredictionsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterpredictedStartDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $converterpredictedStartDaten =
      NullAwareTypeConverter.wrap($converterpredictedStartDate);
  static TypeConverter<CalendarDate, String> $converterearliestEstimatedDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?>
  $converterearliestEstimatedDaten = NullAwareTypeConverter.wrap(
    $converterearliestEstimatedDate,
  );
  static TypeConverter<CalendarDate, String> $converterlatestEstimatedDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $converterlatestEstimatedDaten =
      NullAwareTypeConverter.wrap($converterlatestEstimatedDate);
}

class CyclePredictionRow extends DataClass
    implements Insertable<CyclePredictionRow> {
  final int id;
  final DateTime calculatedAt;
  final String algorithmVersion;
  final CalendarDate? predictedStartDate;
  final CalendarDate? earliestEstimatedDate;
  final CalendarDate? latestEstimatedDate;
  final String confidenceCategory;
  final int historyCount;
  const CyclePredictionRow({
    required this.id,
    required this.calculatedAt,
    required this.algorithmVersion,
    this.predictedStartDate,
    this.earliestEstimatedDate,
    this.latestEstimatedDate,
    required this.confidenceCategory,
    required this.historyCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    if (!nullToAbsent || predictedStartDate != null) {
      map['predicted_start_date'] = Variable<String>(
        $CyclePredictionsTable.$converterpredictedStartDaten.toSql(
          predictedStartDate,
        ),
      );
    }
    if (!nullToAbsent || earliestEstimatedDate != null) {
      map['earliest_estimated_date'] = Variable<String>(
        $CyclePredictionsTable.$converterearliestEstimatedDaten.toSql(
          earliestEstimatedDate,
        ),
      );
    }
    if (!nullToAbsent || latestEstimatedDate != null) {
      map['latest_estimated_date'] = Variable<String>(
        $CyclePredictionsTable.$converterlatestEstimatedDaten.toSql(
          latestEstimatedDate,
        ),
      );
    }
    map['confidence_category'] = Variable<String>(confidenceCategory);
    map['history_count'] = Variable<int>(historyCount);
    return map;
  }

  CyclePredictionsCompanion toCompanion(bool nullToAbsent) {
    return CyclePredictionsCompanion(
      id: Value(id),
      calculatedAt: Value(calculatedAt),
      algorithmVersion: Value(algorithmVersion),
      predictedStartDate: predictedStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedStartDate),
      earliestEstimatedDate: earliestEstimatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(earliestEstimatedDate),
      latestEstimatedDate: latestEstimatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(latestEstimatedDate),
      confidenceCategory: Value(confidenceCategory),
      historyCount: Value(historyCount),
    );
  }

  factory CyclePredictionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclePredictionRow(
      id: serializer.fromJson<int>(json['id']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      predictedStartDate: serializer.fromJson<CalendarDate?>(
        json['predictedStartDate'],
      ),
      earliestEstimatedDate: serializer.fromJson<CalendarDate?>(
        json['earliestEstimatedDate'],
      ),
      latestEstimatedDate: serializer.fromJson<CalendarDate?>(
        json['latestEstimatedDate'],
      ),
      confidenceCategory: serializer.fromJson<String>(
        json['confidenceCategory'],
      ),
      historyCount: serializer.fromJson<int>(json['historyCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'predictedStartDate': serializer.toJson<CalendarDate?>(
        predictedStartDate,
      ),
      'earliestEstimatedDate': serializer.toJson<CalendarDate?>(
        earliestEstimatedDate,
      ),
      'latestEstimatedDate': serializer.toJson<CalendarDate?>(
        latestEstimatedDate,
      ),
      'confidenceCategory': serializer.toJson<String>(confidenceCategory),
      'historyCount': serializer.toJson<int>(historyCount),
    };
  }

  CyclePredictionRow copyWith({
    int? id,
    DateTime? calculatedAt,
    String? algorithmVersion,
    Value<CalendarDate?> predictedStartDate = const Value.absent(),
    Value<CalendarDate?> earliestEstimatedDate = const Value.absent(),
    Value<CalendarDate?> latestEstimatedDate = const Value.absent(),
    String? confidenceCategory,
    int? historyCount,
  }) => CyclePredictionRow(
    id: id ?? this.id,
    calculatedAt: calculatedAt ?? this.calculatedAt,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    predictedStartDate: predictedStartDate.present
        ? predictedStartDate.value
        : this.predictedStartDate,
    earliestEstimatedDate: earliestEstimatedDate.present
        ? earliestEstimatedDate.value
        : this.earliestEstimatedDate,
    latestEstimatedDate: latestEstimatedDate.present
        ? latestEstimatedDate.value
        : this.latestEstimatedDate,
    confidenceCategory: confidenceCategory ?? this.confidenceCategory,
    historyCount: historyCount ?? this.historyCount,
  );
  CyclePredictionRow copyWithCompanion(CyclePredictionsCompanion data) {
    return CyclePredictionRow(
      id: data.id.present ? data.id.value : this.id,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      predictedStartDate: data.predictedStartDate.present
          ? data.predictedStartDate.value
          : this.predictedStartDate,
      earliestEstimatedDate: data.earliestEstimatedDate.present
          ? data.earliestEstimatedDate.value
          : this.earliestEstimatedDate,
      latestEstimatedDate: data.latestEstimatedDate.present
          ? data.latestEstimatedDate.value
          : this.latestEstimatedDate,
      confidenceCategory: data.confidenceCategory.present
          ? data.confidenceCategory.value
          : this.confidenceCategory,
      historyCount: data.historyCount.present
          ? data.historyCount.value
          : this.historyCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclePredictionRow(')
          ..write('id: $id, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('predictedStartDate: $predictedStartDate, ')
          ..write('earliestEstimatedDate: $earliestEstimatedDate, ')
          ..write('latestEstimatedDate: $latestEstimatedDate, ')
          ..write('confidenceCategory: $confidenceCategory, ')
          ..write('historyCount: $historyCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    calculatedAt,
    algorithmVersion,
    predictedStartDate,
    earliestEstimatedDate,
    latestEstimatedDate,
    confidenceCategory,
    historyCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclePredictionRow &&
          other.id == this.id &&
          other.calculatedAt == this.calculatedAt &&
          other.algorithmVersion == this.algorithmVersion &&
          other.predictedStartDate == this.predictedStartDate &&
          other.earliestEstimatedDate == this.earliestEstimatedDate &&
          other.latestEstimatedDate == this.latestEstimatedDate &&
          other.confidenceCategory == this.confidenceCategory &&
          other.historyCount == this.historyCount);
}

class CyclePredictionsCompanion extends UpdateCompanion<CyclePredictionRow> {
  final Value<int> id;
  final Value<DateTime> calculatedAt;
  final Value<String> algorithmVersion;
  final Value<CalendarDate?> predictedStartDate;
  final Value<CalendarDate?> earliestEstimatedDate;
  final Value<CalendarDate?> latestEstimatedDate;
  final Value<String> confidenceCategory;
  final Value<int> historyCount;
  const CyclePredictionsCompanion({
    this.id = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.predictedStartDate = const Value.absent(),
    this.earliestEstimatedDate = const Value.absent(),
    this.latestEstimatedDate = const Value.absent(),
    this.confidenceCategory = const Value.absent(),
    this.historyCount = const Value.absent(),
  });
  CyclePredictionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime calculatedAt,
    required String algorithmVersion,
    this.predictedStartDate = const Value.absent(),
    this.earliestEstimatedDate = const Value.absent(),
    this.latestEstimatedDate = const Value.absent(),
    required String confidenceCategory,
    required int historyCount,
  }) : calculatedAt = Value(calculatedAt),
       algorithmVersion = Value(algorithmVersion),
       confidenceCategory = Value(confidenceCategory),
       historyCount = Value(historyCount);
  static Insertable<CyclePredictionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? calculatedAt,
    Expression<String>? algorithmVersion,
    Expression<String>? predictedStartDate,
    Expression<String>? earliestEstimatedDate,
    Expression<String>? latestEstimatedDate,
    Expression<String>? confidenceCategory,
    Expression<int>? historyCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (predictedStartDate != null)
        'predicted_start_date': predictedStartDate,
      if (earliestEstimatedDate != null)
        'earliest_estimated_date': earliestEstimatedDate,
      if (latestEstimatedDate != null)
        'latest_estimated_date': latestEstimatedDate,
      if (confidenceCategory != null) 'confidence_category': confidenceCategory,
      if (historyCount != null) 'history_count': historyCount,
    });
  }

  CyclePredictionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? calculatedAt,
    Value<String>? algorithmVersion,
    Value<CalendarDate?>? predictedStartDate,
    Value<CalendarDate?>? earliestEstimatedDate,
    Value<CalendarDate?>? latestEstimatedDate,
    Value<String>? confidenceCategory,
    Value<int>? historyCount,
  }) {
    return CyclePredictionsCompanion(
      id: id ?? this.id,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      earliestEstimatedDate:
          earliestEstimatedDate ?? this.earliestEstimatedDate,
      latestEstimatedDate: latestEstimatedDate ?? this.latestEstimatedDate,
      confidenceCategory: confidenceCategory ?? this.confidenceCategory,
      historyCount: historyCount ?? this.historyCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (predictedStartDate.present) {
      map['predicted_start_date'] = Variable<String>(
        $CyclePredictionsTable.$converterpredictedStartDaten.toSql(
          predictedStartDate.value,
        ),
      );
    }
    if (earliestEstimatedDate.present) {
      map['earliest_estimated_date'] = Variable<String>(
        $CyclePredictionsTable.$converterearliestEstimatedDaten.toSql(
          earliestEstimatedDate.value,
        ),
      );
    }
    if (latestEstimatedDate.present) {
      map['latest_estimated_date'] = Variable<String>(
        $CyclePredictionsTable.$converterlatestEstimatedDaten.toSql(
          latestEstimatedDate.value,
        ),
      );
    }
    if (confidenceCategory.present) {
      map['confidence_category'] = Variable<String>(confidenceCategory.value);
    }
    if (historyCount.present) {
      map['history_count'] = Variable<int>(historyCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclePredictionsCompanion(')
          ..write('id: $id, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('predictedStartDate: $predictedStartDate, ')
          ..write('earliestEstimatedDate: $earliestEstimatedDate, ')
          ..write('latestEstimatedDate: $latestEstimatedDate, ')
          ..write('confidenceCategory: $confidenceCategory, ')
          ..write('historyCount: $historyCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $PeriodRecordsTable periodRecords = $PeriodRecordsTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $DailyMoodsTable dailyMoods = $DailyMoodsTable(this);
  late final $SymptomRecordsTable symptomRecords = $SymptomRecordsTable(this);
  late final $CustomSymptomsTable customSymptoms = $CustomSymptomsTable(this);
  late final $TemperatureRecordsTable temperatureRecords =
      $TemperatureRecordsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $MedicationLogsTable medicationLogs = $MedicationLogsTable(this);
  late final $CyclePredictionsTable cyclePredictions = $CyclePredictionsTable(
    this,
  );
  late final Index idxPeriodStart = Index(
    'idx_period_start',
    'CREATE UNIQUE INDEX idx_period_start ON period_records (start_date)',
  );
  late final Index idxDailyDate = Index(
    'idx_daily_date',
    'CREATE UNIQUE INDEX idx_daily_date ON daily_logs (local_date)',
  );
  late final Index idxSymptomLog = Index(
    'idx_symptom_log',
    'CREATE INDEX idx_symptom_log ON symptom_records (daily_log_id)',
  );
  late final Index idxTemperatureDate = Index(
    'idx_temperature_date',
    'CREATE UNIQUE INDEX idx_temperature_date ON temperature_records (local_date)',
  );
  late final Index idxMedLogDate = Index(
    'idx_med_log_date',
    'CREATE INDEX idx_med_log_date ON medication_logs (local_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userPreferences,
    periodRecords,
    dailyLogs,
    dailyMoods,
    symptomRecords,
    customSymptoms,
    temperatureRecords,
    reminders,
    medications,
    medicationLogs,
    cyclePredictions,
    idxPeriodStart,
    idxDailyDate,
    idxSymptomLog,
    idxTemperatureDate,
    idxMedLogDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'daily_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('daily_moods', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'daily_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('symptom_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medication_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<bool> onboardingCompleted,
      required String settingsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<bool> onboardingCompleted,
      Value<String> settingsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreferencesRow,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreferencesRow,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreferencesRow
            >,
          ),
          UserPreferencesRow,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                onboardingCompleted: onboardingCompleted,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                required String settingsJson,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => UserPreferencesCompanion.insert(
                id: id,
                onboardingCompleted: onboardingCompleted,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreferencesRow,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreferencesRow,
        BaseReferences<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreferencesRow
        >,
      ),
      UserPreferencesRow,
      PrefetchHooks Function()
    >;
typedef $$PeriodRecordsTableCreateCompanionBuilder =
    PeriodRecordsCompanion Function({
      required String id,
      required CalendarDate startDate,
      Value<CalendarDate?> endDate,
      Value<String> status,
      Value<String> source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PeriodRecordsTableUpdateCompanionBuilder =
    PeriodRecordsCompanion Function({
      Value<String> id,
      Value<CalendarDate> startDate,
      Value<CalendarDate?> endDate,
      Value<String> status,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PeriodRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodRecordsTable> {
  $$PeriodRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeriodRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodRecordsTable> {
  $$PeriodRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodRecordsTable> {
  $$PeriodRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PeriodRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodRecordsTable,
          PeriodRecord,
          $$PeriodRecordsTableFilterComposer,
          $$PeriodRecordsTableOrderingComposer,
          $$PeriodRecordsTableAnnotationComposer,
          $$PeriodRecordsTableCreateCompanionBuilder,
          $$PeriodRecordsTableUpdateCompanionBuilder,
          (
            PeriodRecord,
            BaseReferences<_$AppDatabase, $PeriodRecordsTable, PeriodRecord>,
          ),
          PeriodRecord,
          PrefetchHooks Function()
        > {
  $$PeriodRecordsTableTableManager(_$AppDatabase db, $PeriodRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> startDate = const Value.absent(),
                Value<CalendarDate?> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeriodRecordsCompanion(
                id: id,
                startDate: startDate,
                endDate: endDate,
                status: status,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate startDate,
                Value<CalendarDate?> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PeriodRecordsCompanion.insert(
                id: id,
                startDate: startDate,
                endDate: endDate,
                status: status,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeriodRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodRecordsTable,
      PeriodRecord,
      $$PeriodRecordsTableFilterComposer,
      $$PeriodRecordsTableOrderingComposer,
      $$PeriodRecordsTableAnnotationComposer,
      $$PeriodRecordsTableCreateCompanionBuilder,
      $$PeriodRecordsTableUpdateCompanionBuilder,
      (
        PeriodRecord,
        BaseReferences<_$AppDatabase, $PeriodRecordsTable, PeriodRecord>,
      ),
      PeriodRecord,
      PrefetchHooks Function()
    >;
typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      required String id,
      required CalendarDate localDate,
      Value<String?> flowLevel,
      Value<int?> painLevel,
      Value<String?> notes,
      Value<String?> moodNote,
      Value<String?> cervicalMucus,
      Value<double?> weightKg,
      Value<double?> sleepHours,
      Value<int?> sleepQuality,
      Value<String?> ovulationTest,
      Value<bool?> sexualActivity,
      Value<String?> protection,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<String> id,
      Value<CalendarDate> localDate,
      Value<String?> flowLevel,
      Value<int?> painLevel,
      Value<String?> notes,
      Value<String?> moodNote,
      Value<String?> cervicalMucus,
      Value<double?> weightKg,
      Value<double?> sleepHours,
      Value<int?> sleepQuality,
      Value<String?> ovulationTest,
      Value<bool?> sexualActivity,
      Value<String?> protection,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DailyLogsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog> {
  $$DailyLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyMoodsTable, List<MoodRecord>>
  _dailyMoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyMoods,
    aliasName: 'daily_logs__id__daily_moods__daily_log_id',
  );

  $$DailyMoodsTableProcessedTableManager get dailyMoodsRefs {
    final manager = $$DailyMoodsTableTableManager(
      $_db,
      $_db.dailyMoods,
    ).filter((f) => f.dailyLogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyMoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SymptomRecordsTable, List<SymptomRecord>>
  _symptomRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.symptomRecords,
    aliasName: 'daily_logs__id__symptom_records__daily_log_id',
  );

  $$SymptomRecordsTableProcessedTableManager get symptomRecordsRefs {
    final manager = $$SymptomRecordsTableTableManager(
      $_db,
      $_db.symptomRecords,
    ).filter((f) => f.dailyLogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_symptomRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodNote => $composableBuilder(
    column: $table.moodNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ovulationTest => $composableBuilder(
    column: $table.ovulationTest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dailyMoodsRefs(
    Expression<bool> Function($$DailyMoodsTableFilterComposer f) f,
  ) {
    final $$DailyMoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyMoods,
      getReferencedColumn: (t) => t.dailyLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyMoodsTableFilterComposer(
            $db: $db,
            $table: $db.dailyMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> symptomRecordsRefs(
    Expression<bool> Function($$SymptomRecordsTableFilterComposer f) f,
  ) {
    final $$SymptomRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptomRecords,
      getReferencedColumn: (t) => t.dailyLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomRecordsTableFilterComposer(
            $db: $db,
            $table: $db.symptomRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodNote => $composableBuilder(
    column: $table.moodNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ovulationTest => $composableBuilder(
    column: $table.ovulationTest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get flowLevel =>
      $composableBuilder(column: $table.flowLevel, builder: (column) => column);

  GeneratedColumn<int> get painLevel =>
      $composableBuilder(column: $table.painLevel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get moodNote =>
      $composableBuilder(column: $table.moodNote, builder: (column) => column);

  GeneratedColumn<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ovulationTest => $composableBuilder(
    column: $table.ovulationTest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dailyMoodsRefs<T extends Object>(
    Expression<T> Function($$DailyMoodsTableAnnotationComposer a) f,
  ) {
    final $$DailyMoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyMoods,
      getReferencedColumn: (t) => t.dailyLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyMoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> symptomRecordsRefs<T extends Object>(
    Expression<T> Function($$SymptomRecordsTableAnnotationComposer a) f,
  ) {
    final $$SymptomRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptomRecords,
      getReferencedColumn: (t) => t.dailyLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.symptomRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogsTable,
          DailyLog,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (DailyLog, $$DailyLogsTableReferences),
          DailyLog,
          PrefetchHooks Function({bool dailyMoodsRefs, bool symptomRecordsRefs})
        > {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> localDate = const Value.absent(),
                Value<String?> flowLevel = const Value.absent(),
                Value<int?> painLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> moodNote = const Value.absent(),
                Value<String?> cervicalMucus = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<String?> ovulationTest = const Value.absent(),
                Value<bool?> sexualActivity = const Value.absent(),
                Value<String?> protection = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLogsCompanion(
                id: id,
                localDate: localDate,
                flowLevel: flowLevel,
                painLevel: painLevel,
                notes: notes,
                moodNote: moodNote,
                cervicalMucus: cervicalMucus,
                weightKg: weightKg,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                ovulationTest: ovulationTest,
                sexualActivity: sexualActivity,
                protection: protection,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate localDate,
                Value<String?> flowLevel = const Value.absent(),
                Value<int?> painLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> moodNote = const Value.absent(),
                Value<String?> cervicalMucus = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<String?> ovulationTest = const Value.absent(),
                Value<bool?> sexualActivity = const Value.absent(),
                Value<String?> protection = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyLogsCompanion.insert(
                id: id,
                localDate: localDate,
                flowLevel: flowLevel,
                painLevel: painLevel,
                notes: notes,
                moodNote: moodNote,
                cervicalMucus: cervicalMucus,
                weightKg: weightKg,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                ovulationTest: ovulationTest,
                sexualActivity: sexualActivity,
                protection: protection,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dailyMoodsRefs = false, symptomRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dailyMoodsRefs) db.dailyMoods,
                    if (symptomRecordsRefs) db.symptomRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dailyMoodsRefs)
                        await $_getPrefetchedData<
                          DailyLog,
                          $DailyLogsTable,
                          MoodRecord
                        >(
                          currentTable: table,
                          referencedTable: $$DailyLogsTableReferences
                              ._dailyMoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DailyLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyMoodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dailyLogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (symptomRecordsRefs)
                        await $_getPrefetchedData<
                          DailyLog,
                          $DailyLogsTable,
                          SymptomRecord
                        >(
                          currentTable: table,
                          referencedTable: $$DailyLogsTableReferences
                              ._symptomRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DailyLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).symptomRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dailyLogId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogsTable,
      DailyLog,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (DailyLog, $$DailyLogsTableReferences),
      DailyLog,
      PrefetchHooks Function({bool dailyMoodsRefs, bool symptomRecordsRefs})
    >;
typedef $$DailyMoodsTableCreateCompanionBuilder =
    DailyMoodsCompanion Function({
      required String dailyLogId,
      required String mood,
      Value<int> rowid,
    });
typedef $$DailyMoodsTableUpdateCompanionBuilder =
    DailyMoodsCompanion Function({
      Value<String> dailyLogId,
      Value<String> mood,
      Value<int> rowid,
    });

final class $$DailyMoodsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyMoodsTable, MoodRecord> {
  $$DailyMoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DailyLogsTable _dailyLogIdTable(_$AppDatabase db) =>
      db.dailyLogs.createAlias('daily_moods__daily_log_id__daily_logs__id');

  $$DailyLogsTableProcessedTableManager get dailyLogId {
    final $_column = $_itemColumn<String>('daily_log_id')!;

    final manager = $$DailyLogsTableTableManager(
      $_db,
      $_db.dailyLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dailyLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyMoodsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyMoodsTable> {
  $$DailyMoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  $$DailyLogsTableFilterComposer get dailyLogId {
    final $$DailyLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableFilterComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyMoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyMoodsTable> {
  $$DailyMoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  $$DailyLogsTableOrderingComposer get dailyLogId {
    final $$DailyLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableOrderingComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyMoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyMoodsTable> {
  $$DailyMoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  $$DailyLogsTableAnnotationComposer get dailyLogId {
    final $$DailyLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyMoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyMoodsTable,
          MoodRecord,
          $$DailyMoodsTableFilterComposer,
          $$DailyMoodsTableOrderingComposer,
          $$DailyMoodsTableAnnotationComposer,
          $$DailyMoodsTableCreateCompanionBuilder,
          $$DailyMoodsTableUpdateCompanionBuilder,
          (MoodRecord, $$DailyMoodsTableReferences),
          MoodRecord,
          PrefetchHooks Function({bool dailyLogId})
        > {
  $$DailyMoodsTableTableManager(_$AppDatabase db, $DailyMoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyMoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyMoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyMoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dailyLogId = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyMoodsCompanion(
                dailyLogId: dailyLogId,
                mood: mood,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dailyLogId,
                required String mood,
                Value<int> rowid = const Value.absent(),
              }) => DailyMoodsCompanion.insert(
                dailyLogId: dailyLogId,
                mood: mood,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyMoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dailyLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (dailyLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dailyLogId,
                                referencedTable: $$DailyMoodsTableReferences
                                    ._dailyLogIdTable(db),
                                referencedColumn: $$DailyMoodsTableReferences
                                    ._dailyLogIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyMoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyMoodsTable,
      MoodRecord,
      $$DailyMoodsTableFilterComposer,
      $$DailyMoodsTableOrderingComposer,
      $$DailyMoodsTableAnnotationComposer,
      $$DailyMoodsTableCreateCompanionBuilder,
      $$DailyMoodsTableUpdateCompanionBuilder,
      (MoodRecord, $$DailyMoodsTableReferences),
      MoodRecord,
      PrefetchHooks Function({bool dailyLogId})
    >;
typedef $$SymptomRecordsTableCreateCompanionBuilder =
    SymptomRecordsCompanion Function({
      required String id,
      required String dailyLogId,
      required String symptomType,
      required int intensity,
      Value<int> rowid,
    });
typedef $$SymptomRecordsTableUpdateCompanionBuilder =
    SymptomRecordsCompanion Function({
      Value<String> id,
      Value<String> dailyLogId,
      Value<String> symptomType,
      Value<int> intensity,
      Value<int> rowid,
    });

final class $$SymptomRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SymptomRecordsTable, SymptomRecord> {
  $$SymptomRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DailyLogsTable _dailyLogIdTable(_$AppDatabase db) =>
      db.dailyLogs.createAlias('symptom_records__daily_log_id__daily_logs__id');

  $$DailyLogsTableProcessedTableManager get dailyLogId {
    final $_column = $_itemColumn<String>('daily_log_id')!;

    final manager = $$DailyLogsTableTableManager(
      $_db,
      $_db.dailyLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dailyLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SymptomRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  $$DailyLogsTableFilterComposer get dailyLogId {
    final $$DailyLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableFilterComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  $$DailyLogsTableOrderingComposer get dailyLogId {
    final $$DailyLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableOrderingComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  $$DailyLogsTableAnnotationComposer get dailyLogId {
    final $$DailyLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyLogId,
      referencedTable: $db.dailyLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomRecordsTable,
          SymptomRecord,
          $$SymptomRecordsTableFilterComposer,
          $$SymptomRecordsTableOrderingComposer,
          $$SymptomRecordsTableAnnotationComposer,
          $$SymptomRecordsTableCreateCompanionBuilder,
          $$SymptomRecordsTableUpdateCompanionBuilder,
          (SymptomRecord, $$SymptomRecordsTableReferences),
          SymptomRecord,
          PrefetchHooks Function({bool dailyLogId})
        > {
  $$SymptomRecordsTableTableManager(
    _$AppDatabase db,
    $SymptomRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dailyLogId = const Value.absent(),
                Value<String> symptomType = const Value.absent(),
                Value<int> intensity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SymptomRecordsCompanion(
                id: id,
                dailyLogId: dailyLogId,
                symptomType: symptomType,
                intensity: intensity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dailyLogId,
                required String symptomType,
                required int intensity,
                Value<int> rowid = const Value.absent(),
              }) => SymptomRecordsCompanion.insert(
                id: id,
                dailyLogId: dailyLogId,
                symptomType: symptomType,
                intensity: intensity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SymptomRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dailyLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (dailyLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dailyLogId,
                                referencedTable: $$SymptomRecordsTableReferences
                                    ._dailyLogIdTable(db),
                                referencedColumn:
                                    $$SymptomRecordsTableReferences
                                        ._dailyLogIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SymptomRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomRecordsTable,
      SymptomRecord,
      $$SymptomRecordsTableFilterComposer,
      $$SymptomRecordsTableOrderingComposer,
      $$SymptomRecordsTableAnnotationComposer,
      $$SymptomRecordsTableCreateCompanionBuilder,
      $$SymptomRecordsTableUpdateCompanionBuilder,
      (SymptomRecord, $$SymptomRecordsTableReferences),
      SymptomRecord,
      PrefetchHooks Function({bool dailyLogId})
    >;
typedef $$CustomSymptomsTableCreateCompanionBuilder =
    CustomSymptomsCompanion Function({required String name, Value<int> rowid});
typedef $$CustomSymptomsTableUpdateCompanionBuilder =
    CustomSymptomsCompanion Function({Value<String> name, Value<int> rowid});

class $$CustomSymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomSymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomSymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CustomSymptomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomSymptomsTable,
          CustomSymptom,
          $$CustomSymptomsTableFilterComposer,
          $$CustomSymptomsTableOrderingComposer,
          $$CustomSymptomsTableAnnotationComposer,
          $$CustomSymptomsTableCreateCompanionBuilder,
          $$CustomSymptomsTableUpdateCompanionBuilder,
          (
            CustomSymptom,
            BaseReferences<_$AppDatabase, $CustomSymptomsTable, CustomSymptom>,
          ),
          CustomSymptom,
          PrefetchHooks Function()
        > {
  $$CustomSymptomsTableTableManager(
    _$AppDatabase db,
    $CustomSymptomsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomSymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomSymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomSymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomSymptomsCompanion(name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CustomSymptomsCompanion.insert(name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomSymptomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomSymptomsTable,
      CustomSymptom,
      $$CustomSymptomsTableFilterComposer,
      $$CustomSymptomsTableOrderingComposer,
      $$CustomSymptomsTableAnnotationComposer,
      $$CustomSymptomsTableCreateCompanionBuilder,
      $$CustomSymptomsTableUpdateCompanionBuilder,
      (
        CustomSymptom,
        BaseReferences<_$AppDatabase, $CustomSymptomsTable, CustomSymptom>,
      ),
      CustomSymptom,
      PrefetchHooks Function()
    >;
typedef $$TemperatureRecordsTableCreateCompanionBuilder =
    TemperatureRecordsCompanion Function({
      required String id,
      required CalendarDate localDate,
      required double temperatureCelsius,
      Value<int?> measurementMinutes,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$TemperatureRecordsTableUpdateCompanionBuilder =
    TemperatureRecordsCompanion Function({
      Value<String> id,
      Value<CalendarDate> localDate,
      Value<double> temperatureCelsius,
      Value<int?> measurementMinutes,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$TemperatureRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TemperatureRecordsTable> {
  $$TemperatureRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measurementMinutes => $composableBuilder(
    column: $table.measurementMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemperatureRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemperatureRecordsTable> {
  $$TemperatureRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measurementMinutes => $composableBuilder(
    column: $table.measurementMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemperatureRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemperatureRecordsTable> {
  $$TemperatureRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<int> get measurementMinutes => $composableBuilder(
    column: $table.measurementMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$TemperatureRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemperatureRecordsTable,
          TemperatureRecord,
          $$TemperatureRecordsTableFilterComposer,
          $$TemperatureRecordsTableOrderingComposer,
          $$TemperatureRecordsTableAnnotationComposer,
          $$TemperatureRecordsTableCreateCompanionBuilder,
          $$TemperatureRecordsTableUpdateCompanionBuilder,
          (
            TemperatureRecord,
            BaseReferences<
              _$AppDatabase,
              $TemperatureRecordsTable,
              TemperatureRecord
            >,
          ),
          TemperatureRecord,
          PrefetchHooks Function()
        > {
  $$TemperatureRecordsTableTableManager(
    _$AppDatabase db,
    $TemperatureRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemperatureRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemperatureRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemperatureRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> localDate = const Value.absent(),
                Value<double> temperatureCelsius = const Value.absent(),
                Value<int?> measurementMinutes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemperatureRecordsCompanion(
                id: id,
                localDate: localDate,
                temperatureCelsius: temperatureCelsius,
                measurementMinutes: measurementMinutes,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate localDate,
                required double temperatureCelsius,
                Value<int?> measurementMinutes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemperatureRecordsCompanion.insert(
                id: id,
                localDate: localDate,
                temperatureCelsius: temperatureCelsius,
                measurementMinutes: measurementMinutes,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemperatureRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemperatureRecordsTable,
      TemperatureRecord,
      $$TemperatureRecordsTableFilterComposer,
      $$TemperatureRecordsTableOrderingComposer,
      $$TemperatureRecordsTableAnnotationComposer,
      $$TemperatureRecordsTableCreateCompanionBuilder,
      $$TemperatureRecordsTableUpdateCompanionBuilder,
      (
        TemperatureRecord,
        BaseReferences<
          _$AppDatabase,
          $TemperatureRecordsTable,
          TemperatureRecord
        >,
      ),
      TemperatureRecord,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String type,
      Value<String?> label,
      Value<bool> enabled,
      Value<int> minutes,
      Value<int> leadDays,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> label,
      Value<bool> enabled,
      Value<int> minutes,
      Value<int> leadDays,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadDays => $composableBuilder(
    column: $table.leadDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadDays => $composableBuilder(
    column: $table.leadDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get leadDays =>
      $composableBuilder(column: $table.leadDays, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRecord,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRecord,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRecord>,
          ),
          ReminderRecord,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> leadDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                type: type,
                label: label,
                enabled: enabled,
                minutes: minutes,
                leadDays: leadDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> label = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> leadDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                type: type,
                label: label,
                enabled: enabled,
                minutes: minutes,
                leadDays: leadDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRecord,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRecord,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRecord>,
      ),
      ReminderRecord,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      Value<String?> name,
      required String scheduleType,
      Value<String?> weekdays,
      Value<int?> intervalDays,
      required CalendarDate anchorDate,
      Value<bool> enabled,
      required int minutes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String> scheduleType,
      Value<String?> weekdays,
      Value<int?> intervalDays,
      Value<CalendarDate> anchorDate,
      Value<bool> enabled,
      Value<int> minutes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, MedicationRecord> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationLogsTable, List<MedicationLog>>
  _medicationLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationLogs,
    aliasName: 'medications__id__medication_logs__medication_id',
  );

  $$MedicationLogsTableProcessedTableManager get medicationLogsRefs {
    final manager = $$MedicationLogsTableTableManager(
      $_db,
      $_db.medicationLogs,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationLogsRefs(
    Expression<bool> Function($$MedicationLogsTableFilterComposer f) f,
  ) {
    final $$MedicationLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableFilterComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate, String> get anchorDate =>
      $composableBuilder(
        column: $table.anchorDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> medicationLogsRefs<T extends Object>(
    Expression<T> Function($$MedicationLogsTableAnnotationComposer a) f,
  ) {
    final $$MedicationLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          MedicationRecord,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (MedicationRecord, $$MedicationsTableReferences),
          MedicationRecord,
          PrefetchHooks Function({bool medicationLogsRefs})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String?> weekdays = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<CalendarDate> anchorDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                scheduleType: scheduleType,
                weekdays: weekdays,
                intervalDays: intervalDays,
                anchorDate: anchorDate,
                enabled: enabled,
                minutes: minutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                required String scheduleType,
                Value<String?> weekdays = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                required CalendarDate anchorDate,
                Value<bool> enabled = const Value.absent(),
                required int minutes,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                scheduleType: scheduleType,
                weekdays: weekdays,
                intervalDays: intervalDays,
                anchorDate: anchorDate,
                enabled: enabled,
                minutes: minutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationLogsRefs) db.medicationLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationLogsRefs)
                    await $_getPrefetchedData<
                      MedicationRecord,
                      $MedicationsTable,
                      MedicationLog
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._medicationLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicationsTableReferences(
                            db,
                            table,
                            p0,
                          ).medicationLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.medicationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      MedicationRecord,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (MedicationRecord, $$MedicationsTableReferences),
      MedicationRecord,
      PrefetchHooks Function({bool medicationLogsRefs})
    >;
typedef $$MedicationLogsTableCreateCompanionBuilder =
    MedicationLogsCompanion Function({
      required String medicationId,
      required CalendarDate localDate,
      required String status,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$MedicationLogsTableUpdateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<String> medicationId,
      Value<CalendarDate> localDate,
      Value<String> status,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

final class $$MedicationLogsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationLogsTable, MedicationLog> {
  $$MedicationLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_logs__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<CalendarDate, String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationLogsTable,
          MedicationLog,
          $$MedicationLogsTableFilterComposer,
          $$MedicationLogsTableOrderingComposer,
          $$MedicationLogsTableAnnotationComposer,
          $$MedicationLogsTableCreateCompanionBuilder,
          $$MedicationLogsTableUpdateCompanionBuilder,
          (MedicationLog, $$MedicationLogsTableReferences),
          MedicationLog,
          PrefetchHooks Function({bool medicationId})
        > {
  $$MedicationLogsTableTableManager(
    _$AppDatabase db,
    $MedicationLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> medicationId = const Value.absent(),
                Value<CalendarDate> localDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationLogsCompanion(
                medicationId: medicationId,
                localDate: localDate,
                status: status,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String medicationId,
                required CalendarDate localDate,
                required String status,
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicationLogsCompanion.insert(
                medicationId: medicationId,
                localDate: localDate,
                status: status,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$MedicationLogsTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn:
                                    $$MedicationLogsTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationLogsTable,
      MedicationLog,
      $$MedicationLogsTableFilterComposer,
      $$MedicationLogsTableOrderingComposer,
      $$MedicationLogsTableAnnotationComposer,
      $$MedicationLogsTableCreateCompanionBuilder,
      $$MedicationLogsTableUpdateCompanionBuilder,
      (MedicationLog, $$MedicationLogsTableReferences),
      MedicationLog,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$CyclePredictionsTableCreateCompanionBuilder =
    CyclePredictionsCompanion Function({
      Value<int> id,
      required DateTime calculatedAt,
      required String algorithmVersion,
      Value<CalendarDate?> predictedStartDate,
      Value<CalendarDate?> earliestEstimatedDate,
      Value<CalendarDate?> latestEstimatedDate,
      required String confidenceCategory,
      required int historyCount,
    });
typedef $$CyclePredictionsTableUpdateCompanionBuilder =
    CyclePredictionsCompanion Function({
      Value<int> id,
      Value<DateTime> calculatedAt,
      Value<String> algorithmVersion,
      Value<CalendarDate?> predictedStartDate,
      Value<CalendarDate?> earliestEstimatedDate,
      Value<CalendarDate?> latestEstimatedDate,
      Value<String> confidenceCategory,
      Value<int> historyCount,
    });

class $$CyclePredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get predictedStartDate => $composableBuilder(
    column: $table.predictedStartDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get earliestEstimatedDate => $composableBuilder(
    column: $table.earliestEstimatedDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get latestEstimatedDate => $composableBuilder(
    column: $table.latestEstimatedDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get confidenceCategory => $composableBuilder(
    column: $table.confidenceCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyCount => $composableBuilder(
    column: $table.historyCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CyclePredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictedStartDate => $composableBuilder(
    column: $table.predictedStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earliestEstimatedDate => $composableBuilder(
    column: $table.earliestEstimatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestEstimatedDate => $composableBuilder(
    column: $table.latestEstimatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceCategory => $composableBuilder(
    column: $table.confidenceCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyCount => $composableBuilder(
    column: $table.historyCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CyclePredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate?, String>
  get predictedStartDate => $composableBuilder(
    column: $table.predictedStartDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate?, String>
  get earliestEstimatedDate => $composableBuilder(
    column: $table.earliestEstimatedDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate?, String>
  get latestEstimatedDate => $composableBuilder(
    column: $table.latestEstimatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceCategory => $composableBuilder(
    column: $table.confidenceCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get historyCount => $composableBuilder(
    column: $table.historyCount,
    builder: (column) => column,
  );
}

class $$CyclePredictionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CyclePredictionsTable,
          CyclePredictionRow,
          $$CyclePredictionsTableFilterComposer,
          $$CyclePredictionsTableOrderingComposer,
          $$CyclePredictionsTableAnnotationComposer,
          $$CyclePredictionsTableCreateCompanionBuilder,
          $$CyclePredictionsTableUpdateCompanionBuilder,
          (
            CyclePredictionRow,
            BaseReferences<
              _$AppDatabase,
              $CyclePredictionsTable,
              CyclePredictionRow
            >,
          ),
          CyclePredictionRow,
          PrefetchHooks Function()
        > {
  $$CyclePredictionsTableTableManager(
    _$AppDatabase db,
    $CyclePredictionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclePredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclePredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclePredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<CalendarDate?> predictedStartDate = const Value.absent(),
                Value<CalendarDate?> earliestEstimatedDate =
                    const Value.absent(),
                Value<CalendarDate?> latestEstimatedDate = const Value.absent(),
                Value<String> confidenceCategory = const Value.absent(),
                Value<int> historyCount = const Value.absent(),
              }) => CyclePredictionsCompanion(
                id: id,
                calculatedAt: calculatedAt,
                algorithmVersion: algorithmVersion,
                predictedStartDate: predictedStartDate,
                earliestEstimatedDate: earliestEstimatedDate,
                latestEstimatedDate: latestEstimatedDate,
                confidenceCategory: confidenceCategory,
                historyCount: historyCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime calculatedAt,
                required String algorithmVersion,
                Value<CalendarDate?> predictedStartDate = const Value.absent(),
                Value<CalendarDate?> earliestEstimatedDate =
                    const Value.absent(),
                Value<CalendarDate?> latestEstimatedDate = const Value.absent(),
                required String confidenceCategory,
                required int historyCount,
              }) => CyclePredictionsCompanion.insert(
                id: id,
                calculatedAt: calculatedAt,
                algorithmVersion: algorithmVersion,
                predictedStartDate: predictedStartDate,
                earliestEstimatedDate: earliestEstimatedDate,
                latestEstimatedDate: latestEstimatedDate,
                confidenceCategory: confidenceCategory,
                historyCount: historyCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CyclePredictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CyclePredictionsTable,
      CyclePredictionRow,
      $$CyclePredictionsTableFilterComposer,
      $$CyclePredictionsTableOrderingComposer,
      $$CyclePredictionsTableAnnotationComposer,
      $$CyclePredictionsTableCreateCompanionBuilder,
      $$CyclePredictionsTableUpdateCompanionBuilder,
      (
        CyclePredictionRow,
        BaseReferences<
          _$AppDatabase,
          $CyclePredictionsTable,
          CyclePredictionRow
        >,
      ),
      CyclePredictionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$PeriodRecordsTableTableManager get periodRecords =>
      $$PeriodRecordsTableTableManager(_db, _db.periodRecords);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$DailyMoodsTableTableManager get dailyMoods =>
      $$DailyMoodsTableTableManager(_db, _db.dailyMoods);
  $$SymptomRecordsTableTableManager get symptomRecords =>
      $$SymptomRecordsTableTableManager(_db, _db.symptomRecords);
  $$CustomSymptomsTableTableManager get customSymptoms =>
      $$CustomSymptomsTableTableManager(_db, _db.customSymptoms);
  $$TemperatureRecordsTableTableManager get temperatureRecords =>
      $$TemperatureRecordsTableTableManager(_db, _db.temperatureRecords);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$MedicationLogsTableTableManager get medicationLogs =>
      $$MedicationLogsTableTableManager(_db, _db.medicationLogs);
  $$CyclePredictionsTableTableManager get cyclePredictions =>
      $$CyclePredictionsTableTableManager(_db, _db.cyclePredictions);
}
