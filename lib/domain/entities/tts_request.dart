import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_request.freezed.dart';
part 'tts_request.g.dart';

@freezed
class TtsRequest with _$TtsRequest {
  const factory TtsRequest({
    required String id,
    required String text,
    required String voiceId,
    @Default('') String modelId,
    @Default(1.0) double speed,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    @Default('mp3') String outputFormat,
    @Default(24000) int sampleRate,
    Map<String, dynamic>? extraParams,
  }) = _TtsRequest;

  factory TtsRequest.fromJson(Map<String, dynamic> json) =>
      _$TtsRequestFromJson(json);
}
