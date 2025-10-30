import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/features/lists/models/provisional_item.dart';

void main() {
  group('ProvisionalItem Model Tests', () {
    test('should create a provisional item with manual source', () {
      final item = ProvisionalItem(
        id: '1',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      );

      expect(item.id, '1');
      expect(item.content, 'Milk');
      expect(item.source, ItemSource.manual);
      expect(item.order, 0);
      expect(item.notes, null);
    });

    test('should create a provisional item with AI-suggested source', () {
      final item = ProvisionalItem(
        id: '2',
        content: 'Bread',
        source: ItemSource.aiSuggested,
        order: 1,
        notes: 'Suggested by AI',
      );

      expect(item.id, '2');
      expect(item.content, 'Bread');
      expect(item.source, ItemSource.aiSuggested);
      expect(item.order, 1);
      expect(item.notes, 'Suggested by AI');
    });

    test('should create a copy with updated values', () {
      final item = ProvisionalItem(
        id: '1',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      );

      final updatedItem = item.copyWith(
        content: 'Almond Milk',
        order: 5,
      );

      expect(updatedItem.id, '1');
      expect(updatedItem.content, 'Almond Milk');
      expect(updatedItem.source, ItemSource.manual);
      expect(updatedItem.order, 5);
    });

    test('should support equality comparison', () {
      final item1 = ProvisionalItem(
        id: '1',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      );

      final item2 = ProvisionalItem(
        id: '1',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      );

      final item3 = ProvisionalItem(
        id: '2',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });
  });

  group('CreateListPage Form Validation Tests', () {
    testWidgets('Empty title should show validation error', (tester) async {
      final formKey = GlobalKey<FormState>();
      final titleController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('Valid title should pass validation', (tester) async {
      final formKey = GlobalKey<FormState>();
      final titleController = TextEditingController(text: 'My List');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, true);
      expect(find.text('Please enter a title'), findsNothing);
    });
  });

  group('Item List Management Logic Tests', () {
    test('should add items to list', () {
      final List<ProvisionalItem> items = [];

      items.add(ProvisionalItem(
        id: '1',
        content: 'Milk',
        source: ItemSource.manual,
        order: 0,
      ));

      items.add(ProvisionalItem(
        id: '2',
        content: 'Bread',
        source: ItemSource.aiSuggested,
        order: 1,
      ));

      expect(items.length, 2);
      expect(items[0].content, 'Milk');
      expect(items[1].content, 'Bread');
      expect(items[0].source, ItemSource.manual);
      expect(items[1].source, ItemSource.aiSuggested);
    });

    test('should remove items from list', () {
      final List<ProvisionalItem> items = [
        ProvisionalItem(
          id: '1',
          content: 'Milk',
          source: ItemSource.manual,
          order: 0,
        ),
        ProvisionalItem(
          id: '2',
          content: 'Bread',
          source: ItemSource.manual,
          order: 1,
        ),
      ];

      items.removeWhere((item) => item.id == '1');

      expect(items.length, 1);
      expect(items[0].id, '2');
      expect(items[0].content, 'Bread');
    });

    test('should update item content', () {
      final List<ProvisionalItem> items = [
        ProvisionalItem(
          id: '1',
          content: 'Milk',
          source: ItemSource.manual,
          order: 0,
        ),
      ];

      final index = items.indexWhere((item) => item.id == '1');
      items[index] = items[index].copyWith(content: 'Almond Milk');

      expect(items[0].content, 'Almond Milk');
      expect(items[0].id, '1');
    });

    test('should reorder items', () {
      final List<ProvisionalItem> items = [
        ProvisionalItem(
          id: '1',
          content: 'First',
          source: ItemSource.manual,
          order: 0,
        ),
        ProvisionalItem(
          id: '2',
          content: 'Second',
          source: ItemSource.manual,
          order: 1,
        ),
        ProvisionalItem(
          id: '3',
          content: 'Third',
          source: ItemSource.manual,
          order: 2,
        ),
      ];

      // Move first item to end
      final item = items.removeAt(0);
      items.insert(2, item);

      // Update orders
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(order: i);
      }

      expect(items[0].content, 'Second');
      expect(items[1].content, 'Third');
      expect(items[2].content, 'First');
      expect(items[0].order, 0);
      expect(items[1].order, 1);
      expect(items[2].order, 2);
    });

    test('should parse comma-separated text into items', () {
      const text = 'Milk, Bread, Eggs';
      final itemTexts = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      expect(itemTexts.length, 3);
      expect(itemTexts[0], 'Milk');
      expect(itemTexts[1], 'Bread');
      expect(itemTexts[2], 'Eggs');
    });

    test('should handle empty strings when parsing', () {
      const text = 'Milk,  , Bread,   ';
      final itemTexts = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      expect(itemTexts.length, 2);
      expect(itemTexts[0], 'Milk');
      expect(itemTexts[1], 'Bread');
    });

    test('should distinguish between manual and AI-suggested items', () {
      final items = [
        ProvisionalItem(
          id: '1',
          content: 'Manual Item',
          source: ItemSource.manual,
          order: 0,
        ),
        ProvisionalItem(
          id: '2',
          content: 'AI Item',
          source: ItemSource.aiSuggested,
          order: 1,
        ),
      ];

      final manualItems = items.where((i) => i.source == ItemSource.manual).toList();
      final aiItems = items.where((i) => i.source == ItemSource.aiSuggested).toList();

      expect(manualItems.length, 1);
      expect(aiItems.length, 1);
      expect(manualItems[0].content, 'Manual Item');
      expect(aiItems[0].content, 'AI Item');
    });
  });

  group('List Creation Validation Tests', () {
    test('should require at least one item', () {
      final items = <ProvisionalItem>[];
      final hasItems = items.isNotEmpty;

      expect(hasItems, false);
    });

    test('should allow creation with items', () {
      final items = [
        ProvisionalItem(
          id: '1',
          content: 'Milk',
          source: ItemSource.manual,
          order: 0,
        ),
      ];
      final hasItems = items.isNotEmpty;

      expect(hasItems, true);
    });

    test('should extract item contents for saving', () {
      final items = [
        ProvisionalItem(
          id: '1',
          content: 'Milk',
          source: ItemSource.manual,
          order: 0,
        ),
        ProvisionalItem(
          id: '2',
          content: 'Bread',
          source: ItemSource.aiSuggested,
          order: 1,
        ),
      ];

      final contents = items.map((item) => item.content).toList();

      expect(contents.length, 2);
      expect(contents[0], 'Milk');
      expect(contents[1], 'Bread');
    });
  });
}
