import { spawn, spawn as nodeSpawn, ChildProcessWithoutNullStreams } from 'child_process';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';
import type { ProviderUsage, ProviderVoice } from './providerRouter';

export const LOCAL_PROVIDER_ID = 'local';
export const LOCAL_CLONE_PREFIX = 'clone:';
const DEFAULT_XTTS_MODEL = 'tts_models/multilingual/multi-dataset/xtts_v2';

/**
 * Budgets for one sidecar command, measured on its own.
 *
 * `synth` is the outlier: a cloned voice goes through XTTS on the CPU, where 209
 * characters took 190s, so a full-length script needs well over an hour. The old
 * ten minutes cut those requests off while the sidecar was still working on them.
 */
const COMMAND_TIMEOUTS: Record<string, number> = {
  'list-voices': 30_000,
  'list-clones': 15_000,
  'delete-clone': 15_000,
  clone: 20 * 60_000,
  synth: 90 * 60_000,
};

/** Commands that hold the sidecar's single request loop for minutes. */
const LONG_COMMANDS: ReadonlySet<string> = new Set(['clone', 'synth']);

export type SidecarCommand = keyof typeof COMMAND_TIMEOUTS;

interface PendingRequest {
  resolve: (data: Record<string, unknown>) => void;
  reject: (error: Error) => void;
  timer: NodeJS.Timeout;
  /** True while this request is the one occupying the sidecar's loop. */
  longRunning: boolean;
  /** When this request gave up, so a queued one can wait at least that long. */
  deadlineAt: number;
}

export interface LocalSynthesisResult {
  audio: Buffer;
  format: 'mp3' | 'wav';
  engine: string;
  voiceId: string;
}

export interface LocalCloneResult {
  voiceId: string;
  name: string;
  language: string;
  createdAt: string;
  modelReady: boolean;
  warning?: string;
}

type SpawnFn = typeof nodeSpawn;

/**
 * Drives the Python sidecar (backend/scripts/tts_local.py).
 *
 * The sidecar is a long-lived child process speaking newline-delimited JSON.
 * One child is kept warm because the XTTS model must stay loaded in memory
 * between requests; it is restarted automatically if it dies.
 */
export class LocalTtsProvider {
  private child: ChildProcessWithoutNullStreams | null = null;
  private buffer = '';
  private nextId = 1;
  private readonly pending = new Map<number, PendingRequest>();
  private readonly spawnFn: SpawnFn;
  private readonly timeouts: Record<string, number>;
  private lastAvailability: { value: boolean; checkedAt: number } | null = null;

  constructor(
    spawnFn: SpawnFn = spawn,
    /** Command budgets, overridable so tests need not wait out a real one. */
    timeouts: Record<string, number> = {}
  ) {
    this.spawnFn = spawnFn;
    this.timeouts = { ...COMMAND_TIMEOUTS, ...timeouts };
  }

  /** Python interpreter + sidecar script must both be present. */
  isAvailable(): boolean {
    if (this.lastAvailability && Date.now() - this.lastAvailability.checkedAt < 30_000) {
      return this.lastAvailability.value;
    }
    const available = Boolean(config.localTtsPython) && fs.existsSync(this.scriptPath());
    this.lastAvailability = { value: available, checkedAt: Date.now() };
    return available;
  }

  /** Forget the cached result so a new configuration is picked up at once. */
  refreshAvailability(): boolean {
    this.lastAvailability = null;
    return this.isAvailable();
  }

  private assertAvailable(): void {
    if (!config.localTtsPython) {
      throw new AppError(
        503,
        'LocalTtsNotConfigured',
        'Chưa cấu hình Python cho TTS trên máy. Đặt LOCAL_TTS_PYTHON trong backend/.env.',
        false
      );
    }
    if (!fs.existsSync(this.scriptPath())) {
      throw new AppError(
        503,
        'LocalTtsNotConfigured',
        `Không tìm thấy sidecar tại ${this.scriptPath()}.`,
        false
      );
    }
  }

  scriptPath(): string {
    return path.join(__dirname, '..', '..', 'scripts', 'tts_local.py');
  }

  supportsVoiceCloning(): boolean {
    return true;
  }

  /** Edge voices plus the clones stored on this machine. */
  async listVoices(language?: string): Promise<ProviderVoice[]> {
    const data = await this.request('list-voices', language ? { language } : {});
    return (data.voices as ProviderVoice[]) ?? [];
  }

