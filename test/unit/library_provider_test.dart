import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/data/datasources/local/audio_local_datasource.dart';
import 'package:voice_huluca/data/repositories/audio_repository_impl.dart';
import 'package:voice_huluca/features/audio_library/library_provider.dart';

void main() {
  late AppDatabase database;
  late AudioRepositoryImpl repository;
  late LibraryNotifier notifier;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AudioRepositoryImpl(AudioLocalDataSource(database));
    notifier = LibraryNotifier(repository);

    await database
        .into(database.projects)
        .insert(const ProjectsCompanion(name: Value('Dự án')));
    await database
        .into(database.voices)
        .insert(
          const VoicesCompanion(
            provider: Value('local'),
            providerVoiceId: Value('vi-VN-NamMinhNeural'),
            name: Value('Edge NamMinh'),
            language: Value('vi'),
            gender: Value('male'),
          ),
        );
  });

  tearDown(() async {
    notifier.dispose();
    await database.close();
  });

  /// setFilter/setSearchQuery start their own load, so give it time to finish.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  Future<void> insertAudio(
    String title, {
    required Duration age,
    bool isFavorite = false,
  }) async {
    final created = DateTime.now().subtract(age);
    await database
        .into(database.audioAssets)
        .insert(
          AudioAssetsCompanion.insert(
            projectId: 1,
            voiceId: 1,
            title: title,
            filePath: '/tmp/$title.mp3',
            format: 'mp3',
            durationMs: 1000,
            fileSize: 100,
            createdAt: Value(created),
            isFavorite: Value(isFavorite),
          ),
        );
  }

  group('Library ordering', () {
    test('shows the newest audio first', () async {
      await insertAudio('cũ nhất', age: const Duration(days: 2));
      await insertAudio('mới nhất', age: const Duration(minutes: 1));
      await insertAudio('giữa', age: const Duration(hours: 5));

      await notifier.loadLibrary(refresh: true);

      expect(notifier.state.audios.map((a) => a.title), [
        'mới nhất',
        'giữa',
        'cũ nhất',
      ]);
    });

    test('search results are newest first too', () async {
      await insertAudio('kịch bản A cũ', age: const Duration(days: 3));
      await insertAudio('kịch bản B mới', age: const Duration(minutes: 2));

      notifier.setSearchQuery('kịch bản');
      await settle();

      expect(notifier.state.audios.map((a) => a.title), [
        'kịch bản B mới',
        'kịch bản A cũ',
      ]);
    });
  });

  group('Library filters', () {
    test('"Gần đây" only lists the last seven days', () async {
      await insertAudio('mới trong tuần', age: const Duration(days: 2));
      await insertAudio('cũ ngoài tháng', age: const Duration(days: 40));

      notifier.setFilter(LibraryFilter.recent);
      await settle();

      expect(notifier.state.audios.map((a) => a.title), ['mới trong tuần']);
    });

    test('"Tất cả" keeps old audio as well', () async {
      await insertAudio('mới trong tuần', age: const Duration(days: 2));
      await insertAudio('cũ ngoài tháng', age: const Duration(days: 40));

      notifier.setFilter(LibraryFilter.all);
      await settle();

      expect(notifier.state.audios.length, 2);
    });

    test('"Yêu thích" lists only favourites, newest first', () async {
      await insertAudio(
        'thích cũ',
        age: const Duration(days: 9),
        isFavorite: true,
      );
      await insertAudio(
        'thích mới',
        age: const Duration(days: 1),
        isFavorite: true,
      );
      await insertAudio('không thích', age: const Duration(minutes: 1));

      notifier.setFilter(LibraryFilter.favorites);
      await settle();

      expect(notifier.state.audios.map((a) => a.title), [
        'thích mới',
        'thích cũ',
      ]);
    });
  });

  group('Library persistence of a favourite', () {
    test('the flag survives a reload from the database', () async {
      await insertAudio('bài hát', age: const Duration(minutes: 3));
      await notifier.loadLibrary(refresh: true);
      final id = notifier.state.audios.single.id;

      expect(await notifier.toggleFavorite(id), isTrue);

      await notifier.loadLibrary(refresh: true);
      expect(notifier.state.audios.single.isFavorite, isTrue);
      expect((await database.getFavoriteAudio()).single.id, id);
    });
  });
}
