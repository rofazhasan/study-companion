import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../firebase_options.dart';
import '../../core/data/isar_service.dart';
import '../../core/services/notification_service.dart';
import '../../features/settings/presentation/providers/api_key_provider.dart';

part 'startup_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> startup(StartupRef ref) async {
  // 1. Initialize Firebase
  // 1. Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Ignore duplicate app error if it happens despite the check
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Wait for auth to be ready (restored)
  await FirebaseAuth.instance.authStateChanges().first;

  // 2. Initialize Isar (Local DB)
  final isarService = IsarService();
  await isarService.init();

  // 3. Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // 4. Request Permissions
  await _requestPermissions();

  // 5. Pre-fetch API Key (Optimize AI Init)
  // This ensures the key is loaded and cached before the user reaches the UI
  await ref.read(apiKeyProvider.future);
}

Future<void> _requestPermissions() async {
  await [
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.storage,
  ].request();
}


