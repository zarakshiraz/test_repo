import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    const app = MaterialApp(
      home: Scaffold(
        appBar: null,
        body: Center(
          child: Text('Test App'),
        ),
      ),
    );

    await tester.pumpWidget(app);

    expect(find.text('Test App'), findsOneWidget);
  });
}
