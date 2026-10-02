const test = require('node:test');
const assert = require('node:assert/strict');

const { chunkText, GOOGLE_PUBLIC_VOICE_ID, isOfficialApiEnabled } = require('../dist/services/googleTts');
const {
  resolveProvider,
  supportsVoiceCloning,
  isProviderAvailable,
  describeProviders,
  DEFAULT_PROVIDER_ID,
} = require('../dist/services/providerRouter');

const MAX = 190;

test('short text stays in a single chunk', () => {
  const chunks = chunkText('Xin chào các bạn, hôm nay trời đẹp quá.');
  assert.equal(chunks.length, 1);
  assert.equal(chunks[0], 'Xin chào các bạn, hôm nay trời đẹp quá.');
});

test('empty text produces no chunks', () => {
  assert.deepEqual(chunkText('   '), []);
  assert.deepEqual(chunkText(''), []);
});

test('every chunk stays within the public endpoint limit', () => {
  const text = Array.from(
    { length: 40 },
    (_, i) => `Câu số ${i} trong kịch bản TikTok dài hơn một chút để ép buộc việc chia đoạn.`,
  ).join(' ');

  const chunks = chunkText(text);

  assert.ok(chunks.length > 1, 'long text must be split');
  for (const chunk of chunks) {
    assert.ok(
      chunk.length <= MAX,
      `chunk too long (${chunk.length}): ${chunk}`,
    );
  }
});

test('splitting loses no characters other than separators', () => {
  const text = 'Một. Hai. Ba. Bốn. Năm. Sáu. Bảy. Tám. Chín. Mười. Mười một.';
  const chunks = chunkText(text);
  const rejoined = chunks.join(' ').replace(/\s+/g, ' ').trim();
  const original = text.replace(/\s+/g, ' ').trim();

  assert.equal(rejoined, original);
});

test('a single very long word is hard split instead of dropped', () => {
  const text = 'A'.repeat(500);
  const chunks = chunkText(text);

  assert.ok(chunks.length >= 3);
  assert.equal(chunks.join(''), text);
  for (const chunk of chunks) {
    assert.ok(chunk.length <= MAX);
  }
});

test('whitespace is normalised so chunk boundaries are clean', () => {
  const chunks = chunkText('  Xin   chào\n\ncác   bạn  ');
  assert.deepEqual(chunks, ['Xin chào các bạn']);
});

test('google provider does not support voice cloning', () => {
  assert.equal(supportsVoiceCloning('google'), false);
  assert.equal(supportsVoiceCloning('elevenlabs'), true);
});

test('google is available without any API key', () => {
  assert.equal(isOfficialApiEnabled(), false);
  assert.equal(isProviderAvailable('google'), true);
});

test('elevenlabs reports unavailable while the backend key is missing', () => {
  assert.equal(isProviderAvailable('elevenlabs'), false);
});

test('unknown providers are rejected with a clear code', () => {
  assert.throws(
    () => resolveProvider('not-a-provider'),
    (error) => error.code === 'UnknownProvider' && error.statusCode === 400,
  );
});

test('provider defaults to Google', () => {
  assert.equal(resolveProvider(undefined), 'google');
  assert.equal(resolveProvider(''), 'google');
  assert.equal(DEFAULT_PROVIDER_ID, 'google');
});

test('provider descriptors expose real capabilities', () => {
  const descriptors = describeProviders();
  const google = descriptors.find((p) => p.id === 'google');
  const elevenLabs = descriptors.find((p) => p.id === 'elevenlabs');

  assert.equal(google.supportsVoiceCloning, false);
  assert.equal(google.available, true);
  assert.equal(elevenLabs.supportsVoiceCloning, true);
});

test('google voice id is stable for the public endpoint', () => {
  assert.equal(GOOGLE_PUBLIC_VOICE_ID, 'google-vi-standard');
});
