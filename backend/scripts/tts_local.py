#!/usr/bin/env python3
"""VietVoice Studio - local TTS sidecar.

Speaks newline-delimited JSON on stdin/stdout so the Node backend can drive it
without any HTTP server. Every request looks like::

    {"id": 1, "command": "list-voices", "params": {}}

and every response like::

    {"id": 1, "ok": true, "data": {...}}
    {"id": 1, "ok": false, "error": {"code": "...", "message": "..."}}

Commands
--------
list-voices    Edge TTS voices plus locally stored clones (``clone:<id>``)
list-clones    Clones stored on this machine
clone          Clone a voice from a WAV sample (XTTS-v2, first run downloads ~1.8GB)
delete-clone   Remove a stored clone
synth          Synthesise speech (Edge TTS, or XTTS-v2 for ``clone:`` voices)

Heavy dependencies (torch / TTS) are imported lazily so the cheap commands keep
working on a machine that only installed the requirements needed for Edge TTS.
"""

from __future__ import annotations

import asyncio
import json
import os
import sys
import traceback
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

VOICES_DIR = Path(
    os.environ.get(
        "VIETVOICE_VOICES_DIR",
        str(Path.home() / ".vietvoice" / "voices"),
    )
)
CLONE_PREFIX = "clone:"
DEFAULT_CLONE_LANGUAGE = "vi"
MIN_SAMPLE_SECONDS = 5.0
MAX_SAMPLE_SECONDS = 30.0
# XTTS-v2 works in 24 kHz and reads its reference through ``soundfile``, which
# only understands linear PCM. Whatever the phone recorded gets decoded to this
# rate before anything else looks at it.
CLONE_SAMPLE_RATE = 24000
# The public Edge endpoint sometimes answers with no audio when requests arrive
# in bursts; a few retries turn that into a non-event for the user.
EDGE_ATTEMPTS = 3
EDGE_BACKOFF_SECONDS = (0.6, 1.8)

# XTTS v2 only supports these languages; anything else is rejected up front so
# the user gets a clear message instead of a model error.
XTTS_LANGUAGES = (
    "en",
    "es",
    "fr",
    "de",
    "it",
    "pt",
    "pl",
    "tr",
    "ru",
    "nl",
    "cs",
    "ar",
    "zh-cn",
    "ja",
    "hu",
    "ko",
    "hi",
)


class SidecarError(Exception):
    """Error that is safe to report back to the app."""

    def __init__(self, code: str, message: str, retryable: bool = False) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.retryable = retryable


def log(message: str) -> None:
    """Diagnostics go to stderr so stdout stays a clean JSON stream."""
    print(f"[tts_local] {message}", file=sys.stderr, flush=True)


def read_json_line(stream) -> Optional[Dict[str, Any]]:
    line = stream.readline()
    if not line:
        return None
    line = line.strip()
    if not line:
        return {}
    try:
        payload = json.loads(line)
    except json.JSONDecodeError as error:
        raise SidecarError("InvalidRequest", f"Bod JSON không hợp lệ: {error}") from error
    if not isinstance(payload, dict):
        raise SidecarError("InvalidRequest", "Yêu cầu phải là một JSON object.")
    return payload


# --------------------------------------------------------------------------- #
# Stored clones
# --------------------------------------------------------------------------- #


@dataclass
class CloneVoice:
    id: str
    name: str
    language: str
    created_at: str
    reference_path: Path

    def to_dict(self) -> Dict[str, Any]:
        return {
            "voice_id": f"{CLONE_PREFIX}{self.id}",
            "id": self.id,
            "name": self.name,
            "language": self.language,
            "created_at": self.created_at,
        }

    def to_voice(self) -> Dict[str, Any]:
        return {
            "voice_id": f"{CLONE_PREFIX}{self.id}",
            "name": self.name,
            "category": "cloned",
            "description": f"Giọng nhân bản trên máy ({self.language})",
            "labels": {"language": self.language, "gender": "custom"},
        }


