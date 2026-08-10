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

  // Legal & Privacy Policy
  static const String privacyPolicyText = """
Last updated: August 2026

1. Introduction
Welcome to CC : AI Video Editor ("we," "our," or "us"). We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

2. Information We Collect
- Device & Usage Information: We collect diagnostic data, app usage statistics, crash logs, and performance metadata to ensure app stability and performance.
- Media & Storage Access: Local photos and video files accessed within the app remain stored strictly on your device. We do not upload your personal media files to remote servers without your explicit action.
- Analytics & Firebase Services: We use Google Firebase Analytics and Firebase Remote Config to analyze app features, measure performance, and deliver dynamic app settings.

3. How We Use Your Information
- To operate, maintain, and improve our video editing tools and features.
- To personalize your user experience and app preferences.
- To detect, prevent, and address technical issues, bugs, and crash reports.

4. Data Security
We implement robust, industry-standard security measures to maintain the safety of your personal information behind encrypted networks.

5. Third-Party Services
Our app integrates Google Firebase services (Firebase Analytics & Remote Config). Third-party providers collect information sent by your device in accordance with their privacy policies.

6. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by updating the "Last updated" date in this policy.

7. Contact Us
If you have any questions or concerns regarding this Privacy Policy, please contact our support team.
""";

  static const String termsAndConditionsText = """
Last updated: August 2026

1. Acceptance of Terms
By downloading, installing, or using CC : AI Video Editor, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the application.

2. License & Use
We grant you a limited, non-exclusive, non-transferable, revocable license to use the app for personal, non-commercial video creation and editing purposes in accordance with these Terms.

3. Intellectual Property Rights
All trademarks, logos, app assets, source code, UI designs, and preset templates remain the exclusive property of CC : AI Video Editor.

4. User Responsibilities
You agree not to modify, reverse engineer, decompile, or misuse any part of the application or introduce malicious code or harmful data.

5. Disclaimer of Warranties
The application is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, either express or implied.
""";

  static const String openSourceLicensesText = """
Open Source Software Licenses & Attribution

This software incorporates open-source components under the following licenses:

• Flutter SDK (BSD 3-Clause License)
• Firebase Core & Analytics (Apache License 2.0)
• Shared Preferences Plugin (BSD 3-Clause License)
• Back Button Interceptor (MIT License)
• Flutter Toast (MIT License)

Full license texts are available in the project documentation.
""";
}
