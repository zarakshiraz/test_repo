import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('ListSummary', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = ListSummary(
        id: 'list123',
        title: 'Grocery List',
        description: 'Weekly groceries',
        createdByUserId: 'user123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        participants: [
          ListPermission(
            userId: 'user123',
            permission: ListPermissionType.owner,
            grantedAt: DateTime(2024, 1, 1),
            grantedBy: 'user123',
          ),
        ],
        status: ListStatus.active,
        category: 'Groceries',
        totalItems: 10,
        completedItems: 5,
        isSaved: true,
        hasReminder: true,
        metadata: {'custom': 'value'},
      );

      final json = original.toJson();
      final restored = ListSummary.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.description, equals(original.description));
      expect(restored.createdByUserId, equals(original.createdByUserId));
      expect(restored.status, equals(original.status));
      expect(restored.category, equals(original.category));
      expect(restored.totalItems, equals(original.totalItems));
      expect(restored.completedItems, equals(original.completedItems));
      expect(restored.isSaved, equals(original.isSaved));
      expect(restored.hasReminder, equals(original.hasReminder));
      expect(restored.participants.length, equals(original.participants.length));
    });

    test('completionPercentage should calculate correctly', () {
      final list = ListSummary(
        id: 'list123',
        title: 'Test List',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalItems: 10,
        completedItems: 5,
      );

      expect(list.completionPercentage, equals(0.5));
    });

    test('isShared should return true when multiple participants', () {
      final now = DateTime.now();
      final list = ListSummary(
        id: 'list123',
        title: 'Test List',
        createdByUserId: 'user123',
        createdAt: now,
        updatedAt: now,
        participants: [
          ListPermission(
            userId: 'user123',
            permission: ListPermissionType.owner,
            grantedAt: now,
          ),
          ListPermission(
            userId: 'user456',
            permission: ListPermissionType.editor,
            grantedAt: now,
          ),
        ],
      );

      expect(list.isShared, isTrue);
    });
  });
}
