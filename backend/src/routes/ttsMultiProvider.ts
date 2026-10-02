import { Request, Response, Router } from 'express';
import { AppError } from '../middleware/errorHandler';
import { DEFAULT_PROVIDER_ID, resolveProvider, synthesize } from '../services/providerRouter';

const router = Router();

interface TtsOptionsBody {
  speed?: number;
  stability?: number;
  similarityBoost?: number;
  style?: number;
  useSpeakerBoost?: boolean;
  modelId?: string;
}

interface SynthesizeBody {
  provider?: string;
  voiceId?: string;
  text?: string;
  modelId?: string;
  options?: TtsOptionsBody;
}

router.post('/', async (req: Request, res: Response, next) => {
  try {
    const body = (req.body ?? {}) as SynthesizeBody;
    const provider = resolveProvider(body.provider ?? DEFAULT_PROVIDER_ID);
    const voiceId = typeof body.voiceId === 'string' ? body.voiceId.trim() : '';
    const text = typeof body.text === 'string' ? body.text.trim() : '';
    const options = body.options ?? {};

    if (!voiceId) {
      throw new AppError(400, 'ValidationError', 'Thiếu voiceId.', false);
    }
    if (!text) {
      throw new AppError(400, 'ValidationError', 'Thiếu nội dung văn bản.', false);
    }

    const result = await synthesize(provider, {
      voiceId,
      text,
      modelId: options.modelId ?? body.modelId,
      speed: options.speed,
      stability: options.stability,
      similarityBoost: options.similarityBoost,
      style: options.style,
      useSpeakerBoost: options.useSpeakerBoost,
    });

    res.set(
      'Content-Type',
      result.format === 'wav' ? 'audio/wav' : 'audio/mpeg'
    );
    res.set('Content-Length', String(result.audio.length));
    res.set('X-Tts-Provider', provider);
    // The app needs the real container to name the file it saves.
    res.set('X-Audio-Format', result.format);
    res.set('X-Tts-Engine', result.engine);
    res.status(200).end(result.audio);
  } catch (error) {
    next(error);
  }
});

export default router;
