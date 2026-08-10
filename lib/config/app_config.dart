import 'package:flutter/material.dart';

/// Centralized Configuration File for App Colors, Icons, Radii, Spacing, Assets, Typography & Texts
/// Edit any color, icon, border radius, asset path, or text string here to control the entire app!

class AppColors {
  // Core Background & Surface Colors
  static const Color scaffoldBackground = Color(0xFF121318);
  static const Color darkBackground = Color(0xFF0D0E12);
  static const Color cardBackground = Color(0xFF1C1E26);
  static const Color surfaceDark = Color(0xFF242733);

  // Primary Accent & Highlight Colors (InShot Red-Pink & Orange Theme)
  static const Color primaryCyan = Color(0xFFFF2E63); // Primary Red-Pink
  static const Color primaryRed = Color(0xFFFF2E63);
  static const Color secondaryAccent = Color(0xFFFF7F3E); // Orange Accent
  static const Color gold = Color(0xFFFFD700);
  static const Color orangeAccent = Color(0xFFFF5C38);
  static const Color errorRed = Color(0xFFFF2D55);
  static const Color greenAccent = Color(0xFF00E676);

  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  static const Color textBlack = Colors.black;
  static const Color textCyan = Color(0xFFFF2E63);

  // Button & Interactive Colors
  static const Color buttonWhite = Colors.white;
  static const Color buttonBlack = Colors.black;
  static const Color buttonCyan = Color(0xFFFF2E63);
}

class AppRadius {
  // Numeric Radius Values
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r30 = 30.0;

  // BorderRadius Objects for easy usage
  static final BorderRadius small = BorderRadius.circular(r6);
  static final BorderRadius medium = BorderRadius.circular(r10);
  static final BorderRadius card = BorderRadius.circular(r12);
  static final BorderRadius dialog = BorderRadius.circular(r16);
  static final BorderRadius button = BorderRadius.circular(r20);
  static final BorderRadius roundedLarge = BorderRadius.circular(r24);
  static final BorderRadius pill = BorderRadius.circular(r30);
}

class AppSpacing {
  // Padding & Margin Offsets
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
}

class AppDurations {
  // Timing Configurations
  static const Duration splashLoading = Duration(seconds: 12);
  static const Duration onboardingInit = Duration(seconds: 10);
  static const Duration aiProcessing = Duration(seconds: 28);
  static const Duration exportRendering = Duration(seconds: 45);
  static const Duration pageTransition = Duration(milliseconds: 300);
}

