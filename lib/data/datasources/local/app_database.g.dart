// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScriptsTable extends Scripts with TableInfo<$ScriptsTable, Script> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScriptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    originalText,
    normalizedText,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Script> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Script map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Script(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
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
  $ScriptsTable createAlias(String alias) {
    return $ScriptsTable(attachedDatabase, alias);
  }
}

class Script extends DataClass implements Insertable<Script> {
  final int id;
  final int projectId;
  final String originalText;
  final String normalizedText;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Script({
    required this.id,
    required this.projectId,
    required this.originalText,
    required this.normalizedText,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['original_text'] = Variable<String>(originalText);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScriptsCompanion toCompanion(bool nullToAbsent) {
    return ScriptsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      originalText: Value(originalText),
      normalizedText: Value(normalizedText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Script.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Script(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      originalText: serializer.fromJson<String>(json['originalText']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'originalText': serializer.toJson<String>(originalText),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Script copyWith({
    int? id,
    int? projectId,
    String? originalText,
    String? normalizedText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Script(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    originalText: originalText ?? this.originalText,
    normalizedText: normalizedText ?? this.normalizedText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Script copyWithCompanion(ScriptsCompanion data) {
    return Script(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Script(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('originalText: $originalText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    originalText,
    normalizedText,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Script &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.originalText == this.originalText &&
          other.normalizedText == this.normalizedText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScriptsCompanion extends UpdateCompanion<Script> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> originalText;
  final Value<String> normalizedText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ScriptsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.originalText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScriptsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String originalText,
    required String normalizedText,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : projectId = Value(projectId),
       originalText = Value(originalText),
       normalizedText = Value(normalizedText);
  static Insertable<Script> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? originalText,
    Expression<String>? normalizedText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (originalText != null) 'original_text': originalText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScriptsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? originalText,
    Value<String>? normalizedText,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ScriptsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      originalText: originalText ?? this.originalText,
      normalizedText: normalizedText ?? this.normalizedText,
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
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
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
    return (StringBuffer('ScriptsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('originalText: $originalText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScriptSegmentsTable extends ScriptSegments
    with TableInfo<$ScriptSegmentsTable, ScriptSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScriptSegmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<int> scriptId = GeneratedColumn<int>(
    'script_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scripts (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioIdMeta = const VerificationMeta(
    'audioId',
  );
  @override
  late final GeneratedColumn<int> audioId = GeneratedColumn<int>(
    'audio_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scriptId,
    sortOrder,
    content,
    normalizedText,
    audioId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'script_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScriptSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scriptIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('audio_id')) {
      context.handle(
        _audioIdMeta,
        audioId.isAcceptableOrUnknown(data['audio_id']!, _audioIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScriptSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScriptSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}script_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
      )!,
      audioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_id'],
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
  $ScriptSegmentsTable createAlias(String alias) {
    return $ScriptSegmentsTable(attachedDatabase, alias);
  }
}

class ScriptSegment extends DataClass implements Insertable<ScriptSegment> {
  final int id;
  final int scriptId;
  final int sortOrder;
  final String content;
  final String normalizedText;
  final int? audioId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ScriptSegment({
    required this.id,
    required this.scriptId,
    required this.sortOrder,
    required this.content,
    required this.normalizedText,
    this.audioId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['script_id'] = Variable<int>(scriptId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['text'] = Variable<String>(content);
    map['normalized_text'] = Variable<String>(normalizedText);
    if (!nullToAbsent || audioId != null) {
      map['audio_id'] = Variable<int>(audioId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScriptSegmentsCompanion toCompanion(bool nullToAbsent) {
    return ScriptSegmentsCompanion(
      id: Value(id),
      scriptId: Value(scriptId),
      sortOrder: Value(sortOrder),
      content: Value(content),
      normalizedText: Value(normalizedText),
      audioId: audioId == null && nullToAbsent
          ? const Value.absent()
          : Value(audioId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScriptSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScriptSegment(
      id: serializer.fromJson<int>(json['id']),
      scriptId: serializer.fromJson<int>(json['scriptId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      content: serializer.fromJson<String>(json['content']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      audioId: serializer.fromJson<int?>(json['audioId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scriptId': serializer.toJson<int>(scriptId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'content': serializer.toJson<String>(content),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'audioId': serializer.toJson<int?>(audioId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScriptSegment copyWith({
    int? id,
    int? scriptId,
    int? sortOrder,
    String? content,
    String? normalizedText,
    Value<int?> audioId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ScriptSegment(
    id: id ?? this.id,
    scriptId: scriptId ?? this.scriptId,
    sortOrder: sortOrder ?? this.sortOrder,
    content: content ?? this.content,
    normalizedText: normalizedText ?? this.normalizedText,
    audioId: audioId.present ? audioId.value : this.audioId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScriptSegment copyWithCompanion(ScriptSegmentsCompanion data) {
    return ScriptSegment(
      id: data.id.present ? data.id.value : this.id,
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      content: data.content.present ? data.content.value : this.content,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      audioId: data.audioId.present ? data.audioId.value : this.audioId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScriptSegment(')
          ..write('id: $id, ')
          ..write('scriptId: $scriptId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('content: $content, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('audioId: $audioId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scriptId,
    sortOrder,
    content,
    normalizedText,
    audioId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScriptSegment &&
          other.id == this.id &&
          other.scriptId == this.scriptId &&
          other.sortOrder == this.sortOrder &&
          other.content == this.content &&
          other.normalizedText == this.normalizedText &&
          other.audioId == this.audioId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScriptSegmentsCompanion extends UpdateCompanion<ScriptSegment> {
  final Value<int> id;
  final Value<int> scriptId;
  final Value<int> sortOrder;
  final Value<String> content;
  final Value<String> normalizedText;
  final Value<int?> audioId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ScriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.scriptId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.content = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.audioId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScriptSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int scriptId,
    required int sortOrder,
    required String content,
    required String normalizedText,
    this.audioId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : scriptId = Value(scriptId),
       sortOrder = Value(sortOrder),
       content = Value(content),
       normalizedText = Value(normalizedText);
  static Insertable<ScriptSegment> custom({
    Expression<int>? id,
    Expression<int>? scriptId,
    Expression<int>? sortOrder,
    Expression<String>? content,
    Expression<String>? normalizedText,
    Expression<int>? audioId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scriptId != null) 'script_id': scriptId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (content != null) 'text': content,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (audioId != null) 'audio_id': audioId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScriptSegmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? scriptId,
    Value<int>? sortOrder,
    Value<String>? content,
    Value<String>? normalizedText,
    Value<int?>? audioId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ScriptSegmentsCompanion(
      id: id ?? this.id,
      scriptId: scriptId ?? this.scriptId,
      sortOrder: sortOrder ?? this.sortOrder,
      content: content ?? this.content,
      normalizedText: normalizedText ?? this.normalizedText,
      audioId: audioId ?? this.audioId,
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
    if (scriptId.present) {
      map['script_id'] = Variable<int>(scriptId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (audioId.present) {
      map['audio_id'] = Variable<int>(audioId.value);
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
    return (StringBuffer('ScriptSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('scriptId: $scriptId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('content: $content, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('audioId: $audioId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VoicesTable extends Voices with TableInfo<$VoicesTable, Voice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoicesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerVoiceIdMeta = const VerificationMeta(
    'providerVoiceId',
  );
  @override
  late final GeneratedColumn<String> providerVoiceId = GeneratedColumn<String>(
    'provider_voice_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentMeta = const VerificationMeta('accent');
  @override
  late final GeneratedColumn<String> accent = GeneratedColumn<String>(
    'accent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isClonedMeta = const VerificationMeta(
    'isCloned',
  );
  @override
  late final GeneratedColumn<bool> isCloned = GeneratedColumn<bool>(
    'is_cloned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cloned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    providerVoiceId,
    name,
    description,
    language,
    gender,
    accent,
    isCloned,
    isFavorite,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Voice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('provider_voice_id')) {
      context.handle(
        _providerVoiceIdMeta,
        providerVoiceId.isAcceptableOrUnknown(
          data['provider_voice_id']!,
          _providerVoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerVoiceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('accent')) {
      context.handle(
        _accentMeta,
        accent.isAcceptableOrUnknown(data['accent']!, _accentMeta),
      );
    }
    if (data.containsKey('is_cloned')) {
      context.handle(
        _isClonedMeta,
        isCloned.isAcceptableOrUnknown(data['is_cloned']!, _isClonedMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Voice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Voice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      providerVoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_voice_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      accent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent'],
      ),
      isCloned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cloned'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
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
  $VoicesTable createAlias(String alias) {
    return $VoicesTable(attachedDatabase, alias);
  }
}

class Voice extends DataClass implements Insertable<Voice> {
  final int id;
  final String provider;
  final String providerVoiceId;
  final String name;
  final String? description;
  final String language;
  final String gender;
  final String? accent;
  final bool isCloned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Voice({
    required this.id,
    required this.provider,
    required this.providerVoiceId,
    required this.name,
    this.description,
    required this.language,
    required this.gender,
    this.accent,
    required this.isCloned,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['provider_voice_id'] = Variable<String>(providerVoiceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['language'] = Variable<String>(language);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || accent != null) {
      map['accent'] = Variable<String>(accent);
    }
    map['is_cloned'] = Variable<bool>(isCloned);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VoicesCompanion toCompanion(bool nullToAbsent) {
    return VoicesCompanion(
      id: Value(id),
      provider: Value(provider),
      providerVoiceId: Value(providerVoiceId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      language: Value(language),
      gender: Value(gender),
      accent: accent == null && nullToAbsent
          ? const Value.absent()
          : Value(accent),
      isCloned: Value(isCloned),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Voice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Voice(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      providerVoiceId: serializer.fromJson<String>(json['providerVoiceId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      language: serializer.fromJson<String>(json['language']),
      gender: serializer.fromJson<String>(json['gender']),
      accent: serializer.fromJson<String?>(json['accent']),
      isCloned: serializer.fromJson<bool>(json['isCloned']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'providerVoiceId': serializer.toJson<String>(providerVoiceId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'language': serializer.toJson<String>(language),
      'gender': serializer.toJson<String>(gender),
      'accent': serializer.toJson<String?>(accent),
      'isCloned': serializer.toJson<bool>(isCloned),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Voice copyWith({
    int? id,
    String? provider,
    String? providerVoiceId,
    String? name,
    Value<String?> description = const Value.absent(),
    String? language,
    String? gender,
    Value<String?> accent = const Value.absent(),
    bool? isCloned,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Voice(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    providerVoiceId: providerVoiceId ?? this.providerVoiceId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    language: language ?? this.language,
    gender: gender ?? this.gender,
    accent: accent.present ? accent.value : this.accent,
    isCloned: isCloned ?? this.isCloned,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Voice copyWithCompanion(VoicesCompanion data) {
    return Voice(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      providerVoiceId: data.providerVoiceId.present
          ? data.providerVoiceId.value
          : this.providerVoiceId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      language: data.language.present ? data.language.value : this.language,
      gender: data.gender.present ? data.gender.value : this.gender,
      accent: data.accent.present ? data.accent.value : this.accent,
      isCloned: data.isCloned.present ? data.isCloned.value : this.isCloned,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Voice(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('providerVoiceId: $providerVoiceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('gender: $gender, ')
          ..write('accent: $accent, ')
          ..write('isCloned: $isCloned, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    providerVoiceId,
    name,
    description,
    language,
    gender,
    accent,
    isCloned,
    isFavorite,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voice &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.providerVoiceId == this.providerVoiceId &&
          other.name == this.name &&
          other.description == this.description &&
          other.language == this.language &&
          other.gender == this.gender &&
          other.accent == this.accent &&
          other.isCloned == this.isCloned &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VoicesCompanion extends UpdateCompanion<Voice> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> providerVoiceId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> language;
  final Value<String> gender;
  final Value<String?> accent;
  final Value<bool> isCloned;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VoicesCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.providerVoiceId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.gender = const Value.absent(),
    this.accent = const Value.absent(),
    this.isCloned = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VoicesCompanion.insert({
    this.id = const Value.absent(),
    required String provider,
    required String providerVoiceId,
    required String name,
    this.description = const Value.absent(),
    required String language,
    required String gender,
    this.accent = const Value.absent(),
    this.isCloned = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : provider = Value(provider),
       providerVoiceId = Value(providerVoiceId),
       name = Value(name),
       language = Value(language),
       gender = Value(gender);
  static Insertable<Voice> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? providerVoiceId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? language,
    Expression<String>? gender,
    Expression<String>? accent,
    Expression<bool>? isCloned,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (providerVoiceId != null) 'provider_voice_id': providerVoiceId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (language != null) 'language': language,
      if (gender != null) 'gender': gender,
      if (accent != null) 'accent': accent,
      if (isCloned != null) 'is_cloned': isCloned,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VoicesCompanion copyWith({
    Value<int>? id,
    Value<String>? provider,
    Value<String>? providerVoiceId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? language,
    Value<String>? gender,
    Value<String?>? accent,
    Value<bool>? isCloned,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VoicesCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      providerVoiceId: providerVoiceId ?? this.providerVoiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      gender: gender ?? this.gender,
      accent: accent ?? this.accent,
      isCloned: isCloned ?? this.isCloned,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (providerVoiceId.present) {
      map['provider_voice_id'] = Variable<String>(providerVoiceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (accent.present) {
      map['accent'] = Variable<String>(accent.value);
    }
    if (isCloned.present) {
      map['is_cloned'] = Variable<bool>(isCloned.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
    return (StringBuffer('VoicesCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('providerVoiceId: $providerVoiceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('gender: $gender, ')
          ..write('accent: $accent, ')
          ..write('isCloned: $isCloned, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VoiceReferencesTable extends VoiceReferences
    with TableInfo<$VoiceReferencesTable, VoiceReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceReferencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<int> voiceId = GeneratedColumn<int>(
    'voice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voices (id)',
    ),
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1024,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    voiceId,
    localFilePath,
    durationMs,
    provider,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceIdMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
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
  VoiceReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceReference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_id'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VoiceReferencesTable createAlias(String alias) {
    return $VoiceReferencesTable(attachedDatabase, alias);
  }
}

class VoiceReference extends DataClass implements Insertable<VoiceReference> {
  final int id;
  final int voiceId;
  final String localFilePath;
  final int durationMs;
  final String provider;
  final DateTime createdAt;
  const VoiceReference({
    required this.id,
    required this.voiceId,
    required this.localFilePath,
    required this.durationMs,
    required this.provider,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['voice_id'] = Variable<int>(voiceId);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['duration_ms'] = Variable<int>(durationMs);
    map['provider'] = Variable<String>(provider);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoiceReferencesCompanion toCompanion(bool nullToAbsent) {
    return VoiceReferencesCompanion(
      id: Value(id),
      voiceId: Value(voiceId),
      localFilePath: Value(localFilePath),
      durationMs: Value(durationMs),
      provider: Value(provider),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceReference(
      id: serializer.fromJson<int>(json['id']),
      voiceId: serializer.fromJson<int>(json['voiceId']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      provider: serializer.fromJson<String>(json['provider']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'voiceId': serializer.toJson<int>(voiceId),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'durationMs': serializer.toJson<int>(durationMs),
      'provider': serializer.toJson<String>(provider),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoiceReference copyWith({
    int? id,
    int? voiceId,
    String? localFilePath,
    int? durationMs,
    String? provider,
    DateTime? createdAt,
  }) => VoiceReference(
    id: id ?? this.id,
    voiceId: voiceId ?? this.voiceId,
    localFilePath: localFilePath ?? this.localFilePath,
    durationMs: durationMs ?? this.durationMs,
    provider: provider ?? this.provider,
    createdAt: createdAt ?? this.createdAt,
  );
  VoiceReference copyWithCompanion(VoiceReferencesCompanion data) {
    return VoiceReference(
      id: data.id.present ? data.id.value : this.id,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      provider: data.provider.present ? data.provider.value : this.provider,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceReference(')
          ..write('id: $id, ')
          ..write('voiceId: $voiceId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, voiceId, localFilePath, durationMs, provider, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceReference &&
          other.id == this.id &&
          other.voiceId == this.voiceId &&
          other.localFilePath == this.localFilePath &&
          other.durationMs == this.durationMs &&
          other.provider == this.provider &&
          other.createdAt == this.createdAt);
}

class VoiceReferencesCompanion extends UpdateCompanion<VoiceReference> {
  final Value<int> id;
  final Value<int> voiceId;
  final Value<String> localFilePath;
  final Value<int> durationMs;
  final Value<String> provider;
  final Value<DateTime> createdAt;
  const VoiceReferencesCompanion({
    this.id = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.provider = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VoiceReferencesCompanion.insert({
    this.id = const Value.absent(),
    required int voiceId,
    required String localFilePath,
    required int durationMs,
    required String provider,
    this.createdAt = const Value.absent(),
  }) : voiceId = Value(voiceId),
       localFilePath = Value(localFilePath),
       durationMs = Value(durationMs),
       provider = Value(provider);
  static Insertable<VoiceReference> custom({
    Expression<int>? id,
    Expression<int>? voiceId,
    Expression<String>? localFilePath,
    Expression<int>? durationMs,
    Expression<String>? provider,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voiceId != null) 'voice_id': voiceId,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (provider != null) 'provider': provider,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VoiceReferencesCompanion copyWith({
    Value<int>? id,
    Value<int>? voiceId,
    Value<String>? localFilePath,
    Value<int>? durationMs,
    Value<String>? provider,
    Value<DateTime>? createdAt,
  }) {
    return VoiceReferencesCompanion(
      id: id ?? this.id,
      voiceId: voiceId ?? this.voiceId,
      localFilePath: localFilePath ?? this.localFilePath,
      durationMs: durationMs ?? this.durationMs,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<int>(voiceId.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceReferencesCompanion(')
          ..write('id: $id, ')
          ..write('voiceId: $voiceId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudioAssetsTable extends AudioAssets
    with TableInfo<$AudioAssetsTable, AudioAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioAssetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<int> scriptId = GeneratedColumn<int>(
    'script_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scripts (id)',
    ),
  );
  static const VerificationMeta _segmentIdMeta = const VerificationMeta(
    'segmentId',
  );
  @override
  late final GeneratedColumn<int> segmentId = GeneratedColumn<int>(
    'segment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES script_segments (id)',
    ),
  );
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<int> voiceId = GeneratedColumn<int>(
    'voice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voices (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1024,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    scriptId,
    segmentId,
    voiceId,
    title,
    filePath,
    format,
    durationMs,
    fileSize,
    createdAt,
    updatedAt,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    }
    if (data.containsKey('segment_id')) {
      context.handle(
        _segmentIdMeta,
        segmentId.isAcceptableOrUnknown(data['segment_id']!, _segmentIdMeta),
      );
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}script_id'],
      ),
      segmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_id'],
      ),
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $AudioAssetsTable createAlias(String alias) {
    return $AudioAssetsTable(attachedDatabase, alias);
  }
}

class AudioAsset extends DataClass implements Insertable<AudioAsset> {
  final int id;
  final int projectId;
  final int? scriptId;
  final int? segmentId;
  final int voiceId;
  final String title;
  final String filePath;
  final String format;
  final int durationMs;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  const AudioAsset({
    required this.id,
    required this.projectId,
    this.scriptId,
    this.segmentId,
    required this.voiceId,
    required this.title,
    required this.filePath,
    required this.format,
    required this.durationMs,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || scriptId != null) {
      map['script_id'] = Variable<int>(scriptId);
    }
    if (!nullToAbsent || segmentId != null) {
      map['segment_id'] = Variable<int>(segmentId);
    }
    map['voice_id'] = Variable<int>(voiceId);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['format'] = Variable<String>(format);
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size'] = Variable<int>(fileSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  AudioAssetsCompanion toCompanion(bool nullToAbsent) {
    return AudioAssetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      scriptId: scriptId == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptId),
      segmentId: segmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentId),
      voiceId: Value(voiceId),
      title: Value(title),
      filePath: Value(filePath),
      format: Value(format),
      durationMs: Value(durationMs),
      fileSize: Value(fileSize),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isFavorite: Value(isFavorite),
    );
  }

  factory AudioAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioAsset(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      scriptId: serializer.fromJson<int?>(json['scriptId']),
      segmentId: serializer.fromJson<int?>(json['segmentId']),
      voiceId: serializer.fromJson<int>(json['voiceId']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      format: serializer.fromJson<String>(json['format']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'scriptId': serializer.toJson<int?>(scriptId),
      'segmentId': serializer.toJson<int?>(segmentId),
      'voiceId': serializer.toJson<int>(voiceId),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'format': serializer.toJson<String>(format),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSize': serializer.toJson<int>(fileSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  AudioAsset copyWith({
    int? id,
    int? projectId,
    Value<int?> scriptId = const Value.absent(),
    Value<int?> segmentId = const Value.absent(),
    int? voiceId,
    String? title,
    String? filePath,
    String? format,
    int? durationMs,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) => AudioAsset(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    scriptId: scriptId.present ? scriptId.value : this.scriptId,
    segmentId: segmentId.present ? segmentId.value : this.segmentId,
    voiceId: voiceId ?? this.voiceId,
    title: title ?? this.title,
    filePath: filePath ?? this.filePath,
    format: format ?? this.format,
    durationMs: durationMs ?? this.durationMs,
    fileSize: fileSize ?? this.fileSize,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  AudioAsset copyWithCompanion(AudioAssetsCompanion data) {
    return AudioAsset(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      segmentId: data.segmentId.present ? data.segmentId.value : this.segmentId,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      format: data.format.present ? data.format.value : this.format,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioAsset(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('scriptId: $scriptId, ')
          ..write('segmentId: $segmentId, ')
          ..write('voiceId: $voiceId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('format: $format, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    scriptId,
    segmentId,
    voiceId,
    title,
    filePath,
    format,
    durationMs,
    fileSize,
    createdAt,
    updatedAt,
    isFavorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioAsset &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.scriptId == this.scriptId &&
          other.segmentId == this.segmentId &&
          other.voiceId == this.voiceId &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.format == this.format &&
          other.durationMs == this.durationMs &&
          other.fileSize == this.fileSize &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isFavorite == this.isFavorite);
}

class AudioAssetsCompanion extends UpdateCompanion<AudioAsset> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<int?> scriptId;
  final Value<int?> segmentId;
  final Value<int> voiceId;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String> format;
  final Value<int> durationMs;
  final Value<int> fileSize;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isFavorite;
  const AudioAssetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.scriptId = const Value.absent(),
    this.segmentId = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.format = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  AudioAssetsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    this.scriptId = const Value.absent(),
    this.segmentId = const Value.absent(),
    required int voiceId,
    required String title,
    required String filePath,
    required String format,
    required int durationMs,
    required int fileSize,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
  }) : projectId = Value(projectId),
       voiceId = Value(voiceId),
       title = Value(title),
       filePath = Value(filePath),
       format = Value(format),
       durationMs = Value(durationMs),
       fileSize = Value(fileSize);
  static Insertable<AudioAsset> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<int>? scriptId,
    Expression<int>? segmentId,
    Expression<int>? voiceId,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? format,
    Expression<int>? durationMs,
    Expression<int>? fileSize,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (scriptId != null) 'script_id': scriptId,
      if (segmentId != null) 'segment_id': segmentId,
      if (voiceId != null) 'voice_id': voiceId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (format != null) 'format': format,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSize != null) 'file_size': fileSize,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  AudioAssetsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<int?>? scriptId,
    Value<int?>? segmentId,
    Value<int>? voiceId,
    Value<String>? title,
    Value<String>? filePath,
    Value<String>? format,
    Value<int>? durationMs,
    Value<int>? fileSize,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isFavorite,
  }) {
    return AudioAssetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      scriptId: scriptId ?? this.scriptId,
      segmentId: segmentId ?? this.segmentId,
      voiceId: voiceId ?? this.voiceId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (scriptId.present) {
      map['script_id'] = Variable<int>(scriptId.value);
    }
    if (segmentId.present) {
      map['segment_id'] = Variable<int>(segmentId.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<int>(voiceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioAssetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('scriptId: $scriptId, ')
          ..write('segmentId: $segmentId, ')
          ..write('voiceId: $voiceId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('format: $format, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $GenerationJobsTable extends GenerationJobs
    with TableInfo<$GenerationJobsTable, GenerationJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenerationJobsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<int> voiceId = GeneratedColumn<int>(
    'voice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voices (id)',
    ),
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    status,
    provider,
    voiceId,
    characterCount,
    startedAt,
    completedAt,
    errorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generation_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GenerationJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceIdMeta);
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterCountMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
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
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GenerationJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GenerationJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_id'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
    );
  }

  @override
  $GenerationJobsTable createAlias(String alias) {
    return $GenerationJobsTable(attachedDatabase, alias);
  }
}

class GenerationJob extends DataClass implements Insertable<GenerationJob> {
  final int id;
  final int projectId;
  final String status;
  final String provider;
  final int voiceId;
  final int characterCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorCode;
  const GenerationJob({
    required this.id,
    required this.projectId,
    required this.status,
    required this.provider,
    required this.voiceId,
    required this.characterCount,
    required this.startedAt,
    this.completedAt,
    this.errorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['status'] = Variable<String>(status);
    map['provider'] = Variable<String>(provider);
    map['voice_id'] = Variable<int>(voiceId);
    map['character_count'] = Variable<int>(characterCount);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    return map;
  }

  GenerationJobsCompanion toCompanion(bool nullToAbsent) {
    return GenerationJobsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      status: Value(status),
      provider: Value(provider),
      voiceId: Value(voiceId),
      characterCount: Value(characterCount),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
    );
  }

  factory GenerationJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GenerationJob(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      status: serializer.fromJson<String>(json['status']),
      provider: serializer.fromJson<String>(json['provider']),
      voiceId: serializer.fromJson<int>(json['voiceId']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'status': serializer.toJson<String>(status),
      'provider': serializer.toJson<String>(provider),
      'voiceId': serializer.toJson<int>(voiceId),
      'characterCount': serializer.toJson<int>(characterCount),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'errorCode': serializer.toJson<String?>(errorCode),
    };
  }

  GenerationJob copyWith({
    int? id,
    int? projectId,
    String? status,
    String? provider,
    int? voiceId,
    int? characterCount,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
  }) => GenerationJob(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    status: status ?? this.status,
    provider: provider ?? this.provider,
    voiceId: voiceId ?? this.voiceId,
    characterCount: characterCount ?? this.characterCount,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
  );
  GenerationJob copyWithCompanion(GenerationJobsCompanion data) {
    return GenerationJob(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      status: data.status.present ? data.status.value : this.status,
      provider: data.provider.present ? data.provider.value : this.provider,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GenerationJob(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('provider: $provider, ')
          ..write('voiceId: $voiceId, ')
          ..write('characterCount: $characterCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('errorCode: $errorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    status,
    provider,
    voiceId,
    characterCount,
    startedAt,
    completedAt,
    errorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenerationJob &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.status == this.status &&
          other.provider == this.provider &&
          other.voiceId == this.voiceId &&
          other.characterCount == this.characterCount &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.errorCode == this.errorCode);
}

class GenerationJobsCompanion extends UpdateCompanion<GenerationJob> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> status;
  final Value<String> provider;
  final Value<int> voiceId;
  final Value<int> characterCount;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> errorCode;
  const GenerationJobsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    this.provider = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.errorCode = const Value.absent(),
  });
  GenerationJobsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String status,
    required String provider,
    required int voiceId,
    required int characterCount,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.errorCode = const Value.absent(),
  }) : projectId = Value(projectId),
       status = Value(status),
       provider = Value(provider),
       voiceId = Value(voiceId),
       characterCount = Value(characterCount);
  static Insertable<GenerationJob> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? status,
    Expression<String>? provider,
    Expression<int>? voiceId,
    Expression<int>? characterCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? errorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (status != null) 'status': status,
      if (provider != null) 'provider': provider,
      if (voiceId != null) 'voice_id': voiceId,
      if (characterCount != null) 'character_count': characterCount,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (errorCode != null) 'error_code': errorCode,
    });
  }

  GenerationJobsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? status,
    Value<String>? provider,
    Value<int>? voiceId,
    Value<int>? characterCount,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? errorCode,
  }) {
    return GenerationJobsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      voiceId: voiceId ?? this.voiceId,
      characterCount: characterCount ?? this.characterCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<int>(voiceId.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenerationJobsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('provider: $provider, ')
          ..write('voiceId: $voiceId, ')
          ..write('characterCount: $characterCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('errorCode: $errorCode')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _defaultVoiceIdMeta = const VerificationMeta(
    'defaultVoiceId',
  );
  @override
  late final GeneratedColumn<int> defaultVoiceId = GeneratedColumn<int>(
    'default_voice_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultSpeedMeta = const VerificationMeta(
    'defaultSpeed',
  );
  @override
  late final GeneratedColumn<double> defaultSpeed = GeneratedColumn<double>(
    'default_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _defaultFormatMeta = const VerificationMeta(
    'defaultFormat',
  );
  @override
  late final GeneratedColumn<String> defaultFormat = GeneratedColumn<String>(
    'default_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mp3'),
  );
  static const VerificationMeta _autoNormalizeMeta = const VerificationMeta(
    'autoNormalize',
  );
  @override
  late final GeneratedColumn<bool> autoNormalize = GeneratedColumn<bool>(
    'auto_normalize',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_normalize" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoSplitMeta = const VerificationMeta(
    'autoSplit',
  );
  @override
  late final GeneratedColumn<bool> autoSplit = GeneratedColumn<bool>(
    'auto_split',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_split" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _warningThresholdMeta = const VerificationMeta(
    'warningThreshold',
  );
  @override
  late final GeneratedColumn<int> warningThreshold = GeneratedColumn<int>(
    'warning_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _ttsProviderMeta = const VerificationMeta(
    'ttsProvider',
  );
  @override
  late final GeneratedColumn<String> ttsProvider = GeneratedColumn<String>(
    'tts_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('google'),
  );
  static const VerificationMeta _backendUrlMeta = const VerificationMeta(
    'backendUrl',
  );
  @override
  late final GeneratedColumn<String> backendUrl = GeneratedColumn<String>(
    'backend_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    defaultVoiceId,
    defaultSpeed,
    defaultFormat,
    autoNormalize,
    autoSplit,
    warningThreshold,
    ttsProvider,
    backendUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('default_voice_id')) {
      context.handle(
        _defaultVoiceIdMeta,
        defaultVoiceId.isAcceptableOrUnknown(
          data['default_voice_id']!,
          _defaultVoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('default_speed')) {
      context.handle(
        _defaultSpeedMeta,
        defaultSpeed.isAcceptableOrUnknown(
          data['default_speed']!,
          _defaultSpeedMeta,
        ),
      );
    }
    if (data.containsKey('default_format')) {
      context.handle(
        _defaultFormatMeta,
        defaultFormat.isAcceptableOrUnknown(
          data['default_format']!,
          _defaultFormatMeta,
        ),
      );
    }
    if (data.containsKey('auto_normalize')) {
      context.handle(
        _autoNormalizeMeta,
        autoNormalize.isAcceptableOrUnknown(
          data['auto_normalize']!,
          _autoNormalizeMeta,
        ),
      );
    }
    if (data.containsKey('auto_split')) {
      context.handle(
        _autoSplitMeta,
        autoSplit.isAcceptableOrUnknown(data['auto_split']!, _autoSplitMeta),
      );
    }
    if (data.containsKey('warning_threshold')) {
      context.handle(
        _warningThresholdMeta,
        warningThreshold.isAcceptableOrUnknown(
          data['warning_threshold']!,
          _warningThresholdMeta,
        ),
      );
    }
    if (data.containsKey('tts_provider')) {
      context.handle(
        _ttsProviderMeta,
        ttsProvider.isAcceptableOrUnknown(
          data['tts_provider']!,
          _ttsProviderMeta,
        ),
      );
    }
    if (data.containsKey('backend_url')) {
      context.handle(
        _backendUrlMeta,
        backendUrl.isAcceptableOrUnknown(data['backend_url']!, _backendUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      defaultVoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_voice_id'],
      ),
      defaultSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_speed'],
      )!,
      defaultFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_format'],
      )!,
      autoNormalize: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_normalize'],
      )!,
      autoSplit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_split'],
      )!,
      warningThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_threshold'],
      )!,
      ttsProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_provider'],
      )!,
      backendUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backend_url'],
      ),
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final int id;
  final String themeMode;
  final int? defaultVoiceId;
  final double defaultSpeed;
  final String defaultFormat;
  final bool autoNormalize;
  final bool autoSplit;
  final int warningThreshold;
  final String ttsProvider;

  /// Base URL of the VietVoice backend. Null means "use the compiled default".
  final String? backendUrl;
  const AppSettingsTableData({
    required this.id,
    required this.themeMode,
    this.defaultVoiceId,
    required this.defaultSpeed,
    required this.defaultFormat,
    required this.autoNormalize,
    required this.autoSplit,
    required this.warningThreshold,
    required this.ttsProvider,
    this.backendUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || defaultVoiceId != null) {
      map['default_voice_id'] = Variable<int>(defaultVoiceId);
    }
    map['default_speed'] = Variable<double>(defaultSpeed);
    map['default_format'] = Variable<String>(defaultFormat);
    map['auto_normalize'] = Variable<bool>(autoNormalize);
    map['auto_split'] = Variable<bool>(autoSplit);
    map['warning_threshold'] = Variable<int>(warningThreshold);
    map['tts_provider'] = Variable<String>(ttsProvider);
    if (!nullToAbsent || backendUrl != null) {
      map['backend_url'] = Variable<String>(backendUrl);
    }
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      defaultVoiceId: defaultVoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultVoiceId),
      defaultSpeed: Value(defaultSpeed),
      defaultFormat: Value(defaultFormat),
      autoNormalize: Value(autoNormalize),
      autoSplit: Value(autoSplit),
      warningThreshold: Value(warningThreshold),
      ttsProvider: Value(ttsProvider),
      backendUrl: backendUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(backendUrl),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      defaultVoiceId: serializer.fromJson<int?>(json['defaultVoiceId']),
      defaultSpeed: serializer.fromJson<double>(json['defaultSpeed']),
      defaultFormat: serializer.fromJson<String>(json['defaultFormat']),
      autoNormalize: serializer.fromJson<bool>(json['autoNormalize']),
      autoSplit: serializer.fromJson<bool>(json['autoSplit']),
      warningThreshold: serializer.fromJson<int>(json['warningThreshold']),
      ttsProvider: serializer.fromJson<String>(json['ttsProvider']),
      backendUrl: serializer.fromJson<String?>(json['backendUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'defaultVoiceId': serializer.toJson<int?>(defaultVoiceId),
      'defaultSpeed': serializer.toJson<double>(defaultSpeed),
      'defaultFormat': serializer.toJson<String>(defaultFormat),
      'autoNormalize': serializer.toJson<bool>(autoNormalize),
      'autoSplit': serializer.toJson<bool>(autoSplit),
      'warningThreshold': serializer.toJson<int>(warningThreshold),
      'ttsProvider': serializer.toJson<String>(ttsProvider),
      'backendUrl': serializer.toJson<String?>(backendUrl),
    };
  }

  AppSettingsTableData copyWith({
    int? id,
    String? themeMode,
    Value<int?> defaultVoiceId = const Value.absent(),
    double? defaultSpeed,
    String? defaultFormat,
    bool? autoNormalize,
    bool? autoSplit,
    int? warningThreshold,
    String? ttsProvider,
    Value<String?> backendUrl = const Value.absent(),
  }) => AppSettingsTableData(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    defaultVoiceId: defaultVoiceId.present
        ? defaultVoiceId.value
        : this.defaultVoiceId,
    defaultSpeed: defaultSpeed ?? this.defaultSpeed,
    defaultFormat: defaultFormat ?? this.defaultFormat,
    autoNormalize: autoNormalize ?? this.autoNormalize,
    autoSplit: autoSplit ?? this.autoSplit,
    warningThreshold: warningThreshold ?? this.warningThreshold,
    ttsProvider: ttsProvider ?? this.ttsProvider,
    backendUrl: backendUrl.present ? backendUrl.value : this.backendUrl,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      defaultVoiceId: data.defaultVoiceId.present
          ? data.defaultVoiceId.value
          : this.defaultVoiceId,
      defaultSpeed: data.defaultSpeed.present
          ? data.defaultSpeed.value
          : this.defaultSpeed,
      defaultFormat: data.defaultFormat.present
          ? data.defaultFormat.value
          : this.defaultFormat,
      autoNormalize: data.autoNormalize.present
          ? data.autoNormalize.value
          : this.autoNormalize,
      autoSplit: data.autoSplit.present ? data.autoSplit.value : this.autoSplit,
      warningThreshold: data.warningThreshold.present
          ? data.warningThreshold.value
          : this.warningThreshold,
      ttsProvider: data.ttsProvider.present
          ? data.ttsProvider.value
          : this.ttsProvider,
      backendUrl: data.backendUrl.present
          ? data.backendUrl.value
          : this.backendUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultVoiceId: $defaultVoiceId, ')
          ..write('defaultSpeed: $defaultSpeed, ')
          ..write('defaultFormat: $defaultFormat, ')
          ..write('autoNormalize: $autoNormalize, ')
          ..write('autoSplit: $autoSplit, ')
          ..write('warningThreshold: $warningThreshold, ')
          ..write('ttsProvider: $ttsProvider, ')
          ..write('backendUrl: $backendUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    defaultVoiceId,
    defaultSpeed,
    defaultFormat,
    autoNormalize,
    autoSplit,
    warningThreshold,
    ttsProvider,
    backendUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.defaultVoiceId == this.defaultVoiceId &&
          other.defaultSpeed == this.defaultSpeed &&
          other.defaultFormat == this.defaultFormat &&
          other.autoNormalize == this.autoNormalize &&
          other.autoSplit == this.autoSplit &&
          other.warningThreshold == this.warningThreshold &&
          other.ttsProvider == this.ttsProvider &&
          other.backendUrl == this.backendUrl);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<int?> defaultVoiceId;
  final Value<double> defaultSpeed;
  final Value<String> defaultFormat;
  final Value<bool> autoNormalize;
  final Value<bool> autoSplit;
  final Value<int> warningThreshold;
  final Value<String> ttsProvider;
  final Value<String?> backendUrl;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultVoiceId = const Value.absent(),
    this.defaultSpeed = const Value.absent(),
    this.defaultFormat = const Value.absent(),
    this.autoNormalize = const Value.absent(),
    this.autoSplit = const Value.absent(),
    this.warningThreshold = const Value.absent(),
    this.ttsProvider = const Value.absent(),
    this.backendUrl = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultVoiceId = const Value.absent(),
    this.defaultSpeed = const Value.absent(),
    this.defaultFormat = const Value.absent(),
    this.autoNormalize = const Value.absent(),
    this.autoSplit = const Value.absent(),
    this.warningThreshold = const Value.absent(),
    this.ttsProvider = const Value.absent(),
    this.backendUrl = const Value.absent(),
  });
  static Insertable<AppSettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<int>? defaultVoiceId,
    Expression<double>? defaultSpeed,
    Expression<String>? defaultFormat,
    Expression<bool>? autoNormalize,
    Expression<bool>? autoSplit,
    Expression<int>? warningThreshold,
    Expression<String>? ttsProvider,
    Expression<String>? backendUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (defaultVoiceId != null) 'default_voice_id': defaultVoiceId,
      if (defaultSpeed != null) 'default_speed': defaultSpeed,
      if (defaultFormat != null) 'default_format': defaultFormat,
      if (autoNormalize != null) 'auto_normalize': autoNormalize,
      if (autoSplit != null) 'auto_split': autoSplit,
      if (warningThreshold != null) 'warning_threshold': warningThreshold,
      if (ttsProvider != null) 'tts_provider': ttsProvider,
      if (backendUrl != null) 'backend_url': backendUrl,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<int?>? defaultVoiceId,
    Value<double>? defaultSpeed,
    Value<String>? defaultFormat,
    Value<bool>? autoNormalize,
    Value<bool>? autoSplit,
    Value<int>? warningThreshold,
    Value<String>? ttsProvider,
    Value<String?>? backendUrl,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      defaultVoiceId: defaultVoiceId ?? this.defaultVoiceId,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      autoNormalize: autoNormalize ?? this.autoNormalize,
      autoSplit: autoSplit ?? this.autoSplit,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      ttsProvider: ttsProvider ?? this.ttsProvider,
      backendUrl: backendUrl ?? this.backendUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (defaultVoiceId.present) {
      map['default_voice_id'] = Variable<int>(defaultVoiceId.value);
    }
    if (defaultSpeed.present) {
      map['default_speed'] = Variable<double>(defaultSpeed.value);
    }
    if (defaultFormat.present) {
      map['default_format'] = Variable<String>(defaultFormat.value);
    }
    if (autoNormalize.present) {
      map['auto_normalize'] = Variable<bool>(autoNormalize.value);
    }
    if (autoSplit.present) {
      map['auto_split'] = Variable<bool>(autoSplit.value);
    }
    if (warningThreshold.present) {
      map['warning_threshold'] = Variable<int>(warningThreshold.value);
    }
    if (ttsProvider.present) {
      map['tts_provider'] = Variable<String>(ttsProvider.value);
    }
    if (backendUrl.present) {
      map['backend_url'] = Variable<String>(backendUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultVoiceId: $defaultVoiceId, ')
          ..write('defaultSpeed: $defaultSpeed, ')
          ..write('defaultFormat: $defaultFormat, ')
          ..write('autoNormalize: $autoNormalize, ')
          ..write('autoSplit: $autoSplit, ')
          ..write('warningThreshold: $warningThreshold, ')
          ..write('ttsProvider: $ttsProvider, ')
          ..write('backendUrl: $backendUrl')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ScriptsTable scripts = $ScriptsTable(this);
  late final $ScriptSegmentsTable scriptSegments = $ScriptSegmentsTable(this);
  late final $VoicesTable voices = $VoicesTable(this);
  late final $VoiceReferencesTable voiceReferences = $VoiceReferencesTable(
    this,
  );
  late final $AudioAssetsTable audioAssets = $AudioAssetsTable(this);
  late final $GenerationJobsTable generationJobs = $GenerationJobsTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    scripts,
    scriptSegments,
    voices,
    voiceReferences,
    audioAssets,
    generationJobs,
    appSettingsTable,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScriptsTable, List<Script>> _scriptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scripts,
    aliasName: $_aliasNameGenerator(db.projects.id, db.scripts.projectId),
  );

  $$ScriptsTableProcessedTableManager get scriptsRefs {
    final manager = $$ScriptsTableTableManager(
      $_db,
      $_db.scripts,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scriptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudioAssetsTable, List<AudioAsset>>
  _audioAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioAssets,
    aliasName: $_aliasNameGenerator(db.projects.id, db.audioAssets.projectId),
  );

  $$AudioAssetsTableProcessedTableManager get audioAssetsRefs {
    final manager = $$AudioAssetsTableTableManager(
      $_db,
      $_db.audioAssets,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audioAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GenerationJobsTable, List<GenerationJob>>
  _generationJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.generationJobs,
    aliasName: $_aliasNameGenerator(
      db.projects.id,
      db.generationJobs.projectId,
    ),
  );

  $$GenerationJobsTableProcessedTableManager get generationJobsRefs {
    final manager = $$GenerationJobsTableTableManager(
      $_db,
      $_db.generationJobs,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_generationJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scriptsRefs(
    Expression<bool> Function($$ScriptsTableFilterComposer f) f,
  ) {
    final $$ScriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableFilterComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audioAssetsRefs(
    Expression<bool> Function($$AudioAssetsTableFilterComposer f) f,
  ) {
    final $$AudioAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableFilterComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> generationJobsRefs(
    Expression<bool> Function($$GenerationJobsTableFilterComposer f) f,
  ) {
    final $$GenerationJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generationJobs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenerationJobsTableFilterComposer(
            $db: $db,
            $table: $db.generationJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> scriptsRefs<T extends Object>(
    Expression<T> Function($$ScriptsTableAnnotationComposer a) f,
  ) {
    final $$ScriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audioAssetsRefs<T extends Object>(
    Expression<T> Function($$AudioAssetsTableAnnotationComposer a) f,
  ) {
    final $$AudioAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> generationJobsRefs<T extends Object>(
    Expression<T> Function($$GenerationJobsTableAnnotationComposer a) f,
  ) {
    final $$GenerationJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generationJobs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenerationJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.generationJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool scriptsRefs,
            bool audioAssetsRefs,
            bool generationJobsRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scriptsRefs = false,
                audioAssetsRefs = false,
                generationJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scriptsRefs) db.scripts,
                    if (audioAssetsRefs) db.audioAssets,
                    if (generationJobsRefs) db.generationJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scriptsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Script
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._scriptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).scriptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audioAssetsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          AudioAsset
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._audioAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).audioAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (generationJobsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          GenerationJob
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._generationJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).generationJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
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

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool scriptsRefs,
        bool audioAssetsRefs,
        bool generationJobsRefs,
      })
    >;
typedef $$ScriptsTableCreateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      required int projectId,
      required String originalText,
      required String normalizedText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ScriptsTableUpdateCompanionBuilder =
    ScriptsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> originalText,
      Value<String> normalizedText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ScriptsTableReferences
    extends BaseReferences<_$AppDatabase, $ScriptsTable, Script> {
  $$ScriptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.scripts.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScriptSegmentsTable, List<ScriptSegment>>
  _scriptSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scriptSegments,
    aliasName: $_aliasNameGenerator(db.scripts.id, db.scriptSegments.scriptId),
  );

  $$ScriptSegmentsTableProcessedTableManager get scriptSegmentsRefs {
    final manager = $$ScriptSegmentsTableTableManager(
      $_db,
      $_db.scriptSegments,
    ).filter((f) => f.scriptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scriptSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudioAssetsTable, List<AudioAsset>>
  _audioAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioAssets,
    aliasName: $_aliasNameGenerator(db.scripts.id, db.audioAssets.scriptId),
  );

  $$AudioAssetsTableProcessedTableManager get audioAssetsRefs {
    final manager = $$AudioAssetsTableTableManager(
      $_db,
      $_db.audioAssets,
    ).filter((f) => f.scriptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audioAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScriptsTableFilterComposer
    extends Composer<_$AppDatabase, $ScriptsTable> {
  $$ScriptsTableFilterComposer({
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

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scriptSegmentsRefs(
    Expression<bool> Function($$ScriptSegmentsTableFilterComposer f) f,
  ) {
    final $$ScriptSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scriptSegments,
      getReferencedColumn: (t) => t.scriptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.scriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audioAssetsRefs(
    Expression<bool> Function($$AudioAssetsTableFilterComposer f) f,
  ) {
    final $$AudioAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.scriptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableFilterComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScriptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScriptsTable> {
  $$ScriptsTableOrderingComposer({
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

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScriptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScriptsTable> {
  $$ScriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scriptSegmentsRefs<T extends Object>(
    Expression<T> Function($$ScriptSegmentsTableAnnotationComposer a) f,
  ) {
    final $$ScriptSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scriptSegments,
      getReferencedColumn: (t) => t.scriptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.scriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audioAssetsRefs<T extends Object>(
    Expression<T> Function($$AudioAssetsTableAnnotationComposer a) f,
  ) {
    final $$AudioAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.scriptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScriptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScriptsTable,
          Script,
          $$ScriptsTableFilterComposer,
          $$ScriptsTableOrderingComposer,
          $$ScriptsTableAnnotationComposer,
          $$ScriptsTableCreateCompanionBuilder,
          $$ScriptsTableUpdateCompanionBuilder,
          (Script, $$ScriptsTableReferences),
          Script,
          PrefetchHooks Function({
            bool projectId,
            bool scriptSegmentsRefs,
            bool audioAssetsRefs,
          })
        > {
  $$ScriptsTableTableManager(_$AppDatabase db, $ScriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<String> normalizedText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScriptsCompanion(
                id: id,
                projectId: projectId,
                originalText: originalText,
                normalizedText: normalizedText,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String originalText,
                required String normalizedText,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScriptsCompanion.insert(
                id: id,
                projectId: projectId,
                originalText: originalText,
                normalizedText: normalizedText,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScriptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                scriptSegmentsRefs = false,
                audioAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scriptSegmentsRefs) db.scriptSegments,
                    if (audioAssetsRefs) db.audioAssets,
                  ],
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$ScriptsTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$ScriptsTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scriptSegmentsRefs)
                        await $_getPrefetchedData<
                          Script,
                          $ScriptsTable,
                          ScriptSegment
                        >(
                          currentTable: table,
                          referencedTable: $$ScriptsTableReferences
                              ._scriptSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScriptsTableReferences(
                                db,
                                table,
                                p0,
                              ).scriptSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scriptId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audioAssetsRefs)
                        await $_getPrefetchedData<
                          Script,
                          $ScriptsTable,
                          AudioAsset
                        >(
                          currentTable: table,
                          referencedTable: $$ScriptsTableReferences
                              ._audioAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScriptsTableReferences(
                                db,
                                table,
                                p0,
                              ).audioAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scriptId == item.id,
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

typedef $$ScriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScriptsTable,
      Script,
      $$ScriptsTableFilterComposer,
      $$ScriptsTableOrderingComposer,
      $$ScriptsTableAnnotationComposer,
      $$ScriptsTableCreateCompanionBuilder,
      $$ScriptsTableUpdateCompanionBuilder,
      (Script, $$ScriptsTableReferences),
      Script,
      PrefetchHooks Function({
        bool projectId,
        bool scriptSegmentsRefs,
        bool audioAssetsRefs,
      })
    >;
typedef $$ScriptSegmentsTableCreateCompanionBuilder =
    ScriptSegmentsCompanion Function({
      Value<int> id,
      required int scriptId,
      required int sortOrder,
      required String content,
      required String normalizedText,
      Value<int?> audioId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ScriptSegmentsTableUpdateCompanionBuilder =
    ScriptSegmentsCompanion Function({
      Value<int> id,
      Value<int> scriptId,
      Value<int> sortOrder,
      Value<String> content,
      Value<String> normalizedText,
      Value<int?> audioId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ScriptSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $ScriptSegmentsTable, ScriptSegment> {
  $$ScriptSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScriptsTable _scriptIdTable(_$AppDatabase db) =>
      db.scripts.createAlias(
        $_aliasNameGenerator(db.scriptSegments.scriptId, db.scripts.id),
      );

  $$ScriptsTableProcessedTableManager get scriptId {
    final $_column = $_itemColumn<int>('script_id')!;

    final manager = $$ScriptsTableTableManager(
      $_db,
      $_db.scripts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scriptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudioAssetsTable, List<AudioAsset>>
  _audioAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioAssets,
    aliasName: $_aliasNameGenerator(
      db.scriptSegments.id,
      db.audioAssets.segmentId,
    ),
  );

  $$AudioAssetsTableProcessedTableManager get audioAssetsRefs {
    final manager = $$AudioAssetsTableTableManager(
      $_db,
      $_db.audioAssets,
    ).filter((f) => f.segmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audioAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScriptSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ScriptSegmentsTable> {
  $$ScriptSegmentsTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioId => $composableBuilder(
    column: $table.audioId,
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

  $$ScriptsTableFilterComposer get scriptId {
    final $$ScriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableFilterComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audioAssetsRefs(
    Expression<bool> Function($$AudioAssetsTableFilterComposer f) f,
  ) {
    final $$AudioAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableFilterComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScriptSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScriptSegmentsTable> {
  $$ScriptSegmentsTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioId => $composableBuilder(
    column: $table.audioId,
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

  $$ScriptsTableOrderingComposer get scriptId {
    final $$ScriptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableOrderingComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScriptSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScriptSegmentsTable> {
  $$ScriptSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioId =>
      $composableBuilder(column: $table.audioId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScriptsTableAnnotationComposer get scriptId {
    final $$ScriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audioAssetsRefs<T extends Object>(
    Expression<T> Function($$AudioAssetsTableAnnotationComposer a) f,
  ) {
    final $$AudioAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScriptSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScriptSegmentsTable,
          ScriptSegment,
          $$ScriptSegmentsTableFilterComposer,
          $$ScriptSegmentsTableOrderingComposer,
          $$ScriptSegmentsTableAnnotationComposer,
          $$ScriptSegmentsTableCreateCompanionBuilder,
          $$ScriptSegmentsTableUpdateCompanionBuilder,
          (ScriptSegment, $$ScriptSegmentsTableReferences),
          ScriptSegment,
          PrefetchHooks Function({bool scriptId, bool audioAssetsRefs})
        > {
  $$ScriptSegmentsTableTableManager(
    _$AppDatabase db,
    $ScriptSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScriptSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScriptSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScriptSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scriptId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> normalizedText = const Value.absent(),
                Value<int?> audioId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScriptSegmentsCompanion(
                id: id,
                scriptId: scriptId,
                sortOrder: sortOrder,
                content: content,
                normalizedText: normalizedText,
                audioId: audioId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scriptId,
                required int sortOrder,
                required String content,
                required String normalizedText,
                Value<int?> audioId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScriptSegmentsCompanion.insert(
                id: id,
                scriptId: scriptId,
                sortOrder: sortOrder,
                content: content,
                normalizedText: normalizedText,
                audioId: audioId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScriptSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scriptId = false, audioAssetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (audioAssetsRefs) db.audioAssets],
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
                    if (scriptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scriptId,
                                referencedTable: $$ScriptSegmentsTableReferences
                                    ._scriptIdTable(db),
                                referencedColumn:
                                    $$ScriptSegmentsTableReferences
                                        ._scriptIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (audioAssetsRefs)
                    await $_getPrefetchedData<
                      ScriptSegment,
                      $ScriptSegmentsTable,
                      AudioAsset
                    >(
                      currentTable: table,
                      referencedTable: $$ScriptSegmentsTableReferences
                          ._audioAssetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScriptSegmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).audioAssetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.segmentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScriptSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScriptSegmentsTable,
      ScriptSegment,
      $$ScriptSegmentsTableFilterComposer,
      $$ScriptSegmentsTableOrderingComposer,
      $$ScriptSegmentsTableAnnotationComposer,
      $$ScriptSegmentsTableCreateCompanionBuilder,
      $$ScriptSegmentsTableUpdateCompanionBuilder,
      (ScriptSegment, $$ScriptSegmentsTableReferences),
      ScriptSegment,
      PrefetchHooks Function({bool scriptId, bool audioAssetsRefs})
    >;
typedef $$VoicesTableCreateCompanionBuilder =
    VoicesCompanion Function({
      Value<int> id,
      required String provider,
      required String providerVoiceId,
      required String name,
      Value<String?> description,
      required String language,
      required String gender,
      Value<String?> accent,
      Value<bool> isCloned,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VoicesTableUpdateCompanionBuilder =
    VoicesCompanion Function({
      Value<int> id,
      Value<String> provider,
      Value<String> providerVoiceId,
      Value<String> name,
      Value<String?> description,
      Value<String> language,
      Value<String> gender,
      Value<String?> accent,
      Value<bool> isCloned,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$VoicesTableReferences
    extends BaseReferences<_$AppDatabase, $VoicesTable, Voice> {
  $$VoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VoiceReferencesTable, List<VoiceReference>>
  _voiceReferencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.voiceReferences,
    aliasName: $_aliasNameGenerator(db.voices.id, db.voiceReferences.voiceId),
  );

  $$VoiceReferencesTableProcessedTableManager get voiceReferencesRefs {
    final manager = $$VoiceReferencesTableTableManager(
      $_db,
      $_db.voiceReferences,
    ).filter((f) => f.voiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _voiceReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudioAssetsTable, List<AudioAsset>>
  _audioAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioAssets,
    aliasName: $_aliasNameGenerator(db.voices.id, db.audioAssets.voiceId),
  );

  $$AudioAssetsTableProcessedTableManager get audioAssetsRefs {
    final manager = $$AudioAssetsTableTableManager(
      $_db,
      $_db.audioAssets,
    ).filter((f) => f.voiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audioAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GenerationJobsTable, List<GenerationJob>>
  _generationJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.generationJobs,
    aliasName: $_aliasNameGenerator(db.voices.id, db.generationJobs.voiceId),
  );

  $$GenerationJobsTableProcessedTableManager get generationJobsRefs {
    final manager = $$GenerationJobsTableTableManager(
      $_db,
      $_db.generationJobs,
    ).filter((f) => f.voiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_generationJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VoicesTableFilterComposer
    extends Composer<_$AppDatabase, $VoicesTable> {
  $$VoicesTableFilterComposer({
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

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerVoiceId => $composableBuilder(
    column: $table.providerVoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCloned => $composableBuilder(
    column: $table.isCloned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
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

  Expression<bool> voiceReferencesRefs(
    Expression<bool> Function($$VoiceReferencesTableFilterComposer f) f,
  ) {
    final $$VoiceReferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voiceReferences,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoiceReferencesTableFilterComposer(
            $db: $db,
            $table: $db.voiceReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audioAssetsRefs(
    Expression<bool> Function($$AudioAssetsTableFilterComposer f) f,
  ) {
    final $$AudioAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableFilterComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> generationJobsRefs(
    Expression<bool> Function($$GenerationJobsTableFilterComposer f) f,
  ) {
    final $$GenerationJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generationJobs,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenerationJobsTableFilterComposer(
            $db: $db,
            $table: $db.generationJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoicesTable> {
  $$VoicesTableOrderingComposer({
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

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerVoiceId => $composableBuilder(
    column: $table.providerVoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCloned => $composableBuilder(
    column: $table.isCloned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
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

class $$VoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoicesTable> {
  $$VoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get providerVoiceId => $composableBuilder(
    column: $table.providerVoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => column);

  GeneratedColumn<bool> get isCloned =>
      $composableBuilder(column: $table.isCloned, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> voiceReferencesRefs<T extends Object>(
    Expression<T> Function($$VoiceReferencesTableAnnotationComposer a) f,
  ) {
    final $$VoiceReferencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voiceReferences,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoiceReferencesTableAnnotationComposer(
            $db: $db,
            $table: $db.voiceReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audioAssetsRefs<T extends Object>(
    Expression<T> Function($$AudioAssetsTableAnnotationComposer a) f,
  ) {
    final $$AudioAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioAssets,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> generationJobsRefs<T extends Object>(
    Expression<T> Function($$GenerationJobsTableAnnotationComposer a) f,
  ) {
    final $$GenerationJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generationJobs,
      getReferencedColumn: (t) => t.voiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenerationJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.generationJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoicesTable,
          Voice,
          $$VoicesTableFilterComposer,
          $$VoicesTableOrderingComposer,
          $$VoicesTableAnnotationComposer,
          $$VoicesTableCreateCompanionBuilder,
          $$VoicesTableUpdateCompanionBuilder,
          (Voice, $$VoicesTableReferences),
          Voice,
          PrefetchHooks Function({
            bool voiceReferencesRefs,
            bool audioAssetsRefs,
            bool generationJobsRefs,
          })
        > {
  $$VoicesTableTableManager(_$AppDatabase db, $VoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> providerVoiceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> accent = const Value.absent(),
                Value<bool> isCloned = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VoicesCompanion(
                id: id,
                provider: provider,
                providerVoiceId: providerVoiceId,
                name: name,
                description: description,
                language: language,
                gender: gender,
                accent: accent,
                isCloned: isCloned,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String provider,
                required String providerVoiceId,
                required String name,
                Value<String?> description = const Value.absent(),
                required String language,
                required String gender,
                Value<String?> accent = const Value.absent(),
                Value<bool> isCloned = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VoicesCompanion.insert(
                id: id,
                provider: provider,
                providerVoiceId: providerVoiceId,
                name: name,
                description: description,
                language: language,
                gender: gender,
                accent: accent,
                isCloned: isCloned,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VoicesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                voiceReferencesRefs = false,
                audioAssetsRefs = false,
                generationJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (voiceReferencesRefs) db.voiceReferences,
                    if (audioAssetsRefs) db.audioAssets,
                    if (generationJobsRefs) db.generationJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (voiceReferencesRefs)
                        await $_getPrefetchedData<
                          Voice,
                          $VoicesTable,
                          VoiceReference
                        >(
                          currentTable: table,
                          referencedTable: $$VoicesTableReferences
                              ._voiceReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).voiceReferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.voiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audioAssetsRefs)
                        await $_getPrefetchedData<
                          Voice,
                          $VoicesTable,
                          AudioAsset
                        >(
                          currentTable: table,
                          referencedTable: $$VoicesTableReferences
                              ._audioAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).audioAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.voiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (generationJobsRefs)
                        await $_getPrefetchedData<
                          Voice,
                          $VoicesTable,
                          GenerationJob
                        >(
                          currentTable: table,
                          referencedTable: $$VoicesTableReferences
                              ._generationJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).generationJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.voiceId == item.id,
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

typedef $$VoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoicesTable,
      Voice,
      $$VoicesTableFilterComposer,
      $$VoicesTableOrderingComposer,
      $$VoicesTableAnnotationComposer,
      $$VoicesTableCreateCompanionBuilder,
      $$VoicesTableUpdateCompanionBuilder,
      (Voice, $$VoicesTableReferences),
      Voice,
      PrefetchHooks Function({
        bool voiceReferencesRefs,
        bool audioAssetsRefs,
        bool generationJobsRefs,
      })
    >;
typedef $$VoiceReferencesTableCreateCompanionBuilder =
    VoiceReferencesCompanion Function({
      Value<int> id,
      required int voiceId,
      required String localFilePath,
      required int durationMs,
      required String provider,
      Value<DateTime> createdAt,
    });
typedef $$VoiceReferencesTableUpdateCompanionBuilder =
    VoiceReferencesCompanion Function({
      Value<int> id,
      Value<int> voiceId,
      Value<String> localFilePath,
      Value<int> durationMs,
      Value<String> provider,
      Value<DateTime> createdAt,
    });

final class $$VoiceReferencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $VoiceReferencesTable, VoiceReference> {
  $$VoiceReferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VoicesTable _voiceIdTable(_$AppDatabase db) => db.voices.createAlias(
    $_aliasNameGenerator(db.voiceReferences.voiceId, db.voices.id),
  );

  $$VoicesTableProcessedTableManager get voiceId {
    final $_column = $_itemColumn<int>('voice_id')!;

    final manager = $$VoicesTableTableManager(
      $_db,
      $_db.voices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_voiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VoiceReferencesTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceReferencesTable> {
  $$VoiceReferencesTableFilterComposer({
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

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VoicesTableFilterComposer get voiceId {
    final $$VoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableFilterComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceReferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceReferencesTable> {
  $$VoiceReferencesTableOrderingComposer({
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

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VoicesTableOrderingComposer get voiceId {
    final $$VoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableOrderingComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceReferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceReferencesTable> {
  $$VoiceReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VoicesTableAnnotationComposer get voiceId {
    final $$VoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceReferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceReferencesTable,
          VoiceReference,
          $$VoiceReferencesTableFilterComposer,
          $$VoiceReferencesTableOrderingComposer,
          $$VoiceReferencesTableAnnotationComposer,
          $$VoiceReferencesTableCreateCompanionBuilder,
          $$VoiceReferencesTableUpdateCompanionBuilder,
          (VoiceReference, $$VoiceReferencesTableReferences),
          VoiceReference,
          PrefetchHooks Function({bool voiceId})
        > {
  $$VoiceReferencesTableTableManager(
    _$AppDatabase db,
    $VoiceReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceReferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> voiceId = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VoiceReferencesCompanion(
                id: id,
                voiceId: voiceId,
                localFilePath: localFilePath,
                durationMs: durationMs,
                provider: provider,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int voiceId,
                required String localFilePath,
                required int durationMs,
                required String provider,
                Value<DateTime> createdAt = const Value.absent(),
              }) => VoiceReferencesCompanion.insert(
                id: id,
                voiceId: voiceId,
                localFilePath: localFilePath,
                durationMs: durationMs,
                provider: provider,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VoiceReferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({voiceId = false}) {
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
                    if (voiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.voiceId,
                                referencedTable:
                                    $$VoiceReferencesTableReferences
                                        ._voiceIdTable(db),
                                referencedColumn:
                                    $$VoiceReferencesTableReferences
                                        ._voiceIdTable(db)
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

typedef $$VoiceReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceReferencesTable,
      VoiceReference,
      $$VoiceReferencesTableFilterComposer,
      $$VoiceReferencesTableOrderingComposer,
      $$VoiceReferencesTableAnnotationComposer,
      $$VoiceReferencesTableCreateCompanionBuilder,
      $$VoiceReferencesTableUpdateCompanionBuilder,
      (VoiceReference, $$VoiceReferencesTableReferences),
      VoiceReference,
      PrefetchHooks Function({bool voiceId})
    >;
typedef $$AudioAssetsTableCreateCompanionBuilder =
    AudioAssetsCompanion Function({
      Value<int> id,
      required int projectId,
      Value<int?> scriptId,
      Value<int?> segmentId,
      required int voiceId,
      required String title,
      required String filePath,
      required String format,
      required int durationMs,
      required int fileSize,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isFavorite,
    });
typedef $$AudioAssetsTableUpdateCompanionBuilder =
    AudioAssetsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<int?> scriptId,
      Value<int?> segmentId,
      Value<int> voiceId,
      Value<String> title,
      Value<String> filePath,
      Value<String> format,
      Value<int> durationMs,
      Value<int> fileSize,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isFavorite,
    });

final class $$AudioAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AudioAssetsTable, AudioAsset> {
  $$AudioAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.audioAssets.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScriptsTable _scriptIdTable(_$AppDatabase db) =>
      db.scripts.createAlias(
        $_aliasNameGenerator(db.audioAssets.scriptId, db.scripts.id),
      );

  $$ScriptsTableProcessedTableManager? get scriptId {
    final $_column = $_itemColumn<int>('script_id');
    if ($_column == null) return null;
    final manager = $$ScriptsTableTableManager(
      $_db,
      $_db.scripts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scriptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScriptSegmentsTable _segmentIdTable(_$AppDatabase db) =>
      db.scriptSegments.createAlias(
        $_aliasNameGenerator(db.audioAssets.segmentId, db.scriptSegments.id),
      );

  $$ScriptSegmentsTableProcessedTableManager? get segmentId {
    final $_column = $_itemColumn<int>('segment_id');
    if ($_column == null) return null;
    final manager = $$ScriptSegmentsTableTableManager(
      $_db,
      $_db.scriptSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_segmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VoicesTable _voiceIdTable(_$AppDatabase db) => db.voices.createAlias(
    $_aliasNameGenerator(db.audioAssets.voiceId, db.voices.id),
  );

  $$VoicesTableProcessedTableManager get voiceId {
    final $_column = $_itemColumn<int>('voice_id')!;

    final manager = $$VoicesTableTableManager(
      $_db,
      $_db.voices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_voiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudioAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioAssetsTable> {
  $$AudioAssetsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
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

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptsTableFilterComposer get scriptId {
    final $$ScriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableFilterComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptSegmentsTableFilterComposer get segmentId {
    final $$ScriptSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.scriptSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.scriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableFilterComposer get voiceId {
    final $$VoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableFilterComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioAssetsTable> {
  $$AudioAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
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

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptsTableOrderingComposer get scriptId {
    final $$ScriptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableOrderingComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptSegmentsTableOrderingComposer get segmentId {
    final $$ScriptSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.scriptSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.scriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableOrderingComposer get voiceId {
    final $$VoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableOrderingComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioAssetsTable> {
  $$AudioAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptsTableAnnotationComposer get scriptId {
    final $$ScriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scriptId,
      referencedTable: $db.scripts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.scripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScriptSegmentsTableAnnotationComposer get segmentId {
    final $$ScriptSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.scriptSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScriptSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.scriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableAnnotationComposer get voiceId {
    final $$VoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioAssetsTable,
          AudioAsset,
          $$AudioAssetsTableFilterComposer,
          $$AudioAssetsTableOrderingComposer,
          $$AudioAssetsTableAnnotationComposer,
          $$AudioAssetsTableCreateCompanionBuilder,
          $$AudioAssetsTableUpdateCompanionBuilder,
          (AudioAsset, $$AudioAssetsTableReferences),
          AudioAsset,
          PrefetchHooks Function({
            bool projectId,
            bool scriptId,
            bool segmentId,
            bool voiceId,
          })
        > {
  $$AudioAssetsTableTableManager(_$AppDatabase db, $AudioAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int?> scriptId = const Value.absent(),
                Value<int?> segmentId = const Value.absent(),
                Value<int> voiceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => AudioAssetsCompanion(
                id: id,
                projectId: projectId,
                scriptId: scriptId,
                segmentId: segmentId,
                voiceId: voiceId,
                title: title,
                filePath: filePath,
                format: format,
                durationMs: durationMs,
                fileSize: fileSize,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                Value<int?> scriptId = const Value.absent(),
                Value<int?> segmentId = const Value.absent(),
                required int voiceId,
                required String title,
                required String filePath,
                required String format,
                required int durationMs,
                required int fileSize,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => AudioAssetsCompanion.insert(
                id: id,
                projectId: projectId,
                scriptId: scriptId,
                segmentId: segmentId,
                voiceId: voiceId,
                title: title,
                filePath: filePath,
                format: format,
                durationMs: durationMs,
                fileSize: fileSize,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudioAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                scriptId = false,
                segmentId = false,
                voiceId = false,
              }) {
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$AudioAssetsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$AudioAssetsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (scriptId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scriptId,
                                    referencedTable:
                                        $$AudioAssetsTableReferences
                                            ._scriptIdTable(db),
                                    referencedColumn:
                                        $$AudioAssetsTableReferences
                                            ._scriptIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (segmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.segmentId,
                                    referencedTable:
                                        $$AudioAssetsTableReferences
                                            ._segmentIdTable(db),
                                    referencedColumn:
                                        $$AudioAssetsTableReferences
                                            ._segmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (voiceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.voiceId,
                                    referencedTable:
                                        $$AudioAssetsTableReferences
                                            ._voiceIdTable(db),
                                    referencedColumn:
                                        $$AudioAssetsTableReferences
                                            ._voiceIdTable(db)
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

typedef $$AudioAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioAssetsTable,
      AudioAsset,
      $$AudioAssetsTableFilterComposer,
      $$AudioAssetsTableOrderingComposer,
      $$AudioAssetsTableAnnotationComposer,
      $$AudioAssetsTableCreateCompanionBuilder,
      $$AudioAssetsTableUpdateCompanionBuilder,
      (AudioAsset, $$AudioAssetsTableReferences),
      AudioAsset,
      PrefetchHooks Function({
        bool projectId,
        bool scriptId,
        bool segmentId,
        bool voiceId,
      })
    >;
typedef $$GenerationJobsTableCreateCompanionBuilder =
    GenerationJobsCompanion Function({
      Value<int> id,
      required int projectId,
      required String status,
      required String provider,
      required int voiceId,
      required int characterCount,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> errorCode,
    });
typedef $$GenerationJobsTableUpdateCompanionBuilder =
    GenerationJobsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> status,
      Value<String> provider,
      Value<int> voiceId,
      Value<int> characterCount,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> errorCode,
    });

final class $$GenerationJobsTableReferences
    extends BaseReferences<_$AppDatabase, $GenerationJobsTable, GenerationJob> {
  $$GenerationJobsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.generationJobs.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VoicesTable _voiceIdTable(_$AppDatabase db) => db.voices.createAlias(
    $_aliasNameGenerator(db.generationJobs.voiceId, db.voices.id),
  );

  $$VoicesTableProcessedTableManager get voiceId {
    final $_column = $_itemColumn<int>('voice_id')!;

    final manager = $$VoicesTableTableManager(
      $_db,
      $_db.voices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_voiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GenerationJobsTableFilterComposer
    extends Composer<_$AppDatabase, $GenerationJobsTable> {
  $$GenerationJobsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableFilterComposer get voiceId {
    final $$VoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableFilterComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GenerationJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $GenerationJobsTable> {
  $$GenerationJobsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableOrderingComposer get voiceId {
    final $$VoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableOrderingComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GenerationJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GenerationJobsTable> {
  $$GenerationJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VoicesTableAnnotationComposer get voiceId {
    final $$VoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voiceId,
      referencedTable: $db.voices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.voices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GenerationJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GenerationJobsTable,
          GenerationJob,
          $$GenerationJobsTableFilterComposer,
          $$GenerationJobsTableOrderingComposer,
          $$GenerationJobsTableAnnotationComposer,
          $$GenerationJobsTableCreateCompanionBuilder,
          $$GenerationJobsTableUpdateCompanionBuilder,
          (GenerationJob, $$GenerationJobsTableReferences),
          GenerationJob,
          PrefetchHooks Function({bool projectId, bool voiceId})
        > {
  $$GenerationJobsTableTableManager(
    _$AppDatabase db,
    $GenerationJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenerationJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GenerationJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenerationJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<int> voiceId = const Value.absent(),
                Value<int> characterCount = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
              }) => GenerationJobsCompanion(
                id: id,
                projectId: projectId,
                status: status,
                provider: provider,
                voiceId: voiceId,
                characterCount: characterCount,
                startedAt: startedAt,
                completedAt: completedAt,
                errorCode: errorCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String status,
                required String provider,
                required int voiceId,
                required int characterCount,
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
              }) => GenerationJobsCompanion.insert(
                id: id,
                projectId: projectId,
                status: status,
                provider: provider,
                voiceId: voiceId,
                characterCount: characterCount,
                startedAt: startedAt,
                completedAt: completedAt,
                errorCode: errorCode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GenerationJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, voiceId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$GenerationJobsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn:
                                    $$GenerationJobsTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (voiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.voiceId,
                                referencedTable: $$GenerationJobsTableReferences
                                    ._voiceIdTable(db),
                                referencedColumn:
                                    $$GenerationJobsTableReferences
                                        ._voiceIdTable(db)
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

typedef $$GenerationJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GenerationJobsTable,
      GenerationJob,
      $$GenerationJobsTableFilterComposer,
      $$GenerationJobsTableOrderingComposer,
      $$GenerationJobsTableAnnotationComposer,
      $$GenerationJobsTableCreateCompanionBuilder,
      $$GenerationJobsTableUpdateCompanionBuilder,
      (GenerationJob, $$GenerationJobsTableReferences),
      GenerationJob,
      PrefetchHooks Function({bool projectId, bool voiceId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<int?> defaultVoiceId,
      Value<double> defaultSpeed,
      Value<String> defaultFormat,
      Value<bool> autoNormalize,
      Value<bool> autoSplit,
      Value<int> warningThreshold,
      Value<String> ttsProvider,
      Value<String?> backendUrl,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<int?> defaultVoiceId,
      Value<double> defaultSpeed,
      Value<String> defaultFormat,
      Value<bool> autoNormalize,
      Value<bool> autoSplit,
      Value<int> warningThreshold,
      Value<String> ttsProvider,
      Value<String?> backendUrl,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
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

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultVoiceId => $composableBuilder(
    column: $table.defaultVoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultSpeed => $composableBuilder(
    column: $table.defaultSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultFormat => $composableBuilder(
    column: $table.defaultFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoNormalize => $composableBuilder(
    column: $table.autoNormalize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoSplit => $composableBuilder(
    column: $table.autoSplit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningThreshold => $composableBuilder(
    column: $table.warningThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backendUrl => $composableBuilder(
    column: $table.backendUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultVoiceId => $composableBuilder(
    column: $table.defaultVoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultSpeed => $composableBuilder(
    column: $table.defaultSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFormat => $composableBuilder(
    column: $table.defaultFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoNormalize => $composableBuilder(
    column: $table.autoNormalize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoSplit => $composableBuilder(
    column: $table.autoSplit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningThreshold => $composableBuilder(
    column: $table.warningThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backendUrl => $composableBuilder(
    column: $table.backendUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<int> get defaultVoiceId => $composableBuilder(
    column: $table.defaultVoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultSpeed => $composableBuilder(
    column: $table.defaultSpeed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultFormat => $composableBuilder(
    column: $table.defaultFormat,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoNormalize => $composableBuilder(
    column: $table.autoNormalize,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoSplit =>
      $composableBuilder(column: $table.autoSplit, builder: (column) => column);

  GeneratedColumn<int> get warningThreshold => $composableBuilder(
    column: $table.warningThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backendUrl => $composableBuilder(
    column: $table.backendUrl,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int?> defaultVoiceId = const Value.absent(),
                Value<double> defaultSpeed = const Value.absent(),
                Value<String> defaultFormat = const Value.absent(),
                Value<bool> autoNormalize = const Value.absent(),
                Value<bool> autoSplit = const Value.absent(),
                Value<int> warningThreshold = const Value.absent(),
                Value<String> ttsProvider = const Value.absent(),
                Value<String?> backendUrl = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                themeMode: themeMode,
                defaultVoiceId: defaultVoiceId,
                defaultSpeed: defaultSpeed,
                defaultFormat: defaultFormat,
                autoNormalize: autoNormalize,
                autoSplit: autoSplit,
                warningThreshold: warningThreshold,
                ttsProvider: ttsProvider,
                backendUrl: backendUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int?> defaultVoiceId = const Value.absent(),
                Value<double> defaultSpeed = const Value.absent(),
                Value<String> defaultFormat = const Value.absent(),
                Value<bool> autoNormalize = const Value.absent(),
                Value<bool> autoSplit = const Value.absent(),
                Value<int> warningThreshold = const Value.absent(),
                Value<String> ttsProvider = const Value.absent(),
                Value<String?> backendUrl = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                themeMode: themeMode,
                defaultVoiceId: defaultVoiceId,
                defaultSpeed: defaultSpeed,
                defaultFormat: defaultFormat,
                autoNormalize: autoNormalize,
                autoSplit: autoSplit,
                warningThreshold: warningThreshold,
                ttsProvider: ttsProvider,
                backendUrl: backendUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ScriptsTableTableManager get scripts =>
      $$ScriptsTableTableManager(_db, _db.scripts);
  $$ScriptSegmentsTableTableManager get scriptSegments =>
      $$ScriptSegmentsTableTableManager(_db, _db.scriptSegments);
  $$VoicesTableTableManager get voices =>
      $$VoicesTableTableManager(_db, _db.voices);
  $$VoiceReferencesTableTableManager get voiceReferences =>
      $$VoiceReferencesTableTableManager(_db, _db.voiceReferences);
  $$AudioAssetsTableTableManager get audioAssets =>
      $$AudioAssetsTableTableManager(_db, _db.audioAssets);
  $$GenerationJobsTableTableManager get generationJobs =>
      $$GenerationJobsTableTableManager(_db, _db.generationJobs);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
