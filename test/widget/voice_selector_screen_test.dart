import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/design_system/app_theme.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/features/voice/voice_selector_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database
        .into(database.voices)
        .insert(
          const VoicesCompanion(
            provider: Value('local'),
            providerVoiceId: Value('vi-VN-NamMinhNeural'),
            name: Value('Edge NamMinh (nam)'),
            language: Value('vi'),
            gender: Value('male'),
          ),
        );
    await database
        .into(database.voices)
        .insert(
          const VoicesCompanion(
            provider: Value('local'),
            providerVoiceId: Value('clone-1'),
            name: Value('Giọng nhân bản của tôi'),
            language: Value('vi'),
            gender: Value('female'),
            isCloned: Value(true),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpSelector(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const VoiceSelectorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every filter chip shows its full label on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpSelector(tester);

    for (final label in ['Tất cả', 'Giọng của tôi', 'Nam', 'Nữ', 'Yêu thích']) {
      final text = tester.widget<Text>(find.text(label).first);
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
    }
    expect(tester.takeException(), isNull);
  });
}
