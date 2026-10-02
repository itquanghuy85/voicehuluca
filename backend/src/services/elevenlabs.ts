import axios, { AxiosError, AxiosInstance } from 'axios';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';
import {
  ElevenLabsVoicesResponse,
  ElevenLabsUsageResponse,
  ElevenLabsVoice,
  UsageResponse,
} from '../types';

const client: AxiosInstance = axios.create({
  baseURL: config.elevenlabsBaseUrl,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 60000,
});

function mapError(error: unknown): AppError {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError;

    if (axiosError.code === 'ECONNABORTED') {
      return new AppError(504, 'Timeout', 'Kết nối quá lâu. Hãy thử lại.', true);
    }

    if (!axiosError.response) {
      return new AppError(503, 'NetworkError', 'Không thể kết nối Internet.', true);
    }

    const status = axiosError.response.status;

    if (status === 401) {
      return new AppError(401, 'Unauthorized', 'Thông tin kết nối không hợp lệ.', false);
    }

    if (status === 422) {
      return new AppError(422, 'ValidationError', 'Dữ liệu gửi lên không hợp lệ.', false);
    }

    if (status === 429) {
      return new AppError(429, 'QuotaExceeded', 'Tài khoản đã đạt giới hạn sử dụng.', true);
    }

    if (status >= 500) {
      return new AppError(502, 'ServiceUnavailable', 'Dịch vụ giọng nói hiện không khả dụng.', true);
    }

    return new AppError(status, 'ApiError', 'Đã xảy ra lỗi khi gọi dịch vụ.', true);
  }

  return new AppError(500, 'UnknownError', 'Đã xảy ra lỗi không mong đợi.', true);
}

function requireApiKey(): void {
  if (!config.elevenlabsApiKey) {
    throw new AppError(
      401,
      'InvalidApiKey',
      'Máy chủ chưa được cấu hình API key. Vui lòng thiết lập ELEVENLABS_API_KEY.',
      false
    );
  }
}

export function isApiKeyConfigured(): boolean {
  return config.elevenlabsApiKey.length > 0;
}

export async function getVoices(): Promise<ElevenLabsVoice[]> {
  requireApiKey();
  try {
    const response = await client.get<ElevenLabsVoicesResponse>('/voices', {
      headers: { 'xi-api-key': config.elevenlabsApiKey },
    });
    return response.data.voices;
  } catch (error) {
    throw mapError(error);
  }
}

export interface TtsAudioParams {
  voiceId: string;
  text: string;
  modelId?: string;
  speed?: number;
  stability?: number;
  similarityBoost?: number;
  style?: number;
  useSpeakerBoost?: boolean;
  stream?: boolean;
}

function clampSpeed(speed: number): number {
  return Math.min(1.2, Math.max(0.7, speed));
}

export async function textToSpeechAudio(params: TtsAudioParams): Promise<Buffer> {
  requireApiKey();

  const modelId =
    params.modelId && params.modelId.length > 0
      ? params.modelId
      : 'eleven_multilingual_v2';

  const voiceSettings: Record<string, unknown> = {
    stability: params.stability ?? 0.5,
    similarity_boost: params.similarityBoost ?? 0.75,
    style: params.style ?? 0.0,
    use_speaker_boost: params.useSpeakerBoost ?? true,
    speed: clampSpeed(params.speed ?? 1.0),
  };

  try {
    const path = `/text-to-speech/${encodeURIComponent(params.voiceId)}${
      params.stream ? '/stream' : ''
    }`;

    const response = await client.post(path, {
      text: params.text,
      model_id: modelId,
      voice_settings: voiceSettings,
    }, {
      responseType: 'arraybuffer',
      headers: { 'xi-api-key': config.elevenlabsApiKey },
    });

    return Buffer.from(response.data as unknown as ArrayBuffer);
  } catch (error) {
    throw mapError(error);
  }
}

export async function cloneVoice(
  name: string,
  files: Express.Multer.File[],
  description?: string,
  language?: string
): Promise<{ voice_id: string; status: string }> {
  requireApiKey();

  try {
    const FormData = (await import('form-data')).default;
    const formData = new FormData();

    formData.append('name', name);
    if (description) {
      formData.append('description', description);
    }
    if (language) {
      formData.append('labels', JSON.stringify({ language }));
    }

    for (const file of files) {
      formData.append('files', file.buffer, {
        filename: file.originalname,
        contentType: file.mimetype,
      });
    }

    const response = await client.post('/voices/add', formData, {
      headers: {
        ...formData.getHeaders(),
        'xi-api-key': config.elevenlabsApiKey,
      },
    });

    return {
      voice_id: response.data.voice_id,
      status: 'completed',
    };
  } catch (error) {
    throw mapError(error);
  }
}

export async function deleteVoice(voiceId: string): Promise<{ success: boolean }> {
  requireApiKey();
  try {
    await client.delete(`/voices/${encodeURIComponent(voiceId)}`, {
      headers: { 'xi-api-key': config.elevenlabsApiKey },
    });
    return { success: true };
  } catch (error) {
    throw mapError(error);
  }
}

export async function getUsage(): Promise<UsageResponse> {
  requireApiKey();
  try {
    const response = await client.get<ElevenLabsUsageResponse>('/user/subscription', {
      headers: { 'xi-api-key': config.elevenlabsApiKey },
    });
    return {
      characterCount: response.data.character_count,
      characterLimit: response.data.character_limit,
      subscriptionTier: response.data.subscription_tier,
      nextCharacterCountResetUnix: response.data.next_character_count_reset_unix,
    };
  } catch (error) {
    throw mapError(error);
  }
}
