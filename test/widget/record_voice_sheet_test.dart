import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/design_system/app_theme.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/features/voice/widgets/record_voice_sheet.dart';

void main() {
  testWidgets('the name field starts empty so saving stays possible', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: RecordVoiceSheet()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final field = tester.widget<TextField>(find.byType(TextField));
    // Regression: the field used to be pre-filled with "Ví dụ: ..." and the
    // save button stayed disabled until the user erased that sample text.
    expect(field.controller?.text, isEmpty);
    expect(find.text(AppStrings.recordVoiceNameLabel), findsOneWidget);
    // No sample yet, so the sheet only offers to start recording.
    expect(find.text(AppStrings.recordVoiceStart), findsOneWidget);
    expect(find.text(AppStrings.recordVoiceSave), findsNothing);
  });

  testWidgets('typing a name is accepted as a real name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: RecordVoiceSheet()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'Giong cua toi');
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Giong cua toi',
    );
    expect(tester.takeException(), isNull);
  });
}
