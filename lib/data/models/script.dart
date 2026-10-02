import 'package:drift/drift.dart';

import 'project.dart';

class Scripts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get originalText => text()();
  TextColumn get normalizedText => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Script {
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

  Script copyWith({
    int? id,
    int? projectId,
    String? originalText,
    String? normalizedText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Script(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      originalText: originalText ?? this.originalText,
      normalizedText: normalizedText ?? this.normalizedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      originalText: json['originalText'] as String,
      normalizedText: json['normalizedText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'originalText': originalText,
      'normalizedText': normalizedText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
