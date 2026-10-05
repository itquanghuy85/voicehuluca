import 'package:record/record.dart';

/// Recording format every voice sample must use: 22 kHz mono WAV, which is what
/// the local XTTS pipeline expects.
///
/// Both recording entry points share this. `VoiceCloningScreen` used to build a
/// default `RecordConfig()` instead, which is AAC-LC at 44.1 kHz stereo written
/// into a `.m4a` file: on iOS the phone really did hand back an M4A, and the
/// sidecar could not decode it. One config, one format.
///
/// [autoGain] lifts quiet voices before the loudness check runs, so a user who
/// simply speaks softly is not told their microphone is broken.
const RecordConfig recordVoiceConfig = RecordConfig(
  encoder: AudioEncoder.wav,
  sampleRate: 22050,
  numChannels: 1,
  autoGain: true,
);

/// Sample length every cloning engine accepts.
///
/// VoiceStudio (OmniVoice) conditions on at most 20s of reference audio; a
/// longer sample is cut while its transcript is not, and the cut-off words are
/// then spoken in front of every generated sentence. XTTS accepts up to 30s but
/// works best well under that, so one 20s cap serves both.
const Duration recordVoiceMinDuration = Duration(seconds: 5);
const Duration recordVoiceMaxDuration = Duration(seconds: 20);

/// How early the recorder stops itself so the file stays inside the limit.
///
/// The backend rejects anything at or past [recordVoiceMaxDuration], and the
/// recorder keeps writing for a moment after the stop request lands. Stopping on
/// the counter alone therefore produced files ~0.7s over the cap, which the
/// backend then refused after the user had already recorded.
const Duration recordVoiceStopMargin = Duration(seconds: 1);

/// Length the recorder actually stops at: the cap minus [recordVoiceStopMargin].
Duration get recordVoiceStopAt =>
    recordVoiceMaxDuration - recordVoiceStopMargin;