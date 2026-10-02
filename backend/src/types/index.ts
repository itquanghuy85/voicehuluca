export interface Voice {
  voiceId: string;
  name: string;
  category?: string;
  description?: string;
  previewUrl?: string;
  labels?: Record<string, string>;
}

export interface TtsRequest {
  text: string;
  voiceId: string;
  modelId?: string;
  speed?: number;
}

export interface TtsResponse {
  id: string;
  status: string;
  audioBase64?: string;
  audioUrl?: string;
  duration?: number;
  characterCount: number;
  providerRequestId?: string;
}

export interface CloneVoiceRequest {
  name: string;
  files: Express.Multer.File[];
  description?: string;
  transcript?: string;
}

export interface CloneVoiceResponse {
  voiceId: string;
  status: string;
}

export interface UsageResponse {
  characterCount: number;
  characterLimit: number;
  subscriptionTier?: string;
  nextCharacterCountResetUnix?: number;
}

export interface ApiError {
  error: {
    code: string;
    message: string;
    retryable: boolean;
    details?: Record<string, unknown>;
  };
}

export interface ElevenLabsVoice {
  voice_id: string;
  name: string;
  category?: string;
  description?: string;
  preview_url?: string;
  labels?: Record<string, string>;
}

export interface ElevenLabsVoicesResponse {
  voices: ElevenLabsVoice[];
}

export interface ElevenLabsTtsResponse {
  audio_base_64?: string;
  content_type?: string;
}

export interface ElevenLabsUsageResponse {
  character_count: number;
  character_limit: number;
  subscription_tier?: string;
  next_character_count_reset_unix?: number;
}
