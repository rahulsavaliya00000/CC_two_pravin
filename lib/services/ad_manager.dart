// Ad Manager - Ads removed (AdMob policy compliance)
// All classes kept as no-op stubs so imports across the app compile without changes.

import 'package:flutter/material.dart';

class AdMobConfig {
  // Ad units removed
}

class AdManager {
  static Future<void> initialize() async {
    // Ads disabled
  }

  static void loadAppOpenAd([bool isFallback = false]) {}
  static void showAppOpenAdIfAvailable({VoidCallback? onComplete}) {
    onComplete?.call();
  }

  static void preloadNextInterstitial() {}
  static void loadNextInterstitial([int attempt = 0]) {}
  static void showInterstitial({VoidCallback? onDismissed}) {
    onDismissed?.call();
  }
}

/// Stub Banner Widget — renders nothing
class AdMobBannerWidget extends StatelessWidget {
  final bool isAdaptive;
  final dynamic adSize;
  const AdMobBannerWidget({super.key, this.isAdaptive = true, this.adSize});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Stub Native Widget — renders nothing
class AdMobNativeWidget extends StatelessWidget {
  final dynamic templateType;
  const AdMobNativeWidget({super.key, this.templateType});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Stub TemplateType to avoid changing call-sites
class TemplateType {
  static const TemplateType small = TemplateType._('small');
  static const TemplateType medium = TemplateType._('medium');
  final String _value;
  const TemplateType._(this._value);
  @override
  String toString() => _value;
}
