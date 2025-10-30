import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../repositories/notification_repository.dart';
import '../models/app_notification.dart';
import '../constants/permissions.dart';

class NotificationService {
  final FirebaseMessaging? _messaging;
  final NotificationRepository _notificationRepository;

  NotificationService(
    this._notificationRepository, {
    FirebaseMessaging? messaging,
  }) : _messaging = messaging;

  Future<void> initialize() async {
    final messaging = _messaging;
    if (messaging == null) {
      debugPrint('FCM not initialized - running in test mode');
      return;
    }

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
    });
  }

  Future<void> notifyListShared({
    required String userId,
    required String listTitle,
    required String sharedByName,
    required PermissionRole role,
    required String listId,
  }) async {
    await _notificationRepository.createNotification(
      userId: userId,
      type: NotificationType.listShared,
      title: 'List Shared',
      message: '$sharedByName shared "$listTitle" with you as ${role.displayName}',
      data: {
        'listId': listId,
        'role': role.value,
      },
    );
  }

  Future<void> notifyPermissionChanged({
    required String userId,
    required String listTitle,
    required String changedByName,
    required PermissionRole newRole,
    required String listId,
  }) async {
    await _notificationRepository.createNotification(
      userId: userId,
      type: NotificationType.permissionChanged,
      title: 'Permission Changed',
      message:
          '$changedByName changed your permission for "$listTitle" to ${newRole.displayName}',
      data: {
        'listId': listId,
        'role': newRole.value,
      },
    );
  }

  Future<void> notifyListUpdated({
    required String userId,
    required String listTitle,
    required String updatedByName,
    required String listId,
  }) async {
    await _notificationRepository.createNotification(
      userId: userId,
      type: NotificationType.listUpdated,
      title: 'List Updated',
      message: '$updatedByName made changes to "$listTitle"',
      data: {
        'listId': listId,
      },
    );
  }
}
