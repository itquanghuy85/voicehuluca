import { config } from '../config';
import { AppError } from '../middleware/errorHandler';
import type { ProviderVoice } from './providerRouter';

export const VOICESTUDIO_PROVIDER_ID = 'voicestudio';

/**
 * OmniVoice, VoiceStudio's default engine, only conditions on the first 20s of
 * a reference ("max_ref_seconds": 20 from GET /engines/tts). A longer sample is
 * cut to a window while the transcript stays whole, and the engine then speaks
 * the leftover transcript in front of every generated sentence. So a sample at
 * or past the limit is refused here instead of producing that audio.
 */
export const VOICESTUDIO_MAX_REF_SECONDS = 20;
export const VOICESTUDIO_MIN_REF_SECONDS = 3;

/** VoiceStudio renders 24 kHz WAV; MP3 would need ffmpeg on the GPU machine. */
const SPEECH_FORMAT = 'wav';

const HEALTH_TIMEOUT_MS = 5_000;
const PROFILE_TIMEOUT_MS = 120_000;
/** VoiceStudio abandons a CPU job after 600s of compute; wait a little longer. */
const SPEECH_TIMEOUT_MS = 15 * 60_000;
const HEALTH_CACHE_MS = 15_000;

/** Error codes the app can act on. HTTP 401 is never used: the app reads it as an expired login. */
export type VoiceStudioErrorCode =
  | 'VOICE_STUDIO_NOT_CONFIGURED'
  | 'VOICE_STUDIO_OFFLINE'
  | 'VOICE_STUDIO_CLOSED'
  | 'AUTH_FAILED'
  | 'MODEL_LOADING'
  | 'ENGINE_UNAVAILABLE'
  | 'PROFILE_INVALID'
  | 'RECORDING_TOO_SHORT'
  | 'RECORDING_TOO_LONG'
  | 'TRANSCRIPT_REQUIRED'
  | 'CLONE_FAILED'
  | 'SYNTHESIS_FAILED'
  | 'TIMEOUT';

export interface VoiceStudioHealth {
  configured: boolean;
  connected: boolean;
  /** "ok" | "starting" | null when unreachable. */
  status: string | null;
  /** Exactly what VoiceStudio reports, e.g. "cuda (NVIDIA GeForce RTX 2060 SUPER)" or "cpu". */
  device: string | null;
  gpu: boolean | null;
  version: string | null;
  latencyMs: number | null;
  error: { code: VoiceStudioErrorCode; message: string } | null;
}

export interface VoiceStudioCloneResult {
  voiceId: string;
  name: string;
}

interface Profile {
  id: string;
  name: string;
  kind?: string;
  language?: string;
  ref_text?: string;
  is_demo?: number;
}

type FetchFn = typeof fetch;

function fail(
  statusCode: number,
  code: VoiceStudioErrorCode,
  message: string,
  retryable: boolean
): AppError {
  return new AppError(statusCode, code, message, retryable, { provider: VOICESTUDIO_PROVIDER_ID });
}

/** Reads the playable length of a PCM WAV without decoding it. Null when it is not a WAV. */
export function wavDurationSeconds(buffer: Buffer): number | null {
  if (buffer.length < 12) return null;
  if (buffer.toString('ascii', 0, 4) !== 'RIFF' || buffer.toString('ascii', 8, 12) !== 'WAVE') {
    return null;
  }
  let byteRate = 0;
  let offset = 12;
  while (offset + 8 <= buffer.length) {
    const id = buffer.toString('ascii', offset, offset + 4);
    const size = buffer.readUInt32LE(offset + 4);
    const body = offset + 8;
    if (id === 'fmt ' && body + 12 <= buffer.length) {
      byteRate = buffer.readUInt32LE(body + 8);
    } else if (id === 'data') {
      if (byteRate <= 0) return null;
      // Streaming writers leave the size at 0 or 0xFFFFFFFF; trust the bytes then.
      const available = buffer.length - body;
      const length = size === 0 || size > available ? available : size;
      return length / byteRate;
    }
    offset = body + size + (size % 2);
  }
  return null;
}