class AppGradients {
  static const LinearGradient primaryHero = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFFFF7F3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberpunk = LinearGradient(
    colors: [Color(0xFFFF2F68), Color(0xFFFF5C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient viralReel = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proOpener = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFFFF4F81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppAssets {
  // Splash & Onboarding Images
  static const String splashLogo = "assets/images/splash_logo.jpg";
  static const String guideHero = "assets/images/guide_hero.jpg";

  static const String onboarding1 = "assets/images/onboarding_1.png";
  static const String onboarding2 = "assets/images/onboarding_2.png";
  static const String onboarding3 = "assets/images/onboarding_3.png";
  static const String onboarding4 = "assets/images/onboarding_4.png";
  static const String onboarding5 = "assets/images/onboarding_5.png";
  static const String onboarding6 = "assets/images/onboarding_6.png";

  // Template Images
  static const String template1 = "assets/images/template_1.jpg";
  static const String template2 = "assets/images/template_2.jpg";
  static const String template3 = "assets/images/template_3.jpg";
  static const String template4 = "assets/images/template_4.jpg";
  static const String template5 = "assets/images/template_5.jpg";
  static const String template6 = "assets/images/template_6.jpg";

  // Tutorial Images
  static const String tutorial1 = "assets/images/tutorial_1.jpg";
  static const String tutorial2 = "assets/images/tutorial_2.jpg";
  static const String tutorial3 = "assets/images/tutorial_3.jpg";
  static const String tutorial4 = "assets/images/tutorial_4.jpg";
}

class AppTextStyles {
  // Headline Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textWhite70,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textWhite54,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonBlack,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

class AppIcons {
  // Navigation & General Icons
  static const IconData studio = Icons.video_library;
  static const IconData templates = Icons.dashboard;
  static const IconData tutorials = Icons.school;
  static const IconData profile = Icons.person;
  static const IconData close = Icons.close;
  static const IconData search = Icons.search;
  static const IconData add = Icons.add;
  static const IconData arrowDropDown = Icons.arrow_drop_down;
  static const IconData arrowForward = Icons.arrow_forward_ios;
  static const IconData moreVert = Icons.more_vert;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData star = Icons.star;
  static const IconData tune = Icons.tune;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline;

  // KineMaster AI & Editing Engine Icons
  static const IconData autoAwesome = Icons.auto_awesome;
  static const IconData psychology = Icons.psychology;
  static const IconData upload = Icons.upload_rounded;
  static const IconData download = Icons.download;
  static const IconData cloudDownload = Icons.cloud_download;
  static const IconData cloudSync = Icons.cloud_sync;
  static const IconData videoCamera = Icons.video_camera_back;
  static const IconData play = Icons.play_arrow;
  static const IconData playCircle = Icons.play_circle_fill;
  static const IconData playCircleRounded = Icons.play_circle_fill_rounded;

  // Toolbar & Editing Functions Icons
  static const IconData split = Icons.content_cut;
  static const IconData speed = Icons.speed;
  static const IconData volume = Icons.volume_up;
  static const IconData animation = Icons.animation;
  static const IconData delete = Icons.delete;
  static const IconData adjust = Icons.color_lens;
  static const IconData filter = Icons.filter;
  static const IconData captions = Icons.closed_caption;
  static const IconData removeBg = Icons.person_remove;
  static const IconData chromaKey = Icons.movie_creation;
  static const IconData stabilize = Icons.waves;
  static const IconData tracking = Icons.track_changes;
  static const IconData mic = Icons.mic;
  static const IconData musicNote = Icons.music_note;
  static const IconData textToSpeech = Icons.text_fields;

  // KineMaster Assets & Category Icons
  static const IconData layers = Icons.layers;
  static const IconData assetStore = Icons.store;
  static const IconData soundFx = Icons.library_music;
  static const IconData fonts = Icons.font_download;
  static const IconData stickers = Icons.emoji_emotions;
  static const IconData transitions = Icons.movie_filter;
  static const IconData movie = Icons.movie;
  static const IconData bolt = Icons.bolt;
  static const IconData vignette = Icons.vignette;
  static const IconData timeline = Icons.timeline;

  // Settings & Legal Icons
  static const IconData restore = Icons.restore;
  static const IconData highQuality = Icons.high_quality;
  static const IconData shutterSpeed = Icons.shutter_speed;
  static const IconData hdr = Icons.hdr_on;
  static const IconData toggleOn = Icons.toggle_on;
  static const IconData memory = Icons.memory;
  static const IconData bugReport = Icons.bug_report;
  static const IconData privacyTip = Icons.privacy_tip;
  static const IconData gavel = Icons.gavel;
  static const IconData code = Icons.code;
  static const IconData analytics = Icons.analytics;
}

class AppStrings {
  // General App Info
  static const String appTitle = "Video Editing InShot for Guide";
  static const String appSubtitle = "Pro Canvas, Speed & Transition Suite";

  // Exit Dialog & Back Press
  static const String exitDialogTitle = "Exit Video Editing InShot for Guide";
  static const String exitDialogContent = "Are you sure you want to exit Video Editing InShot for Guide?";
  static const String cancel = "Cancel";
  static const String exit = "Exit";
  static const String pressBack2Times = "Press back 2 more times to exit app";
  static const String pressBack1Time = "Press back 1 more time to exit app";

  // Splash Screen
  static const String splashInitializing = "Initializing InShot core engine...";

  // Onboarding Screen
  static const String startEditing = "Start Editing";
  static const String next = "Next";
  static const String onboardingInitTitle = "Initializing InShot Editor...";

  static const List<Map<String, String>> onboardingItems = [
    {
      "title": "Dynamic Video Canvas & Ratio",
      "desc": "Adjust your video to any aspect ratio (1:1, 16:9, 9:16) for TikTok, Instagram, and YouTube seamlessly.",
      "image": AppAssets.onboarding1
    },
    {
      "title": "Pro Transition Effects",
      "desc": "Apply smooth cinematically-designed transitions between clips to make your video flow beautifully.",
      "image": AppAssets.onboarding2
    },
    {
      "title": "Advanced Speed Control",
      "desc": "Control video velocity curves with ultra-smooth speed ramping and slow-mo effects.",
      "image": AppAssets.onboarding3
    },
    {
      "title": "Keyframe Animations",
      "desc": "Bring your text, stickers, and pictures to life with dynamic keyframe animation paths.",
      "image": AppAssets.onboarding4
    },
    {
      "title": "Vocal Pitch & Audio Mixer",
      "desc": "Mix background music, voiceovers, apply high-quality filters, and adjust sound levels easily.",
      "image": AppAssets.onboarding5
    },
    {
      "title": "High-Resolution 4K Export",
      "desc": "Render and export high-definition 4K videos at 60 FPS directly to your phone's gallery.",
      "image": AppAssets.onboarding6
    },
  ];

  static const List<String> onboardingLoadingSteps = [
    "Initializing InShot engine...",
    "Preparing video canvas tracks...",
    "Loading Transition presets...",
    "Loading InShot Asset Store filters...",
    "Configuring timeline video tracks...",
    "Loading LUT color profiles...",
    "Initializing visual VFX filters...",
    "Setting up audio mixing console...",
    "Finalizing InShot studio setup...",
    "Launching editing environment...",
  ];

  // Daily Rewards
  static const String dailyRewardTitle = "CLAIM INSHOT PRO REWARDS";
  static const String dailyRewardSubtitle = "Claim consecutive daily rewards to unlock premium InShot filters & speed ramping curves.";
  static const String claimRewards = "Claim Rewards";
  static const String claimed = "Claimed!";
  static const List<String> rewardDays = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"];
  static const List<String> rewardCoins = ["50 Coins", "100 Coins", "150 Coins", "200 Coins", "300 Coins", "500 Coins", "InShot PRO 24H"];

  // AI Project Wizard
  static const String wizardTitle = "InShot Project Wizard";
  static const String selectAspectPlatform = "Select Aspect Ratio & Target Platform:";
  static const String selectStylePreset = "Select Visual Style & VFX Preset:";
  static const String selectAudioMood = "Select Audio & Beat Sync Mood:";
  static const String confirmProjectSetup = "Confirm Project Setup:";
  static const String previous = "Previous";
  static const String nextStep = "Next Step";
  static const String generateAiProject = "Create InShot Project";
  static const String targetPlatform = "Target Platform";
  static const String visualStyle = "Visual Style";
  static const String audioMood = "Audio Mood";

  // Studio Tab
  static const String studioTab = "Studio";
  static const String newProjectTitle = "NEW INSHOT PROJECT";
  static const String newProjectSubtitle = "Start a new canvas project on blank ratio";
  static const String quickAiTools = "InShot Pro AI Tools";
  static const String featuredVideoEffects = "Featured InShot VFX Effects";
  static const String trendingPresets = "Trending InShot Presets";

  // AI Creation Tools
  static const String autoVelocityRamping = "Canvas Ratio & Resize";
  static const String backgroundRemover = "Pro Transition Effects";
  static const String aiColorGrading = "Video Speed Control";
  static const String autoCaptionGenerator = "Keyframe Motion Studio";
  static const String multiTrackTimeline = "Audio Mixer & Sound";
  static const String proExport4k = "Export 4K Ultra HD 60FPS";

  // Templates Tab
  static const String templatesTab = "Templates";
  static const String searchTemplates = "Search 1000+ InShot VFX Templates...";
  static const String useTemplate = "Use Template";
  static const List<String> templateCategories = [
    "All", "InShot VFX", "Transitions", "Speed Ramp", "Keyframe 3D", "Slow Mo", "Beat Sync"
  ];

  // Tutorials Tab
  static const String tutorialsTab = "Tutorials";
  static const String aiEditingMasterclass = "InShot Editing Masterclass";
  static const String learnSecretTechniques = "Learn secret video ratio, transition, and speed ramping techniques from top mobile creators.";
  static const String watchTutorial = "Watch Tutorial";
  static const List<String> tutorialCategories = ["All", "Beginner", "Transitions", "Keyframe Motion"];

  // Profile Tab & Settings
  static const String profileTab = "Profile";
  static const String creatorStudioPro = "InShot Creator Studio";
  static const String proMember = "INSHOT PRO MEMBER";
  static const String projectsCreated = "Projects Created";
  static const String assetsDownloaded = "Assets Downloaded";
  static const String aiCredits = "InShot Credits";

  static const String generalSettings = "General Settings";
  static const String exportQualitySettings = "Export Quality Settings";
  static const String hardwareAcceleration = "Hardware Acceleration";
  static const String cloudSync = "Cloud Sync & Backup";
  static const String clearCache = "Clear Cache";

  static const String legalAndSupport = "Legal & Support";
  static const String reportABug = "Report a Bug";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsAndConditions = "Terms & Conditions";
  static const String openSourceLicenses = "Open Source Licenses";
  static const String appVersion = "Version 4.2.2 (Build 803)";

  // Timeline Toolbar Icons & Actions
  static const String split = "Split";
  static const String speed = "Speed";
  static const String volume = "Sound";
  static const String animation = "Animation";
  static const String delete = "Delete";
  static const String adjust = "Adjust";
  static const String filters = "Filters";
  static const String sampleTimecode = "00:00:12 / 00:03:45";

  // Export Screen
  static const String exportTitle = "InShot Export Settings";
  static const String exportButton = "Export Video";
  static const String renderingExport = "Rendering & Initializing Export...";
  static const String exportKeepScreenActive = "Rendering canvas frames. Please keep screen active.";
  static const String exportFailedTitle = "Export Failed";
  static const String exportFailedContent = "Error Code 402 (Device Codec Unsupported). Please try exporting at a lower resolution or clear device storage.";
  static const String ok = "OK";
  static const String tryAgainLater = "Try Again Later";

  static const String resolutionLabel = "Resolution";
  static const String frameRateLabel = "Frame Rate";
  static const String bitrateLabel = "Target Bitrate (Mbps)";
  static const String codecLabel = "Video Codec";
  static const String colorSpaceLabel = "Color Space";
  static const String audioSampleRateLabel = "Audio Sample Rate";

  static const String hdrEncoding = "HDR Video Encoding";
  static const String hardwareEncoding = "Hardware Accelerated Export";
  static const String exportAudioOnly = "Export Audio Only (.MP3)";
  static const String addWatermark = "Include InShot Watermark";
  static const String analyzeTimeline = "Analyze Timeline";
  static const String analyzing = "Analyzing...";

  static const List<String> resolutionOptions = ["720p (HD)", "1080p (Full HD)", "2K (QHD)", "4K (Ultra HD)"];
  static const List<String> frameRateOptions = ["24 fps (Cinematic)", "30 fps (Standard)", "60 fps (Ultra Smooth)"];
  static const List<String> codecOptions = ['H.264 (High Profile)', 'H.265 (HEVC)', 'AV1 (Experimental)'];
  static const List<String> colorSpaceOptions = ['Rec. 709 (SDR)', 'Rec. 2020 (HDR10)', 'DCI-P3 (Cinema)'];
  static const List<String> sampleRateOptions = ['44.1 kHz', '48 kHz', '96 kHz (Hi-Res)'];

  // Guide & Tool Processing
  static const String toolProcessingFailed = "Tool Processing Failed";
  static const String serviceUnavailable = "Service Temporarily Unavailable";
  static const String serverLimitReached = "Server processing limit reached (Error Code 503). Something went wrong while applying engine assets. Please try again later in 10 minutes.";

  // Legal & Privacy Policy Texts
  static const String privacyPolicyText = """
Last updated: August 2026

1. Introduction
Welcome to InShot Video Studio Guide ("we," "our," or "us"). We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

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
By downloading, installing, or using InShot Video Studio Guide, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the application.

2. License & Use
We grant you a limited, non-exclusive, non-transferable, revocable license to use the app for personal, non-commercial video creation and editing purposes in accordance with these Terms.

3. Intellectual Property Rights
All trademarks, logos, app assets, source code, UI designs, and preset templates remain the exclusive property of InShot Video Studio Guide.

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

