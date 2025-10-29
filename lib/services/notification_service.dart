import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/app_settings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  AppSettings? _settings;
  Function(String)? _onNotificationTap;

  Future<void> initialize({
    required Function(String listId) onNotificationTap,
    AppSettings? settings,
  }) async {
    _onNotificationTap = onNotificationTap;
    _settings = settings;

    tz.initializeTimeZones();

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final listId = message.data['listId'];
    if (listId != null && !_isInQuietHours()) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Reminder',
        body: message.notification?.body ?? '',
        listId: listId,
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    final listId = message.data['listId'];
    if (listId != null) {
      _onNotificationTap?.call(listId);
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    final listId = response.payload;
    if (listId != null) {
      _onNotificationTap?.call(listId);
    }
  }

  bool _isInQuietHours() {
    return _settings?.isInQuietHours(DateTime.now()) ?? false;
  }

  Future<void> scheduleLocalNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String listId,
  }) async {
    if (_isInQuietHours()) {
      final adjustedTime = _adjustForQuietHours(scheduledTime);
      if (adjustedTime != scheduledTime) {
        scheduledTime = adjustedTime;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: listId,
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String listId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: listId,
    );
  }

  DateTime _adjustForQuietHours(DateTime scheduledTime) {
    if (_settings == null || !_settings!.quietHoursEnabled) {
      return scheduledTime;
    }

    if (_settings!.isInQuietHours(scheduledTime)) {
      final endHour = _settings!.quietHoursEndHour;
      return DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        endHour,
        0,
      );
    }

    return scheduledTime;
  }

  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancel(id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  void updateSettings(AppSettings settings) {
    _settings = settings;
  }
}