/**
 * Talks to a VoiceStudio backend over HTTP, on this PC or another one on the LAN.
 *
 * Only the Node backend knows where VoiceStudio is and how to authenticate; the
 * phone just names the `voicestudio` provider.
 *
 * Authentication follows what VoiceStudio actually checks:
 * - LAN share (Settings → network share, port 3901) wants its PIN in `x-omnivoice-pin`.
 * - `OMNIVOICE_API_KEY` on the VoiceStudio side wants `Authorization: Bearer`.
 * Neither header is sent when its setting is empty.
 */
export class VoiceStudioProvider {
  private healthCache: { at: number; value: VoiceStudioHealth } | null = null;

  constructor(private readonly fetchFn: FetchFn = (...args) => fetch(...args)) {}

  get baseUrl(): string {
    return config.voiceStudioBaseUrl.replace(/\/+$/, '');
  }

  isConfigured(): boolean {
    return this.baseUrl.length > 0;
  }

  /** Last known reachability, without waiting on the network. Refreshes in the background. */
  isAvailable(): boolean {
    if (!this.isConfigured()) return false;
    const cached = this.healthCache;
    if (!cached || Date.now() - cached.at > HEALTH_CACHE_MS) {
      void this.health().catch(() => undefined);
    }
    // Before the first probe answers, assume it is up so the app can try and get a real error.
    return cached ? cached.value.connected : true;
  }

  private headers(extra: Record<string, string> = {}): Record<string, string> {
    const headers: Record<string, string> = { ...extra };
    if (config.voiceStudioPin) headers['x-omnivoice-pin'] = config.voiceStudioPin;
    if (config.voiceStudioApiKey) headers.Authorization = `Bearer ${config.voiceStudioApiKey}`;
    return headers;
  }

  private ensureConfigured(): void {
    if (!this.isConfigured()) {
      throw fail(
        503,
        'VOICE_STUDIO_NOT_CONFIGURED',
        'Chưa cấu hình VoiceStudio. Đặt VOICESTUDIO_BASE_URL trong backend/.env.',
        false
      );
    }
  }

  private async request(
    path: string,
    init: RequestInit,
    timeoutMs: number,
    action: 'health' | 'profile' | 'speech'
  ): Promise<Response> {
    try {
      return await this.fetchFn(`${this.baseUrl}${path}`, {
        ...init,
        signal: AbortSignal.timeout(timeoutMs),
      });
    } catch (error) {
      throw this.networkError(error, action);
    }
  }

  /** Tells "PC off / other network" apart from "PC on, VoiceStudio closed" and from a slow job. */
  private networkError(error: unknown, action: 'health' | 'profile' | 'speech'): AppError {
    const cause = (error as { cause?: { code?: string } })?.cause;
    const code = cause?.code ?? (error as { code?: string })?.code ?? '';
    const name = (error as { name?: string })?.name ?? '';
    if (code === 'ECONNREFUSED') {
      return fail(
        503,
        'VOICE_STUDIO_CLOSED',
        'Máy VoiceStudio đang bật nhưng VoiceStudio chưa mở hoặc chưa bật chia sẻ mạng LAN.',
        true
      );
    }
    if (name === 'TimeoutError' || name === 'AbortError') {
      if (action === 'speech') {
        return fail(504, 'TIMEOUT', 'VoiceStudio tạo âm thanh quá lâu. Hãy thử đoạn văn ngắn hơn.', true);
      }
      return fail(
        503,
        'VOICE_STUDIO_OFFLINE',
        'Không kết nối được máy VoiceStudio. Máy có thể đang tắt hoặc không cùng mạng Wi-Fi.',
        true
      );
    }
    if (['EHOSTUNREACH', 'ENETUNREACH', 'ETIMEDOUT', 'ENOTFOUND', 'EAI_AGAIN', 'UND_ERR_CONNECT_TIMEOUT'].includes(code)) {
      return fail(
        503,
        'VOICE_STUDIO_OFFLINE',
        'Không kết nối được máy VoiceStudio. Máy có thể đang tắt hoặc không cùng mạng Wi-Fi.',
        true
      );
    }
    return fail(502, 'VOICE_STUDIO_OFFLINE', `Lỗi kết nối VoiceStudio: ${code || name || 'không rõ'}.`, true);
  }

