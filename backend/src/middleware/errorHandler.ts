import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../types';

export class AppError extends Error {
  public statusCode: number;
  public code: string;
  public retryable: boolean;
  /** Extra machine-readable context, e.g. alternative providers. */
  public details?: Record<string, unknown>;

  constructor(
    statusCode: number,
    code: string,
    message: string,
    retryable: boolean,
    details?: Record<string, unknown>
  ) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.retryable = retryable;
    this.details = details;
  }
}

/** Errors raised by body-parser / multer describe themselves on the error. */
interface FrameworkError extends Error {
  status?: number;
  statusCode?: number;
  type?: string;
  code?: string;
}

type ErrorBody = ApiError['error'];

const BODY_PARSER_MESSAGES: Record<string, string> = {
  'entity.parse.failed': 'Body yêu cầu không phải JSON hợp lệ.',
  'entity.too.large': 'Body yêu cầu vượt quá giới hạn cho phép.',
  'encoding.unsupported': 'Body yêu cầu dùng kiểu mã hoá không được hỗ trợ.',
  'charset.unsupported': 'Body yêu cầu dùng bảng mã không được hỗ trợ.',
  'request.aborted': 'Yêu cầu đã bị huỷ trước khi hoàn tất.',
  'request.size.invalid': 'Kích thước yêu cầu không hợp lệ.',
  'parameters.too.many': 'Yêu cầu chứa quá nhiều tham số.',
};

const MULTER_MESSAGES: Record<string, { statusCode: number; message: string }> = {
  LIMIT_FILE_SIZE: {
    statusCode: 413,
    message: 'Tệp âm thanh vượt quá 25 MB.',
  },
  LIMIT_FILE_COUNT: {
    statusCode: 400,
    message: 'Gửi quá nhiều tệp âm thanh trong một lần.',
  },
  LIMIT_UNEXPECTED_FILE: {
    statusCode: 400,
    message: 'Tệp gửi lên không nằm trong trường mong đợi.',
  },
  LIMIT_PART_COUNT: {
    statusCode: 400,
    message: 'Yêu cầu chứa quá nhiều phần dữ liệu.',
  },
};

export function errorHandler(
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  if (res.headersSent) {
    // The response already started, so only Express can close the connection.
    next(err);
    return;
  }

  if (err instanceof AppError) {
    send(res, err.statusCode, {
      code: err.code,
      message: err.message,
      retryable: err.retryable,
      ...(err.details ? { details: err.details } : {}),
    });
    return;
  }

  const clientError = mapFrameworkError(err);
  if (clientError) {
    send(res, clientError.statusCode, clientError.body);
    return;
  }

  // Never swallow a real bug: without this the log only shows a bare 500.
  console.error(`[error] ${req.method} ${req.originalUrl}`, err);
  send(res, 500, {
    code: 'InternalServerError',
    message: 'Đã xảy ra lỗi không mong đợi.',
    retryable: true,
  });
}

/**
 * Malformed JSON, oversized bodies and upload-limit failures are client
 * mistakes, not server faults. Answer them with their own status so the app can
 * tell "fix your input" apart from "retry later".
 */
function mapFrameworkError(
  err: Error | AppError
): { statusCode: number; body: ErrorBody } | null {
  const uploadError = mapUploadError(err as FrameworkError);
  if (uploadError) {
    return uploadError;
  }

  const candidate = err as FrameworkError;
  const statusCode = pickClientStatus(candidate);
  if (statusCode === undefined) {
    return null;
  }

  const key = candidate.type;
  return {
    statusCode,
    body: {
      code: key === 'entity.parse.failed' ? 'ValidationError' : 'BadRequest',
      message: (key && BODY_PARSER_MESSAGES[key]) ?? 'Yêu cầu không hợp lệ.',
      retryable: false,
    },
  };
}

function mapUploadError(
  error: FrameworkError
): { statusCode: number; body: ErrorBody } | null {
  const code = typeof error.code === 'string' ? error.code : undefined;
  if (!code || !code.startsWith('LIMIT_')) {
    return null;
  }
  const known = MULTER_MESSAGES[code];
  return {
    statusCode: known?.statusCode ?? 400,
    body: {
      code,
      message: known?.message ?? 'Tệp gửi lên không hợp lệ.',
      retryable: false,
    },
  };
}

/** Only trust 4xx statuses: a 5xx coming from a dependency is still a server fault. */
function pickClientStatus(error: FrameworkError): number | undefined {
  for (const value of [error.status, error.statusCode]) {
    if (typeof value === 'number' && value >= 400 && value < 500) {
      return value;
    }
  }
  return undefined;
}

function send(res: Response, statusCode: number, body: ErrorBody): void {
  const response: ApiError = { error: body };
  res.status(statusCode).json(response);
}
