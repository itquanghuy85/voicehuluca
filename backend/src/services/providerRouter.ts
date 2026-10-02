import fs from 'fs';
import os from 'os';
import path from 'path';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';
import * as elevenlabs from './elevenlabs';
import * as google from './googleTts';
import { LOCAL_PROVIDER_ID, localTtsProvider } from './localTtsProvider';

export type ProviderId = 'google' | 'elevenlabs' | 'local';

export interface ProviderVoice {
  voice_id: string;
  name: string;
  category?: string;
  description?: string;
  preview_url?: string;
  labels?: Record<string, string>;
}

export interface ProviderUsage {
  charactersUsed: number;
  charactersLimit: number;
  tier?: string;
  resetAt?: number;
}

export interface ProviderDescriptor {
  id: string;
  name: string;
  supportsVoiceCloning: boolean;
  available: boolean;
}

export const DEFAULT_PROVIDER_ID: ProviderId = 'google';

export function listProviderIds(): string[] {
  return ['google', 'elevenlabs', LOCAL_PROVIDER_ID];
}

export function isKnownProvider(id: string): id is ProviderId {
  return id === 'google' || id === 'elevenlabs' || id === LOCAL_PROVIDER_ID;
}

export function resolveProvider(id: string | undefined | null): ProviderId {
  if (!id) {
    return DEFAULT_PROVIDER_ID;
  }
  const normalized = id.trim().toLowerCase();
  if (!isKnownProvider(normalized)) {
    throw new AppError(
      400,
      'UnknownProvider',
      `Nhà cung cấp "${id}" không được hỗ trợ.`,
      false
    );
  }
  return normalized;
}

export function supportsVoiceCloning(provider: ProviderId): boolean {
  if (provider === 'elevenlabs' || provider === LOCAL_PROVIDER_ID) {
    return true;
  }
  return google.supportsGoogleVoiceCloning();
}

export function isProviderAvailable(provider: ProviderId): boolean {
  if (provider === 'google') {
    return true;
  }
  if (provider === LOCAL_PROVIDER_ID) {
    return localTtsProvider.refreshAvailability();
  }
  return elevenlabs.isApiKeyConfigured();
}

export function describeProviders(): ProviderDescriptor[] {
  return [
    {
      id: 'google',
      name: 'Google TTS',
      supportsVoiceCloning: supportsVoiceCloning('google'),
      available: isProviderAvailable('google'),
    },
    {
      id: 'elevenlabs',
      name: 'ElevenLabs',
      supportsVoiceCloning: supportsVoiceCloning('elevenlabs'),
      available: isProviderAvailable('elevenlabs'),
    },
    {
      id: LOCAL_PROVIDER_ID,
      name: 'TTS trên máy',
      supportsVoiceCloning: supportsVoiceCloning(LOCAL_PROVIDER_ID),
      available: isProviderAvailable(LOCAL_PROVIDER_ID),
    },
  ];
}

export async function getVoices(
  provider: ProviderId,
  language?: string
): Promise<ProviderVoice[]> {
  if (provider === 'google') {
    const voices = await google.listVoices();
    return voices.map((voice) => ({
      voice_id: voice.voice_id,
      name: voice.name,
      category: voice.category,
      description: voice.description,
      labels: voice.labels,
    }));
  }
  if (provider === LOCAL_PROVIDER_ID) {
    return localTtsProvider.listVoices(language);
  }
  const voices = await elevenlabs.getVoices();
  return voices.map((voice) => ({
    voice_id: voice.voice_id,
    name: voice.name,
    category: voice.category,
    description: voice.description,
    preview_url: voice.preview_url,
    labels: voice.labels,
  }));
}

export interface SynthesisRequest {
  voiceId: string;
  text: string;
  modelId?: string;
  speed?: number;
  stability?: number;
  similarityBoost?: number;
  style?: number;
  useSpeakerBoost?: boolean;
}

export interface SynthesisOutput {
  audio: Buffer;
  /** mp3 for Edge/Google, wav for XTTS clones. */
  format: 'mp3' | 'wav';
  engine: string;
}

