import 'package:flutter/services.dart';

/// Opens the system settings page for this app so the user can grant a
/// permission that was denied permanently (Android "Don't allow" twice,
/// iOS Local Network / Microphone denial).
Future<void> openAppSettings() async {
  // iOS opens its own Settings page for the app, which is where
  // Privacy & Security → Local Network lives.
  const channel = MethodChannel(
    'com.vietvoice.vietvoice_studio/settings',
  );
  try {
    await channel.invokeMethod<void>('openAppSettings');
    return;
  } on MissingPluginException {
    // Android is handled natively; other platforms fall through below.
  }
  // No platform handler (tests, desktop): nothing to open.
}
