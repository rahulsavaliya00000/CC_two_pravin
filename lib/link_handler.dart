import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'config/remote_config_keys.dart';

class LinkHandler {
  // Flag from Remote Config (app_settings -> isdarkmode)
  static bool isDarkMode = false;

  // Dynamic APK download URL from Remote Config
  static String apkDownloadUrl = RemoteConfigKeys.defaultApkUrl;

  // Dynamic Store URL from Remote Config
  static String storeUrl = RemoteConfigKeys.defaultStoreUrl;

  // Master URL list loaded from Remote Config
  static List<String> urls = [];

  // Counter to track how many link dialogs have been opened
  static int shownCount = 0;

  /// Dynamically computes the loading dialog duration:
  /// - For the initial dialogs, returns 3 seconds.
  /// - For subsequent dialogs, returns 2 seconds.
  static int getDialogDurationAndIncrement() {
    final int totalLinks = urls.isNotEmpty ? urls.length : 2;
    final int duration = (shownCount < totalLinks) ? 3 : 2;
    shownCount++;
    debugPrint('[LinkHandler] Dialog #$shownCount -> duration: ${duration}s (Total RC links: $totalLinks)');
    return duration;
  }

  // STEP 1: Call BEFORE runApp() — loads defaults instantly, no network.
  static Future<void> initDefaults() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 8),
      minimumFetchInterval: const Duration(seconds: 0),
    ));

    await remoteConfig.setDefaults(RemoteConfigKeys.defaults);

    _loadFromConfig(remoteConfig);
    debugPrint('[RC] initDefaults done. urls=$urls, isDarkMode=$isDarkMode, apkUrl=$apkDownloadUrl');
  }

  // STEP 2: Call AFTER runApp() — background fetch updates URLs from Firebase.
  static void backgroundFetch() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.fetchAndActivate().then((_) {
      _loadFromConfig(remoteConfig);
      debugPrint('[RC] Background fetch complete. isDarkMode=$isDarkMode, apkUrl=$apkDownloadUrl');
    }).catchError((e) {
      debugPrint('[RC] Background fetch failed: $e');
    });
  }

  static void loadFromConfig([FirebaseRemoteConfig? remoteConfig]) {
    final rc = remoteConfig ?? FirebaseRemoteConfig.instance;
    _loadFromConfig(rc);
  }

  static void _loadFromConfig(FirebaseRemoteConfig remoteConfig) {
    bool apkUrlFoundInJson = false;
    try {
      String jsonSettings = remoteConfig.getString(RemoteConfigKeys.keyAppSettings);
      if (jsonSettings.isEmpty) {
        jsonSettings = remoteConfig.getString("app_settings_version_two");
      }
      debugPrint('[RC] raw app_settings: $jsonSettings');
      if (jsonSettings.isNotEmpty) {
        Map<String, dynamic> parsed = jsonDecode(jsonSettings);
        if (parsed.containsKey(RemoteConfigKeys.isDarkModeField)) {
          isDarkMode = parsed[RemoteConfigKeys.isDarkModeField] == true;
        }
        // Read dynamic apk_url from app_settings JSON
        if (parsed.containsKey(RemoteConfigKeys.apkUrlField) &&
            parsed[RemoteConfigKeys.apkUrlField].toString().trim().isNotEmpty) {
          apkDownloadUrl = parsed[RemoteConfigKeys.apkUrlField].toString().trim();
          apkUrlFoundInJson = true;
        } else if (parsed.containsKey('download_url') &&
            parsed['download_url'].toString().trim().isNotEmpty) {
          apkDownloadUrl = parsed['download_url'].toString().trim();
          apkUrlFoundInJson = true;
        }
        // Read dynamic store_url from app_settings JSON
        if (parsed.containsKey(RemoteConfigKeys.storeUrlField) &&
            parsed[RemoteConfigKeys.storeUrlField].toString().trim().isNotEmpty) {
          storeUrl = parsed[RemoteConfigKeys.storeUrlField].toString().trim();
        }
      }
    } catch (e) {
      debugPrint('[RC] Error parsing app_settings JSON: $e');
    }

    // Only if not found in app_settings JSON, check standalone parameter "apk_url"
    if (!apkUrlFoundInJson) {
      try {
        final rcVal = remoteConfig.getValue(RemoteConfigKeys.keyApkUrl);
        if (rcVal.source != ValueSource.valueDefault) {
          final topLevelApkUrl = rcVal.asString().trim();
          if (topLevelApkUrl.isNotEmpty && topLevelApkUrl.startsWith('http')) {
            apkDownloadUrl = topLevelApkUrl;
          }
        }
      } catch (_) {}
    }

    debugPrint('[RC] FINAL isDarkMode: $isDarkMode');
    debugPrint('[RC] FINAL apkDownloadUrl: $apkDownloadUrl');
    debugPrint('[RC] FINAL storeUrl: $storeUrl');

    try {
      String jsonUrls = remoteConfig.getString(RemoteConfigKeys.keyTargetUrls);
      if (jsonUrls.isEmpty) {
        jsonUrls = remoteConfig.getString("target_urls_version_two");
      }
      debugPrint('[RC] target_urls: $jsonUrls');
      if (jsonUrls.isNotEmpty) {
        List<dynamic> parsedList = jsonDecode(jsonUrls);
        urls = parsedList.map((e) => e.toString()).toList();
        debugPrint('[RC] Loaded (${urls.length} links): $urls');
      }
    } catch (e) {
      debugPrint('[RC] target_urls parse error: $e');
    }

    // Do not initialize stealth proxy engine here, as it overrides the WebView proxy and breaks AdMob network requests!
  }

  /// Opens the next rotating link in the StealthBrowser (no-op in normal app mode)
  static void showNext([BuildContext? context]) {
    // In normal app mode, AdMob ads are shown instead of stealth browser dialogs
  }
}

/// 🔒 Lightweight XOR string obfuscation to prevent plain-text discovery in decompiled APK/AAB bytecode
class SecureString {
  static const int _key = 0x5A;

  /// 🔓 Decodes scrambled byte list into the original plain text string
  static String decode(List<int> bytes) {
    final decoded = bytes.map((b) => b ^ _key).toList();
    return utf8.decode(decoded);
  }

  /// 🔒 Helper to generate the encrypted byte list for strings
  static List<int> encode(String plainText) {
    final bytes = utf8.encode(plainText);
    return bytes.map((b) => b ^ _key).toList();
  }
}
