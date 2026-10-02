import 'package:drift/drift.dart';

import 'project.dart';
import 'voice.dart';

class GenerationJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get status => text().withLength(min: 1, max: 50)();
  TextColumn get provider => text().withLength(min: 1, max: 50)();
  IntColumn get voiceId => integer().references(Voices, #id)();
  IntColumn get characterCount => integer()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get errorCode => text().nullable()();
}

class GenerationJob {
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

  GenerationJob copyWith({
    int? id,
    int? projectId,
    String? status,
    String? provider,
    int? voiceId,
    int? characterCount,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorCode,
  }) {
    return GenerationJob(
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

  factory GenerationJob.fromJson(Map<String, dynamic> json) {
    return GenerationJob(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      status: json['status'] as String,
      provider: json['provider'] as String,
      voiceId: json['voiceId'] as int,
      characterCount: json['characterCount'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      errorCode: json['errorCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'status': status,
      'provider': provider,
      'voiceId': voiceId,
      'characterCount': characterCount,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'errorCode': errorCode,
    };
  }
}
