// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TtsRequestImpl _$$TtsRequestImplFromJson(Map<String, dynamic> json) =>
    _$TtsRequestImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      voiceId: json['voiceId'] as String,
      modelId: json['modelId'] as String? ?? '',
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      stability: (json['stability'] as num?)?.toDouble(),
      similarityBoost: (json['similarityBoost'] as num?)?.toDouble(),
      style: (json['style'] as num?)?.toDouble(),
      useSpeakerBoost: json['useSpeakerBoost'] as bool?,
      outputFormat: json['outputFormat'] as String? ?? 'mp3',
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 24000,
      extraParams: json['extraParams'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TtsRequestImplToJson(_$TtsRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'voiceId': instance.voiceId,
      'modelId': instance.modelId,
      'speed': instance.speed,
      'stability': instance.stability,
      'similarityBoost': instance.similarityBoost,
      'style': instance.style,
      'useSpeakerBoost': instance.useSpeakerBoost,
      'outputFormat': instance.outputFormat,
      'sampleRate': instance.sampleRate,
      'extraParams': instance.extraParams,
    };
