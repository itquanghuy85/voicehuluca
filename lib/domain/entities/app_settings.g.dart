// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      id: json['id'] as String? ?? 'default',
      apiKey: json['apiKey'] as String? ?? '',
      defaultVoiceId: json['defaultVoiceId'] as String? ?? '',
      defaultModelId: json['defaultModelId'] as String? ?? '',
      defaultSpeed: (json['defaultSpeed'] as num?)?.toDouble() ?? 1.0,
      defaultOutputFormat: json['defaultOutputFormat'] as String? ?? 'mp3',
      defaultSampleRate: (json['defaultSampleRate'] as num?)?.toInt() ?? 24000,
      language: json['language'] as String? ?? 'vi',
      theme: json['theme'] as String? ?? 'system',
      autoSave: json['autoSave'] as bool? ?? true,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      maxConcurrentGenerations:
          (json['maxConcurrentGenerations'] as num?)?.toInt() ?? 3,
      requestTimeout: json['requestTimeout'] == null
          ? const Duration(seconds: 60)
          : Duration(microseconds: (json['requestTimeout'] as num).toInt()),
      webhookUrl: json['webhookUrl'] as String?,
      customHeaders: json['customHeaders'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'apiKey': instance.apiKey,
      'defaultVoiceId': instance.defaultVoiceId,
      'defaultModelId': instance.defaultModelId,
      'defaultSpeed': instance.defaultSpeed,
      'defaultOutputFormat': instance.defaultOutputFormat,
      'defaultSampleRate': instance.defaultSampleRate,
      'language': instance.language,
      'theme': instance.theme,
      'autoSave': instance.autoSave,
      'enableNotifications': instance.enableNotifications,
      'maxConcurrentGenerations': instance.maxConcurrentGenerations,
      'requestTimeout': instance.requestTimeout.inMicroseconds,
      'webhookUrl': instance.webhookUrl,
      'customHeaders': instance.customHeaders,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
