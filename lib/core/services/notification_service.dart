import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/material.dart';
part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    print('NotificationService: Initialized. Local timezone: ${tz.local.name}');
    
    // Load preference
    // Note: In a real app, we might inject SharedPreferences or use a provider.
    // For simplicity, we'll assume enabled by default or check prefs here if possible.
    // But since this is a service, let's add a method to set enabled state.
  }

  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  Future<void> requestPermissions() async {
    final fln.AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showTimerNotification({
    required String title,
    required String body,
    DateTime? endTime,
  }) async {
    if (!_isEnabled) return;

    final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Shows active timer status',
      importance: fln.Importance.low,
      priority: fln.Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: endTime != null,
      chronometerCountDown: endTime != null,
      when: endTime?.millisecondsSinceEpoch,
      color: Colors.deepPurple,
      subText: 'Stay Focused',
      icon: 'ic_notification', // Use custom notification icon
    );

    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleCompletionNotification({
    required String title,
    required String body,
    required DateTime endTime,
  }) async {
    print('NotificationService: Scheduling completion notification for $endTime');
    final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'timer_completion_channel',
      'Timer Completion',
      channelDescription: 'Notifies when timer finishes',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      playSound: true,
      enableVibration: true,
      color: Colors.deepPurple,
      icon: 'ic_notification',
    );

    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      1, // Different ID for completion notification
      title,
      body,
      tz.TZDateTime.from(endTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleExamAlarm({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('NotificationService: Scheduling exam alarm for $scheduledDate');
    
    // Create a unique ID based on time to allow multiple alarms
    final id = (scheduledDate.millisecondsSinceEpoch / 1000).round().remainder(100000);

    final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'exam_alarm_channel',
      'Exam Alarms',
      channelDescription: 'Alarms for upcoming exams',
      importance: fln.Importance.max,
      priority: fln.Priority.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: fln.AudioAttributesUsage.alarm,
      color: Colors.red,
      icon: 'ic_notification',
      fullScreenIntent: true, // Show even if locked
    );

    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
    await _notificationsPlugin.cancel(1); // Cancel scheduled completion too
  }
}
