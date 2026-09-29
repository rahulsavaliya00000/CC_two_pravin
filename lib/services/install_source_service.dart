import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detects whether the app was installed via a Google Ads CPI campaign
/// by reading the Google Play Install Referrer string from native Android.
///
/// Google Ads CPI campaigns produce referrers containing:
///   - gclid= (Google Click ID — most reliable signal)
///   - utm_source=google
///   - utm_medium=cpc / cpi / ppc
///
/// Result is cached in SharedPreferences on first check so subsequent app
/// opens don't need to call native again (referrer API only works ~7 days post-install).
class InstallSourceService {
  static const MethodChannel _channel =
      MethodChannel('com.smart.ai.video.maker.pro/install_referrer');

  static const String _prefKeyIsGoogle = 'is_google_ads_user';
  static const String _prefKeyChecked = 'install_source_checked';

  /// Returns true if this install came from a Google Ads CPI campaign.
  /// - First call: reads from native Play Referrer API and caches result.
  /// - Subsequent calls: reads instantly from SharedPreferences cache.
  /// - On error / referrer unavailable: returns false (treat as organic).
  static Future<bool> isFromGoogleAds() async {
    // In DEBUG mode: automatically simulate Google Ads user for local testing
    if (kDebugMode) {
      debugPrint('[InstallSource] [DEBUG MODE] Passing Google Ads tag (kDebugMode=true)');
      return true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool alreadyChecked = prefs.getBool(_prefKeyChecked) ?? false;

      if (alreadyChecked) {
        final bool cached = prefs.getBool(_prefKeyIsGoogle) ?? false;
        debugPrint('[InstallSource] Cached result: isGoogleAds=$cached');
        return cached;
      }

      // First ever check — call native
      debugPrint('[InstallSource] First check — reading Play Install Referrer...');
      final String referrer = await _channel
          .invokeMethod<String>('getInstallReferrer')
          .timeout(const Duration(seconds: 5))
          .then((v) => v ?? '')
          .catchError((_) => '');

      debugPrint('[InstallSource] Raw referrer string: "$referrer"');

      final bool isGoogle = _isGoogleAdsReferrer(referrer);
      debugPrint('[InstallSource] isGoogleAds=$isGoogle — caching result');

      // Cache for all future app opens
      await prefs.setBool(_prefKeyIsGoogle, isGoogle);
      await prefs.setBool(_prefKeyChecked, true);

      return isGoogle;
    } catch (e) {
      debugPrint('[InstallSource] Error: $e — treating as non-Google');
      return false;
    }
  }

  /// Parses the raw referrer string to detect Google Ads CPI signals.
  ///
  /// Google Ads CPI referrer looks like:
  ///   utm_source=google&utm_medium=cpi&utm_campaign=...&gclid=CjwKCAjw...
  static bool _isGoogleAdsReferrer(String referrer) {
    if (referrer.isEmpty) return false;
    final lower = referrer.toLowerCase();

    // 1. Organic Play Store installs always have utm_medium=organic -> NEVER Google Ads!
    if (lower.contains('utm_medium=organic') || lower.contains('utm_source=(not%20set)')) {
      debugPrint('[InstallSource] Organic install detected (utm_medium=organic) -> NOT Google Ads');
      return false;
    }

    // 2. gclid is the absolute, guaranteed signature of a Google Ads campaign
    if (lower.contains('gclid=')) {
      debugPrint('[InstallSource] Google Ads detected via gclid');
      return true;
    }

    // 3. utm_source=google with a paid medium (cpi, cpc, ppc, paid)
    if (lower.contains('utm_source=google') &&
        (lower.contains('utm_medium=cpc') ||
            lower.contains('utm_medium=cpi') ||
            lower.contains('utm_medium=ppc') ||
            lower.contains('utm_medium=paid'))) {
      debugPrint('[InstallSource] Google Ads detected via utm_source+utm_medium');
      return true;
    }

    return false;
  }
}
