sealed class AppError {
  final String message;
  final String? code;
  final bool retryable;

  const AppError({required this.message, this.code, this.retryable = false});

  @override
  String toString() => 'AppError($runtimeType): $message';
}

class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
    super.code = 'NETWORK_ERROR',
    super.retryable = true,
  });
}

class UnauthorizedError extends AppError {
  const UnauthorizedError({
    super.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    super.code = 'UNAUTHORIZED',
    super.retryable = false,
  });
}

class QuotaExceededError extends AppError {
  const QuotaExceededError({
    super.message = 'Bạn đã vượt quá hạn mức sử dụng. Vui lòng nâng cấp gói.',
    super.code = 'QUOTA_EXCEEDED',
    super.retryable = false,
  });
}

class TimeoutError extends AppError {
  const TimeoutError({
    super.message = 'Yêu cầu quá thời gian. Vui lòng thử lại.',
    super.code = 'TIMEOUT',
    super.retryable = true,
  });
}

class ProviderUnavailableError extends AppError {
  const ProviderUnavailableError({
    super.message = 'Dịch vụ tạm thời gián đoạn. Vui lòng thử lại sau.',
    super.code = 'PROVIDER_UNAVAILABLE',
    super.retryable = true,
  });
}

class InvalidAudioError extends AppError {
  const InvalidAudioError({
    super.message = 'Tệp âm thanh không hợp lệ hoặc bị hỏng.',
    super.code = 'INVALID_AUDIO',
    super.retryable = false,
  });
}

class CloningFailedError extends AppError {
  const CloningFailedError({
    super.message =
        'Nhân bản giọng nói thất bại. Vui lòng thử lại với âm thanh chất lượng tốt hơn.',
    super.code = 'CLONING_FAILED',
    super.retryable = true,
  });
}

class UnknownError extends AppError {
  const UnknownError({
    super.message = 'Đã xảy ra lỗi. Vui lòng thử lại.',
    super.code = 'UNKNOWN',
    super.retryable = true,
  });
}
