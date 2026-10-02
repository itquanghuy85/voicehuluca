// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScriptImpl _$$ScriptImplFromJson(Map<String, dynamic> json) => _$ScriptImpl(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  voiceId: json['voiceId'] as String?,
  speed: (json['speed'] as num?)?.toDouble(),
  isGenerated: json['isGenerated'] as bool? ?? false,
  audioAssetId: json['audioAssetId'] as String?,
);

Map<String, dynamic> _$$ScriptImplToJson(_$ScriptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'title': instance.title,
      'content': instance.content,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'voiceId': instance.voiceId,
      'speed': instance.speed,
      'isGenerated': instance.isGenerated,
      'audioAssetId': instance.audioAssetId,
    };
