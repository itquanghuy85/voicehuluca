import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  elevenlabsApiKey: process.env.ELEVENLABS_API_KEY || '',
  elevenlabsBaseUrl: 'https://api.elevenlabs.io/v1',
  /**
   * Optional Google Cloud Text-to-Speech API key.
   * When set, the backend uses the official Cloud TTS v1 REST API
   * (full Vietnamese voice catalogue + speaking rate).
   * When empty, the backend falls back to Google's public
   * translate TTS endpoint (single Vietnamese voice, no rate control).
   */
  googleTtsApiKey: process.env.GOOGLE_TTS_API_KEY || '',
  googleTtsBaseUrl: 'https://texttospeech.googleapis.com/v1',
  googlePublicTtsUrl: 'https://translate.google.com/translate_tts',
  googleDefaultVoice: process.env.GOOGLE_TTS_VOICE || 'vi-VN-Standard-A',
  /** Python interpreter used by the local TTS sidecar. Empty => provider off. */
  localTtsPython: process.env.LOCAL_TTS_PYTHON || '',
  /** Where cloned voices live. Empty => ~/.vietvoice/voices */
  localTtsVoicesDir: process.env.LOCAL_TTS_VOICES_DIR || '',
  /** Comma separated app API keys. Empty => auth disabled (development). */
  appApiKeys: (process.env.VVT_API_KEYS || '')
    .split(',')
    .map((key) => key.trim())
    .filter((key) => key.length > 0),
  nodeEnv: process.env.NODE_ENV || 'development',
};
