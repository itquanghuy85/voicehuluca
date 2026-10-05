import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/voice.dart';
import '../../services/tts_provider.dart';
import '../../../core/network/network_failure.dart';

/// Backend gateway for every TTS provider.
///
/// The app never talks to a vendor directly: vendor secrets stay on the
/// backend, this datasource only forwards the selected provider id.
class SynthesizedAudio {
  final Uint8List bytes;

  /// Container the backend actually produced (mp3 or wav for local clones).
  final String format;
  final String provider;

  const SynthesizedAudio({
    required this.bytes,
    required this.format,
    required this.provider,
  });
}

class TtsRemoteDatasource {
  final http.Client _client;
  final String baseUrl;
  final String apiKey;
  final String provider;

  TtsRemoteDatasource({
    http.Client? client,
    required this.baseUrl,
    required this.apiKey,
    this.provider = TtsProviderIds.defaultProvider,
  }) : _client = client ?? http.Client();

  /// App authentication header. This is the VietVoice Studio key, never a
  /// vendor key: provider secrets stay on the backend.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-vvt-api-key': apiKey,
  };

/// Turns transport failures into one typed error.
///
/// The backend is a self-hosted proxy, so a refused connection, a wrong
/// address or a timeout all mean "the voice server is not answering" and must
/// not reach the UI as an unknown provider error.
Future<T> _guard<T>(Future<T> Function() call) async {
  if (baseUrl.trim().isEmpty) {
    // Nothing was dialled, so saying "unreachable" would be a lie: the user has
    // to give the app an address first.
    throw TtsProviderException(
      'Chưa cấu hình địa chỉ máy chủ giọng nói.',
      kind: TtsErrorKind.unconfigured,
      providerId: provider,
    );
  }
try {
    return await call();
  } on http.ClientException catch (error) {
    throw _unreachable(error.message, error);
  } on SocketException catch (error) {
    throw _unreachable(error.message, error);
  } on HandshakeException catch (error) {
    throw _unreachable(error.message, error);
  } on TimeoutException {
    throw _unreachable(
      'Yêu cầu quá thời gian.',
      const SocketException('Connection timed out'),
    );
  }
}

