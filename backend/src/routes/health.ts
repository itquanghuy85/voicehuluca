import { Request, Response, Router } from 'express';
import { describeProviders } from '../services/providerRouter';

const router = Router();

/**
 * Liveness probe for the app's LAN discovery and for the user to check by hand.
 *
 * The service name is the signature the phone looks for when it scans the
 * network, so it must stay stable and must never require authentication.
 *
 * `providers` reports what the backend can actually do right now, so a failed
 * clone can be told apart from a clone whose provider has no API key.
 */
router.get('/', (_req: Request, res: Response) => {
  res.set('Cache-Control', 'no-store');
  const providers: Record<string, boolean> = {};
  for (const provider of describeProviders()) {
    providers[provider.id] = provider.available;
  }
  res.json({
    ok: true,
    // `status` is kept for older builds of the app that still read it.
    status: 'ok',
    service: 'vietvoice-backend',
    version: '1.0.0',
    providers,
    discovery: true,
  });
});

export default router;