import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  static const String appId = 'ca-app-pub-2689108233364143~1594362239';
  static const String appOpenId = 'ca-app-pub-2689108233364143/4877828637';

  static const List<String> bannerUnitIds = [
    'ca-app-pub-2689108233364143/6154368432', // one_banner
    'ca-app-pub-2689108233364143/7030521742', // two_banner
    'ca-app-pub-2689108233364143/1727772336', // three_banner
    'ca-app-pub-2689108233364143/1344628958', // four_banner
    'ca-app-pub-2689108233364143/9357302188', // five_banner
    'ca-app-pub-2689108233364143/8201947279', // six_banner
  ];

  static const List<String> interstitialUnitIds = [
    'ca-app-pub-2689108233364143/1965897321', // one_Interstitial
    'ca-app-pub-2689108233364143/1774325630', // two_interstital
    'ca-app-pub-2689108233364143/4212786716', // three_interstital
    'ca-app-pub-2689108233364143/5150463866', // four_interstital
    'ca-app-pub-2689108233364143/9769913886', // five_interstital
    'ca-app-pub-2689108233364143/9321643166', // six_interstitial
  ];

  static const List<String> nativeUnitIds = [
    'ca-app-pub-2689108233364143/1891423864', // one_nativeadvanced
    'ca-app-pub-2689108233364143/6952178851', // two_nativeadvanced
    'ca-app-pub-2689108233364143/5138855571', // three_nativeadvanced
    'ca-app-pub-2689108233364143/4266571696', // four_nativeadvanced
    'ca-app-pub-2689108233364143/2321120549', // five_nativeadvanced
    'ca-app-pub-2689108233364143/1828110618', // six_nativeadvanced
  ];

  // Google official test ad unit IDs as ultimate waterfall fallback
  static const String testAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';
}

class AdManager {
  static bool _isInitialized = false;

  // App Open Ad
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAppOpenAd = false;

  // Interstitial Ad
  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static List<String> _shuffledInterstitialUnits = [];

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [
            'C0CF96ED36B33E7C0F49654E9544084C', // V2162 test device ID
          ],
        ),
      );
      _isInitialized = true;
      debugPrint('[AdManager] MobileAds initialized successfully with test device ID');
      loadAppOpenAd();
    } catch (e) {
      debugPrint('[AdManager] MobileAds init failed: $e');
    }
  }

  // ----------------- App Open Ad -----------------
  static void loadAppOpenAd([bool isFallback = false]) {
    final adUnitId = isFallback ? AdMobConfig.testAppOpenId : AdMobConfig.appOpenId;
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] AppOpenAd loaded ($adUnitId)');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] AppOpenAd failed to load ($adUnitId): $error');
          _appOpenAd = null;
          if (!isFallback) {
            loadAppOpenAd(true);
          }
        },
      ),
    );
  }

  static void showAppOpenAdIfAvailable({VoidCallback? onComplete}) {
    if (_appOpenAd == null || _isShowingAppOpenAd) {
      debugPrint('[AdManager] AppOpenAd not available or already showing');
      onComplete?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
        onComplete?.call();
      },
    );

    _appOpenAd!.show();
  }

  // ----------------- Interstitial Ad (High Show-Rate Preloading) -----------------
  static void preloadNextInterstitial() {
    if (_interstitialAd == null && !_isLoadingInterstitial) {
      loadNextInterstitial();
    }
  }

  static void loadNextInterstitial([int attempt = 0]) {
    if (_interstitialAd != null || _isLoadingInterstitial) return;
    if (_shuffledInterstitialUnits.isEmpty || attempt == 0) {
      _shuffledInterstitialUnits = List<String>.from(AdMobConfig.interstitialUnitIds)..shuffle();
    }
    if (attempt > _shuffledInterstitialUnits.length) {
      debugPrint('[AdManager] All interstitial waterfall units including fallback failed');
      _isLoadingInterstitial = false;
      return;
    }

    _isLoadingInterstitial = true;
    final String adUnitId;
    if (attempt < _shuffledInterstitialUnits.length) {
      adUnitId = _shuffledInterstitialUnits[attempt];
      debugPrint('[AdManager] Loading Interstitial (shuffled #$attempt: $adUnitId)...');
    } else {
      adUnitId = AdMobConfig.testInterstitialId;
      debugPrint('[AdManager] Loading Interstitial fallback test unit ($adUnitId)...');
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] Interstitial loaded successfully ($adUnitId)!');
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] Interstitial failed ($adUnitId): $error. Trying next unit...');
          _isLoadingInterstitial = false;
          loadNextInterstitial(attempt + 1);
        },
      ),
    );
  }

  static void showInterstitial({VoidCallback? onDismissed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      loadNextInterstitial();
      onDismissed?.call();
    }
  }
}

