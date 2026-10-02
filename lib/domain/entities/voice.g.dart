// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceImpl _$$VoiceImplFromJson(Map<String, dynamic> json) => _$VoiceImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  provider: json['provider'] as String,
  providerVoiceId: json['providerVoiceId'] as String,
  previewUrl: json['previewUrl'] as String?,
  language: json['language'] as String?,
  gender: json['gender'] as String?,
  accent: json['accent'] as String?,
  labels: json['labels'] as Map<String, dynamic>?,
  isCustom: json['isCustom'] as bool? ?? false,
  sampleText: json['sampleText'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$VoiceImplToJson(_$VoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'provider': instance.provider,
      'providerVoiceId': instance.providerVoiceId,
      'previewUrl': instance.previewUrl,
      'language': instance.language,
      'gender': instance.gender,
      'accent': instance.accent,
      'labels': instance.labels,
      'isCustom': instance.isCustom,
      'sampleText': instance.sampleText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
