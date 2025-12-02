import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_companion/core/services/notification_service.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notifications
  await NotificationService().init();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runZonedGuarded(() async {
    runApp(
      const ProviderScope(
        child: StudyCompanionApp(),
      ),
    );
  }, (error, stack) {
    print('CRITICAL: Unhandled Exception: $error');
    print('Stack Trace: $stack');
  });
}
