import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../models/app_notification.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final String userId;
  final _uuid = const Uuid();

  List<AppNotification> _notifications = [];
  bool _isInitialized = false;
  String? _errorMessage;

  NotificationProvider({
    required this.userId,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin() {
    _initialize();
  }

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    try {
      // Initialize local notifications
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
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permission for push notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          // Save token to Firestore
          await _firestore.collection('users').doc(userId).update({
            'fcmToken': token,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }

        // Listen to foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Listen to background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      }

      // Listen to user's notifications from Firestore
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(_onNotificationsChanged);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize notifications: $e';
      notifyListeners();
    }
  }

  void _onNotificationsChanged(QuerySnapshot snapshot) {
    _notifications = snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'New notification',
      body: message.notification?.body ?? '',
      payload: message.data['listId'],
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle notification tap when app is in background
    debugPrint('Background message: ${message.data}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'grocli_channel',
      'Grocli Notifications',
      channelDescription: 'Notifications for Grocli app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<bool> scheduleReminder({
    required String listId,
    required String listTitle,
    required DateTime scheduledTime,
    bool notifyAll = false,
  }) async {
    try {
      final notificationId = _uuid.v4();

      // Schedule local notification
      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'grocli_reminders',
        'Grocli Reminders',
        channelDescription: 'Reminders for lists',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        notificationId.hashCode,
        'Reminder: $listTitle',
        'Don\'t forget about your list!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: listId,
      );

      // Save reminder info to list
      await _firestore.collection('lists').doc(listId).update({
        'reminderTime': scheduledTime.toIso8601String(),
        'remindEveryone': notifyAll,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to schedule reminder: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReminder(String listId) async {
    try {
      // Cancel local notification
      await _localNotifications.cancel(listId.hashCode);

      // Remove reminder from list
      await _firestore.collection('lists').doc(listId).update({
        'reminderTime': null,
        'remindEveryone': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel reminder: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createNotification({
    required NotificationType type,
    required String title,
    required String body,
    String? listId,
    String? fromUserId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _uuid.v4();
      final notification = AppNotification(
        id: notificationId,
        userId: userId,
        type: type,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        listId: listId,
        fromUserId: fromUserId,
        data: data,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create notification: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      
      for (final notification in unreadNotifications) {
        batch.update(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notification.id),
          {'isRead': true},
        );
      }

      await batch.commit();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark all as read: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete notification: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
