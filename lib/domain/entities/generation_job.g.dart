// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GenerationJobImpl _$$GenerationJobImplFromJson(Map<String, dynamic> json) =>
    _$GenerationJobImpl(
      id: json['id'] as String,
      scriptId: json['scriptId'] as String?,
      projectId: json['projectId'] as String?,
      voiceId: json['voiceId'] as String,
      text: json['text'] as String,
      status:
          $enumDecodeNullable(_$GenerationStatusEnumMap, json['status']) ??
          GenerationStatus.idle,
      errorMessage: json['errorMessage'] as String?,
      audioAssetId: json['audioAssetId'] as String?,
      ttsRequestId: json['ttsRequestId'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GenerationJobImplToJson(_$GenerationJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scriptId': instance.scriptId,
      'projectId': instance.projectId,
      'voiceId': instance.voiceId,
      'text': instance.text,
      'status': _$GenerationStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'audioAssetId': instance.audioAssetId,
      'ttsRequestId': instance.ttsRequestId,
      'progress': instance.progress,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$GenerationStatusEnumMap = {
  GenerationStatus.idle: 'idle',
  GenerationStatus.validating: 'validating',
  GenerationStatus.uploading: 'uploading',
  GenerationStatus.generating: 'generating',
  GenerationStatus.downloading: 'downloading',
  GenerationStatus.processing: 'processing',
  GenerationStatus.success: 'success',
  GenerationStatus.error: 'error',
  GenerationStatus.cancelled: 'cancelled',
};
