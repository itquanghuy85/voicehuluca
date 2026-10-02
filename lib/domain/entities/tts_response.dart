import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_response.freezed.dart';
part 'tts_response.g.dart';

@freezed
class TtsResponse with _$TtsResponse {
  const factory TtsResponse({
    required String id,
    required String status,
    String? audioUrl,
    Duration? duration,
    int? characterCount,
    String? providerRequestId,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _TtsResponse;

  factory TtsResponse.fromJson(Map<String, dynamic> json) =>
      _$TtsResponseFromJson(json);
}
