import { Request, Response, Router } from 'express';

const router = Router();

/**
 * Liveness probe for the app's LAN discovery.
 *
 * The service name is the signature the phone looks for when it scans the
 * network, so it must stay stable and must never require authentication.
 */
router.get('/', (_req: Request, res: Response) => {
  res.set('Cache-Control', 'no-store');
  res.json({
    status: 'ok',
    service: 'vietvoice-backend',
    version: '1.0.0',
    discovery: true,
  });
});

export default router;
