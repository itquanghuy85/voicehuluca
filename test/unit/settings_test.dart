import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/data/models/app_settings.dart';

void main() {
  group('AppSettings model', () {
    test('creates AppSettings with default values', () {
      const settings = AppSettings();

      expect(settings.id, 1);
      expect(settings.themeMode, 'system');
      expect(settings.defaultVoiceId, isNull);
      expect(settings.defaultSpeed, 1.0);
      expect(settings.defaultFormat, 'mp3');
      expect(settings.autoNormalize, isTrue);
      expect(settings.autoSplit, isTrue);
      expect(settings.warningThreshold, 1000);
    });

    test('creates AppSettings with custom values', () {
      const settings = AppSettings(
        id: 2,
        themeMode: 'dark',
        defaultVoiceId: 5,
        defaultSpeed: 1.5,
        defaultFormat: 'wav',
        autoNormalize: false,
        autoSplit: false,
        warningThreshold: 2000,
      );

      expect(settings.id, 2);
      expect(settings.themeMode, 'dark');
      expect(settings.defaultVoiceId, 5);
      expect(settings.defaultSpeed, 1.5);
      expect(settings.defaultFormat, 'wav');
      expect(settings.autoNormalize, isFalse);
      expect(settings.autoSplit, isFalse);
      expect(settings.warningThreshold, 2000);
    });

    test('copyWith updates specified fields', () {
      const settings = AppSettings();
      final updated = settings.copyWith(themeMode: 'light', defaultSpeed: 1.25);

      expect(updated.themeMode, 'light');
      expect(updated.defaultSpeed, 1.25);
      expect(updated.id, settings.id);
      expect(updated.defaultFormat, settings.defaultFormat);
    });

    test('copyWith preserves fields when not specified', () {
      const settings = AppSettings(
        themeMode: 'dark',
        defaultVoiceId: 3,
        defaultSpeed: 0.75,
      );

      final updated = settings.copyWith(autoNormalize: false);

      expect(updated.themeMode, 'dark');
      expect(updated.defaultVoiceId, 3);
      expect(updated.defaultSpeed, 0.75);
      expect(updated.autoNormalize, isFalse);
    });

    test('fromJson creates AppSettings from JSON map', () {
      final json = {
        'id': 1,
        'themeMode': 'dark',
        'defaultVoiceId': 10,
        'defaultSpeed': 1.5,
        'defaultFormat': 'wav',
        'autoNormalize': false,
        'autoSplit': false,
        'warningThreshold': 500,
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.id, 1);
      expect(settings.themeMode, 'dark');
      expect(settings.defaultVoiceId, 10);
      expect(settings.defaultSpeed, 1.5);
      expect(settings.defaultFormat, 'wav');
      expect(settings.autoNormalize, isFalse);
      expect(settings.autoSplit, isFalse);
      expect(settings.warningThreshold, 500);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final settings = AppSettings.fromJson(json);

      expect(settings.id, 1);
      expect(settings.themeMode, 'system');
      expect(settings.defaultVoiceId, isNull);
      expect(settings.defaultSpeed, 1.0);
      expect(settings.defaultFormat, 'mp3');
      expect(settings.autoNormalize, isTrue);
      expect(settings.autoSplit, isTrue);
      expect(settings.warningThreshold, 1000);
    });

    test('toJson creates JSON map from AppSettings', () {
      const settings = AppSettings(
        id: 1,
        themeMode: 'light',
        defaultVoiceId: 5,
        defaultSpeed: 1.25,
        defaultFormat: 'ogg',
        autoNormalize: false,
        autoSplit: false,
        warningThreshold: 2000,
      );

      final json = settings.toJson();

      expect(json['id'], 1);
      expect(json['themeMode'], 'light');
      expect(json['defaultVoiceId'], 5);
      expect(json['defaultSpeed'], 1.25);
      expect(json['defaultFormat'], 'ogg');
      expect(json['autoNormalize'], isFalse);
      expect(json['autoSplit'], isFalse);
      expect(json['warningThreshold'], 2000);
    });

    test('toJson and fromJson are inverse operations', () {
      const original = AppSettings(
        id: 1,
        themeMode: 'dark',
        defaultVoiceId: 7,
        defaultSpeed: 0.75,
        defaultFormat: 'wav',
        autoNormalize: false,
        autoSplit: true,
        warningThreshold: 1500,
      );

      final json = original.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.themeMode, original.themeMode);
      expect(restored.defaultVoiceId, original.defaultVoiceId);
      expect(restored.defaultSpeed, original.defaultSpeed);
      expect(restored.defaultFormat, original.defaultFormat);
      expect(restored.autoNormalize, original.autoNormalize);
      expect(restored.autoSplit, original.autoSplit);
      expect(restored.warningThreshold, original.warningThreshold);
    });

    test('fromData creates AppSettings from table data', () {
      final data = AppSettingsTableData(
        id: 1,
        themeMode: 'light',
        defaultVoiceId: 3,
        defaultSpeed: 1.5,
        defaultFormat: 'mp3',
        autoNormalize: true,
        autoSplit: false,
        warningThreshold: 800,
        ttsProvider: 'elevenlabs',
      );

      final settings = AppSettings.fromData(data);

      expect(settings.id, 1);
      expect(settings.themeMode, 'light');
      expect(settings.defaultVoiceId, 3);
      expect(settings.defaultSpeed, 1.5);
      expect(settings.defaultFormat, 'mp3');
      expect(settings.autoNormalize, isTrue);
      expect(settings.autoSplit, isFalse);
      expect(settings.warningThreshold, 800);
      expect(settings.ttsProvider, 'elevenlabs');
    });
  });
}
