import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/network/backend_discovery.dart';

/// Verifies the shipped probe against the backend actually running on this
/// machine. Skips when nothing is listening, so it never fails a plain
/// `flutter test`.
void main() {
  test('the real probe accepts the live backend signature', () async {
    const scanner = LanBackendScanner();
    const baseUrl = 'http://${String.fromEnvironment('LAN_BACKEND_IP')}'
        ':3000/v1';
    if (baseUrl.contains('String.fromEnvironment')) {
      // No IP injected: nothing to probe.
      return;
    }
    final latency = await scanner.ping(baseUrl, timeout: const Duration(seconds: 5));
    expect(latency, isNotNull, reason: 'live backend must be detected');
    expect(latency, greaterThanOrEqualTo(0));

    // Discovery deliberately never reports this device's own address: on a
    // phone that would be the phone's IP, which is never the backend. Here the
    // backend happens to run on the same machine, so the scan must skip it.
    final onSelf = await scanner.scan(
      addresses: [Uri.parse(baseUrl).host],
      probe: (uri) async => uri.host == Uri.parse(baseUrl).host ? 5 : null,
    );
    expect(onSelf, isEmpty, reason: 'the device itself is never a candidate');

    // The same host is still reported when it is a *different* device, which is
    // the real iPhone case.
    final asPeer = await scanner.scan(
      addresses: ['192.168.68.1'],
      probe: (uri) async => uri.host == Uri.parse(baseUrl).host ? 5 : null,
    );
    expect(asPeer.map((server) => server.baseUrl), contains(baseUrl));
  });

  test('a closed port is not reported as a backend', () async {
    const scanner = LanBackendScanner();
    final latency = await scanner.ping(
      'http://127.0.0.1:3999/v1',
      timeout: const Duration(seconds: 2),
    );
    expect(latency, isNull);
  });
}
