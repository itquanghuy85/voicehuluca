const test = require('node:test');
const assert = require('node:assert/strict');
const { EventEmitter } = require('node:events');
const { PassThrough } = require('node:stream');

const { config } = require('../dist/config');
const {
  LocalTtsProvider,
  LOCAL_CLONE_PREFIX,
} = require('../dist/services/localTtsProvider');
const {
  resolveProvider,
  isKnownProvider,
  supportsVoiceCloning,
  isProviderAvailable,
  describeProviders,
  listProviderIds,
  cloningProviderSuggestions,
} = require('../dist/services/providerRouter');

/**
 * Fake python process: answers each JSON request from a scripted map, so the
 * tests cover the protocol, error mapping and crash handling without Python.
 *
 * With `serial: true` it behaves like the real sidecar, which reads one request
 * at a time and answers it before reading the next: responses wait in a queue
 * until the test calls `child.flush()`.
 */
function createFakeSidecar(handlers, { serial = false } = {}) {
  const child = new EventEmitter();
  child.stdout = new PassThrough();
  child.stderr = new PassThrough();
  child.killed = false;
  const held = [];
  child.stdin = new PassThrough();
  child.stdin.on('data', (chunk) => {
    for (const line of String(chunk).split('\n')) {
      if (!line.trim()) continue;
      const request = JSON.parse(line);
      const handler = handlers[request.command];
      if (handler) {
        const response = handler(request);
        // `undefined` means "stay silent" so a pending request can be crashed.
        if (response !== undefined) {
          if (serial) {
            held.push(response);
          } else {
            child.stdout.write(`${JSON.stringify(response)}\n`);
          }
        }
        continue;
      }
      child.stdout.write(
        `${JSON.stringify({ id: request.id, ok: false, error: { code: 'UnknownCommand' } })}\n`
      );
    }
  });
  /** Releases the oldest held response, the way a finished command would. */
  child.flush = () => {
    const response = held.shift();
    if (!response) return false;
    child.stdout.write(`${JSON.stringify(response)}\n`);
    return true;
  };
  child.kill = () => {
    child.killed = true;
    // A real child emits 'exit' when it is killed, which is what rejects
    // whatever request was still in flight.
    child.emit('exit', 1);
  };
  return child;
}

/** Pretend the sidecar is configured, then restore the real value. */
function withConfiguredSidecar(t, handlers, options = {}) {
  const previous = config.localTtsPython;
  config.localTtsPython = 'python';
  t.after(() => {
    config.localTtsPython = previous;
  });
  const { timeouts, ...fakeOptions } = options;
  return new LocalTtsProvider(
    () => createFakeSidecar(handlers, fakeOptions),
    timeouts
  );
}

test('provider id "local" is a known provider', () => {
  assert.equal(isKnownProvider('local'), true);
  assert.equal(resolveProvider('local'), 'local');
  assert.equal(resolveProvider('LOCAL'), 'local');
  assert.ok(listProviderIds().includes('local'));
});

test('local supports voice cloning while google does not', () => {
  assert.equal(supportsVoiceCloning('local'), true);
  assert.equal(supportsVoiceCloning('elevenlabs'), true);
  assert.equal(supportsVoiceCloning('google'), false);
});

test('clone suggestions list only providers that can actually clone', (t) => {
  const previous = config.localTtsPython;
  config.localTtsPython = 'python';
  t.after(() => {
    config.localTtsPython = previous;
  });

  const suggestions = cloningProviderSuggestions();
  const ids = suggestions.map((item) => item.id);

  // Local is free and configured here, so it must be offered.
  assert.ok(ids.includes('local'));
  // Google can never clone, so it must never be suggested.
  assert.ok(!ids.includes('google'));
  for (const item of suggestions) {
    assert.ok(item.name.length > 0);
    assert.ok(item.reason.length > 0);
  }
});

test('descriptors expose local with cloning support', () => {
  const local = describeProviders().find((item) => item.id === 'local');
  assert.ok(local);
  assert.equal(local.supportsVoiceCloning, true);
});

test('local is unavailable while python is not configured', () => {
  const previous = config.localTtsPython;
  config.localTtsPython = '';
  try {
    assert.equal(isProviderAvailable('local'), false);
  } finally {
    config.localTtsPython = previous;
  }
});

test('sidecar protocol: list-voices returns edge voices and clones', async (t) => {
  const provider = withConfiguredSidecar(t, {
    'list-voices': (request) => ({
      id: request.id,
      ok: true,
      data: {
        voices: [
          {
            voice_id: 'vi-VN-HoaiMyNeural',
            name: 'Edge HoaiMy (nữ)',
            category: 'premade',
            labels: { language: 'vi', gender: 'female' },
          },
          {
            voice_id: `${LOCAL_CLONE_PREFIX}abc123`,
            name: 'Giọng của tôi',
            category: 'cloned',
            labels: { language: 'vi', gender: 'custom' },
          },
        ],
        edge_count: 1,
        clone_count: 1,
      },
    }),
  });

  const voices = await provider.listVoices('vi');
  assert.equal(voices.length, 2);
  assert.equal(voices[0].voice_id, 'vi-VN-HoaiMyNeural');
  assert.equal(voices[1].voice_id, `${LOCAL_CLONE_PREFIX}abc123`);
  assert.equal(voices[1].category, 'cloned');
  provider.dispose();
});

