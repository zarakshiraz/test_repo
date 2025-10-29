import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import 'notification_service.dart';

class RemindersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();

  Stream<List<Reminder>> getRemindersForList(String listId) {
    return _firestore
        .collection('reminders')
        .where('listId', isEqualTo: listId)
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reminder.fromMap(doc.data()))
            .toList());
  }

  Future<void> createReminder({
    required String listId,
    required String title,
    String? description,
    required DateTime scheduledTime,
    required ReminderAudience audience,
    required String userId,
  }) async {
    final reminderId = _uuid.v4();
    
    final reminder = Reminder(
      id: reminderId,
      listId: listId,
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      audience: audience,
      createdBy: userId,
    );

    await _firestore
        .collection('reminders')
        .doc(reminderId)
        .set(reminder.toMap());

    await _notificationService.scheduleLocalNotification(
      id: reminderId,
      title: title,
      body: description ?? 'Reminder for list',
      scheduledTime: scheduledTime,
      listId: listId,
    );
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());

    await _notificationService.cancelNotification(reminder.id);
    
    if (reminder.isActive) {
      await _notificationService.scheduleLocalNotification(
        id: reminder.id,
        title: reminder.title,
        body: reminder.description ?? 'Reminder for list',
        scheduledTime: reminder.scheduledTime,
        listId: reminder.listId,
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    await _firestore
        .collection('reminders')
        .doc(reminderId)
        .update({'isActive': false});

    await _notificationService.cancelNotification(reminderId);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _firestore
        .collection('reminders')
        .doc(reminderId)
        .delete();

    await _notificationService.cancelNotification(reminderId);
  }

  Future<Reminder?> getReminder(String reminderId) async {
    final doc = await _firestore
        .collection('reminders')
        .doc(reminderId)
        .get();

    if (!doc.exists) return null;
    return Reminder.fromMap(doc.data()!);
  }
}
