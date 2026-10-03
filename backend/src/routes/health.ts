import { Request, Response, Router } from 'express';
import { describeProviders, DEFAULT_PROVIDER_ID } from '../services/providerRouter';

const router = Router();

/**
 * Liveness probe for the app's LAN discovery and for the user to check by hand.
 *
 * The service name is the signature the phone looks for when it scans the
 * network, so it must stay stable and must never require authentication.
 *
 * `providers` reports what the backend can actually do right now, so a failed
 * clone can be told apart from a clone whose provider has no API key.
 *
 * Extra fields (`ok`, `timestamp`, `provider`) follow the client health-check
 * contract: `ok` mirrors `status`, `timestamp` is the server clock in ISO-8601,
 * and `provider` names the default TTS provider id.
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
    provider: DEFAULT_PROVIDER_ID,
    providers,
    timestamp: new Date().toISOString(),
    discovery: true,
  });
});

export default router;