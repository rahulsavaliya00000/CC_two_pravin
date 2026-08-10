import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'link_handler.dart';
import 'config/app_config.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[MAIN] WidgetsFlutterBinding initialized');
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('[MAIN] Screen orientation locked to portrait');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[MAIN] Firebase initialized');
  } catch (e) {
    debugPrint('[MAIN] Firebase init FAILED: $e');
  }
  
  // Load URLs from defaults BEFORE runApp — instant, no network needed
  try {
    await LinkHandler.initDefaults();
    debugPrint('[MAIN] initDefaults done. urls=${LinkHandler.urls}');
  } catch (e) {
    debugPrint('[MAIN] initDefaults FAILED: $e');
  }

  bool hasSeenOnboarding = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    debugPrint('[MAIN] hasSeenOnboarding=$hasSeenOnboarding');
  } catch (e) {
    debugPrint('[MAIN] SharedPreferences FAILED: $e');
  }
  
  debugPrint('[MAIN] >>> Calling runApp() NOW <<<');
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));

  // Background fetch from Firebase AFTER UI is rendering
  LinkHandler.backgroundFetch();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

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
        title: const Text(AppStrings.exitDialogTitle, style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        content: const Text(AppStrings.exitDialogContent, style: TextStyle(color: AppColors.textWhite70)),
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
    // 1. If CCT is currently open, block back button
    if (LinkHandler.isOpen.value) {
      return true;
    }

    // 2. Count back presses and show exit dialog on the 3rd press
    _backPressCount++;
    if (_backPressCount >= 3) {
      _backPressCount = 0;
      _showExitDialog();
    }

    // 3. Always return true to block the default back event/pop/exit behavior completely
    return true;
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
