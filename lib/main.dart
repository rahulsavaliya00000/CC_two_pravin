import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'link_handler.dart';
import 'config/app_config.dart';
import 'services/ad_manager.dart';
import 'services/install_tracker.dart';


void main() { 
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[MAIN] WidgetsFlutterBinding initialized - launching UI immediately');
  
  // Call runApp immediately so Flutter draws the first frame instantly (0 black screen delay!)
  runApp(const MyApp());

  // Lock orientation in background
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize background services in parallel
  _initServices();
}

Future<void> _initServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[MAIN] Firebase initialized');
    // Track unique app install in Firestore exactly once per device
    InstallTracker.trackInstallOnce();
  } catch (e) {
    debugPrint('[MAIN] Firebase init: $e');
  }

  // Pre-initialize AdMob early so ads are loaded
  AdManager.initialize();
  
  try {
    await LinkHandler.initDefaults();
    debugPrint('[MAIN] initDefaults done. urls=${LinkHandler.urls}');
  } catch (e) {
    debugPrint('[MAIN] initDefaults: $e');
  }

  LinkHandler.backgroundFetch();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, this.hasSeenOnboarding = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _backPressCount = 0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  Future<void> _showExitDialog() async {
    await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.exitDialogTitle, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        content: Text(AppStrings.exitDialogContent, style: const TextStyle(color: AppColors.textWhite70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textWhite54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // Do nothing else here! Just close the dialog.
            },
            child: const Text(AppStrings.exit, style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool> myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    // 1. If there are sub-screens, a dialog, or a webview open, let Flutter handle pop normally
    bool canPop = navigatorKey.currentState?.canPop() ?? false;
    if (canPop) {
      return false; // Back button will close the dialog/webview or navigate back to the previous screen
    }

    // 2. We are on the root screen (HomeScreen/OnboardingScreen) and no dialog is open.
    // Intercept back gesture, count presses, and show the exit dialog on the 3rd press.
    _backPressCount++;
    if (_backPressCount >= 3) {
      _backPressCount = 0;
      _showExitDialog();
    }

    return true; // Return true to block the default back button/gesture pop behavior
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.textWhite,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.textWhite,
          secondary: AppColors.primaryCyan,
          surface: AppColors.cardBackground,
        ),
        fontFamily: 'Roboto',
      ),
      home: PopScope(
        canPop: false,
        child: SplashScreen(hasSeenOnboarding: widget.hasSeenOnboarding),
      ),
    );
  }
}
