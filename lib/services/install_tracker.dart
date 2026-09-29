import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks unique application installs in Cloud Firestore.
/// Increments `app_install` count by 1 exactly once per device installation.
/// Does NOT increment on subsequent app opens / reopens.
class InstallTracker {
  static const String _prefKey = 'app_install_tracked';
  static const String _collection = 'app_installs';
  static const String _docId = 'stats';

  /// Call once at app startup (e.g. from main or splash).
  static Future<void> trackInstallOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool alreadyTracked = prefs.getBool(_prefKey) ?? false;

      if (alreadyTracked) {
        debugPrint('[InstallTracker] Install already tracked. Skipping increment on reopen.');
        return;
      }

      debugPrint('[InstallTracker] New install detected! Recording app_install to Firestore...');
      final docRef = FirebaseFirestore.instance.collection(_collection).doc(_docId);

      await docRef.set({
        'app_install': FieldValue.increment(1),
        'last_install_at': FieldValue.serverTimestamp(),
        'package_name': 'com.smart.ai.video.maker.pro',
        'app_name': 'KM : AI Video Editor guide',
      }, SetOptions(merge: true));

      await prefs.setBool(_prefKey, true);
      debugPrint('[InstallTracker] Successfully incremented app_install in Firestore!');
    } catch (e) {
      debugPrint('[InstallTracker] Error recording app install to Firestore: $e');
    }
  }
}
