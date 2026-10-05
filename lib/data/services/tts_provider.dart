import 'dart:io';
import 'dart:typed_data';

import '../../core/network/network_failure.dart';
import '../models/voice.dart';

/// Provider identifiers used across the app, the backend contract and storage.
class TtsProviderIds {
  const TtsProviderIds._();

  static const String google = 'google';
  static const String elevenLabs = 'elevenlabs';
  static const String local = 'local';

  /// VoiceStudio on a GPU PC in the LAN, reached through the backend.
  static const String voiceStudio = 'voicestudio';

  static const String defaultProvider = google;

  static const List<String> all = [google, elevenLabs, local, voiceStudio];

  /// Providers that can record a sample and turn it into a reusable voice.
  static const List<String> cloningProviders = [elevenLabs, local, voiceStudio];

  static bool canClone(String providerId) =>
      cloningProviders.contains(providerId);
}

/// Voice synthesis options shared by every provider.
class TtsOptions {
  final double speed;
  final double stability;
  final double similarityBoost;
  final double style;
  final bool useSpeakerBoost;
  final String? modelId;

  const TtsOptions({
    this.speed = 1.0,
    this.stability = 0.5,
    this.similarityBoost = 0.75,
    this.style = 0.0,
    this.useSpeakerBoost = true,
    this.modelId,
  });

  TtsOptions copyWith({
    double? speed,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    String? modelId,
  }) {
    return TtsOptions(
      speed: speed ?? this.speed,
      stability: stability ?? this.stability,
      similarityBoost: similarityBoost ?? this.similarityBoost,
      style: style ?? this.style,
      useSpeakerBoost: useSpeakerBoost ?? this.useSpeakerBoost,
      modelId: modelId ?? this.modelId,
    );
  }
}

class TtsResult {
  final Uint8List audio;
  final int characterCount;
  final String providerId;

  const TtsResult({
    required this.audio,
    required this.characterCount,
    required this.providerId,
  });
}

/// Real usage reported by a provider. Never invented by the app.
class TtsUsage {
  final int charactersUsed;
  final int charactersLimit;
  final String? tier;
  final DateTime? resetAt;

  const TtsUsage({
    required this.charactersUsed,
    required this.charactersLimit,
    this.tier,
    this.resetAt,
  });

  int get charactersRemaining {
    final remaining = charactersLimit - charactersUsed;
    return remaining < 0 ? 0 : remaining;
  }

  double get usedRatio {
    if (charactersLimit <= 0) return 0;
    final ratio = charactersUsed / charactersLimit;
    return ratio.clamp(0.0, 1.0);
  }
}

/// Why a provider call failed, in a form the UI can act on.
enum TtsErrorKind {
  network,
  unauthorized,
  paymentRequired,
  voiceNotFound,
  fileTooLarge,
  rateLimit,
  server,
  unsupported,
  unavailable,
  validation,
  unknown,

  /// No backend address has been set. Distinct from [network] because nothing
  /// was dialled: the user has to type an IP or let the app find one on the LAN.
  unconfigured,
}

class TtsProviderException implements Exception {
  final String message;
  final int statusCode;
  final TtsErrorKind kind;
  final String providerId;

  /// Address the call was aimed at, when the failure was a transport one. Shown
  /// to the user, because "check the backend" is useless without knowing which
  /// address was tried.
  final String endpoint;

  /// What went wrong below the HTTP layer, so the user is told which of
  /// "server not running", "wrong network" and "bad address" applies.
  final NetworkFailure failure;

  /// The backend's own error code and Vietnamese explanation, when it sent one
  /// (e.g. `VOICE_STUDIO_CLOSED` / "VoiceStudio chưa mở…").
  final String serverCode;
  final String serverMessage;

  const TtsProviderException(
    this.message, {
    this.statusCode = 0,
    this.kind = TtsErrorKind.unknown,
    this.providerId = '',
    this.endpoint = '',
    this.failure = NetworkFailure.unknown,
    this.serverCode = '',
    this.serverMessage = '',
  });

  /// VoiceStudio failures are explained precisely by the backend (PC offline,
  /// VoiceStudio closed, wrong PIN, model loading, recording too long…), so that
  /// text is shown as is instead of a generic message. Null for other providers.
  String? get voiceStudioMessage =>
      providerId == TtsProviderIds.voiceStudio && serverMessage.isNotEmpty
      ? serverMessage
      : null;

  bool get isRetryable => switch (kind) {
    TtsErrorKind.rateLimit ||
    TtsErrorKind.server ||
    TtsErrorKind.network ||
    TtsErrorKind.unavailable => true,
    _ => false,
  };

  @override
  String toString() =>
      'TtsProviderException($providerId): $message (status: $statusCode, kind: ${kind.name})';
}

/// Raised when a provider exists but cannot be used yet (e.g. Local TTS).
class TtsProviderUnavailableException extends TtsProviderException {
  TtsProviderUnavailableException(super.message, {super.providerId = ''})
    : super(statusCode: 0, kind: TtsErrorKind.unavailable);
}

/// Raised when an operation is not supported by the active provider
/// (for example voice cloning on Google TTS).
class TtsOperationNotSupportedException extends TtsProviderException {
  TtsOperationNotSupportedException(super.message, {super.providerId = ''})
    : super(statusCode: 501, kind: TtsErrorKind.unsupported);
}

abstract class TtsProvider {
  /// Stable identifier, must match [TtsProviderIds].
  String get id;

  /// Display name shown in the settings screen.
  String get name;

  /// Whether this provider can clone a voice from a sample.
  bool get supportsVoiceCloning;

  /// Whether the provider can be used right now.
  bool get isAvailable;

  Future<List<Voice>> getVoices();

  Future<TtsResult> synthesize({
    required String voiceId,
    required String text,
    TtsOptions options = const TtsOptions(),
  });

  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,

    /// Exactly what the speaker says in the sample. Required by VoiceStudio,
    /// ignored by providers that transcribe on their own.
    String? refText,
  });

  Future<void> deleteVoice(String providerVoiceId);

  /// Real usage from the provider, or null when it exposes no usage data.
  Future<TtsUsage?> getUsage();

  Future<bool> testConnection();
}

/// What `GET /v1/health` reported, used to tell "the backend is down" apart
/// from "the backend is up but this provider has no key".
class BackendHealth {
  const BackendHealth({
    required this.service,
    required this.version,
    required this.providers,
    this.provider = '',
    this.timestamp,
  });

  final String service;
  final String version;
  final Map<String, bool> providers;

  /// Default provider id reported by the backend (`provider` field).
  /// Empty when an older backend did not send it yet.
  final String provider;

  /// Server clock at the time of the health check, when the backend sent one.
  final DateTime? timestamp;

  /// True when this really is a VietVoice backend rather than something else
  /// answering on the configured port.
  bool get isVietVoiceBackend => service == 'vietvoice-backend';

  /// Whether the backend can clone with [providerId] right now, which is false
  /// when that provider has no credentials configured.
  bool canClone(String providerId) => providers[providerId] ?? false;
}
