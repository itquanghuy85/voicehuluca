import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voice_huluca/core/errors/app_error.dart';

AppError mapError(Object error) {
  if (error is AppError) return error;
  if (error is DioException) return _mapDioException(error);
  if (error is SocketException) {
    return const NetworkError();
  }
  if (error is TimeoutException) {
    return const TimeoutError();
  }
  if (error is FormatException) {
    return const InvalidAudioError();
  }
  if (error is HttpException) {
    return const NetworkError();
  }
  return UnknownError(message: error.toString());
}

AppError _mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutError();
    case DioExceptionType.connectionError:
      return const NetworkError();
    case DioExceptionType.badResponse:
      return _mapStatusCode(error.response?.statusCode);
    case DioExceptionType.cancel:
      return const UnknownError(
        message: 'Yêu cầu đã bị hủy.',
        code: 'REQUEST_CANCELLED',
      );
    case DioExceptionType.unknown:
      final cause = error.error;
      if (cause is SocketException) return const NetworkError();
      if (cause is TimeoutException) return const TimeoutError();
      return UnknownError(message: error.message ?? 'Unknown error');
    case DioExceptionType.badCertificate:
      return const NetworkError(
        message: 'Lỗi chứng chỉ bảo mật.',
        code: 'BAD_CERTIFICATE',
      );
  }
}

AppError _mapStatusCode(int? statusCode) {
  if (statusCode == null) return const UnknownError();
  switch (statusCode) {
    case 400:
      return const UnknownError(
        message: 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.',
        code: 'BAD_REQUEST',
      );
    case 401:
      return const UnauthorizedError();
    case 403:
      return const UnauthorizedError(
        message: 'Truy cập bị từ chối.',
        code: 'FORBIDDEN',
      );
    case 404:
      return const UnknownError(
        message: 'Không tìm thấy tài nguyên.',
        code: 'NOT_FOUND',
      );
    case 408:
      return const TimeoutError();
    case 413:
      return const UnknownError(
        message: 'Dữ liệu gửi lên quá lớn.',
        code: 'PAYLOAD_TOO_LARGE',
      );
    case 429:
      return const QuotaExceededError(
        message: 'Quá nhiều yêu cầu. Vui lòng chờ một chút.',
        code: 'RATE_LIMITED',
      );
    case 500:
    case 502:
    case 503:
    case 504:
      return const ProviderUnavailableError();
    default:
      if (statusCode >= 400 && statusCode < 500) {
        return UnknownError(
          message: 'Lỗi máy khách: $statusCode',
          code: 'CLIENT_ERROR_$statusCode',
        );
      }
      if (statusCode >= 500) {
        return ProviderUnavailableError(
          message: 'Lỗi máy chủ: $statusCode',
          code: 'SERVER_ERROR_$statusCode',
        );
      }
      return UnknownError(
        message: 'Lỗi không xác định: $statusCode',
        code: 'HTTP_$statusCode',
      );
  }
}
