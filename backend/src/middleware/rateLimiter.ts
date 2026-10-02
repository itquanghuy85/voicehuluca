import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: {
    error: {
      code: 'RateLimitExceeded',
      message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
      retryable: true,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});
