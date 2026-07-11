// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CycleProfilesTable extends CycleProfiles
    with TableInfo<$CycleProfilesTable, CycleProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cycleLengthMeta = const VerificationMeta(
    'cycleLength',
  );
  @override
  late final GeneratedColumn<int> cycleLength = GeneratedColumn<int>(
    'cycle_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttcStatusMeta = const VerificationMeta(
    'ttcStatus',
  );
  @override
  late final GeneratedColumn<String> ttcStatus = GeneratedColumn<String>(
    'ttc_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttcMethodMeta = const VerificationMeta(
    'ttcMethod',
  );
  @override
  late final GeneratedColumn<String> ttcMethod = GeneratedColumn<String>(
    'ttc_method',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleLength,
    startDate,
    ttcStatus,
    ttcMethod,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_length')) {
      context.handle(
        _cycleLengthMeta,
        cycleLength.isAcceptableOrUnknown(
          data['cycle_length']!,
          _cycleLengthMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('ttc_status')) {
      context.handle(
        _ttcStatusMeta,
        ttcStatus.isAcceptableOrUnknown(data['ttc_status']!, _ttcStatusMeta),
      );
    }
    if (data.containsKey('ttc_method')) {
      context.handle(
        _ttcMethodMeta,
        ttcMethod.isAcceptableOrUnknown(data['ttc_method']!, _ttcMethodMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      ttcStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ttc_status'],
      ),
      ttcMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ttc_method'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CycleProfilesTable createAlias(String alias) {
    return $CycleProfilesTable(attachedDatabase, alias);
  }
}

class CycleProfile extends DataClass implements Insertable<CycleProfile> {
  final int id;
  final int cycleLength;
  final DateTime startDate;
  final String? ttcStatus;
  final String? ttcMethod;
  final DateTime createdAt;
  const CycleProfile({
    required this.id,
    required this.cycleLength,
    required this.startDate,
    this.ttcStatus,
    this.ttcMethod,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_length'] = Variable<int>(cycleLength);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || ttcStatus != null) {
      map['ttc_status'] = Variable<String>(ttcStatus);
    }
    if (!nullToAbsent || ttcMethod != null) {
      map['ttc_method'] = Variable<String>(ttcMethod);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CycleProfilesCompanion toCompanion(bool nullToAbsent) {
    return CycleProfilesCompanion(
      id: Value(id),
      cycleLength: Value(cycleLength),
      startDate: Value(startDate),
      ttcStatus: ttcStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(ttcStatus),
      ttcMethod: ttcMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(ttcMethod),
      createdAt: Value(createdAt),
    );
  }

  factory CycleProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleProfile(
      id: serializer.fromJson<int>(json['id']),
      cycleLength: serializer.fromJson<int>(json['cycleLength']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      ttcStatus: serializer.fromJson<String?>(json['ttcStatus']),
      ttcMethod: serializer.fromJson<String?>(json['ttcMethod']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleLength': serializer.toJson<int>(cycleLength),
      'startDate': serializer.toJson<DateTime>(startDate),
      'ttcStatus': serializer.toJson<String?>(ttcStatus),
      'ttcMethod': serializer.toJson<String?>(ttcMethod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CycleProfile copyWith({
    int? id,
    int? cycleLength,
    DateTime? startDate,
    Value<String?> ttcStatus = const Value.absent(),
    Value<String?> ttcMethod = const Value.absent(),
    DateTime? createdAt,
  }) => CycleProfile(
    id: id ?? this.id,
    cycleLength: cycleLength ?? this.cycleLength,
    startDate: startDate ?? this.startDate,
    ttcStatus: ttcStatus.present ? ttcStatus.value : this.ttcStatus,
    ttcMethod: ttcMethod.present ? ttcMethod.value : this.ttcMethod,
    createdAt: createdAt ?? this.createdAt,
  );
  CycleProfile copyWithCompanion(CycleProfilesCompanion data) {
    return CycleProfile(
      id: data.id.present ? data.id.value : this.id,
      cycleLength: data.cycleLength.present
          ? data.cycleLength.value
          : this.cycleLength,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      ttcStatus: data.ttcStatus.present ? data.ttcStatus.value : this.ttcStatus,
      ttcMethod: data.ttcMethod.present ? data.ttcMethod.value : this.ttcMethod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleProfile(')
          ..write('id: $id, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('startDate: $startDate, ')
          ..write('ttcStatus: $ttcStatus, ')
          ..write('ttcMethod: $ttcMethod, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cycleLength, startDate, ttcStatus, ttcMethod, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleProfile &&
          other.id == this.id &&
          other.cycleLength == this.cycleLength &&
          other.startDate == this.startDate &&
          other.ttcStatus == this.ttcStatus &&
          other.ttcMethod == this.ttcMethod &&
          other.createdAt == this.createdAt);
}

class CycleProfilesCompanion extends UpdateCompanion<CycleProfile> {
  final Value<int> id;
  final Value<int> cycleLength;
  final Value<DateTime> startDate;
  final Value<String?> ttcStatus;
  final Value<String?> ttcMethod;
  final Value<DateTime> createdAt;
  const CycleProfilesCompanion({
    this.id = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.startDate = const Value.absent(),
    this.ttcStatus = const Value.absent(),
    this.ttcMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CycleProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.cycleLength = const Value.absent(),
    required DateTime startDate,
    this.ttcStatus = const Value.absent(),
    this.ttcMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : startDate = Value(startDate);
  static Insertable<CycleProfile> custom({
    Expression<int>? id,
    Expression<int>? cycleLength,
    Expression<DateTime>? startDate,
    Expression<String>? ttcStatus,
    Expression<String>? ttcMethod,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleLength != null) 'cycle_length': cycleLength,
      if (startDate != null) 'start_date': startDate,
      if (ttcStatus != null) 'ttc_status': ttcStatus,
      if (ttcMethod != null) 'ttc_method': ttcMethod,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CycleProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleLength,
    Value<DateTime>? startDate,
    Value<String?>? ttcStatus,
    Value<String?>? ttcMethod,
    Value<DateTime>? createdAt,
  }) {
    return CycleProfilesCompanion(
      id: id ?? this.id,
      cycleLength: cycleLength ?? this.cycleLength,
      startDate: startDate ?? this.startDate,
      ttcStatus: ttcStatus ?? this.ttcStatus,
      ttcMethod: ttcMethod ?? this.ttcMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleLength.present) {
      map['cycle_length'] = Variable<int>(cycleLength.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (ttcStatus.present) {
      map['ttc_status'] = Variable<String>(ttcStatus.value);
    }
    if (ttcMethod.present) {
      map['ttc_method'] = Variable<String>(ttcMethod.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleProfilesCompanion(')
          ..write('id: $id, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('startDate: $startDate, ')
          ..write('ttcStatus: $ttcStatus, ')
          ..write('ttcMethod: $ttcMethod, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RitualCompletionsTable extends RitualCompletions
    with TableInfo<$RitualCompletionsTable, RitualCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RitualCompletionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cycleDayMeta = const VerificationMeta(
    'cycleDay',
  );
  @override
  late final GeneratedColumn<int> cycleDay = GeneratedColumn<int>(
    'cycle_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ritualIdMeta = const VerificationMeta(
    'ritualId',
  );
  @override
  late final GeneratedColumn<String> ritualId = GeneratedColumn<String>(
    'ritual_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cycleDay, ritualId, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ritual_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RitualCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_day')) {
      context.handle(
        _cycleDayMeta,
        cycleDay.isAcceptableOrUnknown(data['cycle_day']!, _cycleDayMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleDayMeta);
    }
    if (data.containsKey('ritual_id')) {
      context.handle(
        _ritualIdMeta,
        ritualId.isAcceptableOrUnknown(data['ritual_id']!, _ritualIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ritualIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RitualCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RitualCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_day'],
      )!,
      ritualId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ritual_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $RitualCompletionsTable createAlias(String alias) {
    return $RitualCompletionsTable(attachedDatabase, alias);
  }
}

class RitualCompletion extends DataClass
    implements Insertable<RitualCompletion> {
  final int id;
  final int cycleDay;
  final String ritualId;
  final DateTime completedAt;
  const RitualCompletion({
    required this.id,
    required this.cycleDay,
    required this.ritualId,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_day'] = Variable<int>(cycleDay);
    map['ritual_id'] = Variable<String>(ritualId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  RitualCompletionsCompanion toCompanion(bool nullToAbsent) {
    return RitualCompletionsCompanion(
      id: Value(id),
      cycleDay: Value(cycleDay),
      ritualId: Value(ritualId),
      completedAt: Value(completedAt),
    );
  }

  factory RitualCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RitualCompletion(
      id: serializer.fromJson<int>(json['id']),
      cycleDay: serializer.fromJson<int>(json['cycleDay']),
      ritualId: serializer.fromJson<String>(json['ritualId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleDay': serializer.toJson<int>(cycleDay),
      'ritualId': serializer.toJson<String>(ritualId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  RitualCompletion copyWith({
    int? id,
    int? cycleDay,
    String? ritualId,
    DateTime? completedAt,
  }) => RitualCompletion(
    id: id ?? this.id,
    cycleDay: cycleDay ?? this.cycleDay,
    ritualId: ritualId ?? this.ritualId,
    completedAt: completedAt ?? this.completedAt,
  );
  RitualCompletion copyWithCompanion(RitualCompletionsCompanion data) {
    return RitualCompletion(
      id: data.id.present ? data.id.value : this.id,
      cycleDay: data.cycleDay.present ? data.cycleDay.value : this.cycleDay,
      ritualId: data.ritualId.present ? data.ritualId.value : this.ritualId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RitualCompletion(')
          ..write('id: $id, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('ritualId: $ritualId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleDay, ritualId, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RitualCompletion &&
          other.id == this.id &&
          other.cycleDay == this.cycleDay &&
          other.ritualId == this.ritualId &&
          other.completedAt == this.completedAt);
}

class RitualCompletionsCompanion extends UpdateCompanion<RitualCompletion> {
  final Value<int> id;
  final Value<int> cycleDay;
  final Value<String> ritualId;
  final Value<DateTime> completedAt;
  const RitualCompletionsCompanion({
    this.id = const Value.absent(),
    this.cycleDay = const Value.absent(),
    this.ritualId = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  RitualCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required int cycleDay,
    required String ritualId,
    this.completedAt = const Value.absent(),
  }) : cycleDay = Value(cycleDay),
       ritualId = Value(ritualId);
  static Insertable<RitualCompletion> custom({
    Expression<int>? id,
    Expression<int>? cycleDay,
    Expression<String>? ritualId,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleDay != null) 'cycle_day': cycleDay,
      if (ritualId != null) 'ritual_id': ritualId,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  RitualCompletionsCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleDay,
    Value<String>? ritualId,
    Value<DateTime>? completedAt,
  }) {
    return RitualCompletionsCompanion(
      id: id ?? this.id,
      cycleDay: cycleDay ?? this.cycleDay,
      ritualId: ritualId ?? this.ritualId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleDay.present) {
      map['cycle_day'] = Variable<int>(cycleDay.value);
    }
    if (ritualId.present) {
      map['ritual_id'] = Variable<String>(ritualId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RitualCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('ritualId: $ritualId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $CharmsEarnedTable extends CharmsEarned
    with TableInfo<$CharmsEarnedTable, CharmsEarnedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharmsEarnedTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cycleDayMeta = const VerificationMeta(
    'cycleDay',
  );
  @override
  late final GeneratedColumn<int> cycleDay = GeneratedColumn<int>(
    'cycle_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charmNameMeta = const VerificationMeta(
    'charmName',
  );
  @override
  late final GeneratedColumn<String> charmName = GeneratedColumn<String>(
    'charm_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cycleDay, charmName, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'charms_earned';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharmsEarnedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_day')) {
      context.handle(
        _cycleDayMeta,
        cycleDay.isAcceptableOrUnknown(data['cycle_day']!, _cycleDayMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleDayMeta);
    }
    if (data.containsKey('charm_name')) {
      context.handle(
        _charmNameMeta,
        charmName.isAcceptableOrUnknown(data['charm_name']!, _charmNameMeta),
      );
    } else if (isInserting) {
      context.missing(_charmNameMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharmsEarnedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharmsEarnedData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_day'],
      )!,
      charmName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charm_name'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
    );
  }

  @override
  $CharmsEarnedTable createAlias(String alias) {
    return $CharmsEarnedTable(attachedDatabase, alias);
  }
}

class CharmsEarnedData extends DataClass
    implements Insertable<CharmsEarnedData> {
  final int id;
  final int cycleDay;
  final String charmName;
  final DateTime earnedAt;
  const CharmsEarnedData({
    required this.id,
    required this.cycleDay,
    required this.charmName,
    required this.earnedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_day'] = Variable<int>(cycleDay);
    map['charm_name'] = Variable<String>(charmName);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    return map;
  }

  CharmsEarnedCompanion toCompanion(bool nullToAbsent) {
    return CharmsEarnedCompanion(
      id: Value(id),
      cycleDay: Value(cycleDay),
      charmName: Value(charmName),
      earnedAt: Value(earnedAt),
    );
  }

  factory CharmsEarnedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharmsEarnedData(
      id: serializer.fromJson<int>(json['id']),
      cycleDay: serializer.fromJson<int>(json['cycleDay']),
      charmName: serializer.fromJson<String>(json['charmName']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleDay': serializer.toJson<int>(cycleDay),
      'charmName': serializer.toJson<String>(charmName),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
    };
  }

  CharmsEarnedData copyWith({
    int? id,
    int? cycleDay,
    String? charmName,
    DateTime? earnedAt,
  }) => CharmsEarnedData(
    id: id ?? this.id,
    cycleDay: cycleDay ?? this.cycleDay,
    charmName: charmName ?? this.charmName,
    earnedAt: earnedAt ?? this.earnedAt,
  );
  CharmsEarnedData copyWithCompanion(CharmsEarnedCompanion data) {
    return CharmsEarnedData(
      id: data.id.present ? data.id.value : this.id,
      cycleDay: data.cycleDay.present ? data.cycleDay.value : this.cycleDay,
      charmName: data.charmName.present ? data.charmName.value : this.charmName,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharmsEarnedData(')
          ..write('id: $id, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('charmName: $charmName, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleDay, charmName, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharmsEarnedData &&
          other.id == this.id &&
          other.cycleDay == this.cycleDay &&
          other.charmName == this.charmName &&
          other.earnedAt == this.earnedAt);
}

class CharmsEarnedCompanion extends UpdateCompanion<CharmsEarnedData> {
  final Value<int> id;
  final Value<int> cycleDay;
  final Value<String> charmName;
  final Value<DateTime> earnedAt;
  const CharmsEarnedCompanion({
    this.id = const Value.absent(),
    this.cycleDay = const Value.absent(),
    this.charmName = const Value.absent(),
    this.earnedAt = const Value.absent(),
  });
  CharmsEarnedCompanion.insert({
    this.id = const Value.absent(),
    required int cycleDay,
    required String charmName,
    this.earnedAt = const Value.absent(),
  }) : cycleDay = Value(cycleDay),
       charmName = Value(charmName);
  static Insertable<CharmsEarnedData> custom({
    Expression<int>? id,
    Expression<int>? cycleDay,
    Expression<String>? charmName,
    Expression<DateTime>? earnedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleDay != null) 'cycle_day': cycleDay,
      if (charmName != null) 'charm_name': charmName,
      if (earnedAt != null) 'earned_at': earnedAt,
    });
  }

  CharmsEarnedCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleDay,
    Value<String>? charmName,
    Value<DateTime>? earnedAt,
  }) {
    return CharmsEarnedCompanion(
      id: id ?? this.id,
      cycleDay: cycleDay ?? this.cycleDay,
      charmName: charmName ?? this.charmName,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleDay.present) {
      map['cycle_day'] = Variable<int>(cycleDay.value);
    }
    if (charmName.present) {
      map['charm_name'] = Variable<String>(charmName.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharmsEarnedCompanion(')
          ..write('id: $id, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('charmName: $charmName, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<DateTime> createdAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       email = Value(email);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$WommiDatabase extends GeneratedDatabase {
  _$WommiDatabase(QueryExecutor e) : super(e);
  $WommiDatabaseManager get managers => $WommiDatabaseManager(this);
  late final $CycleProfilesTable cycleProfiles = $CycleProfilesTable(this);
  late final $RitualCompletionsTable ritualCompletions =
      $RitualCompletionsTable(this);
  late final $CharmsEarnedTable charmsEarned = $CharmsEarnedTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cycleProfiles,
    ritualCompletions,
    charmsEarned,
    userProfiles,
  ];
}

typedef $$CycleProfilesTableCreateCompanionBuilder =
    CycleProfilesCompanion Function({
      Value<int> id,
      Value<int> cycleLength,
      required DateTime startDate,
      Value<String?> ttcStatus,
      Value<String?> ttcMethod,
      Value<DateTime> createdAt,
    });
typedef $$CycleProfilesTableUpdateCompanionBuilder =
    CycleProfilesCompanion Function({
      Value<int> id,
      Value<int> cycleLength,
      Value<DateTime> startDate,
      Value<String?> ttcStatus,
      Value<String?> ttcMethod,
      Value<DateTime> createdAt,
    });

class $$CycleProfilesTableFilterComposer
    extends Composer<_$WommiDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableFilterComposer({
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

  ColumnFilters<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttcStatus => $composableBuilder(
    column: $table.ttcStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttcMethod => $composableBuilder(
    column: $table.ttcMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CycleProfilesTableOrderingComposer
    extends Composer<_$WommiDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableOrderingComposer({
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

  ColumnOrderings<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttcStatus => $composableBuilder(
    column: $table.ttcStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttcMethod => $composableBuilder(
    column: $table.ttcMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CycleProfilesTableAnnotationComposer
    extends Composer<_$WommiDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get ttcStatus =>
      $composableBuilder(column: $table.ttcStatus, builder: (column) => column);

  GeneratedColumn<String> get ttcMethod =>
      $composableBuilder(column: $table.ttcMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CycleProfilesTableTableManager
    extends
        RootTableManager<
          _$WommiDatabase,
          $CycleProfilesTable,
          CycleProfile,
          $$CycleProfilesTableFilterComposer,
          $$CycleProfilesTableOrderingComposer,
          $$CycleProfilesTableAnnotationComposer,
          $$CycleProfilesTableCreateCompanionBuilder,
          $$CycleProfilesTableUpdateCompanionBuilder,
          (
            CycleProfile,
            BaseReferences<_$WommiDatabase, $CycleProfilesTable, CycleProfile>,
          ),
          CycleProfile,
          PrefetchHooks Function()
        > {
  $$CycleProfilesTableTableManager(
    _$WommiDatabase db,
    $CycleProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String?> ttcStatus = const Value.absent(),
                Value<String?> ttcMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CycleProfilesCompanion(
                id: id,
                cycleLength: cycleLength,
                startDate: startDate,
                ttcStatus: ttcStatus,
                ttcMethod: ttcMethod,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                required DateTime startDate,
                Value<String?> ttcStatus = const Value.absent(),
                Value<String?> ttcMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CycleProfilesCompanion.insert(
                id: id,
                cycleLength: cycleLength,
                startDate: startDate,
                ttcStatus: ttcStatus,
                ttcMethod: ttcMethod,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CycleProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$WommiDatabase,
      $CycleProfilesTable,
      CycleProfile,
      $$CycleProfilesTableFilterComposer,
      $$CycleProfilesTableOrderingComposer,
      $$CycleProfilesTableAnnotationComposer,
      $$CycleProfilesTableCreateCompanionBuilder,
      $$CycleProfilesTableUpdateCompanionBuilder,
      (
        CycleProfile,
        BaseReferences<_$WommiDatabase, $CycleProfilesTable, CycleProfile>,
      ),
      CycleProfile,
      PrefetchHooks Function()
    >;
typedef $$RitualCompletionsTableCreateCompanionBuilder =
    RitualCompletionsCompanion Function({
      Value<int> id,
      required int cycleDay,
      required String ritualId,
      Value<DateTime> completedAt,
    });
typedef $$RitualCompletionsTableUpdateCompanionBuilder =
    RitualCompletionsCompanion Function({
      Value<int> id,
      Value<int> cycleDay,
      Value<String> ritualId,
      Value<DateTime> completedAt,
    });

class $$RitualCompletionsTableFilterComposer
    extends Composer<_$WommiDatabase, $RitualCompletionsTable> {
  $$RitualCompletionsTableFilterComposer({
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

  ColumnFilters<int> get cycleDay => $composableBuilder(
    column: $table.cycleDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ritualId => $composableBuilder(
    column: $table.ritualId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RitualCompletionsTableOrderingComposer
    extends Composer<_$WommiDatabase, $RitualCompletionsTable> {
  $$RitualCompletionsTableOrderingComposer({
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

  ColumnOrderings<int> get cycleDay => $composableBuilder(
    column: $table.cycleDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ritualId => $composableBuilder(
    column: $table.ritualId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RitualCompletionsTableAnnotationComposer
    extends Composer<_$WommiDatabase, $RitualCompletionsTable> {
  $$RitualCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleDay =>
      $composableBuilder(column: $table.cycleDay, builder: (column) => column);

  GeneratedColumn<String> get ritualId =>
      $composableBuilder(column: $table.ritualId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$RitualCompletionsTableTableManager
    extends
        RootTableManager<
          _$WommiDatabase,
          $RitualCompletionsTable,
          RitualCompletion,
          $$RitualCompletionsTableFilterComposer,
          $$RitualCompletionsTableOrderingComposer,
          $$RitualCompletionsTableAnnotationComposer,
          $$RitualCompletionsTableCreateCompanionBuilder,
          $$RitualCompletionsTableUpdateCompanionBuilder,
          (
            RitualCompletion,
            BaseReferences<
              _$WommiDatabase,
              $RitualCompletionsTable,
              RitualCompletion
            >,
          ),
          RitualCompletion,
          PrefetchHooks Function()
        > {
  $$RitualCompletionsTableTableManager(
    _$WommiDatabase db,
    $RitualCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RitualCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RitualCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RitualCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleDay = const Value.absent(),
                Value<String> ritualId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => RitualCompletionsCompanion(
                id: id,
                cycleDay: cycleDay,
                ritualId: ritualId,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cycleDay,
                required String ritualId,
                Value<DateTime> completedAt = const Value.absent(),
              }) => RitualCompletionsCompanion.insert(
                id: id,
                cycleDay: cycleDay,
                ritualId: ritualId,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RitualCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$WommiDatabase,
      $RitualCompletionsTable,
      RitualCompletion,
      $$RitualCompletionsTableFilterComposer,
      $$RitualCompletionsTableOrderingComposer,
      $$RitualCompletionsTableAnnotationComposer,
      $$RitualCompletionsTableCreateCompanionBuilder,
      $$RitualCompletionsTableUpdateCompanionBuilder,
      (
        RitualCompletion,
        BaseReferences<
          _$WommiDatabase,
          $RitualCompletionsTable,
          RitualCompletion
        >,
      ),
      RitualCompletion,
      PrefetchHooks Function()
    >;
typedef $$CharmsEarnedTableCreateCompanionBuilder =
    CharmsEarnedCompanion Function({
      Value<int> id,
      required int cycleDay,
      required String charmName,
      Value<DateTime> earnedAt,
    });
typedef $$CharmsEarnedTableUpdateCompanionBuilder =
    CharmsEarnedCompanion Function({
      Value<int> id,
      Value<int> cycleDay,
      Value<String> charmName,
      Value<DateTime> earnedAt,
    });

class $$CharmsEarnedTableFilterComposer
    extends Composer<_$WommiDatabase, $CharmsEarnedTable> {
  $$CharmsEarnedTableFilterComposer({
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

  ColumnFilters<int> get cycleDay => $composableBuilder(
    column: $table.cycleDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get charmName => $composableBuilder(
    column: $table.charmName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharmsEarnedTableOrderingComposer
    extends Composer<_$WommiDatabase, $CharmsEarnedTable> {
  $$CharmsEarnedTableOrderingComposer({
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

  ColumnOrderings<int> get cycleDay => $composableBuilder(
    column: $table.cycleDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get charmName => $composableBuilder(
    column: $table.charmName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharmsEarnedTableAnnotationComposer
    extends Composer<_$WommiDatabase, $CharmsEarnedTable> {
  $$CharmsEarnedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleDay =>
      $composableBuilder(column: $table.cycleDay, builder: (column) => column);

  GeneratedColumn<String> get charmName =>
      $composableBuilder(column: $table.charmName, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);
}

class $$CharmsEarnedTableTableManager
    extends
        RootTableManager<
          _$WommiDatabase,
          $CharmsEarnedTable,
          CharmsEarnedData,
          $$CharmsEarnedTableFilterComposer,
          $$CharmsEarnedTableOrderingComposer,
          $$CharmsEarnedTableAnnotationComposer,
          $$CharmsEarnedTableCreateCompanionBuilder,
          $$CharmsEarnedTableUpdateCompanionBuilder,
          (
            CharmsEarnedData,
            BaseReferences<
              _$WommiDatabase,
              $CharmsEarnedTable,
              CharmsEarnedData
            >,
          ),
          CharmsEarnedData,
          PrefetchHooks Function()
        > {
  $$CharmsEarnedTableTableManager(_$WommiDatabase db, $CharmsEarnedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharmsEarnedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharmsEarnedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharmsEarnedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleDay = const Value.absent(),
                Value<String> charmName = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
              }) => CharmsEarnedCompanion(
                id: id,
                cycleDay: cycleDay,
                charmName: charmName,
                earnedAt: earnedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cycleDay,
                required String charmName,
                Value<DateTime> earnedAt = const Value.absent(),
              }) => CharmsEarnedCompanion.insert(
                id: id,
                cycleDay: cycleDay,
                charmName: charmName,
                earnedAt: earnedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharmsEarnedTableProcessedTableManager =
    ProcessedTableManager<
      _$WommiDatabase,
      $CharmsEarnedTable,
      CharmsEarnedData,
      $$CharmsEarnedTableFilterComposer,
      $$CharmsEarnedTableOrderingComposer,
      $$CharmsEarnedTableAnnotationComposer,
      $$CharmsEarnedTableCreateCompanionBuilder,
      $$CharmsEarnedTableUpdateCompanionBuilder,
      (
        CharmsEarnedData,
        BaseReferences<_$WommiDatabase, $CharmsEarnedTable, CharmsEarnedData>,
      ),
      CharmsEarnedData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      Value<DateTime> createdAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<DateTime> createdAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$WommiDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$WommiDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$WommiDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$WommiDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$WommiDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$WommiDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                email: email,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                email: email,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$WommiDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$WommiDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $WommiDatabaseManager {
  final _$WommiDatabase _db;
  $WommiDatabaseManager(this._db);
  $$CycleProfilesTableTableManager get cycleProfiles =>
      $$CycleProfilesTableTableManager(_db, _db.cycleProfiles);
  $$RitualCompletionsTableTableManager get ritualCompletions =>
      $$RitualCompletionsTableTableManager(_db, _db.ritualCompletions);
  $$CharmsEarnedTableTableManager get charmsEarned =>
      $$CharmsEarnedTableTableManager(_db, _db.charmsEarned);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
