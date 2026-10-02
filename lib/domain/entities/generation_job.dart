import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_job.freezed.dart';
part 'generation_job.g.dart';

enum GenerationStatus {
  idle,
  validating,
  uploading,
  generating,
  downloading,
  processing,
  success,
  error,
  cancelled,
}

@freezed
class GenerationJob with _$GenerationJob {
  const factory GenerationJob({
    required String id,
    String? scriptId,
    String? projectId,
    required String voiceId,
    required String text,
    @Default(GenerationStatus.idle) GenerationStatus status,
    String? errorMessage,
    String? audioAssetId,
    String? ttsRequestId,
    @Default(0.0) double progress,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) = _GenerationJob;

  factory GenerationJob.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobFromJson(json);
}
