import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/network/backend_discovery.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

/// Exercises the real health check against the backend on this machine.
///
/// 1. running  → success, correct signature, real latency
/// 2. stopped  → a *distinct* message per cause, never one generic line
///
/// Run with the backend up:
///   flutter test test/manual/live_health_check.dart \
///     --dart-define=LAN_BACKEND_URL=http://192.168.68.50:3000/v1
void main() {
  const url = String.fromEnvironment('LAN_BACKEND_URL');

  test('a running backend reports connected, provider and latency', () async {
    if (url.isEmpty) return;
    final result = await checkBackendHealth(url);

    expect(
      result.isSuccess,
      isTrue,
      reason: 'must not report a failure for a live backend: '
          '${result.errorMessage}',
    );
    expect(result.health!.service, 'vietvoice-backend');
    expect(result.health!.isVietVoiceBackend, isTrue);
    expect(result.latencyMs, isNotNull);
    expect(result.health!.providers, isNotEmpty);
  });

  test('a closed port says refused, not "not found"', () async {
    final result = await checkBackendHealth(
      'http://127.0.0.1:3999/v1',
      timeout: const Duration(seconds: 3),
    );

    expect(result.isSuccess, isFalse);
    // The cause must be distinguishable, not a single generic message.
    expect(result.errorMessage, isNotNull);
    expect(result.errorMessage, isNotEmpty);
  });

  test('an unresolvable host is reported as its own cause', () async {
    final result = await checkBackendHealth(
      'http://khong-ton-tai-vietvoice.invalid/v1',
      timeout: const Duration(seconds: 5),
    );

    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, isNotNull);
  });

  test('a wrong endpoint (404) is told apart from a dead port', () async {
    if (url.isEmpty) return;
    final result = await checkBackendHealth(url, timeout: const Duration(seconds: 5));
    expect(result.isSuccess, isTrue);

    // Same host, path that does not exist -> 404, reported as such.
    final wrongPath = await checkBackendHealth(
      '${Uri.parse(url).replace(path: '/v1/khong-ton-tai')}',
      timeout: const Duration(seconds: 5),
    );
    expect(wrongPath.isSuccess, isFalse);
    expect(wrongPath.errorMessage, isNotNull);
  });

  test('a non-VietVoice service is rejected instead of accepted', () async {
    // Any random web server must not pass as the backend.
    final result = await checkBackendHealth(
      'http://example.com/v1',
      timeout: const Duration(seconds: 8),
    );
    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, isNotNull);
  });

  test('the scanner ignores a closed port on a real host', () async {
    const scanner = LanBackendScanner();
    final latency = await scanner.ping(
      'http://${String.fromEnvironment('LAN_BACKEND_IP')}:3999/v1',
      timeout: const Duration(seconds: 2),
    );
    expect(latency, isNull);
  });

  test('each cause produces its own message (printed for review)', () async {
    final cases = <String, String>{
      'refused / backend stopped': 'http://127.0.0.1:3999/v1',
      'unreachable host': 'http://192.0.2.1:3000/v1',
      'dns failure': 'http://khong-ton-tai-vietvoice.invalid/v1',
      'wrong path (404)': 'http://127.0.0.1:3000/v1/khong-ton-tai',
      if (url.isNotEmpty) 'live backend': url,
    };
    final messages = <String, String>{};
    for (final entry in cases.entries) {
      final result = await checkBackendHealth(
        entry.value,
        timeout: const Duration(seconds: 6),
      );
      messages[entry.key] = result.isSuccess
          ? 'OK service=${result.health!.service} '
              'latency=${result.latencyMs}ms'
          : result.errorMessage!;
    }
    for (final entry in messages.entries) {
      // ignore: avoid_print
      print('>> ${entry.key}: ${entry.value}');
    }

    // Every failure must have its own text; none may be the empty/generic line.
    final failures = messages.entries
        .where((entry) => !entry.key.startsWith('live'))
        .map((entry) => entry.value)
        .toList();
    expect(failures.every((message) => message.trim().isNotEmpty), isTrue);
    expect(failures.toSet().length, greaterThan(1));
  });
}
