const test = require('node:test');
const assert = require('node:assert/strict');

const { config } = require('../dist/config');
const {
  VoiceStudioProvider,
  wavDurationSeconds,
} = require('../dist/services/voiceStudioProvider');
const {
  resolveProvider,
  supportsVoiceCloning,
  listProviderIds,
} = require('../dist/services/providerRouter');

/** Mono 16-bit PCM WAV of the given length, at 16 kHz. */
function wav(seconds) {
  const rate = 16000;
  const dataLength = Math.round(seconds * rate) * 2;
  const buffer = Buffer.alloc(44 + dataLength);
  buffer.write('RIFF', 0, 'ascii');
  buffer.writeUInt32LE(36 + dataLength, 4);
  buffer.write('WAVE', 8, 'ascii');
  buffer.write('fmt ', 12, 'ascii');
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(1, 22);
  buffer.writeUInt32LE(rate, 24);
  buffer.writeUInt32LE(rate * 2, 28);
  buffer.writeUInt16LE(2, 32);
  buffer.writeUInt16LE(16, 34);
  buffer.write('data', 36, 'ascii');
  buffer.writeUInt32LE(dataLength, 40);
  return buffer;
}

function json(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/** Records every call and answers from `handler(url, init)`. */
function fakeFetch(handler) {
  const calls = [];
  const fn = async (url, init = {}) => {
    calls.push({ url: String(url), init });
    return handler(String(url), init);
  };
  fn.calls = calls;
  return fn;
}

function connectionError(code) {
  const error = new TypeError('fetch failed');
  error.cause = { code };
  return error;
}

function withConfig(values, fn) {
  const saved = {
    voiceStudioBaseUrl: config.voiceStudioBaseUrl,
    voiceStudioPin: config.voiceStudioPin,
    voiceStudioApiKey: config.voiceStudioApiKey,
  };
  Object.assign(config, values);
  return Promise.resolve()
    .then(fn)
    .finally(() => Object.assign(config, saved));
}

const LAN = { voiceStudioBaseUrl: 'http://192.0.2.10:3901/', voiceStudioPin: '123456', voiceStudioApiKey: '' };

test('router knows voicestudio and that it can clone', () => {
  assert.ok(listProviderIds().includes('voicestudio'));
  assert.equal(resolveProvider(' VoiceStudio '), 'voicestudio');
  assert.equal(supportsVoiceCloning('voicestudio'), true);
});

test('wavDurationSeconds reads the data chunk, null for non-WAV', () => {
  assert.equal(wavDurationSeconds(wav(5)), 5);
  assert.equal(wavDurationSeconds(wav(19.5)), 19.5);
  assert.equal(wavDurationSeconds(Buffer.from('ID3 not a wav file')), null);
});

test('health online reports the real device and sends the PIN', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() =>
      json(200, { status: 'ok', device: 'cuda (NVIDIA GeForce RTX 2060 SUPER)', version: '0.5.6' })
    );
    const health = await new VoiceStudioProvider(fetch).health();
    assert.equal(health.connected, true);
    assert.equal(health.gpu, true);
    assert.equal(health.device, 'cuda (NVIDIA GeForce RTX 2060 SUPER)');
    assert.equal(health.version, '0.5.6');
    assert.equal(typeof health.latencyMs, 'number');
    assert.equal(fetch.calls[0].url, 'http://192.0.2.10:3901/health');
    assert.equal(fetch.calls[0].init.headers['x-omnivoice-pin'], '123456');
    assert.equal(fetch.calls[0].init.headers.Authorization, undefined);
  }));

test('health on CPU is reported as such, not as GPU', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(200, { status: 'ok', device: 'cpu', version: '0.5.6' }));
    const health = await new VoiceStudioProvider(fetch).health();
    assert.equal(health.gpu, false);
  }));

