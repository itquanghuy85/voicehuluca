import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<AppSettings> updateSettings(AppSettings settings);

  Future<void> clearSettings();

  Future<bool> hasApiKey();

  Future<void> saveApiKey(String apiKey);

  Future<String?> getApiKey();

  Future<void> deleteApiKey();

  Future<AppSettings> resetToDefaults();
}