// ----------------- Anchored Adaptive Banner Ad Widget -----------------
class AdMobBannerWidget extends StatefulWidget {
  final bool isAdaptive;
  final AdSize? adSize;
  const AdMobBannerWidget({
    super.key,
    this.isAdaptive = true,
    this.adSize,
  });

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _currentSize;
  List<String> _shuffledBannerUnits = [];
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _setupAdaptiveBanner();
    }
  }

  Future<void> _setupAdaptiveBanner() async {
    _shuffledBannerUnits = List<String>.from(AdMobConfig.bannerUnitIds)..shuffle();
    if (widget.isAdaptive) {
      final double width = MediaQuery.of(context).size.width;
      final AdSize? adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width.truncate());
      _currentSize = adaptiveSize ?? widget.adSize ?? AdSize.banner;
    } else {
      _currentSize = widget.adSize ?? AdSize.banner;
    }
    if (mounted) {
      _loadBanner(0);
    }
  }

  void _loadBanner(int attempt) {
    if (attempt > _shuffledBannerUnits.length) {
      debugPrint('[AdManager] All banner waterfall units including fallback failed');
      return;
    }

    final String adUnitId;
    if (attempt < _shuffledBannerUnits.length) {
      adUnitId = _shuffledBannerUnits[attempt];
      debugPrint('[AdManager] Loading Adaptive Banner (shuffled #$attempt: $adUnitId)...');
    } else {
      adUnitId = AdMobConfig.testBannerId;
      debugPrint('[AdManager] Loading Banner fallback test unit ($adUnitId)...');
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: _currentSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
          });
          debugPrint('[AdManager] Adaptive Banner loaded ($adUnitId): ${_bannerAd?.size}');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdManager] Banner failed ($adUnitId): $error');
          ad.dispose();
          if (mounted) {
            _loadBanner(attempt + 1);
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// ----------------- Viewport Lazy-Loaded Native Ad (90%+ Show-Rate Safe) -----------------
class AdMobNativeWidget extends StatefulWidget {
  final TemplateType templateType;
  const AdMobNativeWidget({super.key, this.templateType = TemplateType.small});

  @override
  State<AdMobNativeWidget> createState() => _AdMobNativeWidgetState();
}

class _AdMobNativeWidgetState extends State<AdMobNativeWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasRequestedAd = false;
  ScrollPosition? _scrollPosition;
  List<String> _shuffledNativeUnits = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndAttachScrollListener();
  }

  void _checkAndAttachScrollListener() {
    if (_hasRequestedAd) return;

    // Attach to nearest enclosing Scrollable if one exists
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null && _scrollPosition != scrollable.position) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = scrollable.position;
      _scrollPosition?.addListener(_onScroll);
    }

    // Check visibility after layout pass
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasRequestedAd) {
        _evaluateVisibility();
      }
    });
  }

  void _onScroll() {
    if (_hasRequestedAd || !mounted) return;
    _evaluateVisibility();
  }

  void _evaluateVisibility() {
    if (_hasRequestedAd || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      // CRITICAL FOR 90%+ SHOW RATE:
      // Only request the ad if the widget is within or about to enter the visible viewport
      final bool isVisibleOrNear = (position.dy < screenHeight + 100) &&
          (position.dy + renderBox.size.height > -100) &&
          (position.dx < screenWidth) &&
          (position.dx + renderBox.size.width > 0);

      if (isVisibleOrNear) {
        _hasRequestedAd = true;
        _scrollPosition?.removeListener(_onScroll);
        _shuffledNativeUnits = List<String>.from(AdMobConfig.nativeUnitIds)..shuffle();
        _loadNativeAd(0);
      }
    } catch (_) {
      // Ignore if render object is detached
    }
  }

  void _loadNativeAd(int attempt) {
    if (attempt > _shuffledNativeUnits.length) {
      debugPrint('[AdManager] All native waterfall units including fallback failed');
      return;
    }

    final String adUnitId;
    if (attempt < _shuffledNativeUnits.length) {
      adUnitId = _shuffledNativeUnits[attempt];
      debugPrint('[AdManager] Loading Lazy Native unit (shuffled #$attempt: $adUnitId)...');
    } else {
      adUnitId = AdMobConfig.testNativeId;
      debugPrint('[AdManager] Loading Native fallback test unit ($adUnitId)...');
    }

    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: const Color(0xFF181A20), // Blends with app cards
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: const Color(0xFF00E5FF), // Theme cyan
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          size: 11.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white38,
          size: 10.0,
        ),
      ),
      nativeAdOptions: NativeAdOptions(
        videoOptions: VideoOptions(
          startMuted: true,
          customControlsRequested: false,
          clickToExpandRequested: true,
        ),
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        mediaAspectRatio: MediaAspectRatio.any,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
          });
          debugPrint('[AdManager] Lazy Native ad loaded in viewport: $adUnitId');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdManager] Native ad failed ($adUnitId): $error. Trying next...');
          ad.dispose();
          if (mounted) {
            _loadNativeAd(attempt + 1);
          }
        },
      ),
    );
    _nativeAd?.load();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.templateType == TemplateType.medium ? 320.0 : 92.0;

    // While waiting for user to scroll to this position or while loading,
    // preserve minimal layout footprint so position calculation works accurately.
    if (!_isLoaded || _nativeAd == null) {
      return SizedBox(height: _hasRequestedAd ? height : 1.0);
    }

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
