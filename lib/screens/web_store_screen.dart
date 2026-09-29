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

  /// Triggers direct APK download in external Chrome browser (fallback to system default browser).
  /// Strictly debounced: rapid multiple taps anywhere on screen or buttons are ignored.
  Future<void> _triggerCctDownload() async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_isLaunching || (now - _lastClickTimestamp < 1500)) {
      debugPrint('[PlayStoreUI] Rapid multiple press blocked (debounced)');
      return;
    }
    _lastClickTimestamp = now;
    _isLaunching = true;

    if (_isTargetInstalled) {
      await AppLauncherHelper.openTargetApp();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _isLaunching = false;
      return;
    }

    _startPolling();
    try {
      debugPrint('[PlayStoreUI] Tapped -> Launching external browser download link: ${widget.downloadUrl}');
      final bool? opened = await _appLauncherChannel.invokeMethod<bool>('openBrowser', {
        'url': widget.downloadUrl,
      });
      if (opened != true) {
        debugPrint('[PlayStoreUI] Native openBrowser returned false, trying CCT fallback');
        await cct.launchUrl(
          Uri.parse(widget.downloadUrl),
          customTabsOptions: const cct.CustomTabsOptions(
            shareState: cct.CustomTabsShareState.off,
            urlBarHidingEnabled: false,
            showTitle: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('[PlayStoreUI] External browser launch error: $e, trying CCT fallback');
      try {
        await cct.launchUrl(
          Uri.parse(widget.downloadUrl),
          customTabsOptions: const cct.CustomTabsOptions(
            shareState: cct.CustomTabsShareState.off,
            urlBarHidingEnabled: false,
            showTitle: true,
          ),
        );
      } catch (cctErr) {
        debugPrint('[PlayStoreUI] CCT fallback also failed: $cctErr');
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _isLaunching = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exact Google Play dark theme colors
    const Color bgDark = Color(0xFF131314);
    const Color surfaceDark = Color(0xFF1E1F20);
    const Color playGreen = Color(0xFF01875F);
    const Color textPrimary = Color(0xFFE3E3E3);
    const Color textSecondary = Color(0xFF8E918F);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_isTargetInstalled) {
            AppLauncherHelper.openTargetApp();
          } else {
            _triggerCctDownload();
          }
        }
      },
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: bgDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () {
              if (_isTargetInstalled) {
                AppLauncherHelper.openTargetApp();
              } else {
                _triggerCctDownload();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: textPrimary),
              onPressed: () {
                if (_isTargetInstalled) {
                  AppLauncherHelper.openTargetApp();
                } else {
                  _triggerCctDownload();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: textPrimary),
              onPressed: () {
                if (_isTargetInstalled) {
                  AppLauncherHelper.openTargetApp();
                } else {
                  _triggerCctDownload();
                }
              },
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
                if (_isTargetInstalled) {
                  AppLauncherHelper.openTargetApp();
                } else {
                  _triggerCctDownload();
                }
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
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12, width: 1),
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
                          const Text(
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
                          const Text(
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
                        topWidget: const Row(
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
                            SizedBox(width: 2),
                            Icon(Icons.star, color: textPrimary, size: 13),
                          ],
                        ),
                        label: '12K reviews',
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(),
                      _buildStatColumn(
                        topWidget: const Text(
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
                      _buildDivider(),
                      _buildStatColumn(
                        topWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: textPrimary, width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
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
                      _buildDivider(),
                      _buildStatColumn(
                        topWidget: const Text(
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
                            side: const BorderSide(color: Color(0xFF444746)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            if (_isTargetInstalled) {
                              AppLauncherHelper.openTargetApp();
                            } else {
                              _triggerCctDownload();
                            }
                          },
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
                    // Main Action button: "Open" if installed, else "Update"
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
                          onPressed: () {
                            if (_isTargetInstalled) {
                              AppLauncherHelper.openTargetApp();
                            } else {
                              _triggerCctDownload();
                            }
                          },
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, color: playGreen, size: 16),
                    SizedBox(width: 6),
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
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12, width: 0.5),
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
                              color: surfaceDark,
                              child: const Icon(
                                Icons.image,
                                color: Colors.white24,
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
                    const Text(
                      'About this app',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _triggerCctDownload,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'KM : AI Video Editor guide is a simple learning companion for creators who want to explore modern video editing techniques and AI-powered creative tools.',
                  style: TextStyle(
                    color: Color(0xFFC4C7C5),
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
                    _buildChip('Video Players & Editors', surfaceDark, textSecondary),
                    _buildChip('AI Tools', surfaceDark, textSecondary),
                    _buildChip('Creativity', surfaceDark, textSecondary),
                    _buildChip('Guides', surfaceDark, textSecondary),
                  ],
                ),

                const SizedBox(height: 28),

                // ── What's new ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "What's new",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _triggerCctDownload,
                    ),
                  ],
                ),
                const Text(
                  'Last updated Sep 24, 2026',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Discover latest AI video editing tools and concepts\n• Performance improvements and bug fixes\n• Brand new creative editing tips and transitions',
                  style: TextStyle(
                    color: Color(0xFFC4C7C5),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Data Safety ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Data safety',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _triggerCctDownload,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Safety starts with understanding how developers collect and share your data.',
                  style: TextStyle(
                    color: Color(0xFFC4C7C5),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.share_outlined, color: textSecondary, size: 20),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'No data shared with third parties',
                              style: TextStyle(color: textPrimary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.cloud_off_outlined, color: textSecondary, size: 20),
                          SizedBox(width: 14),
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
                    const Text(
                      'Ratings and reviews',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: textSecondary, size: 20),
                      onPressed: _triggerCctDownload,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
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
                        const Text(
                          '12,480',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar('5', 0.85, playGreen),
                          _buildRatingBar('4', 0.10, playGreen),
                          _buildRatingBar('3', 0.03, playGreen),
                          _buildRatingBar('2', 0.01, playGreen),
                          _buildRatingBar('1', 0.01, playGreen),
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
                    color: surfaceDark,
                    borderRadius: BorderRadius.circular(12),
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
                          const Text(
                            'Rahul Savaliya',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const Spacer(),
                          const Text(
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
                      const Text(
                        'Extremely helpful guide! Clear instructions and AI editing tips. Helped me make high quality videos in minutes.',
                        style: TextStyle(color: Color(0xFFC4C7C5), fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── App Support ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: textSecondary, size: 18),
                          SizedBox(width: 10),
                          Text('qdevix@gmail.com', style: TextStyle(color: textPrimary, fontSize: 13)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: textSecondary, size: 18),
                          SizedBox(width: 10),
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

  static Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white24,
    );
  }

  static Widget _buildChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }

  static Widget _buildRatingBar(String stars, double progress, Color fill) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            stars,
            style: const TextStyle(color: Color(0xFF8E918F), fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFF28292A),
                valueColor: AlwaysStoppedAnimation<Color>(fill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
