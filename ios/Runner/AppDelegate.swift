import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerSettingsChannel(registry: engineBridge.pluginRegistry)
  }

  /// Opens this app's page in iOS Settings so a user who denied
  /// Local Network can re-enable it at
  /// Privacy & Security → Local Network → VietVoice Studio.
  private func registerSettingsChannel(registry: FlutterPluginRegistry) {
    let messenger = registry.binaryMessenger
    let channel = FlutterMethodChannel(
      name: "com.vietvoice.vietvoice_studio/settings",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "openAppSettings" {
        if let url = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(url)
        {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
          result(nil)
        } else {
          result(
            FlutterError(
              code: "open_failed",
              message: "Cannot open app settings",
              details: nil
            ))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
