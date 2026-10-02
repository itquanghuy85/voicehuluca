// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioAssetImpl _$$AudioAssetImplFromJson(Map<String, dynamic> json) =>
    _$AudioAssetImpl(
      id: json['id'] as String,
      scriptId: json['scriptId'] as String?,
      projectId: json['projectId'] as String?,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      format: json['format'] as String? ?? 'mp3',
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 24000,
      channels: (json['channels'] as num?)?.toInt() ?? 1,
      voiceId: json['voiceId'] as String?,
      generationJobId: json['generationJobId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$AudioAssetImplToJson(_$AudioAssetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scriptId': instance.scriptId,
      'projectId': instance.projectId,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'fileSizeBytes': instance.fileSizeBytes,
      'duration': instance.duration.inMicroseconds,
      'format': instance.format,
      'sampleRate': instance.sampleRate,
      'channels': instance.channels,
      'voiceId': instance.voiceId,
      'generationJobId': instance.generationJobId,
      'createdAt': instance.createdAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
