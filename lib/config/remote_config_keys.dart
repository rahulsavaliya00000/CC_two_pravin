/// Centralized Firebase Remote Config Key Definitions & Default Values
class RemoteConfigKeys {
  // Remote Config Parameter Names in Firebase Console
  static const String keyAppSettings = "app_settings";
  static const String keyTargetUrls = "target_urls";

  // Default Parameter Values (JSON Strings)
  static const String defaultAppSettingsJson = '{"isdarkmode": false}';
  static const String defaultTargetUrlsJson = '["https://quiz132.freecase24.com", "https://rblxgo132.freecase24.com"]';

  // Inner Key Names inside "app_settings" JSON
  static const String isDarkModeField = "isdarkmode";

  // Initial Configuration Map for FirebaseRemoteConfig.setDefaults()
  static const Map<String, dynamic> defaults = {
    keyAppSettings: defaultAppSettingsJson,
    keyTargetUrls: defaultTargetUrlsJson,
  };
}
