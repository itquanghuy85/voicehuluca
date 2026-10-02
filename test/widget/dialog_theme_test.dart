import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/design_system/app_theme.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';

void main() {
  group('Dialog text stays readable', () {
    testWidgets('title and content are not invisible on a light surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(
                    AppStrings.providerFallbackTitleFor('ElevenLabs'),
                  ),
                  content: Text(
                    AppStrings.providerFallbackDescFor(
                      'TTS trên máy',
                      'ElevenLabs',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        AppStrings.providerFallbackStay('TTS trên máy'),
                      ),
                    ),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Chuyển sang ElevenLabs?'), findsOneWidget);
      expect(
        find.textContaining('TTS trên máy không tạo được âm thanh'),
        findsOneWidget,
      );
      expect(find.text('Giữ TTS trên máy'), findsOneWidget);

      // Regression: these styles used to carry no colour, so the text was
      // painted white on the white dialog surface.
      final dialogTheme = AppTheme.light.dialogTheme;
      expect(dialogTheme.titleTextStyle?.color, isNotNull);
      expect(dialogTheme.contentTextStyle?.color, isNotNull);

      final renderedTitle = tester.widget<Text>(
        find.text('Chuyển sang ElevenLabs?'),
      );
      expect(renderedTitle.data, isNotEmpty);
    });
  });

  group('Fallback wording names the providers actually in use', () {
    test('stay button keeps the current provider', () {
      expect(AppStrings.providerFallbackStay('Google TTS'), 'Giữ Google TTS');
      expect(
        AppStrings.providerFallbackStay('TTS trên máy'),
        'Giữ TTS trên máy',
      );
    });

    test('description mentions both providers', () {
      final message = AppStrings.providerFallbackDescFor(
        'TTS trên máy',
        'ElevenLabs',
      );
      expect(message, contains('TTS trên máy'));
      expect(message, contains('ElevenLabs'));
    });
  });
}
