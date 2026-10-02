import 'dart:async';
import 'dart:io';

import 'backend_endpoint.dart';

/// A VietVoice backend found on the local network.
class DiscoveredBackend {
  final String baseUrl;
  final int latencyMs;

  const DiscoveredBackend({required this.baseUrl, required this.latencyMs});

  ({String host, int port})? get endpoint =>
      BackendEndpoint.endpointOf(baseUrl);

  @override
  bool operator ==(Object other) =>
      other is DiscoveredBackend && other.baseUrl == baseUrl;

  @override
  int get hashCode => baseUrl.hashCode;

  @override
  String toString() => '$baseUrl (${latencyMs}ms)';
}

/// Probes one address. Returns the round trip time in milliseconds, or null
/// when nothing VietVoice-like answered.
typedef BackendProbe = Future<int?> Function(Uri healthUri);

/// Finds the backend on the same Wi-Fi instead of asking the user for an IP.
///
/// The app cannot rely on a fixed address on a home or office network, so it
/// takes the address the phone already has, walks the rest of that /24 and asks
/// each host for `GET /v1/health`. Only hosts that answer with the VietVoice
/// signature are reported.
class LanBackendScanner {
  const LanBackendScanner();

  static const int defaultPort = 3000;
  static const Duration probeTimeout = Duration(milliseconds: 600);
  static const int concurrency = 32;

  /// Private IPv4 ranges only: a public address cannot host a LAN backend.
  static bool isPrivate(String address) {
    final parts = address.split('.');
    if (parts.length != 4) return false;
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((part) => part == null || part < 0 || part > 255)) {
      return false;
    }
    final a = octets[0]!;
    final b = octets[1]!;
    if (a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    return false;
  }

  /// The device's own address, which may be the server when the phone is on the
  /// same machine as the backend (emulators, single-PC setups).
  static Future<List<String>> localAddresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      return interfaces
          .where(
            (iface) =>
                iface.name.startsWith('wlan') || iface.name.startsWith('wi-fi'),
          )
          .expand((iface) => iface.addresses)
          .map((address) => address.address)
          .where(isPrivate)
          .toList();
    } on SocketException {
      return const [];
    }
  }

  /// Host part of `192.168.1.37` -> `192.168.1`, skipping the last octet.
  static String? subnetOf(String address) {
    final parts = address.split('.');
    if (parts.length != 4) return null;
    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  /// Every candidate host in the same /24 as [address].
  static List<String> neighboursOf(String address) {
    final subnet = subnetOf(address);
    if (subnet == null) return const [];
    return [for (var host = 1; host <= 254; host++) '$subnet.$host'];
  }

  /// Runs [probe] over the local subnet and returns what answered, fastest
  /// first. [onProgress] reports how many hosts have been checked so the UI can
  /// show a moving counter instead of a frozen spinner.
  Future<List<DiscoveredBackend>> scan({
    BackendProbe? probe,
    int port = defaultPort,
    List<String>? addresses,
    Duration timeout = probeTimeout,
    int parallelism = concurrency,
    void Function(int checked, int total)? onProgress,
  }) async {
    final local = addresses ?? await localAddresses();
    final hosts = <String>{};
    for (final address in local) {
      hosts.addAll(neighboursOf(address));
    }
    if (hosts.isEmpty) {
      return const [];
    }

    final candidates = hosts.toList();
    final found = <DiscoveredBackend>[];
    var checked = 0;

    for (var start = 0; start < candidates.length; start += parallelism) {
      final end = (start + parallelism).clamp(0, candidates.length);
      final batch = candidates.sublist(start, end);
      final results = await Future.wait(
        batch.map((host) => _probeHost(host, port, timeout, probe)),
      );
      for (final result in results) {
        if (result != null) {
          found.add(result);
        }
      }
      checked += batch.length;
      onProgress?.call(checked, candidates.length);
    }

    found.sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
    return found;
  }

  /// Asks one known address whether it is a VietVoice backend.
  ///
  /// Returns the round trip time in milliseconds, or null when the host is
  /// unreachable or answers with something else.
  Future<int?> ping(String baseUrl, {Duration timeout = probeTimeout}) async {
    return _httpProbe(Uri.parse('$baseUrl/health'), timeout);
  }

  Future<DiscoveredBackend?> _probeHost(
    String host,
    int port,
    Duration timeout,
    BackendProbe? probe,
  ) async {
    final baseUrl = 'http://$host:$port${BackendEndpoint.apiSuffix}';
    final uri = Uri.parse('$baseUrl/health');
    final latency = await (probe?.call(uri) ?? _httpProbe(uri, timeout));
    if (latency == null) {
      return null;
    }
    return DiscoveredBackend(baseUrl: baseUrl, latencyMs: latency);
  }

  /// The shipped probe: a real request that must come from a VietVoice backend.
  Future<int?> _httpProbe(Uri uri, Duration timeout) async {
    final client = HttpClient()
      ..connectionTimeout = timeout
      ..userAgent = 'VietVoiceStudio/1.0 (discovery)';
    final stopwatch = Stopwatch()..start();
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }
      final body = await response
          .transform(const SystemEncoding().decoder)
          .join();
      stopwatch.stop();
      // The signature keeps the scanner from reporting random web servers.
      if (!body.contains('vietvoice-backend')) {
        return null;
      }
      return stopwatch.elapsedMilliseconds == 0
          ? 1
          : stopwatch.elapsedMilliseconds;
    } on Object {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
