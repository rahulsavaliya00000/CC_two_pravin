import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppLauncherHelper {
  static const MethodChannel _channel = MethodChannel('com.smart.ai.video.maker.pro/app_launcher');
  static const String targetPackage = 'com.free.video.view';

  /// Checks if target app is installed on the Android device
  static Future<bool> isTargetAppInstalled() async {
    try {
      final bool isInstalled = await _channel.invokeMethod('isAppInstalled', {
        'packageName': targetPackage,
      }) ?? false;
      debugPrint('[AppLauncher] Is $targetPackage installed? $isInstalled');
      return isInstalled;
    } catch (e) {
      debugPrint('[AppLauncher] Error checking if app is installed: $e');
      return false;
    }
  }

  static bool _isOpening = false;

  /// Opens the target app if installed (debounced against rapid repeated taps)
  static Future<bool> openTargetApp() async {
    if (_isOpening) {
      debugPrint('[AppLauncher] Target app is already being opened — ignoring rapid tap');
      return false;
    }
    _isOpening = true;
    try {
      final bool opened = await _channel.invokeMethod('openApp', {
        'packageName': targetPackage,
      }) ?? false;
      debugPrint('[AppLauncher] Opened $targetPackage: $opened');
      return opened;
    } catch (e) {
      debugPrint('[AppLauncher] Error opening app: $e');
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isOpening = false;
      });
    }
  }
}
