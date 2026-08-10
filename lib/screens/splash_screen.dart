import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import '../link_handler.dart';
import '../config/app_config.dart';

class SplashScreen extends StatefulWidget {
  final bool hasSeenOnboarding;

  const SplashScreen({super.key, required this.hasSeenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 12-second realistic loading animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.hasSeenOnboarding
                  ? const HomeScreen()
                  : const OnboardingScreen(),
            ),
          );
          LinkHandler.showNext(); // Open CCT link immediately on splash completion!
        }
      });

    _controller.forward();
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
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppStrings.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