  async listClones(): Promise<Array<Record<string, unknown>>> {
    const data = await this.request('list-clones', {});
    return (data.clones as Array<Record<string, unknown>>) ?? [];
  }

  async cloneVoice(params: {
    name: string;
    samplePath: string;
    language?: string;
  }): Promise<LocalCloneResult> {
    const data = await this.request('clone', {
      name: params.name,
      samplePath: params.samplePath,
      language: params.language ?? 'vi',
    });
    return {
      voiceId: String(data.voice_id),
      name: String(data.name),
      language: String(data.language ?? 'vi'),
      createdAt: String(data.created_at ?? ''),
      modelReady: data.modelReady !== false,
      warning: data.warning ? String(data.warning) : undefined,
    };
  }

  async deleteClone(voiceId: string): Promise<void> {
    await this.request('delete-clone', { voiceId });
  }

  /**
   * `voiceId` is either an Edge voice name (`vi-VN-HoaiMyNeural`) or a stored
   * clone (`clone:<id>`). Clones are rendered by XTTS and therefore return WAV.
   */
  async synthesize(params: {
    voiceId: string;
    text: string;
    speed?: number;
    model?: string;
  }): Promise<LocalSynthesisResult> {
    const data = await this.request('synth', {
      voiceId: params.voiceId,
      text: params.text,
      speed: params.speed ?? 1.0,
      model: params.model ?? DEFAULT_XTTS_MODEL,
    });

    const audio = Buffer.from(String(data.audioBase64 ?? ''), 'base64');
    if (audio.length === 0) {
      throw new AppError(
        502,
        'EmptyAudio',
        'TTS trên máy trả về âm thanh rỗng.',
        true
      );
    }

    return {
      audio,
      format: data.format === 'wav' ? 'wav' : 'mp3',
      engine: String(data.engine ?? 'edge-tts'),
      voiceId: String(data.voiceId ?? params.voiceId),
    };
  }

  /** Local TTS has no quota to report, so usage is never shown. */
  getUsage(): ProviderUsage | null {
    return null;
  }

  async testConnection(): Promise<boolean> {
    if (!this.isAvailable()) {
      return false;
    }
    try {
      await this.request('list-clones', {});
      return true;
    } catch {
      return false;
    }
  }

  dispose(): void {
    this.child?.kill();
    this.child = null;
  }

  // ------------------------------------------------------------------------- //
  // Sidecar process plumbing
  // ------------------------------------------------------------------------- //

  private request(
    command: SidecarCommand,
    params: Record<string, unknown>
  ): Promise<Record<string, unknown>> {
    this.assertAvailable();
    const child = this.ensureChild();
    const id = this.nextId++;
    const longRunning = LONG_COMMANDS.has(command);
    const budget = this.budgetFor(command, longRunning);

    return new Promise<Record<string, unknown>>((resolve, reject) => {
      const timer = setTimeout(() => {
        this.forgetPending(id);
        // A stuck sidecar is worse than a fresh one: restart and fail loudly.
        // But only when nothing else is using it — the child is a single shared
        // process holding the warm XTTS model, and killing it for a command that
        // merely timed out also failed whatever synthesis was running. A
        // `list-voices` queued behind a five-minute synthesis used to hit its
        // own 30s budget and take that generation down with it (503).
        if (this.pending.size === 0) {
          this.dispose();
        }
        reject(
          new AppError(
            504,
            'LocalTtsTimeout',
            `TTS trên máy phản hồi quá lâu (${command}).`,
            true
          ) as unknown as Error
        );
      }, budget);

      this.pending.set(id, {
        resolve,
        reject,
        timer,
        longRunning,
        deadlineAt: Date.now() + budget,
      });
      try {
        child.stdin.write(`${JSON.stringify({ id, command, params })}\n`);
      } catch (error) {
        // The pipe was already gone, so the request can never be answered.
        this.forgetPending(id);
        reject(crashedError((error as Error).message));
      }
    });
  }

  /**
   * Own budget for [command], plus the time it has to wait in the queue.
   *
   * The sidecar reads one request at a time and answers it before reading the
   * next, so a cheap command sent while a synthesis is running waits for all of
   * it. Judged on its own 30s budget it used to time out while perfectly healthy
   * and, worse, restart the child that was doing the work.
   */
  private budgetFor(command: SidecarCommand, longRunning: boolean): number {
    const own = this.timeouts[command] ?? 60_000;
    if (longRunning) {
      return own;
    }
    const now = Date.now();
    const waiting = [...this.pending.values()]
      .filter((request) => request.longRunning)
      .reduce(
        (longest, request) => Math.max(longest, request.deadlineAt - now),
        0
      );
    return own + Math.max(0, waiting);
  }

