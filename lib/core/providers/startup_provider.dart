import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../firebase_options.dart';
import '../../core/data/isar_service.dart';
import '../../core/services/notification_service.dart';

part 'startup_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> startup(StartupRef ref) async {
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
}

Future<void> _requestPermissions() async {
  await [
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.storage,
  ].request();
}