  /** Maps a non-2xx VoiceStudio answer to an error the app can explain. */
  private async httpError(response: Response, action: 'profile' | 'speech'): Promise<AppError> {
    const text = await response.text().catch(() => '');
    const detail = extractDetail(text);
    const status = response.status;
    if (status === 401 || status === 403) {
      return fail(
        503,
        'AUTH_FAILED',
        'VoiceStudio từ chối kết nối: mã PIN chia sẻ mạng sai hoặc đã đổi. Cập nhật VOICESTUDIO_PIN trong backend/.env.',
        false
      );
    }
    if (status === 404) {
      return fail(404, 'PROFILE_INVALID', 'Giọng này không còn trong VoiceStudio. Hãy tạo lại giọng.', false);
    }
    if (status === 503 && /starting|loading/i.test(detail)) {
      return fail(503, 'MODEL_LOADING', 'VoiceStudio đang khởi động mô hình. Thử lại sau ít phút.', true);
    }
    if (action === 'profile') {
      return fail(
        status >= 500 ? 502 : 422,
        'CLONE_FAILED',
        `VoiceStudio không tạo được giọng: ${detail || `HTTP ${status}`}`,
        status >= 500
      );
    }
    if (status === 400 && /model_not_available|unavailable/i.test(text)) {
      return fail(503, 'ENGINE_UNAVAILABLE', `Engine VoiceStudio chưa sẵn sàng: ${detail}`, true);
    }
    return fail(
      status >= 500 ? 503 : 422,
      'SYNTHESIS_FAILED',
      `VoiceStudio không tạo được âm thanh: ${detail || `HTTP ${status}`}`,
      status >= 500
    );
  }

  /** Probes GET /health. Never throws: unreachable is a state, not an exception. */
  async health(): Promise<VoiceStudioHealth> {
    const empty: VoiceStudioHealth = {
      configured: this.isConfigured(),
      connected: false,
      status: null,
      device: null,
      gpu: null,
      version: null,
      latencyMs: null,
      error: null,
    };
    if (!this.isConfigured()) {
      return {
        ...empty,
        error: { code: 'VOICE_STUDIO_NOT_CONFIGURED', message: 'Chưa cấu hình VOICESTUDIO_BASE_URL.' },
      };
    }
    const started = Date.now();
    let value: VoiceStudioHealth;
    try {
      const response = await this.request('/health', { headers: this.headers() }, HEALTH_TIMEOUT_MS, 'health');
      const latencyMs = Date.now() - started;
      const body = (await response.json().catch(() => ({}))) as Record<string, unknown>;
      const device = typeof body.device === 'string' ? body.device : null;
      const status = typeof body.status === 'string' ? body.status : null;
      value = {
        ...empty,
        connected: response.ok,
        status,
        device,
        gpu: device === null ? null : /^cuda/i.test(device),
        version: typeof body.version === 'string' ? body.version : null,
        latencyMs,
        error: response.ok
          ? null
          : status === 'starting'
            ? { code: 'MODEL_LOADING', message: 'VoiceStudio đang khởi động.' }
            : { code: 'ENGINE_UNAVAILABLE', message: `VoiceStudio trả về HTTP ${response.status}.` },
      };
    } catch (error) {
      const appError = error as AppError;
      value = {
        ...empty,
        error: { code: appError.code as VoiceStudioErrorCode, message: appError.message },
      };
    }
    this.healthCache = { at: Date.now(), value };
    return value;
  }

  async listVoices(): Promise<ProviderVoice[]> {
    this.ensureConfigured();
    const response = await this.request('/profiles', { headers: this.headers() }, PROFILE_TIMEOUT_MS, 'profile');
    if (!response.ok) throw await this.httpError(response, 'profile');
    const profiles = (await response.json()) as Profile[];
    return profiles.map((profile) => ({
      voice_id: profile.id,
      name: profile.name,
      category: profile.kind === 'clone' ? 'cloned' : 'premade',
      description: profile.is_demo ? 'Giọng mẫu của VoiceStudio' : undefined,
      labels: {
        language: profile.language ?? '',
        engine: 'voicestudio',
      },
    }));
  }

