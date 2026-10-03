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

/// Sample length XTTS works best in.
const Duration recordVoiceMinDuration = Duration(seconds: 5);
const Duration recordVoiceMaxDuration = Duration(seconds: 30);