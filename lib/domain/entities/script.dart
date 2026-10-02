import 'package:freezed_annotation/freezed_annotation.dart';

part 'script.freezed.dart';
part 'script.g.dart';

@freezed
class Script with _$Script {
  const factory Script({
    required String id,
    required String projectId,
    required String title,
    required String content,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? voiceId,
    double? speed,
    @Default(false) bool isGenerated,
    String? audioAssetId,
  }) = _Script;

  factory Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);
}
