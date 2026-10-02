import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/design_system/app_icons.dart';
import 'package:voice_huluca/core/design_system/app_theme.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/data/datasources/local/audio_local_datasource.dart';
import 'package:voice_huluca/data/repositories/audio_repository_impl.dart';
import 'package:voice_huluca/features/audio_library/library_provider.dart';
import 'package:voice_huluca/features/audio_library/library_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database
        .into(database.projects)
        .insert(const ProjectsCompanion(name: Value('Dự án')));
    await database
        .into(database.voices)
        .insert(
          const VoicesCompanion(
            provider: Value('local'),
            providerVoiceId: Value('vi-VN-NamMinhNeural'),
            name: Value('Edge NamMinh (nam) rất là dài và khó đọc'),
            language: Value('vi'),
            gender: Value('male'),
          ),
        );
    await database
        .into(database.audioAssets)
        .insert(
          AudioAssetsCompanion.insert(
            projectId: 1,
            voiceId: 1,
            title: 'Chào mừng bạn đến với VietVoice Studio của chúng tôi',
            filePath: '/tmp/a.mp3',
            format: 'mp3',
            durationMs: 23000,
            fileSize: 142704,
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          libraryProvider.overrideWith(
            (ref) => LibraryNotifier(
              AudioRepositoryImpl(
                AudioLocalDataSource(ref.watch(appDatabaseProvider)),
              ),
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const LibraryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a long voice name does not overflow the card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpLibrary(tester);

    expect(find.textContaining('Edge NamMinh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the newest audio is listed first', (tester) async {
    await database
        .into(database.audioAssets)
        .insert(
          AudioAssetsCompanion.insert(
            projectId: 1,
            voiceId: 1,
            title: 'Audio cũ hơn',
            filePath: '/tmp/b.mp3',
            format: 'mp3',
            durationMs: 1000,
            fileSize: 100,
            createdAt: Value(DateTime.now().subtract(const Duration(days: 3))),
          ),
        );

    await pumpLibrary(tester);

    final titles = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(
      titles.indexOf('Chào mừng bạn đến với VietVoice Studio của chúng tôi'),
      lessThan(titles.indexOf('Audio cũ hơn')),
    );
  });

  testWidgets('favouriting from the menu reports success', (tester) async {
    await pumpLibrary(tester);

    await tester.tap(find.byIcon(AppIcons.more).first);
    await tester.pumpAndSettle();
    // The filter chip and the menu action share the same label, so pick the
    // action inside the action sheet.
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoActionSheet),
        matching: find.text('Yêu thích'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đã thêm vào yêu thích'), findsOneWidget);
    expect((await database.getFavoriteAudio()).length, 1);
    expect(tester.takeException(), isNull);
  });
}
