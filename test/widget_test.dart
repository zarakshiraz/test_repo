import 'package:flutter_test/flutter_test.dart';
import 'package:testing_repo/models/app_settings.dart';
import 'package:testing_repo/models/reminder.dart';
import 'package:testing_repo/models/todo_list.dart';

void main() {
  group('AppSettings tests', () {
    test('Quiet hours logic works correctly', () {
      final settings = AppSettings(
        quietHoursEnabled: true,
        quietHoursStartHour: 22,
        quietHoursEndHour: 8,
      );

      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 23, 0)), true);
      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 7, 0)), true);
      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 10, 0)), false);
      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 15, 0)), false);
    });

    test('Quiet hours disabled returns false', () {
      final settings = AppSettings(
        quietHoursEnabled: false,
        quietHoursStartHour: 22,
        quietHoursEndHour: 8,
      );

      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 23, 0)), false);
      expect(settings.isInQuietHours(DateTime(2024, 1, 1, 7, 0)), false);
    });

    test('copyWith works correctly', () {
      final settings = AppSettings(
        quietHoursEnabled: true,
        quietHoursStartHour: 22,
        quietHoursEndHour: 8,
      );

      final updated = settings.copyWith(quietHoursEnabled: false);
      
      expect(updated.quietHoursEnabled, false);
      expect(updated.quietHoursStartHour, 22);
      expect(updated.quietHoursEndHour, 8);
    });
  });

  group('Reminder model tests', () {
    test('Reminder can be created', () {
      final reminder = Reminder(
        id: 'test-id',
        listId: 'list-id',
        title: 'Test Reminder',
        description: 'Test Description',
        scheduledTime: DateTime(2024, 12, 31, 10, 0),
        audience: ReminderAudience.self,
        createdBy: 'user-123',
      );

      expect(reminder.id, 'test-id');
      expect(reminder.title, 'Test Reminder');
      expect(reminder.audience, ReminderAudience.self);
      expect(reminder.isActive, true);
    });

    test('Reminder copyWith works correctly', () {
      final reminder = Reminder(
        id: 'test-id',
        listId: 'list-id',
        title: 'Test Reminder',
        scheduledTime: DateTime(2024, 12, 31, 10, 0),
        audience: ReminderAudience.self,
        createdBy: 'user-123',
      );

      final updated = reminder.copyWith(
        title: 'Updated Title',
        audience: ReminderAudience.allParticipants,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.audience, ReminderAudience.allParticipants);
      expect(updated.id, 'test-id');
      expect(updated.listId, 'list-id');
    });
  });

  group('TodoList model tests', () {
    test('TodoList can be created', () {
      final now = DateTime.now();
      final list = TodoList(
        id: 'list-id',
        name: 'My List',
        ownerId: 'user-123',
        participantIds: ['user-123', 'user-456'],
        createdAt: now,
        updatedAt: now,
      );

      expect(list.id, 'list-id');
      expect(list.name, 'My List');
      expect(list.ownerId, 'user-123');
      expect(list.participantIds.length, 2);
    });

    test('TodoList copyWith works correctly', () {
      final now = DateTime.now();
      final list = TodoList(
        id: 'list-id',
        name: 'My List',
        ownerId: 'user-123',
        participantIds: ['user-123'],
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.copyWith(name: 'Updated List');

      expect(updated.name, 'Updated List');
      expect(updated.id, 'list-id');
      expect(updated.ownerId, 'user-123');
    });
  });
}
