import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocli/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('RegisterPage displays all required elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Grocli and start collaborating'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('Create Account'), findsNWidgets(2));
  });

  testWidgets('RegisterPage validates all required fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('RegisterPage validates password match', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');

    final emailField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'test@example.com');

    final passwordField = find.byType(TextFormField).at(3);
    await tester.enterText(passwordField, 'password123');

    final confirmPasswordField = find.byType(TextFormField).at(4);
    await tester.enterText(confirmPasswordField, 'different');

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('RegisterPage validates name length', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    final nameField = find.byType(TextFormField).first;
    await tester.enterText(nameField, 'A');

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
  });

  testWidgets('RegisterPage shows error when terms not accepted', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');

    final emailField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'test@example.com');

    final passwordField = find.byType(TextFormField).at(3);
    await tester.enterText(passwordField, 'password123');

    final confirmPasswordField = find.byType(TextFormField).at(4);
    await tester.enterText(confirmPasswordField, 'password123');

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Please accept the terms and conditions'), findsOneWidget);
  });

  testWidgets('RegisterPage allows checkbox to be checked', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    final checkbox = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkbox).value, false);

    await tester.tap(checkbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(checkbox).value, true);
  });
}
