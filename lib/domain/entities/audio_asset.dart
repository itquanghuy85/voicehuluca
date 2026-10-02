import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_asset.freezed.dart';
part 'audio_asset.g.dart';

@freezed
class AudioAsset with _$AudioAsset {
  const factory AudioAsset({
    required String id,
    String? scriptId,
    String? projectId,
    required String fileName,
    required String filePath,
    required int fileSizeBytes,
    required Duration duration,
    @Default('mp3') String format,
    @Default(24000) int sampleRate,
    @Default(1) int channels,
    String? voiceId,
    String? generationJobId,
    required DateTime createdAt,
    DateTime? deletedAt,
    @Default(false) bool isDeleted,
  }) = _AudioAsset;

  factory AudioAsset.fromJson(Map<String, dynamic> json) =>
      _$AudioAssetFromJson(json);
}