  /**
   * Creates a clone profile from the recording and the transcript the user confirmed.
   *
   * The transcript is required: VoiceStudio would otherwise run its own ASR, which
   * mis-hears Vietnamese, and a wrong transcript makes every generated sentence
   * start with the misheard words.
   */
  async cloneVoice(params: {
    name: string;
    sample: Buffer;
    filename: string;
    refText: string;
    language?: string;
  }): Promise<VoiceStudioCloneResult> {
    this.ensureConfigured();
    const refText = params.refText.trim();
    if (!refText) {
      throw fail(400, 'TRANSCRIPT_REQUIRED', 'Cần nội dung câu bạn đã đọc trong bản ghi.', false);
    }
    const duration = wavDurationSeconds(params.sample);
    if (duration !== null && duration < VOICESTUDIO_MIN_REF_SECONDS) {
      throw fail(
        422,
        'RECORDING_TOO_SHORT',
        `Bản ghi dài ${duration.toFixed(1)}s, cần ít nhất ${VOICESTUDIO_MIN_REF_SECONDS}s.`,
        false
      );
    }
    if (duration !== null && duration >= VOICESTUDIO_MAX_REF_SECONDS) {
      throw fail(
        422,
        'RECORDING_TOO_LONG',
        `Bản ghi dài ${duration.toFixed(1)}s, VoiceStudio chỉ nhận dưới ${VOICESTUDIO_MAX_REF_SECONDS}s.`,
        false
      );
    }

    const form = new FormData();
    form.append('name', params.name);
    form.append('kind', 'clone');
    form.append('ref_text', refText);
    form.append('language', params.language ?? 'vi');
    form.append(
      'ref_audio',
      new Blob([new Uint8Array(params.sample)], { type: 'audio/wav' }),
      params.filename || 'sample.wav'
    );
    const response = await this.request(
      '/profiles',
      { method: 'POST', headers: this.headers(), body: form },
      PROFILE_TIMEOUT_MS,
      'profile'
    );
    if (!response.ok) throw await this.httpError(response, 'profile');
    const profile = (await response.json()) as Profile;
    if (!profile.id) {
      throw fail(502, 'CLONE_FAILED', 'VoiceStudio không trả về mã giọng.', true);
    }
    return { voiceId: profile.id, name: profile.name ?? params.name };
  }

  async synthesize(params: {
    voiceId: string;
    text: string;
    speed?: number;
    language?: string;
  }): Promise<{ audio: Buffer; format: 'wav'; engine: string }> {
    this.ensureConfigured();
    // VoiceStudio answers an unknown voice id with its default voice and HTTP 200,
    // so a deleted clone would silently come back as someone else. Check first.
    const profile = await this.request(
      `/profiles/${encodeURIComponent(params.voiceId)}`,
      { headers: this.headers() },
      PROFILE_TIMEOUT_MS,
      'profile'
    );
    if (!profile.ok) throw await this.httpError(profile, 'speech');
    const body: Record<string, unknown> = {
      model: 'omnivoice',
      input: params.text,
      voice: params.voiceId,
      response_format: SPEECH_FORMAT,
      language: params.language ?? 'vi',
    };
    if (typeof params.speed === 'number' && params.speed > 0) body.speed = params.speed;
    const response = await this.request(
      '/v1/audio/speech',
      {
        method: 'POST',
        headers: this.headers({ 'Content-Type': 'application/json' }),
        body: JSON.stringify(body),
      },
      SPEECH_TIMEOUT_MS,
      'speech'
    );
    if (!response.ok) throw await this.httpError(response, 'speech');
    const audio = Buffer.from(await response.arrayBuffer());
    if (audio.length < 44) {
      throw fail(502, 'SYNTHESIS_FAILED', 'VoiceStudio trả về âm thanh rỗng.', true);
    }
    return { audio, format: 'wav', engine: 'voicestudio-omnivoice' };
  }

  async deleteVoice(voiceId: string): Promise<void> {
    this.ensureConfigured();
    const response = await this.request(
      `/profiles/${encodeURIComponent(voiceId)}`,
      { method: 'DELETE', headers: this.headers() },
      PROFILE_TIMEOUT_MS,
      'profile'
    );
    if (!response.ok && response.status !== 404) throw await this.httpError(response, 'profile');
  }
}

/** Pulls the human-readable part out of FastAPI (`detail`) and OpenAI-style (`error.message`) bodies. */
function extractDetail(text: string): string {
  try {
    const parsed = JSON.parse(text) as { detail?: unknown; error?: { message?: unknown } };
    if (typeof parsed.detail === 'string') return parsed.detail;
    if (parsed.error && typeof parsed.error.message === 'string') return parsed.error.message;
    if (parsed.detail !== undefined) return JSON.stringify(parsed.detail).slice(0, 300);
  } catch {
    /* not JSON */
  }
  return text.slice(0, 300);
}

export const voiceStudioProvider = new VoiceStudioProvider();
