import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'link_handler.dart';

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

  Future<bool> _showExitDialog() async {
    return await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Exit CC : AI Video Editor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit the app?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              // Open CCT on exit tap if URL is ready
              LinkHandler.showNext();
            },
            child: const Text("Exit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    // 1. If CCT is currently open, block back button
    if (LinkHandler.isOpen.value) {
      return true;
    }

    // 2. If no URLs configured, let Android handle normally
    if (LinkHandler.urls.isEmpty) {
      return false;
    }

    // 3. Are we at root screen?
    bool isRoot = !(navigatorKey.currentState?.canPop() ?? false);
    if (!isRoot) {
      return false;
    }

    // 4. At root with stealth active — 3-step exit flow
    _backPressCount++;
    if (_backPressCount == 1) {
      LinkHandler.showNext(); // Show CCT on first back press
      Fluttertoast.showToast(msg: "Press back 2 more times to exit app", backgroundColor: Colors.black87, textColor: Colors.white);
      return true;
    } else if (_backPressCount == 2) {
      Fluttertoast.showToast(msg: "Press back 1 more time to exit app", backgroundColor: Colors.black87, textColor: Colors.white);
      return true;
    } else {
      await _showExitDialog();
      _backPressCount = 0;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CC : AI Video Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1E1E1E),
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
