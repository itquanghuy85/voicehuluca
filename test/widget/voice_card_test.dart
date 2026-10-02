import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/features/voice/widgets/voice_card.dart';

Voice _voice({
  required String name,
  String? description,
  String language = 'vi',
  String gender = 'female',
  bool isCloned = false,
}) {
  final now = DateTime(2026, 1, 1);
  return Voice(
    id: 1,
    provider: 'local',
    providerVoiceId: 'clone:abc',
    name: name,
    description: description,
    language: language,
    gender: gender,
    isCloned: isCloned,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _host(Voice voice, {double width = 360}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: VoiceCard(
            voice: voice,
            isSelected: true,
            isPlaying: false,
            onTap: () {},
            onPreviewPressed: () {},
            onFavoritePressed: () {},
            onMenuSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a cloned voice card does not overflow on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        _voice(
          name: 'Clone E2E 6s',
          description: 'Giọng nhân bản từ mẫu thu',
          isCloned: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The cloned badge must be readable, not cut to "Nhân …".
    expect(find.text('Nhân bản'), findsOneWidget);
  });

  testWidgets('long names and language codes stay inside the card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        _voice(
          name: 'Một cái tên rất dài để kiểm tra việc cắt chữ không tràn ra',
          description: 'Mô tả cũng dài để xem chữ bị cắt gọn gàng',
          language: 'vi-VN',
          gender: 'unknown-long-value',
          isCloned: true,
        ),
        width: 320,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
