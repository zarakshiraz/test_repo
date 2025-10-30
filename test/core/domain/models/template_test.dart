import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('Template', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = Template(
        id: 'template123',
        name: 'Weekly Groceries',
        description: 'Standard weekly grocery list',
        createdByUserId: 'user123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        items: [
          const TemplateItem(
            content: 'Milk',
            category: 'Dairy',
            quantity: 1.0,
            unit: 'gallon',
            order: 0,
          ),
          const TemplateItem(
            content: 'Bread',
            category: 'Bakery',
            quantity: 2.0,
            unit: 'loaves',
            order: 1,
          ),
        ],
        category: 'Groceries',
        isPublic: true,
        usageCount: 42,
        tags: ['grocery', 'weekly'],
        metadata: {'version': '1.0'},
      );

      final json = original.toJson();
      final restored = Template.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.description, equals(original.description));
      expect(restored.createdByUserId, equals(original.createdByUserId));
      expect(restored.items.length, equals(original.items.length));
      expect(restored.category, equals(original.category));
      expect(restored.isPublic, equals(original.isPublic));
      expect(restored.usageCount, equals(original.usageCount));
      expect(restored.tags, equals(original.tags));
    });

    test('itemCount should return correct number of items', () {
      final template = Template(
        id: 'template123',
        name: 'Test Template',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [
          const TemplateItem(content: 'Item 1', order: 0),
          const TemplateItem(content: 'Item 2', order: 1),
          const TemplateItem(content: 'Item 3', order: 2),
        ],
      );

      expect(template.itemCount, equals(3));
    });
  });
}