test('sidecar protocol: synth decodes base64 and reports the format', async (t) => {
  const provider = withConfiguredSidecar(t, {
    synth: (request) => {
      const isClone = request.params.voiceId.startsWith(LOCAL_CLONE_PREFIX);
      return {
        id: request.id,
        ok: true,
        data: {
          audioBase64: Buffer.from([0xff, 0xf3, 0x64]).toString('base64'),
          format: isClone ? 'wav' : 'mp3',
          engine: isClone ? 'xtts_v2' : 'edge-tts',
          voiceId: request.params.voiceId,
        },
      };
    },
  });

  const edge = await provider.synthesize({
    voiceId: 'vi-VN-HoaiMyNeural',
    text: 'xin chào',
  });
  assert.equal(edge.format, 'mp3');
  assert.equal(edge.engine, 'edge-tts');
  assert.deepEqual([...edge.audio], [0xff, 0xf3, 0x64]);

  const clone = await provider.synthesize({
    voiceId: `${LOCAL_CLONE_PREFIX}abc`,
    text: 'xin chào',
  });
  assert.equal(clone.format, 'wav');
  assert.equal(clone.engine, 'xtts_v2');
  provider.dispose();
});

test('sidecar protocol: empty audio is rejected instead of saved', async (t) => {
  const provider = withConfiguredSidecar(t, {
    synth: (request) => ({
      id: request.id,
      ok: true,
      data: { audioBase64: '', format: 'mp3', engine: 'edge-tts' },
    }),
  });

  await assert.rejects(
    () => provider.synthesize({ voiceId: 'vi-VN-HoaiMyNeural', text: 'x' }),
    (error) => error.code === 'EmptyAudio'
  );
  provider.dispose();
});

test('clone returns the clone id and flags a missing model honestly', async (t) => {
  const provider = withConfiguredSidecar(t, {
    clone: (request) => ({
      id: request.id,
      ok: true,
      data: {
        voice_id: `${LOCAL_CLONE_PREFIX}new1`,
        id: 'new1',
        name: request.params.name,
        language: 'vi',
        created_at: '2026-01-01T00:00:00Z',
        modelReady: false,
        warning: 'Chưa cài Coqui TTS',
      },
    }),
  });

  const result = await provider.cloneVoice({
    name: 'Giọng tôi',
    samplePath: 'C:/tmp/a.wav',
  });
  assert.equal(result.voiceId, `${LOCAL_CLONE_PREFIX}new1`);
  assert.equal(result.name, 'Giọng tôi');
  assert.equal(result.modelReady, false);
  assert.match(result.warning, /Coqui/);
  provider.dispose();
});

test('sidecar errors keep their message and set retryable correctly', async (t) => {
  const provider = withConfiguredSidecar(t, {
    'list-clones': (request) => ({
      id: request.id,
      ok: false,
      error: { code: 'InternalError', message: 'hỏng rồi' },
    }),
  });

  await assert.rejects(
    () => provider.listClones(),
    (error) => error.code === 'LocalTtsError' && error.retryable === false
  );
  provider.dispose();
});

test('a crashing sidecar rejects pending requests instead of hanging', async (t) => {
  // The silent handler keeps the request pending until the process dies.
  const provider = withConfiguredSidecar(t, {
    'list-clones': () => undefined,
  });

  const pending = provider.listClones();
  const child = provider.child;
  assert.ok(child, 'sidecar should have been spawned');
  child.emit('exit', 1);

  await assert.rejects(pending, (error) => error.code === 'LocalTtsCrashed');
  provider.dispose();
});

test('a broken sidecar pipe rejects pending requests instead of crashing', async (t) => {
  const provider = withConfiguredSidecar(t, {
    'list-clones': () => undefined,
  });

  const pending = provider.listClones();
  const child = provider.child;
  assert.ok(child, 'sidecar should have been spawned');
  // Without a listener on stdin this would be an unhandled 'error' event and
  // would take the whole backend process down.
  child.stdin.emit('error', new Error('EPIPE'));

  await assert.rejects(
    pending,
    (error) => error.code === 'LocalTtsCrashed' && error.statusCode === 503
  );
  provider.dispose();
});

