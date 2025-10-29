import 'package:flutter_test/flutter_test.dart';

import 'package:testing_repo/main.dart';

void main() {
  testWidgets('App loads with onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GrocliApp());

    expect(find.text('Welcome to Grocli'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('Can navigate through onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const GrocliApp());

    expect(find.text('Welcome to Grocli'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    expect(find.text('AI-Powered Suggestions'), findsOneWidget);
  });

  testWidgets('Can skip onboarding to home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GrocliApp());

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    expect(find.text('Grocli'), findsOneWidget);
    expect(find.text('Shopping Progress'), findsOneWidget);
  });

  testWidgets('Complete onboarding shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GrocliApp());

    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text(i < 3 ? 'NEXT' : 'GET STARTED'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Grocli'), findsOneWidget);
  });
}
