// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TtsResponseImpl _$$TtsResponseImplFromJson(Map<String, dynamic> json) =>
    _$TtsResponseImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      audioUrl: json['audioUrl'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      characterCount: (json['characterCount'] as num?)?.toInt(),
      providerRequestId: json['providerRequestId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TtsResponseImplToJson(_$TtsResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'audioUrl': instance.audioUrl,
      'duration': instance.duration?.inMicroseconds,
      'characterCount': instance.characterCount,
      'providerRequestId': instance.providerRequestId,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };
