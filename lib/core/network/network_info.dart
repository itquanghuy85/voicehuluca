import 'dart:async';
import 'dart:io';

class NetworkInfo {
  NetworkInfo._();

  static const String _checkHost = 'google.com';
  static const int _checkPort = 53;
  static const Duration _timeout = Duration(seconds: 5);

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup(_checkHost).timeout(_timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasInternetAccess() async {
    try {
      final socket = await Socket.connect(
        _checkHost,
        _checkPort,
        timeout: _timeout,
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isWifiConnected() async {
    if (!await isConnected()) return false;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      return interfaces.any(
        (iface) =>
            iface.name.startsWith('wlan') ||
            iface.name.startsWith('wi-fi') ||
            iface.name.startsWith('wifi'),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isMobileDataConnected() async {
    if (!await isConnected()) return false;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      return interfaces.any(
        (iface) =>
            iface.name.startsWith('rmnet') ||
            iface.name.startsWith('pdp_ip') ||
            iface.name.startsWith('ccmni') ||
            iface.name.startsWith('tun'),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<NetworkStatus> checkStatus() async {
    final connected = await isConnected();
    if (!connected) return NetworkStatus.disconnected;

    final wifi = await isWifiConnected();
    if (wifi) return NetworkStatus.wifi;

    final mobile = await isMobileDataConnected();
    if (mobile) return NetworkStatus.mobile;

    return NetworkStatus.other;
  }
}

enum NetworkStatus { disconnected, wifi, mobile, other }
