import '../models/reminder.dart';

/// Repository interface for reminder operations.
abstract class ReminderRepository {
  // Reminder CRUD operations
  Future<Reminder> createReminder(Reminder reminder);
  Future<Reminder?> getReminder(String reminderId);
  Future<void> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String reminderId);

  // Reminder queries
  Future<List<Reminder>> getListReminders(String listId);
  Future<List<Reminder>> getUserReminders(String userId);
  Future<List<Reminder>> getPendingReminders({DateTime? before});
  Future<List<Reminder>> getActiveReminders();
  Stream<List<Reminder>> watchListReminders(String listId);
  Stream<List<Reminder>> watchUserReminders(String userId);

  // Reminder operations
  Future<void> cancelReminder(String reminderId);
  Future<void> markAsSent(String reminderId);
  Future<void> snoozeReminder(String reminderId, Duration duration);

  // Reminder scheduling
  Future<void> scheduleLocalNotification(Reminder reminder);
  Future<void> cancelLocalNotification(String reminderId);
  Future<void> rescheduleReminder(String reminderId, DateTime newTime);

  // Recurring reminders
  Future<Reminder> createRecurringReminder(
    Reminder reminder,
    String pattern,
  );
  Future<void> updateRecurringPattern(String reminderId, String pattern);

  // Bulk operations
  Future<void> cancelAllListReminders(String listId);
  Future<List<Reminder>> getDueReminders();

  // Offline support placeholders
  Future<void> syncPendingChanges();
  Future<bool> hasPendingChanges();
}