export async function synthesize(
  provider: ProviderId,
  request: SynthesisRequest
): Promise<SynthesisOutput> {
  if (provider === 'google') {
    const audio = await google.synthesize({
      voiceId: request.voiceId,
      text: request.text,
      speed: request.speed,
    });
    return { audio, format: 'mp3', engine: 'google-translate' };
  }
  if (provider === LOCAL_PROVIDER_ID) {
    const result = await localTtsProvider.synthesize({
      voiceId: request.voiceId,
      text: request.text,
      speed: request.speed,
    });
    return { audio: result.audio, format: result.format, engine: result.engine };
  }
  const audio = await elevenlabs.textToSpeechAudio({
    voiceId: request.voiceId,
    text: request.text,
    modelId: request.modelId,
    speed: request.speed,
    stability: request.stability,
    similarityBoost: request.similarityBoost,
    style: request.style,
    useSpeakerBoost: request.useSpeakerBoost,
  });
  return { audio, format: 'mp3', engine: 'elevenlabs' };
}

/**
 * Providers that can clone a voice, cheapest and most private first.
 * Sent with a 501 so the app can offer a real alternative instead of a dead end.
 */
export function cloningProviderSuggestions(): Array<{
  id: string;
  name: string;
  reason: string;
}> {
  return describeProviders()
    .filter((provider) => provider.supportsVoiceCloning)
    .filter((provider) => provider.available)
    .map((provider) => ({
      id: provider.id,
      name: provider.name,
      reason:
        provider.id === LOCAL_PROVIDER_ID
          ? 'Chạy trên máy, miễn phí, không cần API key.'
          : 'Chất lượng cao, có thể phát sinh phí theo gói.',
    }));
}

export function assertVoiceCloningSupported(provider: ProviderId): void {
  if (supportsVoiceCloning(provider)) {
    return;
  }
  throw new AppError(
    501,
    'VoiceCloningNotSupported',
    'Nhà cung cấp đang chọn không hỗ trợ tạo bản sao giọng nói.',
    false
  );
}

export async function cloneVoice(
  provider: ProviderId,
  params: {
    name: string;
    files: Express.Multer.File[];
    description?: string;
    language?: string;
  }
): Promise<{ voice_id: string; status: string; modelReady?: boolean; warning?: string }> {
  assertVoiceCloningSupported(provider);

  if (provider === LOCAL_PROVIDER_ID) {
    const sample = params.files[0];
    const result = await localTtsProvider.cloneVoice({
      name: params.name,
      // The sidecar reads the WAV from disk, so hand it a real file path.
      samplePath: writeTemporarySample(sample),
      language: params.language ?? 'vi',
    });
    return {
      voice_id: result.voiceId,
      status: result.modelReady ? 'completed' : 'pending_model',
      modelReady: result.modelReady,
      warning: result.warning,
    };
  }

  const result = await elevenlabs.cloneVoice(
    params.name,
    params.files,
    params.description,
    params.language
  );
  return { voice_id: result.voice_id, status: result.status };
}

function writeTemporarySample(file: Express.Multer.File): string {
  const extension = path.extname(file.originalname) || '.wav';
  const target = path.join(
    os.tmpdir(),
    `vietvoice-sample-${Date.now()}-${Math.random().toString(16).slice(2)}${extension}`
  );
  fs.writeFileSync(target, file.buffer);
  // The sidecar only needs the bytes, so drop the copy as soon as it is done.
  setTimeout(() => {
    try {
      fs.unlinkSync(target);
    } catch {
      /* best effort cleanup */
    }
  }, CLONE_SAMPLE_TTL_MS).unref?.();
  return target;
}

const CLONE_SAMPLE_TTL_MS = 10 * 60_000;

export async function deleteVoice(
  provider: ProviderId,
  voiceId: string
): Promise<{ success: boolean }> {
  if (provider === 'google') {
    throw new AppError(
      400,
      'OperationNotSupported',
      'Google TTS không cho phép xoá giọng có sẵn.',
      false
    );
  }
  if (provider === LOCAL_PROVIDER_ID) {
    await localTtsProvider.deleteClone(voiceId);
    return { success: true };
  }
  return elevenlabs.deleteVoice(voiceId);
}

/** Real usage only. Returns null when the provider exposes no usage data. */
export async function getUsage(provider: ProviderId): Promise<ProviderUsage | null> {
  if (provider === 'google') {
    return google.getUsage();
  }
  if (provider === LOCAL_PROVIDER_ID) {
    return localTtsProvider.getUsage();
  }
  const usage = await elevenlabs.getUsage();
  return {
    charactersUsed: usage.characterCount,
    charactersLimit: usage.characterLimit,
    tier: usage.subscriptionTier,
    resetAt: usage.nextCharacterCountResetUnix,
  };
}

export function providerRequiresAppAuth(): boolean {
  return config.appApiKeys.length > 0;
}
