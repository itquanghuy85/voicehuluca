import 'package:flutter/services.dart';

/// Opens the system settings page for this app so the user can grant a
/// permission that was denied permanently (Android "Don't allow" twice).
Future<void> openAppSettings() async {
  try {
    await const MethodChannel(
      'com.vietvoice.vietvoice_studio/settings',
    ).invokeMethod<void>('openAppSettings');
  } on MissingPluginException {
    // Non-Android platforms: nothing to open.
  }
}
