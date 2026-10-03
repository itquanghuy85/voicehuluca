import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import fs from 'fs';
import path from 'path';
import { config } from './config';
import { rateLimiter } from './middleware/rateLimiter';
import { errorHandler } from './middleware/errorHandler';
import { appApiKeyAuth } from './middleware/appAuth';
import healthRouter from './routes/health';
import voicesRouter from './routes/voices';
import ttsRouter from './routes/tts';
import ttsMultiProviderRouter from './routes/ttsMultiProvider';
import cloneRouter from './routes/clone';
import usageRouter from './routes/usage';
import { describeProviders } from './services/providerRouter';

const app = express();

const reqLogPath = path.join(__dirname, '..', 'requests.log');
const logLine = (line: string) => {
  try {
    fs.appendFileSync(reqLogPath, `${new Date().toISOString()} ${line}\n`);
  } catch {}
  console.log(line);
};

app.use((req, res, next) => {
  const started = Date.now();
  logLine(`[START] ${req.method} ${req.originalUrl} from ${req.ip}`);
  res.on('finish', () => {
    logLine(
      `[REQ] ${req.method} ${req.originalUrl} from ${req.ip} -> ${res.statusCode} (${Date.now() - started}ms)`
    );
  });
  res.on('close', () => {
    if (!res.writableEnded) {
      logLine(`[ABORTED] ${req.method} ${req.originalUrl} after ${Date.now() - started}ms`);
    }
  });
  next();
});
app.use(helmet());
app.use(cors({
  // A LAN backend is called by IP from the phone (a null/webview origin) as
  // well as from browsers. Reflecting the origin keeps those calls working in
  // every NODE_ENV without opening the API to credentialed cross-site use.
  origin: true,
}));
app.use(express.json({ limit: '10mb' }));

// Health is a liveness probe for LAN discovery and for the user to tap by
// hand: it must answer even under load and without an app API key.
app.use('/v1/health', healthRouter);
app.use('/health', healthRouter);
app.use(rateLimiter);
app.use('/v1/providers', (_req, res) => {
  res.json({ providers: describeProviders() });
});
app.use('/v1/tts', appApiKeyAuth, ttsMultiProviderRouter);
app.use('/v1/voices/add', appApiKeyAuth, cloneRouter);
app.use('/v1/voices/clone', appApiKeyAuth, cloneRouter);
app.use('/v1/voices', appApiKeyAuth, voicesRouter);
app.use('/v1/text-to-speech', appApiKeyAuth, ttsRouter);
app.use('/v1/user', appApiKeyAuth, usageRouter);

app.use(errorHandler);

app.listen(config.port, '0.0.0.0', () => {
  console.log(`VietVoice Studio backend running on port ${config.port}`);
  console.log(
    'LAN: point the phone at http://<this-machine-lan-ip>:' +
      `${config.port}/v1 (same Wi-Fi), then open /v1/health from the phone.`,
  );
});
