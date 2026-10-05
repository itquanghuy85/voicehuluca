import { Request, Response, Router } from 'express';
import { voiceStudioProvider } from '../services/voiceStudioProvider';

const router = Router();

/**
 * Live state of the VoiceStudio machine: reachable, device (CUDA/CPU), version,
 * latency. Every field is what VoiceStudio reported, or null when it did not.
 * The base URL is reported as host:port only; the PIN never leaves the backend.
 */
router.get('/health', async (_req: Request, res: Response, next) => {
  try {
    const health = await voiceStudioProvider.health();
    let host: string | null = null;
    try {
      host = voiceStudioProvider.baseUrl ? new URL(voiceStudioProvider.baseUrl).host : null;
    } catch {
      host = null;
    }
    res.set('Cache-Control', 'no-store');
    res.json({ ...health, host });
  } catch (error) {
    next(error);
  }
});

export default router;
