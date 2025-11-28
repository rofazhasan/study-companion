import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/data/isar_service.dart';
import 'core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final isarService = IsarService();
  await isarService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // Request permissions
  await _requestPermissions();
  
  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const StudyCompanionApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.storage, // For older Android versions if needed
  ].request();
}