test('health while VoiceStudio is starting is MODEL_LOADING', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(503, { status: 'starting', step: 'ml_imports', version: '0.5.6' }));
    const health = await new VoiceStudioProvider(fetch).health();
    assert.equal(health.connected, false);
    assert.equal(health.error.code, 'MODEL_LOADING');
  }));

test('connection refused means VoiceStudio is closed, not that the network is down', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => {
      throw connectionError('ECONNREFUSED');
    });
    const health = await new VoiceStudioProvider(fetch).health();
    assert.equal(health.connected, false);
    assert.equal(health.error.code, 'VOICE_STUDIO_CLOSED');
  }));

test('unreachable host means the PC is offline', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => {
      throw connectionError('EHOSTUNREACH');
    });
    const health = await new VoiceStudioProvider(fetch).health();
    assert.equal(health.error.code, 'VOICE_STUDIO_OFFLINE');
  }));

test('not configured: health says so and calls nothing', () =>
  withConfig({ voiceStudioBaseUrl: '' }, async () => {
    const fetch = fakeFetch(() => json(200, {}));
    const provider = new VoiceStudioProvider(fetch);
    const health = await provider.health();
    assert.equal(health.configured, false);
    assert.equal(health.error.code, 'VOICE_STUDIO_NOT_CONFIGURED');
    assert.equal(provider.isAvailable(), false);
    assert.equal(fetch.calls.length, 0);
  }));

test('clone sends name, kind=clone, ref_text, language and the audio', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(200, { id: 'ab12cd34', name: 'Giọng Huy' }));
    const result = await new VoiceStudioProvider(fetch).cloneVoice({
      name: 'Giọng Huy',
      sample: wav(8),
      filename: 'voice_clone_x.wav',
      refText: '  Xin chào, tôi đang kiểm tra giọng nói.  ',
    });
    assert.deepEqual(result, { voiceId: 'ab12cd34', name: 'Giọng Huy' });
    const { url, init } = fetch.calls[0];
    assert.equal(url, 'http://192.0.2.10:3901/profiles');
    assert.equal(init.method, 'POST');
    const form = init.body;
    assert.equal(form.get('name'), 'Giọng Huy');
    assert.equal(form.get('kind'), 'clone');
    assert.equal(form.get('ref_text'), 'Xin chào, tôi đang kiểm tra giọng nói.');
    assert.equal(form.get('language'), 'vi');
    const audio = form.get('ref_audio');
    assert.equal(audio.size, wav(8).length);
  }));

test('clone without a transcript is refused before upload', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(200, { id: 'x' }));
    await assert.rejects(
      new VoiceStudioProvider(fetch).cloneVoice({ name: 'a', sample: wav(8), filename: 'a.wav', refText: '  ' }),
      { code: 'TRANSCRIPT_REQUIRED', statusCode: 400 }
    );
    assert.equal(fetch.calls.length, 0);
  }));

for (const [seconds, ok] of [
  [5, true],
  [10, true],
  [15, true],
  [19.9, true],
  [20, false],
  [20.1, false],
  [30, false],
]) {
  test(`clone of a ${seconds}s sample is ${ok ? 'sent' : 'refused before upload'}`, () =>
    withConfig(LAN, async () => {
      const fetch = fakeFetch(() => json(200, { id: 'p1', name: 'a' }));
      const run = new VoiceStudioProvider(fetch).cloneVoice({
        name: 'a',
        sample: wav(seconds),
        filename: 'a.wav',
        refText: 'một hai ba',
      });
      if (ok) {
        await run;
        assert.equal(fetch.calls.length, 1);
      } else {
        await assert.rejects(run, { code: 'RECORDING_TOO_LONG', statusCode: 422 });
        assert.equal(fetch.calls.length, 0);
      }
    }));
}

test('clone 422 from VoiceStudio keeps its reason', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(422, { detail: 'clone profiles require ref_audio' }));
    await assert.rejects(
      new VoiceStudioProvider(fetch).cloneVoice({ name: 'a', sample: wav(8), filename: 'a.wav', refText: 'x' }),
      (error) => error.code === 'CLONE_FAILED' && error.statusCode === 422 && /ref_audio/.test(error.message)
    );
  }));