  private ensureChild(): ChildProcessWithoutNullStreams {
    if (this.child && !this.child.killed) {
      return this.child;
    }

    const child = this.spawnFn(config.localTtsPython, [this.scriptPath()], {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: {
        ...process.env,
        PYTHONIOENCODING: 'utf-8',
        PYTHONUNBUFFERED: '1',
        VIETVOICE_VOICES_DIR: config.localTtsVoicesDir || defaultVoicesDir(),
      },
    }) as ChildProcessWithoutNullStreams;

    this.buffer = '';
    child.stdout.setEncoding('utf8');
    child.stdout.on('data', (chunk: string) => this.onStdout(chunk));
    child.stderr.setEncoding('utf8');
    child.stderr.on('data', (chunk: string) => {
      process.stderr.write(`[tts_local] ${chunk}`);
    });

    child.on('error', (error) => this.failAllPending(error));
    // A broken pipe must not take the whole backend down with it.
    child.stdin.on('error', (error) => {
      this.child = null;
      this.failAllPending(crashedError(error.message));
    });
    child.on('exit', (code) => {
      this.child = null;
      this.failAllPending(
        crashedError(`TTS trên máy đã dừng (mã ${code ?? 'null'})`)
      );
    });

    this.child = child;
    return child;
  }

  private onStdout(chunk: string): void {
    this.buffer += chunk;
    let newlineIndex = this.buffer.indexOf('\n');
    while (newlineIndex >= 0) {
      const line = this.buffer.slice(0, newlineIndex).trim();
      this.buffer = this.buffer.slice(newlineIndex + 1);
      if (line) {
        this.resolveLine(line);
      }
      newlineIndex = this.buffer.indexOf('\n');
    }
  }

  private resolveLine(line: string): void {
    let parsed: {
      id?: number;
      ok?: boolean;
      data?: Record<string, unknown>;
      error?: { code?: string; message?: string };
    };
    try {
      parsed = JSON.parse(line);
    } catch {
      process.stderr.write(`[tts_local] không đọc được JSON: ${line}\n`);
      return;
    }

    const request = typeof parsed.id === 'number' ? this.pending.get(parsed.id) : undefined;
    if (!request) {
      return;
    }
    this.pending.delete(parsed.id as number);
    clearTimeout(request.timer);

    if (parsed.ok) {
      request.resolve(parsed.data ?? {});
      return;
    }
    request.reject(
      new AppError(
        mapSidecarCode(parsed.error?.code),
        'LocalTtsError',
        parsed.error?.message ?? 'TTS trên máy không trả lổi.',
        parsed.error?.code === 'EdgeServiceUnavailable' ||
          parsed.error?.code === 'ModelUnavailable'
      ) as unknown as Error
    );
  }

  private failAllPending(error: Error): void {
    for (const [id, request] of this.pending) {
      clearTimeout(request.timer);
      this.pending.delete(id);
      request.reject(error);
    }
  }

  /** Drop a request and clear its timer, e.g. when it timed out or failed early. */
  private forgetPending(id: number): void {
    const request = this.pending.get(id);
    if (request) {
      clearTimeout(request.timer);
      this.pending.delete(id);
    }
  }
}

function defaultVoicesDir(): string {
  return path.join(os.homedir(), '.vietvoice', 'voices');
}

/** A dead sidecar is worth retrying: the next request respawns the process. */
function crashedError(reason: string): AppError {
  return new AppError(
    503,
    'LocalTtsCrashed',
    `TTS trên máy đã dừng (${reason}). Hãy thử lại.`,
    true
  );
}

/** Sidecar error codes mapped onto the app's HTTP semantics. */
function mapSidecarCode(code?: string): number {
  switch (code) {
    case 'ValidationError':
      return 400;
    case 'SampleNotFound':
    case 'CloneNotFound':
      return 404;
    case 'SampleTooShort':
    case 'SampleTooLong':
    case 'InvalidSample':
      return 422;
    case 'EmptyAudio':
      return 502;
    case 'ModelUnavailable':
    case 'EdgeServiceUnavailable':
      return 502;
    case 'MissingDependency':
      return 503;
    case 'LocalTtsTimeout':
      return 504;
    default:
      return 500;
  }
}

/** Single shared instance: the sidecar (and its model) must be reused. */
export const localTtsProvider = new LocalTtsProvider();
