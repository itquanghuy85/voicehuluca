import { Request, Response, Router } from 'express';
import { AppError } from '../middleware/errorHandler';
import {
  DEFAULT_PROVIDER_ID,
  deleteVoice,
  getVoices,
  resolveProvider,
} from '../services/providerRouter';

const router = Router();

router.get('/', async (req: Request, res: Response, next) => {
  try {
    const provider = resolveProvider(
      (req.query.provider as string | undefined) ?? DEFAULT_PROVIDER_ID
    );
    const language = req.query.language as string | undefined;
    const voices = await getVoices(provider, language);
    res.set('X-Tts-Provider', provider);
    res.json({ provider, voices });
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', async (req: Request, res: Response, next) => {
  try {
    const voiceId = req.params.id;
    if (!voiceId) {
      throw new AppError(400, 'ValidationError', 'Thiếu voiceId.', false);
    }
    const provider = resolveProvider(
      (req.query.provider as string | undefined) ?? DEFAULT_PROVIDER_ID
    );
    const result = await deleteVoice(provider, voiceId);
    res.set('X-Tts-Provider', provider);
    res.json({ provider, ...result });
  } catch (error) {
    next(error);
  }
});

export default router;
