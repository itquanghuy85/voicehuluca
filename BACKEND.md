# Backend

VietVoice Studio can connect to a custom backend proxy for enhanced security, rate limiting, and usage tracking.

---

## Overview

### Why Use a Backend?

| Benefit | Description |
|---------|-------------|
| **API Key Security** | ElevenLabs API key stored server-side, never exposed to client |
| **Rate Limiting** | Control usage per user to manage costs |
| **Usage Analytics** | Track character consumption and generation history |
| **Caching** | Cache frequent requests to reduce API calls |
| **Authentication** | User management and subscription enforcement |
| **Cost Control** | Prevent abuse and unexpected charges |

### Architecture

```
┌─────────────┐      HTTPS       ┌──────────────────┐      HTTPS       ┌─────────────┐
│  Flutter    │ ←──────────────→ │  Backend Proxy   │ ←──────────────→ │ ElevenLabs  │
│  App        │   (Dio Client)   │  (api.vietvoice) │   (Server Key)   │  API        │
└─────────────┘                  └──────────────────┘                  └─────────────┘
```

---

## API Endpoints

### Base URL

```
Production:  https://api.vietvoice.studio/v1
Development: http://localhost:3000/v1
```

### Authentication

All endpoints require a Bearer token (except `/auth/login` and `/auth/register`).

```
Authorization: Bearer {access_token}
```

### Endpoints

#### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/register` | Create new account |
| `POST` | `/auth/login` | Login and get tokens |
| `POST` | `/auth/refresh` | Refresh access token |
| `POST` | `/auth/logout` | Invalidate tokens |

#### Voices

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/voices` | List available voices |
| `GET` | `/voices/:id` | Get voice details |
| `POST` | `/voices/clone` | Clone voice from audio |
| `DELETE` | `/voices/:id` | Delete cloned voice |

#### TTS

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/tts/synthesize` | Generate speech from text |
| `POST` | `/tts/synthesize/stream` | Stream speech generation |
| `GET` | `/tts/status/:requestId` | Check generation status |
| `GET` | `/tts/history` | Get generation history |

#### User

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/user/profile` | Get user profile |
| `GET` | `/user/usage` | Get usage statistics |
| `GET` | `/user/subscription` | Get subscription details |

---

## Request/Response Format

### Authentication

#### Register

```http
POST /v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "Nguyen Van A"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "Nguyen Van A",
    "created_at": "2026-09-30T10:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
  "expires_in": 3600
}
```

#### Login

```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "Nguyen Van A"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
  "expires_in": 3600
}
```

### Voice Synthesis

#### Standard Synthesis

```http
POST /v1/tts/synthesize
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "voice_id": "vn_female_01",
  "text": "Xin chào, đây là giọng nói AI.",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.5,
    "similarity_boost": 0.75,
    "style": 0.0,
    "use_speaker_boost": true
  }
}
```

**Response (200):**
```json
{
  "request_id": "req_xyz789",
  "status": "completed",
  "audio_url": "https://cdn.vietvoice.studio/audio/req_xyz789.mp3",
  "duration_ms": 3500,
  "character_count": 32,
  "model_id": "eleven_multilingual_v2"
}
```

#### Streaming Synthesis

```http
POST /v1/tts/synthesize/stream
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "voice_id": "vn_female_01",
  "text": "Xin chào, đây là giọng nói AI.",
  "model_id": "eleven_multilingual_v2"
}
```

**Response (200):** Binary audio stream (audio/mpeg)

### Voice Cloning

```http
POST /v1/voices/clone
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

