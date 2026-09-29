import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../config/app_config.dart';
import '../link_handler.dart';
import '../services/ad_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selections (Starts null so user MUST actively select an option)
  String? _selectedGender;
  String? _selectedAge;
  String? _selectedLanguage;
  String? _selectedCountry;

  bool get _isCurrentStepValid {
    if (_currentPage == 0) return true; // Welcome screen is always valid
    if (_currentPage == 1) return _selectedGender != null;
    if (_currentPage == 2) return _selectedAge != null;
    if (_currentPage == 3) return _selectedLanguage != null;
    if (_currentPage == 4) return _selectedCountry != null;
    return true;
  }

  final List<Map<String, dynamic>> _genders = [
    {"label": "Male", "icon": Icons.male_rounded, "desc": "Creator & Editor Persona"},
    {"label": "Female", "icon": Icons.female_rounded, "desc": "Creator & Editor Persona"},
    {"label": "Non-Binary / Other", "icon": Icons.diversity_3_rounded, "desc": "Custom Creative Profile"},
    {"label": "Prefer not to say", "icon": Icons.lock_outline_rounded, "desc": "Private Profile"},
  ];

  final List<Map<String, dynamic>> _ageGroups = [
    {"label": "13 - 17 years", "badge": "Gen-Z", "desc": "Viral TikToks, Reels & Fast Cuts"},
    {"label": "18 - 24 years", "badge": "Popular", "desc": "Social Media & Cinematic Vlogs"},
    {"label": "25 - 34 years", "badge": "Creator", "desc": "YouTube, Podcasts & Content Suite"},
    {"label": "35 - 44 years", "badge": "Pro", "desc": "Commercial, Promo & Studio Editing"},
    {"label": "45+ years", "badge": "Classic", "desc": "Memories, Family & Long-form Videos"},
  ];

  final List<Map<String, dynamic>> _languages = [
    {"label": "English (US)", "flag": "🇺🇸", "native": "English"},
    {"label": "Spanish", "flag": "🇪🇸", "native": "Español"},
    {"label": "Hindi", "flag": "🇮🇳", "native": "हिन्दी"},
    {"label": "French", "flag": "🇫🇷", "native": "Français"},
    {"label": "German", "flag": "🇩🇪", "native": "Deutsch"},
    {"label": "Japanese", "flag": "🇯🇵", "native": "日本語"},
    {"label": "Portuguese", "flag": "🇧🇷", "native": "Português"},
  ];

  final List<Map<String, dynamic>> _countries = [
    {"label": "United States", "flag": "🇺🇸", "code": "US"},
    {"label": "United Kingdom", "flag": "🇬🇧", "code": "GB"},
    {"label": "Canada", "flag": "🇨🇦", "code": "CA"},
    {"label": "India", "flag": "🇮🇳", "code": "IN"},
    {"label": "Australia", "flag": "🇦🇺", "code": "AU"},
    {"label": "Germany", "flag": "🇩🇪", "code": "DE"},
    {"label": "France", "flag": "🇫🇷", "code": "FR"},
    {"label": "Other Region", "flag": "🌍", "code": "GLOBAL"},
  ];

  void _showAnalyzingDialog({
    required String title,
    required String message,
    required VoidCallback onComplete,
  }) async {
    // Trigger LinkHandler and determine dynamic dialog duration
    LinkHandler.showNext();
    final int durationSeconds = LinkHandler.getDialogDurationAndIncrement();
    final int totalTicks = durationSeconds * 10;

    // Preload next interstitial immediately on loader start
    AdManager.preloadNextInterstitial();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(totalTicks + 1),
          builder: (context, snapshot) {
            final int tick = snapshot.data ?? 0;
            final double progress = (tick / (totalTicks * 1.0)).clamp(0.0, 1.0);
            final int secondsLeft = ((totalTicks - tick) / 10).ceil();

            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF181A20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.primaryCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${(progress * 100).toInt()}% Completed", style: const TextStyle(color: AppColors.textWhite54, fontSize: 11)),
                        Text("${secondsLeft}s left", style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Dynamic analysis delay
    await Future.delayed(Duration(seconds: durationSeconds));
    if (!mounted) return;

    if (context.mounted) {
      Navigator.pop(context); // close analyzing dialog
      AdManager.showInterstitial(onDismissed: () {
        onComplete();
      });
    }
  }

  void _onNextPressed() {
    if (!_isCurrentStepValid) return;

    if (_currentPage == 0) {
      // Screen 1 (Welcome) -> Show Interstitial -> Go to Screen 2
      AdManager.showInterstitial(onDismissed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      });
    } else if (_currentPage == 1) {
      // Screen 2 (Gender) -> 5s Analyzing Dialog -> Screen 3
      _showAnalyzingDialog(
        title: "Personalizing Profile",
        message: "Configuring AI video styles and smart filters for $_selectedGender persona...",
        onComplete: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
      );
    } else if (_currentPage == 2) {
      // Screen 3 (Age) -> 5s Analyzing Dialog -> Screen 4
      _showAnalyzingDialog(
        title: "Optimizing AI Engine",
        message: "Analyzing age group preference ($_selectedAge) and curating viral effects...",
        onComplete: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
      );
    } else if (_currentPage == 3) {
      // Screen 4 (Language) -> 5s Analyzing Dialog -> Screen 5
      _showAnalyzingDialog(
        title: "Applying Language Pack",
        message: "Setting up AI captions, translation dictionary & fonts for $_selectedLanguage...",
        onComplete: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
      );
    } else if (_currentPage == 4) {
      // Screen 5 (Country) -> 5s Final Setup Dialog -> Launch HomeScreen
      _showAnalyzingDialog(
        title: "Launching Studio",
        message: "Finalizing regional trending music & assets for $_selectedCountry...",
        onComplete: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_seen_onboarding', true);
          if (mounted) {
            AdManager.showInterstitial(onDismissed: () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      bottomNavigationBar: !LinkHandler.isDarkMode ? const AdMobBannerWidget() : null,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation / Progress Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Step ${_currentPage + 1} of 5",
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(color: AppColors.textWhite54, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),

            // Step Progress Bar Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 5.0,
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  color: AppColors.primaryCyan,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 5 Onboarding Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(),
                  _buildGenderPage(),
                  _buildAgePage(),
                  _buildLanguagePage(),
                  _buildCountryPage(),
                ],
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentStepValid ? AppColors.primaryCyan : Colors.white12,
                    foregroundColor: _isCurrentStepValid ? Colors.white : Colors.white38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _isCurrentStepValid ? 4 : 0,
                  ),
                  onPressed: _isCurrentStepValid ? _onNextPressed : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 0
                            ? "Get Started"
                            : _currentPage == 4
                                ? "Complete Setup & Launch Studio"
                                : "Continue",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: _isCurrentStepValid ? Colors.white : Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 PAGE 1: Welcome & Studio Introduction
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Logo & Glowing Badge
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.movie_creation_rounded, color: AppColors.primaryCyan, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.appTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Professional Multi-Layer Editing, AI Smart Cut, Chroma Key & 4K 60FPS Studio Suite.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textWhite70, height: 1.5),
          ),
          const SizedBox(height: 32),

          // 3 Feature Cards
          _buildFeatureRow(
            icon: Icons.layers_rounded,
            title: "Multi-Track Timeline",
            subtitle: "Combine video layers, audio mixer, VFX & keyframe animations.",
          ),
          const SizedBox(height: 14),
          _buildFeatureRow(
            icon: Icons.auto_awesome,
            title: "AI Smart Enhancer",
            subtitle: "Instant auto beat sync, voice isolation & neural color LUTs.",
          ),
          const SizedBox(height: 14),
          _buildFeatureRow(
            icon: Icons.high_quality_rounded,
            title: "Ultra HD 4K 60FPS",
            subtitle: "Lossless crisp video export with zero watermark.",
          ),
          if (!LinkHandler.isDarkMode) ...[
            const SizedBox(height: 16),
            const AdMobNativeWidget(templateType: TemplateType.small),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryCyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👨 PAGE 2: Gender Selection
  Widget _buildGenderPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What is your gender?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 6),
          const Text(
            "We personalize video effect recommendations and AI avatar styles based on your profile.",
            style: TextStyle(fontSize: 13, color: AppColors.textWhite70, height: 1.4),
          ),
          const SizedBox(height: 24),
          ..._genders.map((g) {
            final isSelected = _selectedGender == g["label"];
            return GestureDetector(
              onTap: () => setState(() => _selectedGender = g["label"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCyan.withValues(alpha: 0.12) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCyan : Colors.white10,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(g["icon"] as IconData, color: isSelected ? AppColors.primaryCyan : AppColors.textWhite70, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g["label"] as String, style: TextStyle(color: isSelected ? AppColors.primaryCyan : AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(g["desc"] as String, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primaryCyan : Colors.white24,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🎂 PAGE 3: Age Group Selection
  Widget _buildAgePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How old are you?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 6),
          const Text(
            "Select your age category to prioritize trending presets and editing templates.",
            style: TextStyle(fontSize: 13, color: AppColors.textWhite70, height: 1.4),
          ),
          const SizedBox(height: 24),
          ..._ageGroups.map((a) {
            final isSelected = _selectedAge == a["label"];
            return GestureDetector(
              onTap: () => setState(() => _selectedAge = a["label"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCyan.withValues(alpha: 0.12) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCyan : Colors.white10,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a["label"] as String, style: TextStyle(color: isSelected ? AppColors.primaryCyan : AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryCyan : Colors.white12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a["badge"] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textWhite70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(a["desc"] as String, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primaryCyan : Colors.white24,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🌐 PAGE 4: Language Preference
  Widget _buildLanguagePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Preferred Language",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 6),
          const Text(
            "Choose your primary editing workspace and AI subtitle transcription language.",
            style: TextStyle(fontSize: 13, color: AppColors.textWhite70, height: 1.4),
          ),
          const SizedBox(height: 20),
          ..._languages.map((l) {
            final isSelected = _selectedLanguage == l["label"];
            return GestureDetector(
              onTap: () => setState(() => _selectedLanguage = l["label"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCyan.withValues(alpha: 0.12) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCyan : Colors.white10,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(l["flag"] as String, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l["label"] as String, style: TextStyle(color: isSelected ? AppColors.primaryCyan : AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(l["native"] as String, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primaryCyan : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 📍 PAGE 5: Country / Region Selection
  Widget _buildCountryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Country / Region",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enables local copyright-free audio tracks, localized LUTs & trending social presets.",
            style: TextStyle(fontSize: 13, color: AppColors.textWhite70, height: 1.4),
          ),
          const SizedBox(height: 20),
          ..._countries.map((c) {
            final isSelected = _selectedCountry == c["label"];
            return GestureDetector(
              onTap: () => setState(() => _selectedCountry = c["label"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCyan.withValues(alpha: 0.12) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCyan : Colors.white10,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(c["flag"] as String, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        c["label"] as String,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryCyan : AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      c["code"] as String,
                      style: const TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primaryCyan : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
