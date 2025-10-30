import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('ListItem', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = ListItem(
        id: 'item123',
        listId: 'list123',
        content: 'Milk',
        state: ItemState.completed,
        completedByUserId: 'user123',
        completedAt: DateTime(2024, 1, 3),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        createdByUserId: 'user123',
        order: 1,
        notes: 'Whole milk',
        category: 'Dairy',
        quantity: 2.0,
        unit: 'gallons',
        metadata: {'store': 'Trader Joe\'s'},
      );

      final json = original.toJson();
      final restored = ListItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.listId, equals(original.listId));
      expect(restored.content, equals(original.content));
      expect(restored.state, equals(original.state));
      expect(restored.completedByUserId, equals(original.completedByUserId));
      expect(restored.order, equals(original.order));
      expect(restored.notes, equals(original.notes));
      expect(restored.category, equals(original.category));
      expect(restored.quantity, equals(original.quantity));
      expect(restored.unit, equals(original.unit));
      expect(restored.metadata, equals(original.metadata));
    });

    test('state helpers should work correctly', () {
      final pendingItem = ListItem(
        id: 'item123',
        listId: 'list123',
        content: 'Milk',
        state: ItemState.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdByUserId: 'user123',
      );

      expect(pendingItem.isPending, isTrue);
      expect(pendingItem.isCompleted, isFalse);
      expect(pendingItem.isCancelled, isFalse);

      final completedItem = pendingItem.copyWith(state: ItemState.completed);
      expect(completedItem.isCompleted, isTrue);
      expect(completedItem.isPending, isFalse);
    });
  });
}
