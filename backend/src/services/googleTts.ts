import axios from 'axios';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';

/**
 * Google Text-to-Speech.
 *
 * Two modes, chosen automatically from configuration:
 *  1. Official Cloud TTS v1 REST API (requires GOOGLE_TTS_API_KEY).
 *     Supports the full Vietnamese voice catalogue and speaking rate.
 *  2. Public Google translate TTS endpoint (no key required).
 *     Single Vietnamese voice, ~200 characters per request, no rate control.
 *
 * Voice identifiers:
 *  - mode 1: the Google voice name, e.g. "vi-VN-Standard-A"
 *  - mode 2: "google-vi-standard"
 */
export const GOOGLE_PROVIDER_ID = 'google';
export const GOOGLE_PUBLIC_VOICE_ID = 'google-vi-standard';
const PUBLIC_MAX_CHARS = 190;

const browserHeaders = {
  'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
  'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
};

export function isOfficialApiEnabled(): boolean {
  return config.googleTtsApiKey.length > 0;
}

export function supportsGoogleVoiceCloning(): boolean {
  return false;
}

export interface GoogleVoice {
  voice_id: string;
  name: string;
  category: string;
  description?: string;
  labels: Record<string, string>;
}

export function getVoices(): GoogleVoice[] {
  if (!isOfficialApiEnabled()) {
    return [
      {
        voice_id: GOOGLE_PUBLIC_VOICE_ID,
        name: 'Google Ti\u1ebfng Vi\u1ec7t',
        category: 'premade',
        description: 'Gi\u1ecdng n\u1ee5 m\u1ed9c c\u1ee1a Google d\u00e0nh cho ti\u1ebfng Vi\u1ec7t.',
        labels: { language: 'vi', gender: 'female' },
      },
    ];
  }
  return [];
}

function escapeXml(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

interface GoogleCloudVoiceResponse {
  name: string;
  languageCodes?: string[];
  ssmlGender?: string;
}

async function fetchPublicVoices(): Promise<GoogleVoice[]> {
  const response = await axios.get<{ voices?: GoogleCloudVoiceResponse[] }>(
    `${config.googleTtsBaseUrl}/voices`,
    {
      params: { key: config.googleTtsApiKey },
      timeout: 15000,
      headers: { 'Accept-Encoding': 'gzip' },
    }
  );

  const voices = (response.data.voices ?? [])
    .filter((voice) => (voice.languageCodes ?? []).some((code) => code.startsWith('vi')))
    .map((voice) => ({
      voice_id: voice.name,
      name: voice.name,
      category: 'premade',
      description: `Google Cloud TTS (${voice.ssmlGender ?? 'NEUTRAL'})`,
      labels: {
        language: (voice.languageCodes ?? ['vi-VN'])[0].toLowerCase(),
        gender: (voice.ssmlGender ?? 'NEUTRAL').toLowerCase(),
      },
    }));

  return voices;
}

export async function listVoices(): Promise<GoogleVoice[]> {
  if (!isOfficialApiEnabled()) {
    return getVoices();
  }
  try {
    const voices = await fetchPublicVoices();
    return voices.length > 0 ? voices : getVoices();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      throw mapGoogleError(error);
    }
    throw new AppError(502, 'ProviderError', 'Kh\u00f4ng l\u1ea5y \u0111\u01b0\u1ee3c danh s\u00e1ch gi\u1ecdng Google.', true);
  }
}

function mapGoogleError(error: unknown): AppError {
  if (axios.isAxiosError(error)) {
    const axiosError = error;

    if (axiosError.code === 'ECONNABORTED') {
      return new AppError(504, 'Timeout', 'Google TTS ph\u1ea3n h\u1ed3i qu\u00e1 l\u00e2u. H\u00e3y th\u1eed l\u1ea1i.', true);
    }

    if (!axiosError.response) {
      return new AppError(503, 'NetworkError', 'Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn Google TTS.', true);
    }

    const status = axiosError.response.status;

    if (status === 400 || status === 422) {
      return new AppError(422, 'ValidationError', 'Google TTS t\u1eeb ch\u1ed1i n\u1ed9i dung kh\u00f4ng h\u1ee3p l\u1ec7.', false);
    }
    if (status === 401 || status === 403) {
      return new AppError(401, 'InvalidApiKey', 'Kh\u00f3a API key Google ch\u01b0a \u0111\u01b0\u1ee3c c\u1ea5u h\u00ecnh.', false);
    }
    if (status === 429) {
      return new AppError(429, 'QuotaExceeded', 'Google TTS \u0111\u00e3 ch\u1ea1m gi\u1edbi h\u1ea1n s\u1eed d\u1ee5ng.', true);
    }
    if (status >= 500) {
      return new AppError(502, 'ServiceUnavailable', 'D\u1ecbch v\u1ee5 gi\u1ecdng n\u00f3i Google hi\u1ec7n kh\u00f4ng kh\u1ea3 d\u1ee5ng.', true);
    }

    return new AppError(status, 'ApiError', 'L\u1ed7i khi g\u1ecdi d\u1ecbch v\u1ee5 gi\u1ecdng n\u00f3i Google.', true);
  }

  return new AppError(500, 'UnknownError', 'L\u1ed7i kh\u00f4ng mong \u0111\u1ee3i khi d\u00f9ng Google TTS.', true);
}

