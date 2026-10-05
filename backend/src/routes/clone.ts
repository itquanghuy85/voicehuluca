import { Request, Response, Router } from 'express';
import multer from 'multer';
import { AppError } from '../middleware/errorHandler';
import {
  DEFAULT_PROVIDER_ID,
  assertVoiceCloningSupported,
  cloningProviderSuggestions,
  cloneVoice,
  resolveProvider,
} from '../services/providerRouter';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 25 * 1024 * 1024,
    files: 10,
  },
});

const router = Router();

function parseFiles(req: Request): Express.Multer.File[] {
  const files = req.files as Express.Multer.File[] | undefined;
  if (!files || files.length === 0) {
    throw new AppError(400, 'ValidationError', 'Cần ít nhất một file âm thanh.', false);
  }
  return files;
}

async function handleClone(req: Request, res: Response): Promise<void> {
  const { name, description, language, provider: rawProvider, ref_text: refText } = req.body;
  const provider = resolveProvider(rawProvider ?? DEFAULT_PROVIDER_ID);

  if (typeof name !== 'string' || name.trim().length === 0) {
    throw new AppError(400, 'ValidationError', 'Tên giọng nói là bắt buộc.', false);
  }

  // Google TTS cannot clone; tell the app who can instead of just refusing.
  if (!supportsCloning(provider)) {
    throw new AppError(
      501,
      'VoiceCloningNotSupported',
      'Nhà cung cấp đang chọn không hỗ trợ tạo bản sao giọng nói.',
      false,
      { suggestions: cloningProviderSuggestions() }
    );
  }

  const files = parseFiles(req);
  const result = await cloneVoice(provider, {
    name: name.trim(),
    files,
    description: typeof description === 'string' ? description : undefined,
    language: typeof language === 'string' ? language : undefined,
    refText: typeof refText === 'string' ? refText : undefined,
  });

  res.set('X-Tts-Provider', provider);
  res.status(200).json({ provider, ...result });
}

function supportsCloning(provider: ReturnType<typeof resolveProvider>): boolean {
  try {
    assertVoiceCloningSupported(provider);
    return true;
  } catch {
    return false;
  }
}

// POST /v1/voices/clone  (canonical, provider aware)
router.post('/clone', upload.array('files', 10), async (req, res, next) => {
  try {
    await handleClone(req, res);
  } catch (error) {
    next(error);
  }
});

// POST /v1/voices/add  (ElevenLabs compatible alias, defaults to elevenlabs)
router.post('/', upload.array('files', 10), async (req, res, next) => {
  try {
    await handleClone(req, res);
  } catch (error) {
    next(error);
  }
});

export default router;
