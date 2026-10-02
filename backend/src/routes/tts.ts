import { Router, Request, Response } from 'express';
import { textToSpeechAudio } from '../services/elevenlabs';
import { AppError } from '../middleware/errorHandler';

const router = Router();

interface VoiceSettings {
  stability?: number;
  similarity_boost?: number;
  style?: number;
  speed?: number;
  use_speaker_boost?: boolean;
}

interface TtsBody {
  text?: string;
  model_id?: string;
  voice_settings?: VoiceSettings;
}

async function handleSynthesize(req: Request, res: Response, stream: boolean): Promise<void> {
  const voiceId = req.params.voiceId;
  const body = (req.body ?? {}) as TtsBody;
  const text = typeof body.text === 'string' ? body.text.trim() : '';

  if (!voiceId) {
    throw new AppError(400, 'ValidationError', 'Thiếu voiceId.', false);
  }

  if (!text) {
    throw new AppError(400, 'ValidationError', 'Thiếu nội dung văn bản.', false);
  }

  const audio = await textToSpeechAudio({
    voiceId,
    text,
    modelId: body.model_id,
    speed: body.voice_settings?.speed,
    stability: body.voice_settings?.stability,
    similarityBoost: body.voice_settings?.similarity_boost,
    style: body.voice_settings?.style,
    useSpeakerBoost: body.voice_settings?.use_speaker_boost,
    stream,
  });

  res.set('Content-Type', 'audio/mpeg');
  res.set('Content-Length', String(audio.length));
  res.status(200).end(audio);
}

router.post('/:voiceId/stream', async (req, res, next) => {
  try {
    await handleSynthesize(req, res, true);
  } catch (error) {
    next(error);
  }
});

router.post('/:voiceId', async (req, res, next) => {
  try {
    await handleSynthesize(req, res, false);
  } catch (error) {
    next(error);
  }
});

export default router;
