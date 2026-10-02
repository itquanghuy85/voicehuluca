import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voice_huluca/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VietVoiceStudioApp()));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(VietVoiceStudioApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
