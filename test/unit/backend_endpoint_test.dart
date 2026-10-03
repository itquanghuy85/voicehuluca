import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/network/backend_discovery.dart';
import 'package:voice_huluca/core/network/backend_endpoint.dart';

void main() {
  group('Backend address the user typed', () {
    test('a bare host and port becomes an http API URL', () {
      expect(
        BackendEndpoint.parse('192.168.1.20:3000').url,
        'http://192.168.1.20:3000/v1',
      );
    });

    test('a host without a port is accepted', () {
      expect(
        BackendEndpoint.parse('192.168.1.20').url,
        'http://192.168.1.20/v1',
      );
    });

    test('a trailing slash or an existing /v1 is not duplicated', () {
      expect(
        BackendEndpoint.parse('http://192.168.1.20:3000/').url,
        'http://192.168.1.20:3000/v1',
      );
      expect(
        BackendEndpoint.parse('http://192.168.1.20:3000/v1/').url,
        'http://192.168.1.20:3000/v1',
      );
    });

    test('https and a host name are kept', () {
      expect(
        BackendEndpoint.parse('https://api.vietvoice.studio/v1').url,
        'https://api.vietvoice.studio/v1',
      );
      expect(
        BackendEndpoint.parse('vps.example.com/api/v1').url,
        'http://vps.example.com/api/v1',
      );
    });

    test('whitespace around the value is ignored', () {
      expect(
        BackendEndpoint.parse('  10.0.0.5:3000  ').url,
        'http://10.0.0.5:3000/v1',
      );
    });

    test('empty and unusable values explain themselves', () {
      expect(BackendEndpoint.parse('').url, isNull);
      expect(BackendEndpoint.parse('   ').message, isNotNull);
      expect(BackendEndpoint.parse('ftp://host').url, isNull);
      expect(BackendEndpoint.parse('http://').url, isNull);
    });

    test('a stored address falls back to the compiled default', () {
      expect(BackendEndpoint.resolve(null), isNotEmpty);
      expect(
        BackendEndpoint.resolve('192.168.1.20:3000'),
        'http://192.168.1.20:3000/v1',
      );
      expect(BackendEndpoint.resolve('nonsense://'), isNotEmpty);
    });

    test('host and port can be read back for display and probing', () {
      expect(BackendEndpoint.endpointOf('http://192.168.1.20:3000/v1'), (
        host: '192.168.1.20',
        port: 3000,
      ));
      expect(BackendEndpoint.endpointOf('https://api.vietvoice.studio/v1'), (
        host: 'api.vietvoice.studio',
        port: 443,
      ));
      expect(BackendEndpoint.endpointOf('http://'), isNull);
    });
  });

  group('Which addresses the scanner looks at', () {
    test('only private IPv4 ranges count', () {
      expect(LanBackendScanner.isPrivate('192.168.1.20'), isTrue);
      expect(LanBackendScanner.isPrivate('10.0.0.5'), isTrue);
      expect(LanBackendScanner.isPrivate('172.16.4.4'), isTrue);
      expect(LanBackendScanner.isPrivate('172.32.4.4'), isFalse);
      expect(LanBackendScanner.isPrivate('8.8.8.8'), isFalse);
      expect(LanBackendScanner.isPrivate('127.0.0.1'), isFalse);
      expect(LanBackendScanner.isPrivate('not-an-ip'), isFalse);
      expect(LanBackendScanner.isPrivate('192.168.1.300'), isFalse);
    });

    test('the whole /24 around the device address is a candidate list', () {
      final neighbours = LanBackendScanner.neighboursOf('192.168.1.37');
      expect(neighbours.length, 254);
      expect(neighbours.first, '192.168.1.1');
      expect(neighbours.last, '192.168.1.254');
      expect(LanBackendScanner.neighboursOf('nonsense'), isEmpty);
    });

    test('Wi-Fi interfaces are preferred on every platform naming', () {
      expect(
        LanBackendScanner.selectLocalAddresses({
          'wlan0': ['192.168.68.117'],
          'pdp_ip0': ['10.20.30.40'],
        }),
        ['192.168.68.117'],
      );
      expect(
        LanBackendScanner.selectLocalAddresses({
          'en0': ['192.168.68.117'],
          'pdp_ip0': ['10.20.30.40'],
        }),
        ['192.168.68.117'],
      );
    });

    test('an interface name the platform invents still yields an address', () {
      // iOS names Wi-Fi en0 today; a name outside the known prefixes must not
      // be able to make discovery report "no local address".
      expect(
        LanBackendScanner.selectLocalAddresses({
          'bridge100': ['192.168.68.117'],
        }),
        ['192.168.68.117'],
      );
      expect(
        LanBackendScanner.selectLocalAddresses({
          'en9': ['192.168.1.20'],
          'en0': ['169.254.9.9'],
        }),
        ['192.168.1.20'],
      );
    });

    test('public and link-local addresses are never scanned', () {
      expect(
        LanBackendScanner.selectLocalAddresses({
          'en0': ['8.8.8.8', '169.254.1.1', '127.0.0.1'],
        }),
        isEmpty,
      );
    });

    test('the interfaces of the machine running the test are usable', () async {
      // Exercises the real dart:io path, so a throwing or empty enumeration is
      // caught here instead of on a phone.
      final report = await LanBackendScanner.interfaceReport();
      expect(report.isNotEmpty, isTrue);
      final addresses = await LanBackendScanner.localAddresses();
      expect(addresses.every(LanBackendScanner.isPrivate), isTrue);
    });
  });

  group('Scanning the local subnet', () {
    const scanner = LanBackendScanner();

    test('reports only hosts that answer, fastest first', () async {
      final probed = <String>[];

      final found = await scanner.scan(
        addresses: const ['192.168.5.10'],
        parallelism: 64,
        probe: (uri) async {
          probed.add(uri.host);
          if (uri.host == '192.168.5.42') return 42;
          if (uri.host == '192.168.5.7') return 7;
          return null;
        },
      );

      expect(probed.length, 254);
      expect(found.map((server) => server.baseUrl), [
        'http://192.168.5.7:3000/v1',
        'http://192.168.5.42:3000/v1',
      ]);
      expect(found.first.latencyMs, 7);
    });

    test('the probe is asked for /v1/health on the backend port', () async {
      Uri? asked;
      await scanner.scan(
        addresses: const ['192.168.5.10'],
        port: 8080,
        parallelism: 254,
        probe: (uri) async {
          asked ??= uri;
          return null;
        },
      );

      expect(asked.toString(), 'http://192.168.5.1:8080/v1/health');
    });

    test('two subnets are scanned once each, hosts are not repeated', () async {
      var calls = 0;
      await scanner.scan(
        addresses: const ['192.168.5.10', '192.168.5.11'],
        parallelism: 254,
        probe: (_) async {
          calls++;
          return null;
        },
      );

      expect(calls, 254);
    });

    test('progress is reported for every batch', () async {
      final progress = <int>[];
      await scanner.scan(
        addresses: const ['192.168.5.10'],
        parallelism: 100,
        probe: (_) async => null,
        onProgress: (checked, total) {
          expect(total, 254);
          progress.add(checked);
        },
      );

      expect(progress, [100, 200, 254]);
    });

    test('an empty or public address list scans nothing', () async {
      var calls = 0;
      final found = await scanner.scan(
        addresses: const [],
        probe: (_) async {
          calls++;
          return 1;
        },
      );

      expect(found, isEmpty);
      expect(calls, 0);
    });
  });

  test('a discovered server knows its host and port', () {
    const server = DiscoveredBackend(
      baseUrl: 'http://192.168.1.20:3000/v1',
      latencyMs: 12,
    );
    expect(server.endpoint, (host: '192.168.1.20', port: 3000));
  });
}
