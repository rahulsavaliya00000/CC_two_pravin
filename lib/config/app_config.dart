import 'package:flutter/material.dart';

/// Centralized Configuration File for App Colors & Texts
/// Edit any color or text string here to reflect across the entire app!

class AppColors {
  // Core Background & Surface Colors
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  // Primary Accent & Highlight Colors
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color secondaryAccent = Color(0xFF7C4DFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color orangeAccent = Colors.orangeAccent;
  static const Color errorRed = Colors.redAccent;

  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  static const Color textBlack = Colors.black;
  static const Color textCyan = Color(0xFF00E5FF);

  // Button & Interactive Colors
  static const Color buttonWhite = Colors.white;
  static const Color buttonBlack = Colors.black;
  static const Color buttonCyan = Color(0xFF00E5FF);
}

class AppStrings {
  // General App Info
  static const String appTitle = "CC : AI Video Editor";
  static const String appSubtitle = "The Ultimate AI Video Creation Suite";

  // Exit Dialog & Back Press
  static const String exitDialogTitle = "Exit CC : AI Video Editor";
  static const String exitDialogContent = "Are you sure you want to exit the app?";
  static const String cancel = "Cancel";
  static const String exit = "Exit";
  static const String pressBack2Times = "Press back 2 more times to exit app";
  static const String pressBack1Time = "Press back 1 more time to exit app";

  // Splash Screen
  static const String splashInitializing = "Initializing core assets...";

  // Onboarding Screen
  static const String startEditing = "Start Editing";
  static const String next = "Next";
  static const String onboardingInitTitle = "Initializing Assets...";

  static const List<Map<String, String>> onboardingItems = [
    {
      "title": "Unleash Your Creativity",
      "desc": "The ultimate mobile video editor for professionals and beginners.",
      "image": "assets/images/onboarding_1.png"
    },
    {
      "title": "Manage Your Media",
      "desc": "Import 4K clips, photos, and audio effortlessly.",
      "image": "assets/images/onboarding_2.png"
    },
    {
      "title": "Precision Trimming",
      "desc": "Cut, split, and arrange clips with frame-by-frame accuracy on the timeline.",
      "image": "assets/images/onboarding_3.png"
    },
    {
      "title": "Stunning Visuals",
      "desc": "Apply cinematic filters, color grading, and dynamic effects.",
      "image": "assets/images/onboarding_4.png"
    },
    {
      "title": "Perfect Soundscapes",
      "desc": "Mix multi-track audio, add voiceovers, and sync beats.",
      "image": "assets/images/onboarding_5.png"
    },
    {
      "title": "Share with the World",
      "desc": "Export in high resolution without watermarks.",
      "image": "assets/images/onboarding_6.png"
    },
  ];

  static const List<String> onboardingLoadingSteps = [
    "Initializing app assets...",
    "Preparing canvas frames...",
    "Initializing engine...",
    "Loading preset templates...",
    "Configuring timeline tracks...",
    "Loading color profiles...",
    "Initializing visual effects...",
    "Setting up editing studio...",
    "Finalizing asset initialization...",
    "Launching studio environment...",
  ];

  // Export Screen
  static const String exportTitle = "Export Settings";
  static const String exportButton = "Export Video";
  static const String renderingExport = "Rendering & Initializing Export...";
  static const String exportKeepScreenActive = "Initializing asset rendering. Please keep screen active.";
  static const String exportFailedTitle = "Export Failed";
  static const String exportFailedContent = "Error Code 402 (Device Codec Unsupported). Please try exporting at a lower resolution or clear device storage.";
  static const String ok = "OK";
  static const String tryAgainLater = "Try Again Later";

  // Guide & Tool Processing
  static const String toolProcessingFailed = "Tool Processing Failed";
  static const String serviceUnavailable = "Service Temporarily Unavailable";
  static const String serverLimitReached = "Server processing limit reached (Error Code 503). Something went wrong while applying engine assets. Please try again later in 10 minutes.";
}
