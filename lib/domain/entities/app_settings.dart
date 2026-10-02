import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('default') String id,
    @Default('') String apiKey,
    @Default('') String defaultVoiceId,
    @Default('') String defaultModelId,
    @Default(1.0) double defaultSpeed,
    @Default('mp3') String defaultOutputFormat,
    @Default(24000) int defaultSampleRate,
    @Default('vi') String language,
    @Default('system') String theme,
    @Default(true) bool autoSave,
    @Default(true) bool enableNotifications,
    @Default(3) int maxConcurrentGenerations,
    @Default(Duration(seconds: 60)) Duration requestTimeout,
    String? webhookUrl,
    Map<String, dynamic>? customHeaders,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
