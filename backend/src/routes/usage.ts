import { Request, Response, Router } from 'express';
import { isApiKeyConfigured } from '../services/elevenlabs';
import {
  DEFAULT_PROVIDER_ID,
  describeProviders,
  getUsage,
  isProviderAvailable,
  resolveProvider,
} from '../services/providerRouter';

const router = Router();

router.get('/', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    service: 'vietvoice-backend',
    elevenlabs_configured: isApiKeyConfigured(),
    providers: describeProviders(),
  });
});

router.get('/subscription', async (req: Request, res: Response, next) => {
  try {
    const provider = resolveProvider(
      (req.query.provider as string | undefined) ?? 'elevenlabs'
    );
    const usage = await getUsage(provider);
    if (!usage) {
      res.status(200).json({ provider, available: false });
      return;
    }
    res.status(200).json({
      provider,
      available: true,
      charactersUsed: usage.charactersUsed,
      charactersLimit: usage.charactersLimit,
      tier: usage.tier,
      resetAt: usage.resetAt,
    });
  } catch (error) {
    next(error);
  }
});

router.get('/providers', (_req: Request, res: Response) => {
  res.status(200).json({
    defaultProvider: DEFAULT_PROVIDER_ID,
    providers: describeProviders().map((provider) => ({
      ...provider,
      available: isProviderAvailable(provider.id as 'google' | 'elevenlabs'),
    })),
  });
});

export default router;
