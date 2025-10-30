import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:testing_repo/main.dart';

void main() {
  Future<void> openProductLaunchList(WidgetTester tester) async {
    await tester.tap(find.text('Product Launch Checklist'));
    await tester.pumpAndSettle();
  }

  testWidgets('allows reordering checklist items and updates order state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ListManagementApp());
    await tester.pumpAndSettle();

    await openProductLaunchList(tester);

    expect(find.byType(ReorderableDragStartListener), findsWidgets);
    final Finder dragHandle = find.byType(ReorderableDragStartListener).first;

    await tester.drag(dragHandle, const Offset(0, 200));
    await tester.pumpAndSettle();

    final ListManagementAppState appState = tester
        .state<ListManagementAppState>(find.byType(ListManagementApp));
    final TaskList list = appState.activeLists.firstWhere(
      (TaskList element) => element.id == 'list-product',
    );

    expect(list.items.map((ChecklistItem item) => item.id).toList(), <String>[
      'update-website',
      'design-assets',
      'coordinate-marketing',
    ]);
  });

  testWidgets('completing an item records metadata and strikes through text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ListManagementApp());
    await tester.pumpAndSettle();

    await openProductLaunchList(tester);

    final Finder checkbox = find.byKey(
      const Key('checklist-checkbox-design-assets'),
    );
    expect(checkbox, findsOneWidget);

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(find.textContaining('Checked by Alex Johnson'), findsOneWidget);

    final ListManagementAppState appState = tester
        .state<ListManagementAppState>(find.byType(ListManagementApp));
    final TaskList list = appState.activeLists.firstWhere(
      (TaskList element) => element.id == 'list-product',
    );
    final ChecklistItem item = list.items.firstWhere(
      (ChecklistItem element) => element.id == 'design-assets',
    );

    expect(item.isComplete, isTrue);
    expect(item.lastEditedBy, 'Alex Johnson');
    expect(item.lastEditedAt, isNotNull);
  });

  testWidgets('completing a list moves it to the archive and clears chat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ListManagementApp());
    await tester.pumpAndSettle();

    await openProductLaunchList(tester);

    await tester.tap(find.byKey(const Key('complete-list-button')));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(ListDetailScreen), findsNothing);

    final ListManagementAppState appState = tester
        .state<ListManagementAppState>(find.byType(ListManagementApp));
    expect(
      appState.activeLists.any(
        (TaskList element) => element.id == 'list-product',
      ),
      isFalse,
    );

    final TaskList archived = appState.archivedLists.firstWhere(
      (TaskList element) => element.id == 'list-product',
    );
    expect(archived.chatMessages, isEmpty);

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Product Launch Checklist'), findsWidgets);
  });
}
