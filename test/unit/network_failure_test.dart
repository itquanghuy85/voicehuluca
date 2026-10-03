import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/network/network_failure.dart';

/// Every transport failure was reported as one "không kết nối được" message.
/// They need different fixes, so each one has to be told apart, and
/// `package:http` throws away the error code, so the messages matter.
void main() {
  group('classifyNetworkFailure', () {
    test('a refused connection is not a timeout and not a wrong address', () {
      expect(
        classifyNetworkFailure(
          SocketException('Connection refused', osError: _osError(61)),
        ),
        NetworkFailure.refused,
      );
      expect(
        classifyNetworkFailure(
          SocketException('Connection refused', osError: _osError(10061)),
        ),
        NetworkFailure.refused,
      );
    });

    test('a timeout is reported as a timeout', () {
      expect(
        classifyNetworkFailure(
          SocketException('timed out', osError: _osError(60)),
        ),
        NetworkFailure.timedOut,
      );
    });

    test('an unreachable network is not confused with a refused port', () {
      expect(
        classifyNetworkFailure(
          SocketException('', osError: _osError(51)),
        ),
        NetworkFailure.unreachable,
      );
      expect(
        classifyNetworkFailure(
          SocketException('', osError: _osError(65)),
        ),
        NetworkFailure.unreachable,
      );
    });

    test('a failed hostname lookup is reported as DNS, not as unreachable', () {
      expect(
        classifyNetworkFailure(
          SocketException('', osError: _osError(8)),
        ),
        NetworkFailure.dns,
      );
    });

    test('the platform messages survive losing the error code', () {
      // This is the shape package:http actually throws.
      expect(
        classifyNetworkFailure(
          SocketException('Connection refused', osError: null),
        ),
        NetworkFailure.refused,
      );
      expect(
        classifyNetworkFailure(
          const ClientExceptionLike('Failed host lookup: api.vietvoice.studio'),
        ),
        NetworkFailure.dns,
      );
      expect(
        classifyNetworkFailure(
          const ClientExceptionLike('Connection timed out'),
        ),
        NetworkFailure.timedOut,
      );
      expect(
        classifyNetworkFailure(
          const ClientExceptionLike('No route to host'),
        ),
        NetworkFailure.unreachable,
      );
      expect(
        classifyNetworkFailure(
          const ClientExceptionLike('Network is unreachable'),
        ),
        NetworkFailure.unreachable,
      );
    });

    test('a TLS failure is separated from a network failure', () {
      expect(
        classifyNetworkFailure(
          const HandshakeException('Handshake error in client'),
        ),
        NetworkFailure.tls,
      );
    });

    test('an unrecognised failure does not pretend to know the cause', () {
      expect(
        classifyNetworkFailure(SocketException('', osError: null)),
        NetworkFailure.unknown,
      );
    });
  });
}

OSError _osError(int code) => OSError('test', code);

/// Stands in for `package:http`'s ClientException, which keeps only a message.
class ClientExceptionLike implements Exception {
  const ClientExceptionLike(this.message);

  final String message;

  @override
  String toString() => 'ClientException: $message';
}