name: "My Cloned Voice"
description: "Warm female Vietnamese voice"
language: "vi"
files: [audio1.wav, audio2.wav]
```

**Response (200):**
```json
{
  "voice_id": "voice_clone_abc123",
  "name": "My Cloned Voice",
  "description": "Warm female Vietnamese voice",
  "language": "vi",
  "status": "ready",
  "created_at": "2026-09-30T10:05:00Z"
}
```

### Usage Statistics

```http
GET /v1/user/usage
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "character_count": 15000,
  "character_limit": 30000,
  "character_remaining": 15000,
  "usage_percentage": 50.0,
  "reset_date": "2026-10-01T00:00:00Z",
  "voice_count": 3,
  "voice_limit": 10,
  "generation_count": 45,
  "total_audio_duration_ms": 125000
}
```

---

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "details": {
      "retry_after": 60,
      "limit": 100,
      "remaining": 0
    }
  }
}
```

### HTTP Status Codes

| Code | Meaning | Client Action |
|------|---------|---------------|
| `400` | Bad Request (malformed JSON, missing field, unknown provider) | Check request format |
| `401` | Unauthorized | Fix the app API key |
| `404` | Not Found | Verify resource ID |
| `413` | Payload Too Large (body over 10 MB, audio file over 25 MB) | Send a smaller file |
| `422` | Validation Error | Check sample duration / format |
| `429` | Rate Limited | Wait and retry |
| `500` | Server Error | Retry with backoff — the cause is logged to stderr |
| `501` | Not Implemented (provider cannot clone voices) | Pick another provider |
| `502` | Upstream provider failed | Retry, or switch provider |
| `503` | Service Unavailable (no key, sidecar down) | Retry later |
| `504` | Sidecar timeout | Retry, or switch provider |

### Error Codes

Codes are emitted in `PascalCase` and every response also carries `retryable`.

| Code | Status | Description |
|------|--------|-------------|
| `ValidationError` | 400 | Malformed JSON body or a missing/blank field |
| `BadRequest` | 400 | Request rejected by body parsing (encoding, size, abort) |
| `UnknownProvider` | 400 | `provider` is not `google`, `elevenlabs` or `local` |
| `MissingApiKey` / `InvalidApiKey` | 401 | Missing or wrong `x-vvt-api-key` |
| `CloneNotFound` / `SampleNotFound` | 404 | Clone or sample file does not exist |
| `LIMIT_FILE_SIZE` | 413 | Audio sample exceeds the 25 MB upload limit |
| `SampleTooShort` / `SampleTooLong` / `InvalidSample` | 422 | Sample outside 5–30s or not decodable |
| `RateLimitExceeded` | 429 | More than 100 requests per minute |
| `OperationNotSupported` | 400 | Provider forbids the operation (e.g. deleting a Google voice) |
| `InternalServerError` | 500 | Unexpected fault; the stack goes to the backend stderr log |
| `VoiceCloningNotSupported` | 501 | Selected provider cannot clone voices |
| `EmptyAudio` / `LocalTtsError` | 502 | Provider returned no audio, or the sidecar failed |
| `ModelUnavailable` / `EdgeServiceUnavailable` | 502 | XTTS model missing, or Edge TTS unreachable |
| `LocalTtsNotConfigured` | 503 | `LOCAL_TTS_PYTHON` or the sidecar script is missing |
| `LocalTtsCrashed` | 503 | The Python sidecar died; the next request respawns it |
| `LocalTtsTimeout` | 504 | The sidecar did not answer within its command timeout |

---

## Security

### Authentication Flow

```
┌──────────┐                    ┌──────────┐
│   App    │ ── Login ────────→ │ Backend  │
│          │ ←─ Access Token ─  │          │
│          │ ←─ Refresh Token ─ │          │
│          │                    │          │
│          │ ── API Request ──→ │          │
│          │   (Access Token)   │          │
│          │ ←─ Response ─────  │          │
│          │                    │          │
│          │ ── Token Refresh → │          │
│          │   (Refresh Token)  │          │
│          │ ←─ New Tokens ───  │          │
└──────────┘                    └──────────┘
```

### Token Management

| Token | Expiry | Storage | Usage |
|-------|--------|---------|-------|
| **Access Token** | 1 hour | Memory | API requests |
| **Refresh Token** | 30 days | Secure Storage | Get new access token |

