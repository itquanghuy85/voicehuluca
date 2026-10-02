import 'package:drift/drift.dart';

import 'script.dart';

class ScriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scriptId => integer().references(Scripts, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get content => text().named('text')();
  TextColumn get normalizedText => text()();
  IntColumn get audioId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ScriptSegment {
  final int id;
  final int scriptId;
  final int sortOrder;
  final String text;
  final String normalizedText;
  final int? audioId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScriptSegment({
    required this.id,
    required this.scriptId,
    required this.sortOrder,
    required this.text,
    required this.normalizedText,
    this.audioId,
    required this.createdAt,
    required this.updatedAt,
  });

  ScriptSegment copyWith({
    int? id,
    int? scriptId,
    int? sortOrder,
    String? text,
    String? normalizedText,
    int? audioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScriptSegment(
      id: id ?? this.id,
      scriptId: scriptId ?? this.scriptId,
      sortOrder: sortOrder ?? this.sortOrder,
      text: text ?? this.text,
      normalizedText: normalizedText ?? this.normalizedText,
      audioId: audioId ?? this.audioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScriptSegment.fromJson(Map<String, dynamic> json) {
    return ScriptSegment(
      id: json['id'] as int,
      scriptId: json['scriptId'] as int,
      sortOrder: json['sortOrder'] as int,
      text: json['text'] as String,
      normalizedText: json['normalizedText'] as String,
      audioId: json['audioId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scriptId': scriptId,
      'sortOrder': sortOrder,
      'text': text,
      'normalizedText': normalizedText,
      'audioId': audioId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