/**
 * Splits text into chunks the public endpoint can handle.
 * Prefers sentence boundaries, then word boundaries, never exceeds maxChars.
 */
export function chunkText(text: string, maxChars: number = PUBLIC_MAX_CHARS): string[] {
  const normalized = text.replace(/\s+/g, ' ').trim();
  if (normalized.length === 0) {
    return [];
  }
  if (normalized.length <= maxChars) {
    return [normalized];
  }

  const sentences = normalized.match(/[^.!?\u2026;:\n]+[.!?\u2026;:]?/g) ?? [normalized];
  const chunks: string[] = [];
  let current = '';

  const flush = () => {
    const trimmed = current.trim();
    if (trimmed.length > 0) {
      chunks.push(trimmed);
    }
    current = '';
  };

  const pushWithWordSplit = (value: string) => {
    if (value.length <= maxChars) {
      current = current.length > 0 ? `${current} ${value}` : value;
      return;
    }
    flush();
    let remaining = value;
    while (remaining.length > maxChars) {
      let cut = remaining.lastIndexOf(' ', maxChars);
      if (cut <= 0) {
        cut = maxChars;
      }
      chunks.push(remaining.slice(0, cut).trim());
      remaining = remaining.slice(cut).trim();
    }
    if (remaining.length > 0) {
      current = remaining;
    }
  };

  for (const sentence of sentences) {
    const piece = sentence.trim();
    if (piece.length === 0) {
      continue;
    }
    if (piece.length > maxChars) {
      flush();
      pushWithWordSplit(piece);
      continue;
    }
    const candidate = current.length > 0 ? `${current} ${piece}` : piece;
    if (candidate.length > maxChars) {
      flush();
    }
    current = current.length > 0 ? `${current} ${piece}` : piece;
  }

  flush();
  return chunks.filter((chunk) => chunk.length > 0);
}

async function synthesizePublic(text: string, speed: number): Promise<Buffer> {
  const chunks = chunkText(text);
  if (chunks.length === 0) {
    throw new AppError(400, 'ValidationError', 'Thi\u1ebfu n\u1ed9i dung v\u0103n b\u1ea3n.', false);
  }

  const buffers: Buffer[] = [];
  const multiChunk = chunks.length > 1;

  for (let index = 0; index < chunks.length; index += 1) {
    const chunk = chunks[index];
    try {
      const response = await axios.get<ArrayBuffer>(config.googlePublicTtsUrl, {
        params: multiChunk
          ? {
              ie: 'UTF-8',
              client: 'tw-ob',
              tl: 'vi',
              total: chunks.length,
              idx: index,
              q: chunk,
            }
          : {
              ie: 'UTF-8',
              client: 'tw-ob',
              tl: 'vi',
              q: chunk,
            },
        responseType: 'arraybuffer',
        timeout: 20000,
        // speaking rate is not supported by this endpoint; the speed option
        // is accepted for API compatibility only.
        validateStatus: (status) => status === 200,
        headers: browserHeaders,
      });
      buffers.push(Buffer.from(response.data));
    } catch (error) {
      throw mapGoogleError(error);
    }
  }

  return Buffer.concat(buffers);
}

async function synthesizeOfficial(
  text: string,
  voiceId: string,
  speed: number
): Promise<Buffer> {
  const chunks = chunkText(text, 2000);
  const buffers: Buffer[] = [];

  for (const chunk of chunks) {
    try {
      const response = await axios.post<{ audioContent: string }>(
        `${config.googleTtsBaseUrl}/text:synthesize`,
        {
          input: { text: escapeXml(chunk) },
          voice: { languageCode: voiceId, name: voiceId },
          audioConfig: {
            audioEncoding: 'MP3',
            speakingRate: Math.min(4, Math.max(0.25, speed)),
          },
        },
        {
          params: { key: config.googleTtsApiKey },
          timeout: 30000,
        }
      );
      buffers.push(Buffer.from(response.data.audioContent, 'base64'));
    } catch (error) {
      throw mapGoogleError(error);
    }
  }

  return Buffer.concat(buffers);
}

export interface GoogleSynthesisParams {
  voiceId: string;
  text: string;
  speed?: number;
}

export async function synthesize(params: GoogleSynthesisParams): Promise<Buffer> {
  const text = params.text.trim();
  if (text.length === 0) {
    throw new AppError(400, 'ValidationError', 'Thi\u1ebfu n\u1ed9i dung v\u0103n b\u1ea3n.', false);
  }

  const speed = params.speed && params.speed > 0 ? params.speed : 1;

  if (isOfficialApiEnabled()) {
    const voiceId = params.voiceId && params.voiceId !== GOOGLE_PUBLIC_VOICE_ID
      ? params.voiceId
      : config.googleDefaultVoice;
    return synthesizeOfficial(text, voiceId, speed);
  }

  return synthesizePublic(text, speed);
}

/** Google public TTS has no quota API: usage is reported as unavailable. */
export function getUsage(): null {
  return null;
}
