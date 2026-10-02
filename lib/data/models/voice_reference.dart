import 'package:drift/drift.dart';

import 'voice.dart';

class VoiceReferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get voiceId => integer().references(Voices, #id)();
  TextColumn get localFilePath => text().withLength(min: 1, max: 1024)();
  IntColumn get durationMs => integer()();
  TextColumn get provider => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class VoiceReference {
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

  VoiceReference copyWith({
    int? id,
    int? voiceId,
    String? localFilePath,
    int? durationMs,
    String? provider,
    DateTime? createdAt,
  }) {
    return VoiceReference(
      id: id ?? this.id,
      voiceId: voiceId ?? this.voiceId,
      localFilePath: localFilePath ?? this.localFilePath,
      durationMs: durationMs ?? this.durationMs,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VoiceReference.fromJson(Map<String, dynamic> json) {
    return VoiceReference(
      id: json['id'] as int,
      voiceId: json['voiceId'] as int,
      localFilePath: json['localFilePath'] as String,
      durationMs: json['durationMs'] as int,
      provider: json['provider'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voiceId': voiceId,
      'localFilePath': localFilePath,
      'durationMs': durationMs,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
