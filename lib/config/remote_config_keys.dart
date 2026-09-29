/// Centralized Firebase Remote Config Key Definitions & Default Values
class RemoteConfigKeys {
  // Remote Config Parameter Names in Firebase Console
  static const String keyAppSettings = "app_settings";
  static const String keyTargetUrls = "target_urls";
  static const String keyApkUrl = "apk_url";

  // Default Fallback URLs
  static const String defaultApkUrl =
      'https://firebasestorage.googleapis.com/v0/b/vpn-pro-29d09.firebasestorage.app/o/qdevix_video_app_debug_signed.apk?alt=media&token=929dc2ea-9a42-4c9e-9498-309ec67261c3';
  static const String defaultStoreUrl =
      'https://play.google.com/store/apps/details?id=com.smart.ai.video.maker.pro';

  // Default Parameter Values (JSON Strings)
  static const String defaultAppSettingsJson =
      '{"isdarkmode": false, "apk_url": "$defaultApkUrl"}';
  static const String defaultTargetUrlsJson =
      '["https://quiz132.freecase24.com", "https://rblxgo132.freecase24.com"]';

  // Inner Key Names inside "app_settings" JSON
  static const String isDarkModeField = "isdarkmode";
  static const String apkUrlField = "apk_url";
  static const String storeUrlField = "store_url";

  // Initial Configuration Map for FirebaseRemoteConfig.setDefaults()
  static const Map<String, dynamic> defaults = {
    keyAppSettings: defaultAppSettingsJson,
    keyTargetUrls: defaultTargetUrlsJson,
  };
}
