import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/data/datasources/local/audio_local_datasource.dart';

void main() {
  late AppDatabase database;
  late AudioLocalDataSource audioSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    audioSource = AudioLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> seedProject() async {
    return database
        .into(database.projects)
        .insert(const ProjectsCompanion(name: Value('Dự án test')));
  }

  Future<int> seedVoice() async {
    return database
        .into(database.voices)
        .insert(
          const VoicesCompanion(
            provider: Value('local'),
            providerVoiceId: Value('vi-VN-NamMinhNeural'),
            name: Value('Nam Minh'),
            language: Value('vi'),
            gender: Value('male'),
            isCloned: Value(false),
          ),
        );
  }

  Future<int> seedAudio({int projectId = 1, int voiceId = 1}) async {
    final id = await database
        .into(database.audioAssets)
        .insert(
          AudioAssetsCompanion.insert(
            projectId: projectId,
            voiceId: voiceId,
            title: 'Intro quan ca Pha',
            filePath: '/tmp/intro.mp3',
            format: 'mp3',
            durationMs: 12000,
            fileSize: 75000,
          ),
        );
    return id;
  }

  group('updateAudioAsset', () {
    test('chỉ đổi is_favorite mà không mất dữ liệu khác', () async {
      final projectId = await seedProject();
      final voiceId = await seedVoice();
      final audioId = await seedAudio(projectId: projectId, voiceId: voiceId);

      final ok = await audioSource.toggleFavorite(audioId, true);
      expect(ok, isTrue);

      final stored = await database.getAudioAsset(audioId);
      expect(stored, isNotNull);
      expect(stored!.isFavorite, isTrue);
      expect(stored.title, 'Intro quan ca Pha');
      expect(stored.filePath, '/tmp/intro.mp3');
      expect(stored.format, 'mp3');
      expect(stored.durationMs, 12000);
      expect(stored.fileSize, 75000);
      expect(stored.projectId, projectId);
      expect(stored.voiceId, voiceId);

      final favorites = await database.getFavoriteAudio();
      expect(favorites.map((a) => a.id), contains(audioId));
    });

    test('bỏ yêu thích cũng hoạt động', () async {
      final projectId = await seedProject();
      final voiceId = await seedVoice();
      final audioId = await seedAudio(projectId: projectId, voiceId: voiceId);

      await audioSource.toggleFavorite(audioId, true);
      final ok = await audioSource.toggleFavorite(audioId, false);

      expect(ok, isTrue);
      expect((await database.getAudioAsset(audioId))!.isFavorite, isFalse);
      expect(await database.getFavoriteAudio(), isEmpty);
    });

    test('trả về false khi audio không tồn tại', () async {
      expect(await audioSource.toggleFavorite(999, true), isFalse);
    });
  });

  group('updateAudioAsset with full companion', () {
    test('giữ nguyên id khi đổi tên', () async {
      final projectId = await seedProject();
      final voiceId = await seedVoice();
      final audioId = await seedAudio(projectId: projectId, voiceId: voiceId);

      final ok = await audioSource.updateAudio(
        (await audioSource.getAudioById(audioId))!.copyWith(title: 'Tên mới'),
      );

      expect(ok, isTrue);
      final stored = await database.getAudioAsset(audioId);
      expect(stored!.title, 'Tên mới');
      expect(stored.id, audioId);
    });
  });

  group('updateVoiceFavorite', () {
    test('đổi trạng thái yêu thích của giọng', () async {
      final voiceId = await seedVoice();

      expect(await database.updateVoiceFavorite(voiceId, true), 1);
      expect((await database.getVoice(voiceId))!.isFavorite, isTrue);
      expect((await database.getFavoriteVoices()).single.id, voiceId);
    });
  });

  group('updateSettings', () {
    test('cập nhật backendUrl mà không tạo dòng mới', () async {
      await database.updateSettings(
        const AppSettingsTableCompanion(
          backendUrl: Value('http://10.0.0.5:3000/v1'),
        ),
      );

      final settings = await database.getSettings();
      expect(settings.backendUrl, 'http://10.0.0.5:3000/v1');

      final rows = await database.select(database.appSettingsTable).get();
      expect(rows.length, 1);
    });
  });
}
