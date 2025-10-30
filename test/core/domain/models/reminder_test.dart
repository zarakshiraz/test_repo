import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('Reminder', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = Reminder(
        id: 'reminder123',
        listId: 'list123',
        listTitle: 'Grocery List',
        createdByUserId: 'user123',
        reminderTime: DateTime(2024, 12, 31, 10, 0),
        scope: ReminderScope.allParticipants,
        targetUserIds: ['user123', 'user456'],
        message: 'Don\'t forget to bring reusable bags!',
        isRecurring: true,
        recurringPattern: 'weekly',
        createdAt: DateTime(2024, 1, 1),
        isSent: false,
        isCancelled: false,
        metadata: {'source': 'app'},
      );

      final json = original.toJson();
      final restored = Reminder.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.listId, equals(original.listId));
      expect(restored.listTitle, equals(original.listTitle));
      expect(restored.createdByUserId, equals(original.createdByUserId));
      expect(restored.scope, equals(original.scope));
      expect(restored.targetUserIds, equals(original.targetUserIds));
      expect(restored.message, equals(original.message));
      expect(restored.isRecurring, equals(original.isRecurring));
      expect(restored.recurringPattern, equals(original.recurringPattern));
      expect(restored.isSent, equals(original.isSent));
      expect(restored.isCancelled, equals(original.isCancelled));
    });

    test('scope helpers should work correctly', () {
      final personalReminder = Reminder(
        id: 'reminder123',
        listId: 'list123',
        createdByUserId: 'user123',
        reminderTime: DateTime.now().add(const Duration(hours: 1)),
        scope: ReminderScope.onlyMe,
        createdAt: DateTime.now(),
      );

      expect(personalReminder.isPersonal, isTrue);
      expect(personalReminder.isShared, isFalse);

      final sharedReminder = personalReminder.copyWith(
        scope: ReminderScope.allParticipants,
      );

      expect(sharedReminder.isPersonal, isFalse);
      expect(sharedReminder.isShared, isTrue);
    });

    test('isPending should return correct value', () {
      final pendingReminder = Reminder(
        id: 'reminder123',
        listId: 'list123',
        createdByUserId: 'user123',
        reminderTime: DateTime.now().add(const Duration(hours: 1)),
        scope: ReminderScope.onlyMe,
        createdAt: DateTime.now(),
        isSent: false,
        isCancelled: false,
      );

      expect(pendingReminder.isPending, isTrue);

      final sentReminder = pendingReminder.copyWith(isSent: true);
      expect(sentReminder.isPending, isFalse);
    });
  });
}
