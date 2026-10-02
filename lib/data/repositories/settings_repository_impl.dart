import '../datasources/local/settings_local_datasource.dart';
import '../models/app_settings.dart';

class SettingsRepositoryImpl {
  final SettingsLocalDataSource _local;

  SettingsRepositoryImpl(this._local);

  Future<AppSettings> getSettings() => _local.getSettings();

  Stream<AppSettings> watchSettings() => _local.watchSettings();

  Future<bool> updateSettings(AppSettings settings) =>
      _local.updateSettings(settings);

  Future<bool> setThemeMode(String themeMode) => _local.setThemeMode(themeMode);

  Future<bool> setDefaultVoiceId(int? voiceId) =>
      _local.setDefaultVoiceId(voiceId);

  Future<bool> setDefaultSpeed(double speed) => _local.setDefaultSpeed(speed);

  Future<bool> setDefaultFormat(String format) =>
      _local.setDefaultFormat(format);

  Future<bool> setAutoNormalize(bool value) => _local.setAutoNormalize(value);

  Future<bool> setAutoSplit(bool value) => _local.setAutoSplit(value);

  Future<bool> setWarningThreshold(int threshold) =>
      _local.setWarningThreshold(threshold);

  Future<bool> setTtsProvider(String providerId) =>
      _local.setTtsProvider(providerId);
}