test('a command queued behind a synthesis is not cut short', async (t) => {
  // The sidecar answers one request at a time, so `list-voices` sent while a
  // synthesis is running has to wait for all of it. Judged on its own 40ms
  // budget it used to time out while the sidecar was perfectly healthy.
  const provider = withConfiguredSidecar(
    t,
    {
      synth: (request) => ({
        id: request.id,
        ok: true,
        data: {
          audioBase64: Buffer.from([0xff, 0xf3, 0x64]).toString('base64'),
          format: 'wav',
          engine: 'xtts_v2',
        },
      }),
      'list-voices': (request) => ({
        id: request.id,
        ok: true,
        data: { voices: [], edge_count: 0, clone_count: 0 },
      }),
    },
    { serial: true, timeouts: { 'list-voices': 40 } }
  );

  const synthesis = provider.synthesize({
    voiceId: `${LOCAL_CLONE_PREFIX}abc`,
    text: 'xin chào',
  });
  const voices = provider.listVoices('vi');
  const child = provider.child;

  const outcome = await Promise.race([
    voices.then(() => 'settled', () => 'settled'),
    new Promise((resolve) => setTimeout(() => resolve('still queued'), 150)),
  ]);
  assert.equal(outcome, 'still queued');
  assert.equal(child.killed, false);

  // Releasing the synthesis lets the queued command answer normally.
  child.flush();
  child.flush();
  assert.deepEqual(await voices, []);
  assert.equal((await synthesis).engine, 'xtts_v2');
  provider.dispose();
});

test('a command that times out does not kill the job already running', async (t) => {
  // Regression: the timeout handler restarted the shared child, and the exit
  // handler then failed whatever was still running with a 503 the user could do
  // nothing about. In the request log a `list-voices` arriving 30s into a
  // generation turned both generations into 503s.
  let cloneId;
  const provider = withConfiguredSidecar(
    t,
    {
      clone: (request) => {
        cloneId = request.id;
        return undefined;
      },
      synth: () => undefined,
    },
    // Both are long commands, so neither waits for the other and the synth gives
    // up while the clone is still loading the model.
    { timeouts: { clone: 5_000, synth: 60 } }
  );

  const cloning = provider.cloneVoice({
    name: 'Giọng của tôi',
    samplePath: 'C:/tmp/a.wav',
  });
  const synthesis = provider.synthesize({
    voiceId: `${LOCAL_CLONE_PREFIX}abc`,
    text: 'xin chào',
  });
  const child = provider.child;

  await assert.rejects(synthesis, (error) => error.code === 'LocalTtsTimeout');
  assert.equal(child.killed, false);

  child.stdout.write(
    `${JSON.stringify({
      id: cloneId,
      ok: true,
      data: {
        voice_id: `${LOCAL_CLONE_PREFIX}new1`,
        id: 'new1',
        name: 'Giọng của tôi',
        language: 'vi',
        created_at: '2026-01-01T00:00:00Z',
        modelReady: true,
      },
    })}\n`
  );
  assert.equal((await cloning).voiceId, `${LOCAL_CLONE_PREFIX}new1`);
  provider.dispose();
});

test('a wedged sidecar with nothing else in flight is still restarted', async (t) => {
  const provider = withConfiguredSidecar(
    t,
    { 'list-clones': () => undefined },
    { timeouts: { 'list-clones': 30 } }
  );

  const pending = provider.listClones();
  const child = provider.child;

  await assert.rejects(pending, (error) => error.code === 'LocalTtsTimeout');
  // With no other request to protect, a fresh child is still the right answer.
  assert.equal(child.killed, true);
  provider.dispose();
});

test('requests are refused when the sidecar is not configured', async () => {
  const previous = config.localTtsPython;
  config.localTtsPython = '';
  try {
    const provider = new LocalTtsProvider(() => createFakeSidecar({}));
    await assert.rejects(
      () => provider.listClones(),
      (error) => error.code === 'LocalTtsNotConfigured'
    );
  } finally {
    config.localTtsPython = previous;
  }
});

test('testConnection is false without python and true with a live sidecar', async (t) => {
  const previous = config.localTtsPython;
  config.localTtsPython = '';
  const provider = new LocalTtsProvider(() => createFakeSidecar({}));
  assert.equal(await provider.testConnection(), false);

  const working = withConfiguredSidecar(t, {
    'list-clones': (request) => ({ id: request.id, ok: true, data: { clones: [] } }),
  });
  assert.equal(await working.testConnection(), true);
  working.dispose();
  config.localTtsPython = previous;
});

test('local provider never reports usage numbers', () => {
  const provider = new LocalTtsProvider(() => createFakeSidecar({}));
  assert.equal(provider.getUsage(), null);
  assert.equal(provider.supportsVoiceCloning(), true);
});

test('delete-clone forwards the voice id', async (t) => {
  const seen = [];
  const provider = withConfiguredSidecar(t, {
    'delete-clone': (request) => {
      seen.push(request.params.voiceId);
      return { id: request.id, ok: true, data: { success: true } };
    },
  });

  await provider.deleteClone(`${LOCAL_CLONE_PREFIX}abc123`);
  assert.deepEqual(seen, [`${LOCAL_CLONE_PREFIX}abc123`]);
  provider.dispose();
});
