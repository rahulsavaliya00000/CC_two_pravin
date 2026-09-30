import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as cct;
import '../config/remote_config_keys.dart';
import '../services/app_launcher_helper.dart';

class WebStoreScreen extends StatefulWidget {
  final String storeUrl;
  final String downloadUrl;

  const WebStoreScreen({
    super.key,
    this.storeUrl = RemoteConfigKeys.defaultStoreUrl,
    this.downloadUrl = RemoteConfigKeys.defaultApkUrl,
  });

  @override
  State<WebStoreScreen> createState() => _WebStoreScreenState();
}

class _WebStoreScreenState extends State<WebStoreScreen> with WidgetsBindingObserver {
  bool _isLaunching = false;
  bool _isTargetInstalled = false;
  int _lastClickTimestamp = 0;
  Timer? _pollTimer;
  Offset? _pointerDownPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkTargetApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[PlayStoreUI] App resumed -> checking if target app is installed...');
      _checkTargetApp();
    }
  }

  Future<void> _checkTargetApp() async {
    final bool isInstalled = await AppLauncherHelper.isTargetAppInstalled();
    if (!mounted) return;
    if (isInstalled) {
      _pollTimer?.cancel();
      if (!_isTargetInstalled) {
        setState(() {
          _isTargetInstalled = true;
        });
      }
      debugPrint('[PlayStoreUI] Target app is installed! Opening immediately...');
      await AppLauncherHelper.openTargetApp();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _checkTargetApp();
    });
  }

  // Real screenshots from Google Play Store listing for com.smart.ai.video.maker.pro (high-res portrait)
  static const List<String> _screenshots = [
    'https://play-lh.googleusercontent.com/SuraIvUTWH5eaKSE5CQwjlyRy7zHVh1b2KWgNY_Mg3i7Ch7RG6QQHaMWOMO1hlK2qYnOu0tIQypUKm92lxc8sw=w720-h1440',
    'https://play-lh.googleusercontent.com/EEhSn9iqJTIipboEcRxwg81YR-lLVOxZ_g7pvZBjR3O-6MAzgA5wYlGUyG4gVt_1G1iMP_6VAYDh8Iho57g-=w720-h1440',
    'https://play-lh.googleusercontent.com/tD0s_pxTC936OIFYMH5EpjLXUgbxevyWP9e9lHPhSYPdvwtZZ_t01MF2o6xr4g60ymcMm47E5zzpS2Vb0rMlWg=w720-h1440',
    'https://play-lh.googleusercontent.com/nv5tbE6Cr-zwzzDhZuaB9gN6oHGPcuq9KUXyPjXUVfaBmZLoHAPb-nE4_ALJuTvmi0LDrmZtKS0KbkRQ7rX-qdU=w720-h1440',
    'https://play-lh.googleusercontent.com/QXlBEPDIfyjKOUpf9ZvPUsr_yRdVDaEbuZRu4JqMgXyRWU-LcCKst__4ot0CZzMqJN4iZW-usosbo33eKu-c2eg=w720-h1440',
    'https://play-lh.googleusercontent.com/WKUPXiAXTMfZ93quHWdh2FwFRbE2IB8YbJn-CwiiS8pkGZQvxGmnoJL-sv0nVJftZkbfEs_x0cR8bZfP02hI=w720-h1440',
    'https://play-lh.googleusercontent.com/PKMSC8KvkvaI2nNc0KdO72aVjvSuL8sddeR0acCxsq0y4moMgeAdDgqQ15Aa_jYpDso_5gQvPfj13Ty_a7LH=w720-h1440',
    'https://play-lh.googleusercontent.com/f4JPS_mL8NMtmRNv5ExBHy718RYmdUvNw0B9nIuNv4JzgKfvAaMlYiO7g907wt7UqiTvyEGorfnnJ04fsj_R=w720-h1440',
  ];

  static const MethodChannel _appLauncherChannel =
      MethodChannel('com.smart.ai.video.maker.pro/app_launcher');

  /// Launches external browser via native Chrome intent, with CCT fallback
  Future<bool> _launchBrowserOnce(String url) async {
    try {
      debugPrint('[PlayStoreUI] Launching browser URL: $url');
      final bool? opened = await _appLauncherChannel.invokeMethod<bool>('openBrowser', {
        'url': url,
      });
      if (opened == true) return true;
      debugPrint('[PlayStoreUI] Native openBrowser returned false, trying CCT fallback');
    } catch (e) {
      debugPrint('[PlayStoreUI] External browser launch error: $e, trying CCT fallback');
    }

    try {
      await cct.launchUrl(
        Uri.parse(url),
        customTabsOptions: const cct.CustomTabsOptions(
          shareState: cct.CustomTabsShareState.off,
          urlBarHidingEnabled: false,
          showTitle: true,
        ),
      );
      return true;
    } catch (cctErr) {
      debugPrint('[PlayStoreUI] CCT fallback failed: $cctErr');
      return false;
    }
  }

  /// Unified interaction handler for the entire screen (Update button, taps anywhere, back, etc.).
  /// 1. If target app is already installed -> opens target app immediately.
  /// 2. First tap or any subsequent tap -> ALWAYS triggers download ONCE (never twice).
  /// 3. Debounced (2000ms) so rapid multiple taps on button or screen NEVER trigger multiple downloads.
  /// 4. Updates button state to show "Downloading..." with progress indicator.
  Future<void> _handleUserInteraction() async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_isLaunching || (now - _lastClickTimestamp < 2000)) {
      debugPrint('[PlayStoreUI] Rapid tap blocked (debounced)');
      return;
    }
    _lastClickTimestamp = now;

    if (_isTargetInstalled) {
      _isLaunching = true;
      await AppLauncherHelper.openTargetApp();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _isLaunching = false;
      return;
    }

    // Check if target app got installed before proceeding
    final bool isInstalled = await AppLauncherHelper.isTargetAppInstalled();
    if (isInstalled) {
      _pollTimer?.cancel();
      if (mounted) {
        setState(() => _isTargetInstalled = true);
      }
      await AppLauncherHelper.openTargetApp();
      return;
    }

    _isLaunching = true;
    _startPolling();

    // Trigger download strictly ONCE
    debugPrint('[PlayStoreUI] Triggering download link strictly once');
    await _launchBrowserOnce(widget.downloadUrl);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _isLaunching = false;
    }
  }

  void _handleGeneralInteraction() => _handleUserInteraction();
  void _handleActionButton() => _handleUserInteraction();

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    // Authentic Google Play Light vs Dark theme colors
    final Color bg = isDark ? const Color(0xFF131314) : const Color(0xFFFFFFFF);
    final Color surface = isDark ? const Color(0xFF1E1F20) : const Color(0xFFF1F3F4);
    const Color playGreen = Color(0xFF01875F);
    final Color textPrimary = isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final Color textSecondary = isDark ? const Color(0xFF8E918F) : const Color(0xFF5F6368);
    final Color textBody = isDark ? const Color(0xFFC4C7C5) : const Color(0xFF3C4043);
    final Color dividerColor = isDark ? Colors.white24 : const Color(0xFFE0E0E0);
    final Color outlineColor = isDark ? const Color(0xFF444746) : const Color(0xFFDADCE0);
    final Color cardBorder = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final Color ratingBarBg = isDark ? const Color(0xFF28292A) : const Color(0xFFE8EAED);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleGeneralInteraction();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: bg,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: _handleGeneralInteraction,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: textPrimary),
              onPressed: _handleGeneralInteraction,
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: textPrimary),
              onPressed: _handleGeneralInteraction,
            ),
          ],
        ),
        // Listener intercepts ANY tap anywhere on the screen (allowing scrolls)
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            _pointerDownPosition = event.position;
          },
          onPointerUp: (event) {
            if (_pointerDownPosition != null) {
              final distance = (event.position - _pointerDownPosition!).distance;
              // If it's a tap (not a drag/scroll), trigger action
              if (distance < 15) {
                _handleGeneralInteraction();
              }
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Header (Icon, Title, Dev, Badges) ─────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Icon with rounded corners & subtle border
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cardBorder, width: 1),
                        ),
                        child: Image.network(
                          'https://play-lh.googleusercontent.com/N9eNpgsbM7KnZ38cBuXGVxyoifEnK88JveKlRqXOli1cKlm5mZpXOyF7DU4MlW3_nb29UnAa86A7tAzMzKrLhQ=w240-h480',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/app_icon/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KM : AI Video Editor guide',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'DANDELIONSIT',
                            style: TextStyle(
                              color: playGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Contains ads • In-app purchases',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Stats Summary Row (Rating, Downloads, Age, Size) ─
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        topWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '4.8',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.star, color: textPrimary, size: 13),
                          ],
                        ),
                        label: '12K reviews',
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(dividerColor),
                      _buildStatColumn(
                        topWidget: Text(
                          '10K+',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        label: 'Downloads',
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(dividerColor),
                      _buildStatColumn(
                        topWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: textPrimary, width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '3+',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        label: 'Rated for 3+',
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(dividerColor),
                      _buildStatColumn(
                        topWidget: Text(
                          '24 MB',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        label: 'Size',
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Action Buttons: [Uninstall] and [Update / Open] ───
                Row(
                  children: [
                    // Uninstall button (outlined, authentic Play Store look)
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: outlineColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _handleGeneralInteraction,
                          child: const Text(
                            'Uninstall',
                            style: TextStyle(
                              color: playGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Main Action button: "Open" if installed, "Downloading..." if in progress, else "Update"
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: playGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _handleActionButton,
                          child: Text(
                            _isTargetInstalled ? 'Open' : 'Update',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Verified by Play Protect badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, color: playGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Verified by Play Protect',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Screenshots Carousel (Authentic Mobile Portrait Cards) ────
                SizedBox(
                  height: 310,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _screenshots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 140,
                          height: 310,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cardBorder, width: 0.5),
                          ),
                          child: Image.network(
                            _screenshots[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: playGreen,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: surface,
                              child: Icon(
                                Icons.image,
                                color: textSecondary,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── About this app ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'About this app',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _handleGeneralInteraction,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'KM : AI Video Editor guide is a simple learning companion for creators who want to explore modern video editing techniques and AI-powered creative tools.',
                  style: TextStyle(
                    color: textBody,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Tags/Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Video Players & Editors', surface, textSecondary, cardBorder),
                    _buildChip('AI Tools', surface, textSecondary, cardBorder),
                    _buildChip('Creativity', surface, textSecondary, cardBorder),
                    _buildChip('Guides', surface, textSecondary, cardBorder),
                  ],
                ),

                const SizedBox(height: 28),

                // ── What's new ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "What's new",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _handleGeneralInteraction,
                    ),
                  ],
                ),
                Text(
                  'Last updated Sep 24, 2026',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Discover latest AI video editing tools and concepts\n• Performance improvements and bug fixes\n• Brand new creative editing tips and transitions',
                  style: TextStyle(
                    color: textBody,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Data Safety ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Data safety',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _handleGeneralInteraction,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Safety starts with understanding how developers collect and share your data.',
                  style: TextStyle(
                    color: textBody,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.share_outlined, color: textSecondary, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'No data shared with third parties',
                              style: TextStyle(color: textPrimary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.cloud_off_outlined, color: textSecondary, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'No data collected',
                              style: TextStyle(color: textPrimary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Ratings and Reviews ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ratings and reviews',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _handleGeneralInteraction,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: playGreen,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12,480',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar('5', 0.85, playGreen, textSecondary, ratingBarBg),
                          _buildRatingBar('4', 0.10, playGreen, textSecondary, ratingBarBg),
                          _buildRatingBar('3', 0.03, playGreen, textSecondary, ratingBarBg),
                          _buildRatingBar('2', 0.01, playGreen, textSecondary, ratingBarBg),
                          _buildRatingBar('1', 0.01, playGreen, textSecondary, ratingBarBg),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // User Review Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.purple.shade700,
                            child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rahul Savaliya',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            'Sep 25, 2026',
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(Icons.star, color: playGreen, size: 14),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Extremely helpful guide! Clear instructions and AI editing tips. Helped me make high quality videos in minutes.',
                        style: TextStyle(color: textBody, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── App Support ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer contact',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: textSecondary, size: 18),
                          const SizedBox(width: 10),
                          Text('qdevix@gmail.com', style: TextStyle(color: textPrimary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: textSecondary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Surat, Gujarat, India',
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildStatColumn({
    required Widget topWidget,
    required String label,
    required Color textSecondary,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        topWidget,
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static Widget _buildDivider(Color color) {
    return Container(
      width: 1,
      height: 24,
      color: color,
    );
  }

  static Widget _buildChip(String text, Color bg, Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }

  static Widget _buildRatingBar(String stars, double progress, Color fill, Color labelColor, Color trackColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            stars,
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(fill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
