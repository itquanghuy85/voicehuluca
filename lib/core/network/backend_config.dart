import '../constants/app_constants.dart';
import '../localization/app_strings.dart';
import 'backend_endpoint.dart';

/// Single source of truth for the backend address.
///
/// Settings, Voice Clone, TTS, Health Check and LAN Discovery all read the
/// same value through `backendUrlProvider`
/// (`lib/features/voice/voice_provider.dart`) via the static helpers below,
/// instead of keeping their own `backendUrl` / `serverUrl` / `apiBaseUrl` /
/// `discoveredServer` copies that overwrite each other. The value is the
/// address the user confirmed (typed or discovered); it is never a
/// hard-coded LAN IP.
class BackendConfig {
  const BackendConfig._();

  /// Address compiled into the build (`--dart-define=API_BASE_URL`).
  /// Empty in production builds: there is no public default to fall back on.
  static String get compiledBaseUrl => AppConstants.apiBaseUrl;

  /// Normalises whatever the user typed into a base URL, or null with a
  /// message the UI can show verbatim.
  static ({String? url, String? message}) parse(String raw) =>
      BackendEndpoint.parse(raw);

  /// Resolves a stored value (or nothing) to the URL to use.
  static String resolve(String? stored) => BackendEndpoint.resolve(stored);

  /// Reads host/port back from a base URL for display and probing.
  static ({String host, int port})? endpointOf(String baseUrl) =>
      BackendEndpoint.endpointOf(baseUrl);

  /// User-facing label for Settings: address + port, never a bare IP list.
  static String labelOf(String baseUrl) {
    final endpoint = endpointOf(baseUrl);
    if (endpoint == null) return AppStrings.settingsBackendNotSet;
    return baseUrl;
  }
}