test('wrong PIN is AUTH_FAILED and never HTTP 401 (the app reads 401 as an expired login)', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(401, { detail: 'PIN required' }));
    await assert.rejects(new VoiceStudioProvider(fetch).listVoices(), (error) => {
      assert.equal(error.code, 'AUTH_FAILED');
      assert.notEqual(error.statusCode, 401);
      return true;
    });
  }));

test('synthesize posts to /v1/audio/speech and returns the WAV', () =>
  withConfig(LAN, async () => {
    const audio = wav(2);
    const fetch = fakeFetch((url) =>
      url.endsWith('/profiles/ab12cd34')
        ? json(200, { id: 'ab12cd34', name: 'a' })
        : new Response(audio, { status: 200, headers: { 'Content-Type': 'audio/wav' } })
    );
    const result = await new VoiceStudioProvider(fetch).synthesize({ voiceId: 'ab12cd34', text: 'Xin chào', speed: 1 });
    assert.equal(result.format, 'wav');
    assert.equal(result.audio.length, audio.length);
    assert.equal(fetch.calls[0].url, 'http://192.0.2.10:3901/profiles/ab12cd34');
    const { url, init } = fetch.calls[1];
    assert.equal(url, 'http://192.0.2.10:3901/v1/audio/speech');
    const body = JSON.parse(init.body);
    assert.equal(body.voice, 'ab12cd34');
    assert.equal(body.input, 'Xin chào');
    assert.equal(body.response_format, 'wav');
    assert.equal(body.language, 'vi');
  }));

test('synthesis 503 for an overloaded job is SYNTHESIS_FAILED with the reason, retryable', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch((url) =>
      url.includes('/profiles/')
        ? json(200, { id: 'a' })
        : json(503, { error: { message: 'OpenAI TTS generate ran for more than 600s of actual compute time' } })
    );
    await assert.rejects(new VoiceStudioProvider(fetch).synthesize({ voiceId: 'a', text: 'b' }), (error) => {
      assert.equal(error.code, 'SYNTHESIS_FAILED');
      assert.equal(error.statusCode, 503);
      assert.equal(error.retryable, true);
      assert.match(error.message, /600s/);
      return true;
    });
  }));

test('a deleted voice is PROFILE_INVALID and never reaches synthesis (VoiceStudio would use its default voice)', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch(() => json(404, { detail: 'Profile not found' }));
    await assert.rejects(new VoiceStudioProvider(fetch).synthesize({ voiceId: 'gone', text: 'b' }), {
      code: 'PROFILE_INVALID',
    });
    assert.equal(fetch.calls.length, 1);
    assert.ok(!fetch.calls.some((call) => call.url.endsWith('/v1/audio/speech')));
  }));

test('a timed-out synthesis is TIMEOUT, not "offline"', () =>
  withConfig(LAN, async () => {
    const fetch = fakeFetch((url) => {
      if (url.includes('/profiles/')) return json(200, { id: 'a' });
      const error = new Error('aborted');
      error.name = 'TimeoutError';
      throw error;
    });
    await assert.rejects(new VoiceStudioProvider(fetch).synthesize({ voiceId: 'a', text: 'b' }), {
      code: 'TIMEOUT',
      statusCode: 504,
    });
  }));

test('API key is sent as Bearer only when configured', () =>
  withConfig({ ...LAN, voiceStudioPin: '', voiceStudioApiKey: 'k-1' }, async () => {
    const fetch = fakeFetch(() => json(200, []));
    await new VoiceStudioProvider(fetch).listVoices();
    assert.equal(fetch.calls[0].init.headers.Authorization, 'Bearer k-1');
    assert.equal(fetch.calls[0].init.headers['x-omnivoice-pin'], undefined);
  }));
