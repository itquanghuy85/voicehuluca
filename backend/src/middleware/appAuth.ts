import { NextFunction, Request, Response } from 'express';
import { config } from '../config';
import { AppError } from './errorHandler';

/**
 * App-level authentication.
 *
 * The Flutter app never receives vendor secrets; it only holds a VietVoice
 * Studio API key which is forwarded as `xi-api-key` (or `Authorization: Bearer`).
 *
 * Authentication is enforced only when VVT_API_KEYS is configured on the
 * backend. When the list is empty (local development) the check is skipped.
 */
export function appApiKeyAuth(req: Request, _res: Response, next: NextFunction): void {
  const configured = config.appApiKeys;
  if (configured.length === 0) {
    next();
    return;
  }

  const authorization = req.header('authorization') ?? '';
  const bearer = authorization.toLowerCase().startsWith('bearer ')
    ? authorization.slice(7).trim()
    : '';
  const provided = (
    req.header('x-vvt-api-key') ??
    req.header('xi-api-key') ??
    bearer
  ).trim();

  if (provided.length === 0) {
    next(new AppError(401, 'MissingApiKey', 'Thiếu API key của ứng dụng.', false));
    return;
  }

  if (!configured.includes(provided)) {
    next(new AppError(401, 'InvalidApiKey', 'API key của ứng dụng không hợp lệ.', false));
    return;
  }

  next();
}
