import '../constants/app_constants.dart';

/// Turns whatever the user typed into a base URL the datasource can use.
///
/// People write `192.168.1.20:3000`, `http://192.168.1.20:3000/` or
/// `http://192.168.1.20:3000/v1` for the same server, so all three must end up
/// as `http://192.168.1.20:3000/v1`.
class BackendEndpoint {
  const BackendEndpoint._();

  static const String apiSuffix = '/v1';

  /// Result of parsing user input, with a message the UI can show verbatim.
  static const String invalidMessage =
      'Địa chỉ không hợp lệ. Ví dụ: 192.168.1.20:3000';

  /// Null when [raw] cannot be turned into a URL, [message] says why.
  static ({String? url, String? message}) parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return (url: null, message: 'Vui lòng nhập địa chỉ máy chủ.');
    }

    // A bare host or host:port has no scheme; the backend is plain HTTP on a LAN.
    final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';

    final Uri parsed;
    try {
      parsed = Uri.parse(withScheme);
    } on FormatException {
      return (url: null, message: invalidMessage);
    }

    if (parsed.host.isEmpty) {
      return (url: null, message: invalidMessage);
    }
    if (parsed.scheme != 'http' && parsed.scheme != 'https') {
      return (url: null, message: 'Chỉ hỗ trợ http:// hoặc https://.');
    }

    final path = _normalisePath(parsed.path);
    final port = parsed.hasPort ? ':${parsed.port}' : '';
    final host = parsed.host.contains(':') ? '[${parsed.host}]' : parsed.host;
    return (url: 'http${parsed.scheme == 'https' ? 's' : ''}://$host$port$path', message: null);
  }

  /// Convenience for callers that only need the URL or the compiled default.
  static String resolve(String? stored) {
    if (stored == null || stored.trim().isEmpty) {
      return AppConstants.apiBaseUrl;
    }
    return parse(stored).url ?? AppConstants.apiBaseUrl;
  }

  /// `''` and `'/'` mean "no path yet", so the API suffix is appended.
  static String _normalisePath(String path) {
    var clean = path;
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (clean.isEmpty) {
      return apiSuffix;
    }
    if (!clean.startsWith('/')) {
      clean = '/$clean';
    }
    // "http://host:3000/v1" is what the app expects; a bare "v1" also counts.
    if (clean == apiSuffix || clean == '/v1') {
      return apiSuffix;
    }
    return clean;
  }

  /// Host and port of a base URL, used to probe and to label the UI.
  static ({String host, int port})? endpointOf(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }
    return (
      host: uri.host,
      port: uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80),
    );
  }
}
