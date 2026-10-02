import 'dart:io';
import 'dart:typed_data';

import '../models/voice.dart';

/// Provider identifiers used across the app, the backend contract and storage.
class TtsProviderIds {
  const TtsProviderIds._();

  static const String google = 'google';
  static const String elevenLabs = 'elevenlabs';
  static const String local = 'local';

  static const String defaultProvider = google;

  static const List<String> all = [google, elevenLabs, local];

  /// Providers that can record a sample and turn it into a reusable voice.
  static const List<String> cloningProviders = [elevenLabs, local];

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
}

class TtsProviderException implements Exception {
  final String message;
  final int statusCode;
  final TtsErrorKind kind;
  final String providerId;

  const TtsProviderException(
    this.message, {
    this.statusCode = 0,
    this.kind = TtsErrorKind.unknown,
    this.providerId = '',
  });

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
  });

  Future<void> deleteVoice(String providerVoiceId);

  /// Real usage from the provider, or null when it exposes no usage data.
  Future<TtsUsage?> getUsage();

  Future<bool> testConnection();
}
