import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../config/app_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _restoreSavedPage();
  }

  void _restoreSavedPage() async {
    final prefs = await SharedPreferences.getInstance();
    int savedPage = prefs.getInt('onboarding_current_page') ?? 0;
    if (savedPage > 0 && savedPage < AppStrings.onboardingItems.length) {
      if (mounted) {
        setState(() {
          _currentPage = savedPage;
        });
        _pageController.jumpToPage(savedPage);
      }
    }
  }

  void _onPageChanged(int index) async {
    setState(() => _currentPage = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_current_page', index);
  }

  void _finishOnboarding() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<int>(
          // Tick every 100ms — 100 ticks over 10 seconds = 0→100%
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(101),
          builder: (context, snapshot) {
            int progress = snapshot.data ?? 0;
            // Which step label to show (changes every ~1 second = every 10 ticks)
            int stepIndex = ((progress / 100) * AppStrings.onboardingLoadingSteps.length).floor().clamp(0, AppStrings.onboardingLoadingSteps.length - 1);
            String currentStep = AppStrings.onboardingLoadingSteps[stepIndex];

            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                AppStrings.onboardingInitTitle,
                style: TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      currentStep,
                      key: ValueKey(currentStep),
                      style: const TextStyle(color: AppColors.textWhite70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100.0,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("$progress%", style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );

    // 10 seconds (100 ticks × 100ms)
    await Future.delayed(const Duration(seconds: 10));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.remove('onboarding_current_page'); // Wipe saved index on completion
    
    if (context.mounted) {
      Navigator.pop(context); // close dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: AppStrings.onboardingItems.length,
            itemBuilder: (context, index) {
              final data = AppStrings.onboardingItems[index];
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data['image']!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data['title']!,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['desc']!,
                            style: const TextStyle(fontSize: 16, color: AppColors.textWhite70, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots indicator
                Row(
                  children: List.generate(
                    AppStrings.onboardingItems.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primaryCyan : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next/Start Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonWhite,
                    foregroundColor: AppColors.buttonBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (_currentPage == AppStrings.onboardingItems.length - 1) {
                      _finishOnboarding();
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(_currentPage == AppStrings.onboardingItems.length - 1 ? AppStrings.startEditing : AppStrings.next, style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

