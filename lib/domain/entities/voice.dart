import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice.freezed.dart';
part 'voice.g.dart';

@freezed
class Voice with _$Voice {
  const factory Voice({
    required String id,
    required String name,
    String? description,
    required String provider,
    required String providerVoiceId,
    String? previewUrl,
    String? language,
    String? gender,
    String? accent,
    Map<String, dynamic>? labels,
    @Default(false) bool isCustom,
    String? sampleText,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Voice;

  factory Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);
}