### Security Headers

```http
# Required on all responses
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

### API Key Security

- ElevenLabs API key is **never** exposed to the client
- Stored in environment variables on the server
- Rotated regularly
- Access logged and monitored

---

## Rate Limiting

### Limits

| Tier | Requests/min | Characters/day | Concurrent |
|------|-------------|----------------|------------|
| **Free** | 20 | 10,000 | 1 |
| **Basic** | 60 | 50,000 | 3 |
| **Pro** | 200 | 200,000 | 10 |
| **Enterprise** | Custom | Custom | Custom |

### Rate Limit Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1699999999
```

### Handling Rate Limits

```dart
// Exponential backoff retry
Future<T> withRetry<T>(Future<T> Function() fn) async {
  const maxRetries = 3;
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429 && i < maxRetries - 1) {
        final retryAfter = e.response?.headers.value('retry-after');
        final delay = int.tryParse(retryAfter ?? '') ?? (2 * (i + 1));
        await Future.delayed(Duration(seconds: delay));
        continue;
      }
      rethrow;
    }
  }
  throw Exception('Max retries exceeded');
}
```

---

## Deployment

### Backend Technology Stack

| Component | Technology |
|-----------|-----------|
| **Runtime** | Node.js 20+ / Deno |
| **Framework** | Express / Hono / Fastify |
| **Database** | PostgreSQL |
| **Cache** | Redis |
| **Queue** | Bull / SQS |
| **Hosting** | AWS / GCP / Azure |

### Environment Variables

```env
# Server
PORT=3000
NODE_ENV=production

# Database
DATABASE_URL=postgresql://user:pass@host:5432/vietvoice
REDIS_URL=redis://host:6379

# ElevenLabs
ELEVENLABS_API_KEY=your_server_side_api_key
ELEVENLABS_BASE_URL=https://api.elevenlabs.io

# Auth
JWT_SECRET=your_jwt_secret
JWT_EXPIRY=3600
REFRESH_TOKEN_EXPIRY=2592000

# Rate Limiting
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX=60
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/vietvoice
      - REDIS_URL=redis://redis:6379
      - ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY}
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: vietvoice
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

### Health Check

```http
GET /v1/health
```

**Response (200):**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": 86400,
  "services": {
    "database": "connected",
    "redis": "connected",
    "elevenlabs": "connected"
  }
}
```

---

## Client Configuration

### App Configuration

In the Flutter app, configure the backend URL:

```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl = 'https://api.vietvoice.studio/v1';
```

### Dio Client Setup

```dart
// lib/data/datasources/remote/tts_remote_datasource.dart
final dio = Dio(BaseOptions(
  baseUrl: AppConstants.apiBaseUrl,
  connectTimeout: AppConstants.connectionTimeout,
  receiveTimeout: AppConstants.apiTimeout,
  headers: {
    'Content-Type': 'application/json',
  },
));

// Add auth interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await _getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Try to refresh token
      final newToken = await _refreshToken();
      if (newToken != null) {
        // Retry original request
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await dio.fetch(error.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(error);
  },
));
```

---

## Monitoring

### Metrics to Track

| Metric | Description |
|--------|-------------|
| **Request Count** | Total API requests per minute |
| **Error Rate** | Percentage of failed requests |
| **Latency** | P50, P95, P99 response times |
| **Character Usage** | Characters consumed per user/day |
| **Active Users** | Concurrent users |
| **Cache Hit Rate** | Percentage of cached responses |

### Logging

```json
{
  "timestamp": "2026-09-30T10:00:00Z",
  "level": "info",
  "method": "POST",
  "path": "/v1/tts/synthesize",
  "user_id": "usr_abc123",
  "status": 200,
  "duration_ms": 1250,
  "character_count": 32,
  "voice_id": "vn_female_01"
}
```
