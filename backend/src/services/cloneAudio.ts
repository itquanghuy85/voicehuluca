import { execFile, spawn } from 'child_process';
import { promisify } from 'util';

const run = promisify(execFile);

/**
 * Audio preparation for voice cloning.
 *
 * ElevenLabs documents MP3 at 192 kbps or better for cloning samples, so an
 * upload is re-encoded when FFmpeg is available. FFmpeg is not bundled: when it
 * is missing the original file is sent unchanged, because ElevenLabs accepts
 * WAV, MP3 and M4A directly. Nothing is faked either way, the provider decides.
 */

/** Bitrate ElevenLabs asks for on cloning samples. */
export const CLONE_MP3_BITRATE_KBPS = 192;

let ffmpegChecked = false;
let ffmpegAvailable = false;

/** Whether the `ffmpeg` binary can be run, probed once per process. */
export async function hasFfmpeg(): Promise<boolean> {
  if (ffmpegChecked) return ffmpegAvailable;
  ffmpegChecked = true;
  try {
    await run('ffmpeg', ['-version'], { timeout: 5000 });
    ffmpegAvailable = true;
  } catch {
    ffmpegAvailable = false;
  }
  return ffmpegAvailable;
}

export interface CloneSample {
  buffer: Buffer;
  filename: string;
  contentType: string;
}

/**
 * Re-encodes a sample to MP3 at 192 kbps, mono, 44.1 kHz.
 *
 * Returns the input untouched when FFmpeg is not installed or the conversion
 * fails, so a missing codec degrades to "send what we were given" instead of
 * blocking the clone.
 */
export async function toCloneMp3(sample: CloneSample): Promise<CloneSample> {
  if (!(await hasFfmpeg())) return sample;

  try {
    const buffer = await pipeThroughFfmpeg(sample.buffer);
    if (buffer.length === 0) return sample;
    return {
      buffer,
      filename: `${sample.filename.replace(/\.[^.]+$/, '')}.mp3`,
      contentType: 'audio/mpeg',
    };
  } catch {
    return sample;
  }
}

/** Feeds bytes to ffmpeg on stdin and collects the MP3 it writes to stdout. */
function pipeThroughFfmpeg(input: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const child = spawn(
      'ffmpeg',
      [
        '-nostdin',
        '-v',
        'error',
        '-i',
        'pipe:0',
        '-ac',
        '1',
        '-ar',
        '44100',
        '-b:a',
        `${CLONE_MP3_BITRATE_KBPS}k`,
        '-f',
        'mp3',
        'pipe:1',
      ],
      { stdio: ['pipe', 'pipe', 'pipe'] }
    );

    const chunks: Buffer[] = [];
    const errors: Buffer[] = [];
    child.stdout.on('data', (chunk: Buffer) => chunks.push(chunk));
    child.stderr.on('data', (chunk: Buffer) => errors.push(chunk));
    child.on('error', reject);
    child.on('close', (code) => {
      if (code === 0) {
        resolve(Buffer.concat(chunks));
      } else {
        reject(new Error(`ffmpeg exited ${code}: ${Buffer.concat(errors).toString()}`));
      }
    });

    child.stdin.on('error', () => {
      // ffmpeg closed stdin early; `close` reports the real reason.
    });
    child.stdin.end(input);
  });
}