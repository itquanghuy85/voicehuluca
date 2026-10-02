import 'package:drift/drift.dart';

import 'project.dart';
import 'script.dart';
import 'script_segment.dart';
import 'voice.dart';

class AudioAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  IntColumn get scriptId => integer().nullable().references(Scripts, #id)();
  IntColumn get segmentId =>
      integer().nullable().references(ScriptSegments, #id)();
  IntColumn get voiceId => integer().references(Voices, #id)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().withLength(min: 1, max: 1024)();
  TextColumn get format => text().withLength(min: 1, max: 10)();
  IntColumn get durationMs => integer()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

class AudioAsset {
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
    this.isFavorite = false,
  });

  AudioAsset copyWith({
    int? id,
    int? projectId,
    int? scriptId,
    int? segmentId,
    int? voiceId,
    String? title,
    String? filePath,
    String? format,
    int? durationMs,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return AudioAsset(
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

  factory AudioAsset.fromJson(Map<String, dynamic> json) {
    return AudioAsset(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      scriptId: json['scriptId'] as int?,
      segmentId: json['segmentId'] as int?,
      voiceId: json['voiceId'] as int,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      format: json['format'] as String,
      durationMs: json['durationMs'] as int,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'scriptId': scriptId,
      'segmentId': segmentId,
      'voiceId': voiceId,
      'title': title,
      'filePath': filePath,
      'format': format,
      'durationMs': durationMs,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }
}