TtsProviderException _unreachable(String detail, Object cause) =>
    TtsProviderException(
      'Máy chủ giọng nói không phản hồi: $detail',
      kind: TtsErrorKind.network,
      providerId: provider,
      endpoint: baseUrl,
      failure: classifyNetworkFailure(cause),
    );

  Future<List<Voice>> getVoices() async {
    final uri = Uri.parse(
      '$baseUrl/voices',
    ).replace(queryParameters: {'provider': provider});
    final response = await _guard(() => _client.get(uri, headers: _headers));

    if (response.statusCode != 200) {
      throw _toException(
        'Failed to fetch voices: ${response.statusCode}',
        response,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final voicesList = (data['voices'] as List<dynamic>?) ?? const [];

    return voicesList.map((v) => _toVoice(v as Map<String, dynamic>)).toList();
  }

  /// Real availability per provider, as reported by the backend.
  Future<Map<String, bool>> getProviderAvailability() async {
    final uri = Uri.parse('$baseUrl/providers');
    final response = await _guard(() => _client.get(uri, headers: _headers));

    if (response.statusCode != 200) {
      throw _toException(
        'Failed to fetch providers: ${response.statusCode}',
        response,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['providers'] as List<dynamic>?) ?? const [];
    return {
      for (final item in list)
        if (item is Map<String, dynamic> && item['id'] is String)
          item['id'] as String: item['available'] == true,
    };
  }

  Voice _toVoice(Map<String, dynamic> map) {
    final labels = map['labels'] as Map<String, dynamic>?;
    final now = DateTime.now();
    return Voice(
      id: 0,
      provider: provider,
      providerVoiceId: (map['voice_id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      description: map['description'] as String?,
      language: (labels?['language'] as String?) ?? 'vi',
      gender: (labels?['gender'] as String?) ?? 'neutral',
      accent: labels?['accent'] as String?,
      isCloned: map['category'] == 'cloned',
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<SynthesizedAudio> synthesizeAudio({
    required String voiceId,
    required String text,
    TtsOptions options = const TtsOptions(),
  }) async {
    final uri = Uri.parse('$baseUrl/tts');
    final response = await _guard(
      () => _client.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'provider': provider,
          'voiceId': voiceId,
          'text': text,
          'options': {
            'speed': options.speed,
            'stability': options.stability,
            'similarityBoost': options.similarityBoost,
            'style': options.style,
            'useSpeakerBoost': options.useSpeakerBoost,
            if (options.modelId != null && options.modelId!.isNotEmpty)
              'modelId': options.modelId,
          },
        }),
      ),
    );

    if (response.statusCode != 200) {
      throw _toException('Synthesis failed: ${response.statusCode}', response);
    }

    return SynthesizedAudio(
      bytes: response.bodyBytes,
      format: _formatOf(response),
      provider: provider,
    );
  }

  /// Same call as [synthesizeAudio] for callers that only need the audio.
  Future<Uint8List> synthesize({
    required String voiceId,
    required String text,
    TtsOptions options = const TtsOptions(),
  }) async {
    final audio = await synthesizeAudio(
      voiceId: voiceId,
      text: text,
      options: options,
    );
    return audio.bytes;
  }

  /// The backend reports the container it actually produced. XTTS clones come
  /// back as WAV while streaming providers send MP3.
  String _formatOf(http.Response response) {
    final header = response.headers['x-audio-format']?.trim().toLowerCase();
    if (header == 'wav') return 'wav';
    if (header == 'mp3') return 'mp3';
    return _sniffFormat(response.bodyBytes);
  }

  static String _sniffFormat(Uint8List bytes) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45) {
      return 'wav';
    }
    return 'mp3';
  }

  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
    String? refText,
  }) async {
    final uri = Uri.parse('$baseUrl/voices/clone');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    request.fields['provider'] = provider;
    request.fields['name'] = name;
    request.fields['description'] = description;
    if (language != null) {
      request.fields['language'] = language;
    }
    final transcript = refText?.trim() ?? '';
    if (transcript.isNotEmpty) {
      request.fields['ref_text'] = transcript;
    }

    for (final file in audioFiles) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          bytes,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      );
    }

    final streamedResponse = await _guard(() => _client.send(request));

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw _fromBody(
        'Voice cloning failed: ${streamedResponse.statusCode} - $body',
        streamedResponse.statusCode,
        body,
      );
    }

    final responseBody = await streamedResponse.stream.bytesToString();
    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    final now = DateTime.now();
    return Voice(
      id: 0,
      provider: provider,
      providerVoiceId: (data['voice_id'] ?? '') as String,
      name: name,
      description: description,
      language: language ?? 'vi',
      gender: 'neutral',
      isCloned: true,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> deleteVoice(String providerVoiceId) async {
    final uri = Uri.parse(
      '$baseUrl/voices/${Uri.encodeComponent(providerVoiceId)}',
    ).replace(queryParameters: {'provider': provider});
    final response = await _guard(() => _client.delete(uri, headers: _headers));

    if (response.statusCode != 200) {
      throw _toException(
        'Failed to delete voice: ${response.statusCode}',
        response,
      );
    }
  }

  /// Returns null when the provider reports no usage data.
  Future<TtsUsage?> getUsage() async {
    final uri = Uri.parse(
      '$baseUrl/user/subscription',
    ).replace(queryParameters: {'provider': provider});
    final response = await _guard(() => _client.get(uri, headers: _headers));

    if (response.statusCode != 200) {
      throw _toException(
        'Failed to get usage: ${response.statusCode}',
        response,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['available'] != true) {
      return null;
    }

    final resetAt = data['resetAt'];
    return TtsUsage(
      charactersUsed: (data['charactersUsed'] as num?)?.toInt() ?? 0,
      charactersLimit: (data['charactersLimit'] as num?)?.toInt() ?? 0,
      tier: data['tier'] as String?,
      resetAt: resetAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (resetAt as num).toInt() * 1000,
            ),
    );
  }

  /// Asks the backend whether it is up and what it can do, before an upload is
  /// attempted. Uses the same error path as every other call, so an unreachable
  /// backend is reported by cause instead of a bare boolean.
  ///
  /// Health failures keep their HTTP meaning: 404 is a wrong endpoint/path,
  /// 401/403 is app auth, 5xx is the server or provider — the caller maps them
  /// to distinct messages instead of one "cannot connect" line.
  Future<BackendHealth> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    final stopwatch = Stopwatch()..start();
    final response = await _guard(() => _client.get(uri, headers: _headers));
    stopwatch.stop();
    if (response.statusCode != 200) {
      throw _fromBody(
        'Health check failed: ${response.statusCode}',
        response.statusCode,
        response.body,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw TtsProviderException(
        'Máy chủ trả về dữ liệu không hợp lệ.',
        kind: TtsErrorKind.server,
        providerId: provider,
        endpoint: baseUrl,
      );
    }
    final providers = decoded['providers'];
    final timestampRaw = decoded['timestamp'] as String?;
    return BackendHealth(
      service: decoded['service'] as String? ?? '',
      version: decoded['version'] as String? ?? '',
      provider: decoded['provider'] as String? ?? '',
      timestamp: timestampRaw == null
          ? null
          : DateTime.tryParse(timestampRaw),
      providers: providers is Map
          ? {
              for (final entry in providers.entries)
                entry.key.toString(): entry.value == true,
            }
          : const {},
    );
  }

  /// Timed health check for Settings: reports latency alongside the payload so
  /// the UI can show address + provider + latency without a second request.
  Future<({BackendHealth health, int latencyMs})> checkHealthTimed({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final stopwatch = Stopwatch()..start();
    final health = await checkHealth().timeout(timeout);
    stopwatch.stop();
    return (
      health: health,
      latencyMs: stopwatch.elapsedMilliseconds == 0
          ? 1
          : stopwatch.elapsedMilliseconds,
    );
  }

  Future<bool> testConnection() async {
    try {
      final result = await checkHealthTimed(
        timeout: const Duration(seconds: 10),
      ).timeout(const Duration(seconds: 10));
      debugPrint(
        'testConnection $baseUrl/health -> ${result.health.service} '
        '(${result.latencyMs}ms)',
      );
      return result.health.isVietVoiceBackend;
    } catch (e) {
      debugPrint('testConnection error: $e');
      return false;
    }
  }

  TtsProviderException _toException(String message, http.Response response) {
    return _fromBody(message, response.statusCode, response.body);
  }

  TtsProviderException _fromBody(String message, int statusCode, String body) {
    String? code;
    String? serverMessage;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          code = error['code'] as String?;
          final text = error['message'];
          if (text is String) serverMessage = text;
        }
      }
    } catch (_) {
      code = null;
    }

    final kind = _kindForStatus(statusCode, code);
    return TtsProviderException(
      message,
      statusCode: statusCode,
      kind: kind,
      providerId: provider,
      serverCode: code ?? '',
      serverMessage: serverMessage ?? '',
    );
  }

  TtsErrorKind _kindForStatus(int statusCode, String? code) {
    switch (code) {
      case 'VoiceCloningNotSupported':
      case 'OperationNotSupported':
        return TtsErrorKind.unsupported;
      case 'UnknownProvider':
      case 'ValidationError':
        return TtsErrorKind.validation;
      case 'NetworkError':
        return TtsErrorKind.network;
      case 'Timeout':
        return TtsErrorKind.server;
      case 'ServiceUnavailable':
      case 'ProviderError':
        return TtsErrorKind.unavailable;
    }

    switch (statusCode) {
      case 401:
        return TtsErrorKind.unauthorized;
      case 402:
        return TtsErrorKind.paymentRequired;
      case 404:
        return TtsErrorKind.voiceNotFound;
      case 413:
        return TtsErrorKind.fileTooLarge;
      case 429:
        return TtsErrorKind.rateLimit;
      case 501:
        return TtsErrorKind.unsupported;
      case 500:
      case 502:
      case 503:
      case 504:
        return TtsErrorKind.server;
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return TtsErrorKind.validation;
        }
        return TtsErrorKind.unknown;
    }
  }

  void dispose() {
    _client.close();
  }
}
