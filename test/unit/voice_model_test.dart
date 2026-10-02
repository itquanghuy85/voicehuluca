import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/data/models/voice.dart';

void main() {
  group('Voice model', () {
    test('creates Voice with required fields', () {
      final voice = Voice(
        id: 1,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_female_01',
        name: 'Giọng Nữ 01',
        description: 'Giọng nữ trung tính',
        language: 'vi',
        gender: 'female',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(voice.id, 1);
      expect(voice.provider, 'elevenlabs');
      expect(voice.providerVoiceId, 'vn_female_01');
      expect(voice.name, 'Giọng Nữ 01');
      expect(voice.description, 'Giọng nữ trung tính');
      expect(voice.language, 'vi');
      expect(voice.gender, 'female');
      expect(voice.isCloned, isFalse);
      expect(voice.isFavorite, isFalse);
    });

    test('creates Voice with optional fields', () {
      final voice = Voice(
        id: 2,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_male_01',
        name: 'Giọng Nam 01',
        description: null,
        language: 'vi',
        gender: 'male',
        accent: 'northern',
        isCloned: true,
        isFavorite: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(voice.accent, 'northern');
      expect(voice.isCloned, isTrue);
      expect(voice.isFavorite, isTrue);
    });

    test('copyWith updates specified fields', () {
      final voice = Voice(
        id: 1,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_female_01',
        name: 'Giọng Nữ 01',
        description: 'Mô tả',
        language: 'vi',
        gender: 'female',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = voice.copyWith(name: 'Tên mới', isFavorite: true);

      expect(updated.name, 'Tên mới');
      expect(updated.isFavorite, isTrue);
      expect(updated.id, voice.id);
      expect(updated.provider, voice.provider);
    });

    test('copyWith preserves fields when not specified', () {
      final voice = Voice(
        id: 1,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_female_01',
        name: 'Giọng Nữ 01',
        description: 'Mô tả',
        language: 'vi',
        gender: 'female',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = voice.copyWith(isCloned: true);

      expect(updated.name, voice.name);
      expect(updated.description, voice.description);
      expect(updated.language, voice.language);
      expect(updated.gender, voice.gender);
      expect(updated.isCloned, isTrue);
    });

    test('fromJson creates Voice from JSON map', () {
      final json = {
        'id': 1,
        'provider': 'elevenlabs',
        'providerVoiceId': 'vn_female_01',
        'name': 'Giọng Nữ 01',
        'description': 'Mô tả',
        'language': 'vi',
        'gender': 'female',
        'accent': 'northern',
        'isCloned': true,
        'isFavorite': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final voice = Voice.fromJson(json);

      expect(voice.id, 1);
      expect(voice.provider, 'elevenlabs');
      expect(voice.providerVoiceId, 'vn_female_01');
      expect(voice.name, 'Giọng Nữ 01');
      expect(voice.isCloned, isTrue);
      expect(voice.isFavorite, isTrue);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'provider': 'elevenlabs',
        'providerVoiceId': 'vn_female_01',
        'name': 'Giọng Nữ 01',
        'language': 'vi',
        'gender': 'female',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final voice = Voice.fromJson(json);

      expect(voice.description, isNull);
      expect(voice.accent, isNull);
      expect(voice.isCloned, isFalse);
      expect(voice.isFavorite, isFalse);
    });

    test('toJson creates JSON map from Voice', () {
      final voice = Voice(
        id: 1,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_female_01',
        name: 'Giọng Nữ 01',
        description: 'Mô tả',
        language: 'vi',
        gender: 'female',
        accent: 'northern',
        isCloned: true,
        isFavorite: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = voice.toJson();

      expect(json['id'], 1);
      expect(json['provider'], 'elevenlabs');
      expect(json['providerVoiceId'], 'vn_female_01');
      expect(json['name'], 'Giọng Nữ 01');
      expect(json['description'], 'Mô tả');
      expect(json['language'], 'vi');
      expect(json['gender'], 'female');
      expect(json['accent'], 'northern');
      expect(json['isCloned'], isTrue);
      expect(json['isFavorite'], isTrue);
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('toJson and fromJson are inverse operations', () {
      final original = Voice(
        id: 1,
        provider: 'elevenlabs',
        providerVoiceId: 'vn_female_01',
        name: 'Giọng Nữ 01',
        description: 'Mô tả',
        language: 'vi',
        gender: 'female',
        accent: 'northern',
        isCloned: true,
        isFavorite: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = original.toJson();
      final restored = Voice.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.provider, original.provider);
      expect(restored.providerVoiceId, original.providerVoiceId);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.language, original.language);
      expect(restored.gender, original.gender);
      expect(restored.accent, original.accent);
      expect(restored.isCloned, original.isCloned);
      expect(restored.isFavorite, original.isFavorite);
    });
  });
}
