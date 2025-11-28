import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'focus_lock_service.g.dart';

@Riverpod(keepAlive: true)
FocusLockService focusLockService(FocusLockServiceRef ref) {
  return FocusLockService();
}

class FocusLockService {
  static const platform = MethodChannel('com.example.study_companion/focus_mode');
  static const String _lastEmergencyExitKey = 'last_emergency_exit_timestamp';

  static const String _isDeepFocusActiveKey = 'is_deep_focus_active';

  Future<void> enableLock() async {
    try {
      await platform.invokeMethod('enableDeepFocus');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDeepFocusActiveKey, true);
    } on PlatformException catch (e) {
      print("Failed to enable focus lock: '${e.message}'.");
    }
  }

  Future<void> disableLock() async {
    try {
      await platform.invokeMethod('disableDeepFocus');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDeepFocusActiveKey, false);
    } on PlatformException catch (e) {
      print("Failed to disable focus lock: '${e.message}'.");
    }
  }

  Future<bool> isDeepFocusActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDeepFocusActiveKey) ?? false;
  }

  Future<bool> isDeviceAdminActive() async {
    try {
      final bool isActive = await platform.invokeMethod('isDeviceAdminActive');
      return isActive;
    } on PlatformException catch (e) {
      print("Failed to check device admin: '${e.message}'.");
      return false;
    }
  }

  Future<void> requestDeviceAdmin() async {
    try {
      await platform.invokeMethod('requestDeviceAdmin');
    } on PlatformException catch (e) {
      print("Failed to request device admin: '${e.message}'.");
    }
  }

  Future<bool> canEmergencyExit() async {
    final prefs = await SharedPreferences.getInstance();
    final lastExit = prefs.getInt(_lastEmergencyExitKey);
    if (lastExit == null) return true;

    final lastExitTime = DateTime.fromMillisecondsSinceEpoch(lastExit);
    final now = DateTime.now();
    return now.difference(lastExitTime).inHours >= 24;
  }

  Future<Duration> timeUntilNextEmergencyExit() async {
    final prefs = await SharedPreferences.getInstance();
    final lastExit = prefs.getInt(_lastEmergencyExitKey);
    if (lastExit == null) return Duration.zero;

    final lastExitTime = DateTime.fromMillisecondsSinceEpoch(lastExit);
    final now = DateTime.now();
    final difference = now.difference(lastExitTime);
    if (difference.inHours >= 24) return Duration.zero;
    
    return const Duration(hours: 24) - difference;
  }

  Future<bool> emergencyExit() async {
    if (await canEmergencyExit()) {
      await disableLock();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastEmergencyExitKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    }
    return false;
  }
}
