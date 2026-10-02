const test = require('node:test');
const assert = require('node:assert/strict');

const { AppError, errorHandler } = require('../dist/middleware/errorHandler');

/** Minimal express response that records what the handler wrote. */
function createResponse(headersSent = false) {
  return {
    headersSent,
    statusCode: undefined,
    body: undefined,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
}

function createRequest() {
  return { method: 'POST', originalUrl: '/v1/tts' };
}

/** Run the handler and return { status, body } for easy assertions. */
function handle(error, { headersSent = false } = {}) {
  const res = createResponse(headersSent);
  let forwarded;
  errorHandler(error, createRequest(), res, (err) => {
    forwarded = err;
  });
  return { res, forwarded };
}

test('AppError keeps its status, code and retryable flag', () => {
  const { res } = handle(
    new AppError(422, 'SampleTooShort', 'Mẫu âm thanh quá ngắn.', false)
  );

  assert.equal(res.statusCode, 422);
  assert.deepEqual(res.body, {
    error: {
      code: 'SampleTooShort',
      message: 'Mẫu âm thanh quá ngắn.',
      retryable: false,
    },
  });
});

test('AppError details are forwarded when present', () => {
  const { res } = handle(
    new AppError(501, 'VoiceCloningNotSupported', 'Không hỗ trợ.', false, {
      alternatives: ['local'],
    })
  );

  assert.deepEqual(res.body.error.details, { alternatives: ['local'] });
});

test('malformed JSON is a 400 validation error, not a server fault', () => {
  // This is what express.json() throws, and what the app used to see as a 500.
  const parseError = Object.assign(new SyntaxError('Unexpected token \\ in JSON'), {
    type: 'entity.parse.failed',
    status: 400,
    statusCode: 400,
  });

  const { res } = handle(parseError);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, 'ValidationError');
  assert.equal(res.body.error.retryable, false);
  assert.match(res.body.error.message, /JSON/);
});

test('the raw JSON parser message is not leaked to the client', () => {
  const parseError = Object.assign(new SyntaxError('Unexpected token } in JSON at position 4'), {
    type: 'entity.parse.failed',
    status: 400,
  });

  const { res } = handle(parseError);

  assert.ok(!res.body.error.message.includes('position 4'));
});

test('an oversized body keeps its 413 status', () => {
  const tooLarge = Object.assign(new Error('request entity too large'), {
    type: 'entity.too.large',
    status: 413,
  });

  const { res } = handle(tooLarge);

  assert.equal(res.statusCode, 413);
  assert.equal(res.body.error.retryable, false);
});

test('multer upload limits become 413 or 400 without touching the 500 path', () => {
  const sizeError = Object.assign(new Error('File too large'), {
    name: 'MulterError',
    code: 'LIMIT_FILE_SIZE',
  });
  const { res: sizeResponse } = handle(sizeError);
  assert.equal(sizeResponse.statusCode, 413);
  assert.equal(sizeResponse.body.error.code, 'LIMIT_FILE_SIZE');

  const fieldError = Object.assign(new Error('Unexpected field'), {
    name: 'MulterError',
    code: 'LIMIT_UNEXPECTED_FILE',
  });
  const { res: fieldResponse } = handle(fieldError);
  assert.equal(fieldResponse.statusCode, 400);
});

test('unexpected exceptions answer 500 and are logged with their stack', () => {
  const boom = new Error('kaboom');
  const logged = [];
  const originalConsoleError = console.error;
  console.error = (...args) => logged.push(args);
  try {
    const { res } = handle(boom);
    assert.equal(res.statusCode, 500);
    assert.equal(res.body.error.code, 'InternalServerError');
    assert.equal(res.body.error.retryable, true);
  } finally {
    console.error = originalConsoleError;
  }

  assert.equal(logged.length, 1);
  assert.match(logged[0][0], /POST \/v1\/tts/);
  assert.equal(logged[0][1], boom);
});

test('a 5xx status coming from a dependency stays a server fault', () => {
  const upstream = Object.assign(new Error('upstream exploded'), { status: 502 });

  const { res } = handle(upstream);

  assert.equal(res.statusCode, 500);
  assert.equal(res.body.error.code, 'InternalServerError');
});

test('a response that already started is handed back to express', () => {
  const { res, forwarded } = handle(new Error('too late'), {
    headersSent: true,
  });

  assert.equal(forwarded.message, 'too late');
  assert.equal(res.body, undefined);
});
