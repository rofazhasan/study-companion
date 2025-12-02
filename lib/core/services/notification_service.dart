import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Global key to access navigator context for navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.startsWith('group:')) {
      final groupId = response.payload!.split(':')[1];
      // Navigate to group chat
      final context = navigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).push('/social/chat/$groupId');
      }
    }
  }

  Future<void> showMessageNotification({
    required String id,
    required String title,
    required String body,
    required String groupId,
  }) async {
    if (!_isEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'message_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    // Use hashcode of ID for integer ID, or random
    await _notificationsPlugin.show(
      id.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: 'group:$groupId',
    );
  }
  // Settings
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  void setEnabled(bool value) {
    _isEnabled = value;
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showTimerNotification({
    required String title,
    required String body,
    DateTime? endTime,
  }) async {
    if (!_isEnabled) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Active timer notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: true,
      usesChronometer: endTime != null,
      when: endTime?.millisecondsSinceEpoch,
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      0, // Timer ID
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
    if (!_isEnabled) return;

    await _notificationsPlugin.zonedSchedule(
      1, // Completion ID
      title,
      body,
      tz.TZDateTime.from(endTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel',
          'Timer',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
    await _notificationsPlugin.cancel(1);
  }

  Future<void> scheduleExamAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isEnabled) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exam_channel',
          'Exams',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
