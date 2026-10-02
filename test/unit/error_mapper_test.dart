import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/errors/app_error.dart';
import 'package:voice_huluca/core/errors/error_mapper.dart';

void main() {
  group('mapError', () {
    test('returns AppError as-is', () {
      const error = NetworkError();
      expect(mapError(error), equals(error));
    });

    test('maps SocketException to NetworkError', () {
      final error = const SocketException('Connection refused');
      final result = mapError(error);
      expect(result, isA<NetworkError>());
    });

    test('maps TimeoutException to TimeoutError', () {
      final error = TimeoutException('Timed out', const Duration(seconds: 30));
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });

    test('maps FormatException to InvalidAudioError', () {
      final error = const FormatException('Invalid format');
      final result = mapError(error);
      expect(result, isA<InvalidAudioError>());
    });

    test('maps HttpException to NetworkError', () {
      final error = const HttpException('HTTP error');
      final result = mapError(error);
      expect(result, isA<NetworkError>());
    });

    test('maps unknown error to UnknownError', () {
      final error = Exception('Something went wrong');
      final result = mapError(error);
      expect(result, isA<UnknownError>());
    });
  });

  group('DioException mapping', () {
    test('maps connectionTimeout to TimeoutError', () {
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });

    test('maps sendTimeout to TimeoutError', () {
      final error = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });

    test('maps receiveTimeout to TimeoutError', () {
      final error = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });

    test('maps connectionError to NetworkError', () {
      final error = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<NetworkError>());
    });

    test('maps badCertificate to NetworkError', () {
      final error = DioException(
        type: DioExceptionType.badCertificate,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<NetworkError>());
    });

    test('maps cancel to UnknownError', () {
      final error = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapError(error);
      expect(result, isA<UnknownError>());
    });

    test('maps unknown with SocketException cause to NetworkError', () {
      final error = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        error: const SocketException('Connection refused'),
      );
      final result = mapError(error);
      expect(result, isA<NetworkError>());
    });

    test('maps unknown with TimeoutException cause to TimeoutError', () {
      final error = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        error: TimeoutException('Timed out', const Duration(seconds: 30)),
      );
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });
  });

  group('HTTP status code mapping', () {
    test('maps 401 to UnauthorizedError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      final result = mapError(error);
      expect(result, isA<UnauthorizedError>());
    });

    test('maps 403 to UnauthorizedError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );
      final result = mapError(error);
      expect(result, isA<UnauthorizedError>());
    });

    test('maps 429 to QuotaExceededError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 429,
        ),
      );
      final result = mapError(error);
      expect(result, isA<QuotaExceededError>());
    });

    test('maps 500 to ProviderUnavailableError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final result = mapError(error);
      expect(result, isA<ProviderUnavailableError>());
    });

    test('maps 503 to ProviderUnavailableError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
        ),
      );
      final result = mapError(error);
      expect(result, isA<ProviderUnavailableError>());
    });

    test('maps 400 to UnknownError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
        ),
      );
      final result = mapError(error);
      expect(result, isA<UnknownError>());
    });

    test('maps 404 to UnknownError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );
      final result = mapError(error);
      expect(result, isA<UnknownError>());
    });

    test('maps 408 to TimeoutError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 408,
        ),
      );
      final result = mapError(error);
      expect(result, isA<TimeoutError>());
    });
  });

  group('AppError properties', () {
    test('NetworkError has correct defaults', () {
      const error = NetworkError();
      expect(error.retryable, isTrue);
      expect(error.code, 'NETWORK_ERROR');
      expect(error.message, isNotEmpty);
    });

    test('UnauthorizedError has correct defaults', () {
      const error = UnauthorizedError();
      expect(error.retryable, isFalse);
      expect(error.code, 'UNAUTHORIZED');
    });

    test('QuotaExceededError has correct defaults', () {
      const error = QuotaExceededError();
      expect(error.retryable, isFalse);
      expect(error.code, 'QUOTA_EXCEEDED');
    });

    test('TimeoutError has correct defaults', () {
      const error = TimeoutError();
      expect(error.retryable, isTrue);
      expect(error.code, 'TIMEOUT');
    });

    test('ProviderUnavailableError has correct defaults', () {
      const error = ProviderUnavailableError();
      expect(error.retryable, isTrue);
      expect(error.code, 'PROVIDER_UNAVAILABLE');
    });

    test('InvalidAudioError has correct defaults', () {
      const error = InvalidAudioError();
      expect(error.retryable, isFalse);
      expect(error.code, 'INVALID_AUDIO');
    });

    test('CloningFailedError has correct defaults', () {
      const error = CloningFailedError();
      expect(error.retryable, isTrue);
      expect(error.code, 'CLONING_FAILED');
    });

    test('UnknownError has correct defaults', () {
      const error = UnknownError();
      expect(error.retryable, isTrue);
      expect(error.code, 'UNKNOWN');
    });

    test('custom message can be provided', () {
      const error = NetworkError(message: 'Custom network error');
      expect(error.message, 'Custom network error');
    });

    test('toString includes type and message', () {
      const error = NetworkError();
      final str = error.toString();
      expect(str, contains('NetworkError'));
      expect(str, contains(error.message));
    });
  });
}
