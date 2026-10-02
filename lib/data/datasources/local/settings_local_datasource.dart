import 'package:drift/drift.dart';

import '../../models/app_settings.dart';
import 'app_database.dart';

class SettingsLocalDataSource {
  final AppDatabase _database;

  SettingsLocalDataSource(this._database);

  Future<AppSettings> getSettings() => _database.getSettings();

  Stream<AppSettings> watchSettings() => _database.watchSettings();

  Future<bool> updateSettings(AppSettings settings) {
    final companion = AppSettingsTableCompanion(
      // Single-row table: replace() matches on the primary key.
      id: const Value(1),
      themeMode: Value(settings.themeMode),
      defaultVoiceId: Value(settings.defaultVoiceId),
      defaultSpeed: Value(settings.defaultSpeed),
      defaultFormat: Value(settings.defaultFormat),
      autoNormalize: Value(settings.autoNormalize),
      autoSplit: Value(settings.autoSplit),
      warningThreshold: Value(settings.warningThreshold),
      ttsProvider: Value(settings.ttsProvider),
      backendUrl: Value(settings.backendUrl),
    );
    return _database.updateSettings(companion);
  }

  Future<bool> setThemeMode(String themeMode) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(themeMode: themeMode));
  }

  Future<bool> setDefaultVoiceId(int? voiceId) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(defaultVoiceId: voiceId));
  }

  Future<bool> setDefaultSpeed(double speed) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(defaultSpeed: speed));
  }

  Future<bool> setDefaultFormat(String format) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(defaultFormat: format));
  }

  Future<bool> setAutoNormalize(bool value) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(autoNormalize: value));
  }

  Future<bool> setAutoSplit(bool value) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(autoSplit: value));
  }

  Future<bool> setWarningThreshold(int threshold) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(warningThreshold: threshold));
  }

  Future<bool> setTtsProvider(String providerId) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(ttsProvider: providerId));
  }

  /// Pass null to fall back to the address the app was built with.
  Future<bool> setBackendUrl(String? url) async {
    final settings = await getSettings();
    return updateSettings(settings.copyWith(backendUrl: url));
  }
}