def ensure_voices_dir() -> Path:
    VOICES_DIR.mkdir(parents=True, exist_ok=True)
    return VOICES_DIR


def clone_dir(clone_id: str) -> Path:
    return ensure_voices_dir() / clone_id


def read_clone(directory: Path) -> Optional[CloneVoice]:
    config_path = directory / "config.json"
    reference = directory / "reference.wav"
    if not config_path.is_file() or not reference.is_file():
        return None
    try:
        stored = json.loads(config_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return CloneVoice(
        id=stored.get("id", directory.name),
        name=stored.get("name", directory.name),
        language=stored.get("language", DEFAULT_CLONE_LANGUAGE),
        created_at=stored.get("created_at", ""),
        reference_path=reference,
    )


def list_clones() -> List[CloneVoice]:
    root = ensure_voices_dir()
    clones: List[CloneVoice] = []
    for entry in sorted(root.iterdir()):
        if not entry.is_dir():
            continue
        clone = read_clone(entry)
        if clone is not None:
            clones.append(clone)
    clones.sort(key=lambda item: item.created_at, reverse=True)
    return clones


def audio_duration_seconds(path: Path) -> float:
    """Read duration from the WAV header without extra dependencies."""
    import wave

    with wave.open(str(path), "rb") as handle:
        frames = handle.getnframes()
        rate = handle.getframerate() or 1
        return frames / float(rate)


def is_pcm_wav(path: Path) -> bool:
    """True when ``wave`` can already read the file, i.e. plain PCM WAV."""
    import wave

    try:
        with wave.open(str(path), "rb") as handle:
            return handle.getcomptype() == "NONE" and handle.getsampwidth() == 2
    except Exception:
        return False


def _decode_to_mono(path: Path) -> Tuple[Any, int]:
    """Return ``(float32 mono samples, sample_rate)`` for any audio container.

    Order matters. ``soundfile`` is tried first because it reads WAV and FLOC
    with no extra machinery, and because the torchcodec import behind
    ``torchaudio`` is slow to fail when FFmpeg is missing. The two remaining
    decoders are the ones that can read AAC in an M4A container, which is what
    iOS produces, and both of them need FFmpeg: one as a library torchcodec can
    load, the other as the ``ffmpeg`` command on PATH.
    """
    import numpy as np

    failures: List[str] = []
    try:
        import soundfile as sf

        data, rate = sf.read(str(path), dtype="float32", always_2d=True)
        return np.ascontiguousarray(data.mean(axis=1), dtype="float32"), int(rate)
    except Exception as error:  # noqa: BLE001 - any decoder failure is a fallback
        failures.append(f"soundfile: {_brief(error)}")

    try:
        import torch
        import torchaudio

        waveform, rate = torchaudio.load(str(path))
        mono = waveform.to(torch.float32).mean(dim=0).numpy()
        return np.ascontiguousarray(mono, dtype="float32"), int(rate)
    except Exception as error:  # noqa: BLE001
        failures.append(f"torchaudio: {_brief(error)}")

    try:
        return _decode_with_ffmpeg(path)
    except Exception as error:  # noqa: BLE001
        failures.append(f"ffmpeg: {_brief(error)}")

    raise SidecarError(
        "InvalidSample",
        "Không đọc được file âm thanh. Bản ghi từ iPhone là AAC trong file M4A, "
        "cần FFmpeg để giải mã. Cài FFmpeg rồi mở lại backend, hoặc chuyển sang "
        "nhà cung cấp ElevenLabs. (" + "; ".join(failures) + ")",
    )


def _decode_with_ffmpeg(path: Path) -> Tuple[Any, int]:
    """Decode through the ``ffmpeg`` CLI, which reads every container we get."""
    import subprocess
    import tempfile

    import numpy as np
    import soundfile as sf

    with tempfile.TemporaryDirectory() as workdir:
        target = Path(workdir) / "decoded.wav"
        result = subprocess.run(
            [
                "ffmpeg",
                "-nostdin",
                "-v",
                "error",
                "-y",
                "-i",
                str(path),
                "-ac",
                "1",
                "-ar",
                str(CLONE_SAMPLE_RATE),
                "-c:a",
                "pcm_s16le",
                str(target),
            ],
            capture_output=True,
            text=True,
            timeout=120,
        )
        if result.returncode != 0 or not target.is_file():
            raise RuntimeError(
                f"exit {result.returncode}: {_brief_text(result.stderr)}"
            )
        data, rate = sf.read(str(target), dtype="float32", always_2d=True)
        return np.ascontiguousarray(data.mean(axis=1), dtype="float32"), int(rate)


def _brief_text(text: str, limit: int = 160) -> str:
    """One line of command output, without the noise around it."""
    collapsed = " ".join((text or "").split())
    return collapsed if len(collapsed) <= limit else collapsed[:limit] + "…"


def _brief(error: Exception, limit: int = 160) -> str:
    """One line of a decoder failure, without the multi-paragraph traceback."""
    return _brief_text(str(error), limit)


def normalize_sample(path: Path) -> Path:
    """Rewrite any recording as mono 16-bit PCM WAV and return the new path.

    The phone decides the container, not us: iOS returns AAC in an M4A file and
    Android varies between 16 and 24-bit PCM. ``wave`` and ``soundfile`` read
    PCM only, so the upload is decoded once, here, where a decoder exists.

    The result is a *different path*: libsndfile picks its output format from
    the file extension, so it cannot write a WAV back into a file called
    ``.m4a`` and would raise instead of converting.
    """
    if is_pcm_wav(path):
        return path

    import numpy as np
    import soundfile as sf

    samples, rate = _decode_to_mono(path)
    if samples.size == 0 or rate <= 0:
        raise SidecarError("InvalidSample", "File âm thanh rỗng.")

    if rate != CLONE_SAMPLE_RATE:
        samples = _resample(samples, rate, CLONE_SAMPLE_RATE)

    converted = path.with_name(f"{path.stem}.wav")
    sf.write(str(converted), samples, CLONE_SAMPLE_RATE, subtype="PCM_16")
    log(
        f"Đã chuyển mẫu âm thanh sang WAV {CLONE_SAMPLE_RATE}Hz 16-bit "
        f"(mẫu gốc {path.suffix or '?'} {rate}Hz)."
    )
    return converted


def _resample(samples: Any, source_rate: int, target_rate: int) -> Any:
    """Resample mono float32 audio, preferring torchaudio when it is installed."""
    import numpy as np

    if source_rate == target_rate:
        return samples

    try:
        import torch
        import torchaudio.functional as F

        waveform = torch.from_numpy(np.ascontiguousarray(samples, dtype="float32"))
        resampled = F.resample(waveform, source_rate, target_rate)
        return np.ascontiguousarray(resampled.numpy(), dtype="float32")
    except Exception:
        # Linear interpolation is not a great anti-aliasing filter, but a voice
        # reference does not need one and numpy is always available.
        count = max(1, int(round(samples.size * target_rate / source_rate)))
        positions = np.linspace(0, samples.size - 1, count, dtype="float64")
        return np.interp(positions, np.arange(samples.size), samples).astype(
            "float32"
        )


def validate_sample(path: Path) -> None:
    if not path.is_file():
        raise SidecarError("SampleNotFound", "Không tìm thấy file âm thanh mẫu.")
    if path.stat().st_size < 1024:
        raise SidecarError(
            "SampleTooShort",
            "File âm thanh quá ngắn, hãy ghi khoảng 5-30 giây.",
        )
    try:
        duration = audio_duration_seconds(path)
    except (wave.Error, EOFError, OSError) as error:
        raise SidecarError(
            "InvalidSample", f"Không đọc được file WAV: {error}"
        ) from error
    if duration < MIN_SAMPLE_SECONDS:
        raise SidecarError(
            "SampleTooShort",
            f"Mẫu âm thanh dài {duration:.1f}s, cần ít nhất {MIN_SAMPLE_SECONDS:.0f}s.",
        )
    if duration > MAX_SAMPLE_SECONDS:
        raise SidecarError(
            "SampleTooLong",
            f"Mẫu âm thanh dài {duration:.1f}s, tối đa {MAX_SAMPLE_SECONDS:.0f}s.",
        )


# --------------------------------------------------------------------------- #
# Edge TTS
# --------------------------------------------------------------------------- #


def edge_tts_module():
    try:
        import edge_tts  # noqa: WPS433 - optional dependency
    except ImportError as error:  # pragma: no cover - depends on environment
        raise SidecarError(
            "MissingDependency",
            "Chưa cài edge-tts. Chạy: pip install -r backend/requirements-tts.txt",
            retryable=False,
        ) from error
    return edge_tts


def normalize_rate(speed: Optional[float]) -> str:
    """edge-tts expects a percentage string such as ``+10%``."""
    if not speed or speed <= 0:
        return "+0%"
    percent = int(round((float(speed) - 1.0) * 100))
    percent = max(-50, min(100, percent))
    return f"{percent:+d}%"


def run_async(coroutine):
    import asyncio

    try:
        return asyncio.run(coroutine)
    except RuntimeError as error:  # pragma: no cover - nested loop guard
        raise SidecarError("InternalError", str(error), retryable=True) from error


async def edge_list_voices() -> List[Dict[str, Any]]:
    edge_tts = edge_tts_module()
    last_error: Optional[Exception] = None

    # The public endpoint occasionally answers with an empty body when several
    # requests arrive in a burst, so a couple of retries avoids random failures.
    for attempt in range(EDGE_ATTEMPTS):
        try:
            return await edge_tts.list_voices()
        except Exception as error:  # network / throttling / service failure
            last_error = error
            if attempt + 1 < EDGE_ATTEMPTS:
                await asyncio.sleep(EDGE_BACKOFF_SECONDS[attempt])

    raise SidecarError(
        "EdgeServiceUnavailable",
        f"Không lấy được danh sách giọng Edge TTS: {last_error}",
        retryable=True,
    )


def to_edge_voice(voice: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "voice_id": voice["ShortName"],
        "name": _describe_edge_voice(voice),
        "category": "premade",
        "description": f"Microsoft Edge ({voice.get('Locale', '')})",
        "labels": {
            "language": (voice.get("Locale", "") or "vi").split("-")[0].lower(),
            "gender": (voice.get("Gender") or "neutral").lower(),
        },
    }


def _describe_edge_voice(voice: Dict[str, Any]) -> str:
    """Short display name, e.g. "HoaiMy Online (Natural) - Vietnamese" -> "HoaiMy (nữ)"."""
    import re

    friendly = (voice.get("FriendlyName") or voice.get("ShortName") or "").replace(
        "Microsoft ", ""
    )
    short_name = re.split(r" - | Online", friendly)[0].strip()
    gender = (voice.get("Gender") or "").lower()
    suffix = {"male": " (nam)", "female": " (nữ)"}.get(gender, "")
    return f"Edge {short_name}{suffix}"


async def edge_synthesize(text: str, voice_id: str, speed: Optional[float]) -> bytes:
    """Synthesise with Edge TTS, retrying the transient empty responses."""
    edge_tts = edge_tts_module()
    rate = normalize_rate(speed)
    last_error: Optional[Exception] = None

    for attempt in range(EDGE_ATTEMPTS):
        audio = bytearray()
        try:
            communicate = edge_tts.Communicate(text, voice_id, rate=rate)
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio.extend(chunk["data"])
        except Exception as error:
            last_error = error
        else:
            if audio:
                return bytes(audio)
            last_error = RuntimeError("Edge TTS trả về âm thanh rỗng.")

        if attempt + 1 < EDGE_ATTEMPTS:
            log(f"Edge TTS thất bại ({last_error}), thử lại lần {attempt + 2}...")
            await asyncio.sleep(EDGE_BACKOFF_SECONDS[attempt])

    raise SidecarError(
        "EdgeServiceUnavailable",
        f"Edge TTS không tạo được âm thanh: {last_error}",
        retryable=True,
    )


# --------------------------------------------------------------------------- #
# XTTS-v2 (voice cloning)
# --------------------------------------------------------------------------- #


def xtts_module():
    """Load Coqui TTS lazily: the model is only needed for clones.

    Both the upstream ``TTS`` package and the prebuilt ``coqui-tts`` fork are
    accepted, because upstream needs a C++ toolchain to build on Windows.
    """
    if os.environ.get("COQUI_TOS_AGREED") != "1":
        os.environ["COQUI_TOS_AGREED"] = "1"

    import importlib

    for module_name in ("TTS.api", "coqui_tts.api"):
        try:
            module = importlib.import_module(module_name)
        except ImportError:
            continue
        engine = getattr(module, "TTS", None)
        if engine is not None:
            return engine

    raise SidecarError(
        "MissingDependency",
        "Chưa cài Coqui TTS để nhân bản giọng. "
        "Chạy: pip install -r backend/requirements-tts.txt",
        retryable=False,
    )


_xtts_cache: Dict[str, Any] = {}


def patch_audio_loading() -> None:
    """Let Coqui read the reference WAV without a system FFmpeg install.

    ``torchaudio.load`` routes through torchcodec/FFmpeg on recent torch builds
    and fails when FFmpeg is missing. The reference is always a plain WAV, which
    ``soundfile`` (libsndfile) reads on its own, so fall back to it instead of
    requiring FFmpeg to be installed.
    """
    try:
        import numpy as np
        import soundfile as sf
        import torch
        import torchaudio
    except ImportError:  # pragma: no cover - depends on environment
        return

    original_load = getattr(torchaudio, "_load_patched_by_vietvoice", False)
    if original_load:
        return

    def load(uri, *args, **kwargs):
        try:
            return torchaudio_load(uri, *args, **kwargs)
        except Exception:
            data, sample_rate = sf.read(str(uri), dtype="float32", always_2d=True)
            tensor = torch.from_numpy(np.ascontiguousarray(data.T))
            return tensor, sample_rate

    torchaudio_load = torchaudio.load
    torchaudio.load = load
    torchaudio._load_patched_by_vietvoice = True


def get_xtts(model_name: str = "tts_models/multilingual/multi-dataset/xtts_v2"):
    """Instantiate XTTS once and keep it warm for the rest of the process."""
    if model_name in _xtts_cache:
        return _xtts_cache[model_name]

    CoquiTTS = xtts_module()
    patch_audio_loading()
    log(f"Đang tải mô hình {model_name} (lần đầu khoảng 1.8GB)...")
    try:
        engine = CoquiTTS(model_name=model_name, progress_bar=False)
    except Exception as error:
        raise SidecarError(
            "ModelUnavailable",
            f"Không tải được mô hình XTTS: {error}",
            retryable=True,
        ) from error
    _xtts_cache[model_name] = engine
    log("Mô hình XTTS đã sẵn sàng.")
    return engine


def normalize_xtts_language(language: Optional[str]) -> str:
    normalized = (language or DEFAULT_CLONE_LANGUAGE).strip().lower()
    if normalized in XTTS_LANGUAGES:
        return normalized
    if normalized.startswith("vi"):
        return "en"
    return normalized


def xtts_synthesize(
    reference: Path, text: str, language: str, model_name: str, speed: float
) -> Path:
    engine = get_xtts(model_name)
    output = ensure_voices_dir() / f"_preview_{uuid.uuid4().hex}.wav"
    try:
        engine.tts_to_file(
            text=text,
            speaker_wav=str(reference),
            language=normalize_xtts_language(language),
            file_path=str(output),
            speed=speed if speed and speed > 0 else 1.0,
        )
    except Exception as error:
        raise SidecarError(
            "CloneSynthesisFailed", f"XTTS không tạo được âm thanh: {error}", retryable=True
        ) from error
    if not output.is_file() or output.stat().st_size == 0:
        raise SidecarError("EmptyAudio", "XTTS trả về âm thanh rỗng.", retryable=True)
    return output


# --------------------------------------------------------------------------- #
# Commands
# --------------------------------------------------------------------------- #


def command_list_voices(params: Dict[str, Any]) -> Dict[str, Any]:
    """Edge voices first, then the clones recorded on this machine.

    Vietnamese voices lead the list because VietVoice Studio targets Vietnamese
    content; everything else follows alphabetically.
    """
    language_filter = (params.get("language") or "").lower()
    voices = [to_edge_voice(voice) for voice in run_async(edge_list_voices())]

    def sort_key(voice: Dict[str, Any]) -> tuple:
        language = voice["labels"].get("language", "")
        is_vietnamese = 0 if language.startswith("vi") else 1
        return (is_vietnamese, language, voice["name"])

    voices.sort(key=sort_key)

    if language_filter:
        voices = [
            voice
            for voice in voices
            if voice["labels"].get("language", "").startswith(language_filter)
        ]
    clones = [clone.to_voice() for clone in list_clones()]
    return {
        "voices": voices + clones,
        "edge_count": len(voices),
        "clone_count": len(clones),
    }


def command_list_clones(_params: Dict[str, Any]) -> Dict[str, Any]:
    return {"clones": [clone.to_dict() for clone in list_clones()]}


def command_clone(params: Dict[str, Any]) -> Dict[str, Any]:
    name = (params.get("name") or "").strip()
    if not name:
        raise SidecarError("ValidationError", "Cần đặt tên cho giọng mới.")

    raw_path = params.get("samplePath")
    if not raw_path:
        raise SidecarError("ValidationError", "Thiếu file âm thanh mẫu.")

    sample = normalize_sample(Path(str(raw_path)))
    validate_sample(sample)

    language = (params.get("language") or DEFAULT_CLONE_LANGUAGE).strip().lower()
    clone_id = uuid.uuid4().hex[:12]
    target = clone_dir(clone_id)
    target.mkdir(parents=True, exist_ok=True)

    reference = target / "reference.wav"
    reference.write_bytes(sample.read_bytes())

    created_at = datetime.now(timezone.utc).isoformat()
    (target / "config.json").write_text(
        json.dumps(
            {
                "id": clone_id,
                "name": name,
                "language": language,
                "created_at": created_at,
                "engine": "xtts_v2",
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    # Warm the model up front: the first clone would otherwise fail slowly and
    # the user would see no feedback at all.
    try:
        get_xtts(params.get("model") or "tts_models/multilingual/multi-dataset/xtts_v2")
    except SidecarError as error:
        # Keep the stored sample so the user can retry without re-recording.
        log(f"Cảnh báo khi tải mô hình: {error.message}")
        return {
            **CloneVoice(clone_id, name, language, created_at, reference).to_dict(),
            "modelReady": False,
            "warning": error.message,
        }

    return {
        **CloneVoice(clone_id, name, language, created_at, reference).to_dict(),
        "modelReady": True,
    }


def command_delete_clone(params: Dict[str, Any]) -> Dict[str, Any]:
    voice_id = str(params.get("voiceId") or "")
    if not voice_id.startswith(CLONE_PREFIX):
        raise SidecarError("ValidationError", "voiceId phải bắt đầu bằng 'clone:'.")
    clone_id = voice_id[len(CLONE_PREFIX) :]
    if not clone_id or "/" in clone_id or "\\" in clone_id or clone_id.startswith("."):
        raise SidecarError("ValidationError", "voiceId không hợp lệ.")

    target = clone_dir(clone_id)
    if not target.is_dir():
        raise SidecarError("CloneNotFound", "Không tìm thấy giọng đã lưu.")

    import shutil

    shutil.rmtree(target, ignore_errors=True)
    return {"voice_id": voice_id, "success": True}


def command_synth(params: Dict[str, Any]) -> Dict[str, Any]:
    text = (params.get("text") or "").strip()
    if not text:
        raise SidecarError("ValidationError", "Thiếu nội dung văn bản.")

    voice_id = (params.get("voiceId") or "").strip()
    if not voice_id:
        raise SidecarError("ValidationError", "Thiếu voiceId.")

    speed = params.get("speed")
    speed_value = float(speed) if speed else 1.0

    if not voice_id.startswith(CLONE_PREFIX):
        audio = run_async(edge_synthesize(text, voice_id, speed_value))
        return {
            "audioBase64": _b64(audio),
            "format": "mp3",
            "engine": "edge-tts",
            "voiceId": voice_id,
        }

    clone_id = voice_id[len(CLONE_PREFIX) :]
    clone = read_clone(clone_dir(clone_id)) if clone_id else None
    if clone is None:
        raise SidecarError("CloneNotFound", "Không tìm thấy giọng đã nhân bản.")

    model_name = params.get("model") or "tts_models/multilingual/multi-dataset/xtts_v2"
    output = xtts_synthesize(
        clone.reference_path, text, clone.language, model_name, speed_value
    )
    try:
        audio = output.read_bytes()
    finally:
        try:
            output.unlink()
        except OSError:
            pass
    return {
        "audioBase64": _b64(audio),
        "format": "wav",
        "engine": "xtts_v2",
        "voiceId": voice_id,
    }


def _b64(data: bytes) -> str:
    import base64

    return base64.b64encode(data).decode("ascii")


COMMANDS: Dict[str, Callable[[Dict[str, Any]], Dict[str, Any]]] = {
    "list-voices": command_list_voices,
    "list-clones": command_list_clones,
    "clone": command_clone,
    "delete-clone": command_delete_clone,
    "synth": command_synth,
}


def dispatch(command: str, params: Dict[str, Any]) -> Dict[str, Any]:
    handler = COMMANDS.get(command)
    if handler is None:
        raise SidecarError(
            "UnknownCommand",
            f"Lệnh không hỗ trợ: {command}. "
            f"Các lệnh hợp lệ: {', '.join(sorted(COMMANDS))}.",
        )
    return handler(params)


def force_utf8_streams() -> None:
    """Windows defaults to a legacy code page, which breaks Vietnamese JSON."""
    for stream in (sys.stdin, sys.stdout):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            try:
                reconfigure(encoding="utf-8", errors="replace")
            except (ValueError, OSError):  # pragma: no cover - already detached
                pass


def main() -> int:
    force_utf8_streams()
    log(f"Khởi động. Thư mục giọng: {ensure_voices_dir()}")
    stdin = sys.stdin
    stdout = sys.stdout

    while True:
        try:
            payload = read_json_line(stdin)
        except SidecarError as error:
            stdout.write(
                json.dumps(
                    {"id": None, "ok": False, "error": {"code": error.code, "message": error.message}},
                    ensure_ascii=False,
                )
                + "\n"
            )
            stdout.flush()
            continue

        if payload is None:
            log("Nhận EOF, thoát.")
            return 0
        if not payload:
            continue

        request_id = payload.get("id")
        command = str(payload.get("command") or "")
        params = payload.get("params") or {}

        try:
            data = dispatch(command, params)
            response = {"id": request_id, "ok": True, "data": data}
        except SidecarError as error:
            response = {
                "id": request_id,
                "ok": False,
                "error": {
                    "code": error.code,
                    "message": error.message,
                    "retryable": error.retryable,
                },
            }
        except Exception as error:  # unexpected: keep the sidecar alive
            traceback.print_exc(file=sys.stderr)
            response = {
                "id": request_id,
                "ok": False,
                "error": {
                    "code": "InternalError",
                    "message": str(error),
                    "retryable": True,
                },
            }

        stdout.write(json.dumps(response, ensure_ascii=False) + "\n")
        stdout.flush()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:  # pragma: no cover
        sys.exit(0)
