import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocli/main.dart';

void main() {
  testWidgets('GrocliApp initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GrocliApp()));
    
    await tester.pumpAndSettle();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
