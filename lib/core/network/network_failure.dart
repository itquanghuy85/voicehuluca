import 'dart:io';

/// Why a request never reached the backend.
///
/// "Không kết nối được" is true for all of these and useless for every one of
/// them: a refused connection means the server is not listening, an unreachable
/// network means the two devices are on different Wi-Fi, and a failed lookup
/// means the address is a name instead of an IP. Each needs a different fix, so
/// each is reported separately.
enum NetworkFailure {
  /// Nothing is listening on that host and port.
  refused,

  /// The connection was accepted but no answer came in time.
  timedOut,

  /// There is no route to the host: different network, or the LAN blocks
  /// device-to-device traffic.
  unreachable,

  /// The hostname could not be resolved.
  dns,

  /// The TLS handshake failed.
  tls,

  /// Something else went wrong below the HTTP layer.
  unknown,
}

/// Classifies a failed request so the user is told what to change.
///
/// `package:http` converts socket errors into [ClientException] and keeps only
/// the message, so the error code is usually gone by the time this runs. The
/// platform messages are stable strings on both Android and iOS, so they are
/// matched explicitly and each pattern is covered by a test.
NetworkFailure classifyNetworkFailure(Object error) {
  if (error is SocketException) {
    final code = error.osError?.errorCode;
    // Android and iOS report POSIX codes, Windows reports Winsock codes.
    switch (code) {
      case 61 || 10061:
        return NetworkFailure.refused;
      case 60 || 10060:
        return NetworkFailure.timedOut;
      case 51 || 10051 || 65 || 10065:
        return NetworkFailure.unreachable;
      case 8 || 11001 || 11004:
        return NetworkFailure.dns;
    }
    final fromMessage = _fromText(_describe(error));
    if (fromMessage != NetworkFailure.unknown) return fromMessage;
    return NetworkFailure.unknown;
  }

  if (error is HandshakeException) return NetworkFailure.tls;

  return _fromText(_describe(error));
}

NetworkFailure _fromText(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('refused')) return NetworkFailure.refused;
  if (lower.contains('timed out') || lower.contains('timeout')) {
    return NetworkFailure.timedOut;
  }
  if (lower.contains('host lookup') ||
      lower.contains('name or service not known') ||
      lower.contains('nodename nor servname') ||
      lower.contains('no address associated')) {
    return NetworkFailure.dns;
  }
  if (lower.contains('unreachable') ||
      lower.contains('no route to host') ||
      lower.contains('network is down')) {
    return NetworkFailure.unreachable;
  }
  if (lower.contains('handshake') || lower.contains('certificate')) {
    return NetworkFailure.tls;
  }
  return NetworkFailure.unknown;
}

String _describe(Object error) {
  if (error is HandshakeException) {
    return '${error.message} ${error.osError?.message ?? ''}';
  }
  if (error is SocketException) {
    return '${error.osError?.message ?? ''} ${error.message}';
  }
  return error.toString();
}