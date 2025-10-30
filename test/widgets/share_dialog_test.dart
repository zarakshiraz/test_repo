import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_repo/widgets/share_dialog.dart';
import 'package:testing_repo/models/contact.dart';
import 'package:testing_repo/models/participant.dart';
import 'package:testing_repo/constants/permissions.dart';

void main() {
  group('ShareDialog Widget Tests', () {
    final contacts = [
      const Contact(id: 'user2', name: 'User 2', email: 'user2@test.com'),
      const Contact(id: 'user3', name: 'User 3', email: 'user3@test.com'),
      const Contact(id: 'user4', name: 'User 4', email: 'user4@test.com'),
    ];

    testWidgets('displays share dialog with contacts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Share List'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('User 3'), findsOneWidget);
      expect(find.text('User 4'), findsOneWidget);
    });

    testWidgets('allows selecting contacts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (_) {},
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      expect(find.byType(DropdownButton<PermissionRole>), findsOneWidget);
    });

    testWidgets('allows changing permission role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (_) {},
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      final dropdown = find.byType(DropdownButton<PermissionRole>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final editorOption = find.text('Can Edit').last;
      await tester.tap(editorOption);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<PermissionRole>), findsOneWidget);
    });

    testWidgets('share button is disabled when no contacts selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (_) {},
            ),
          ),
        ),
      );

      final shareButton = find.widgetWithText(ElevatedButton, 'Share');
      expect(shareButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(shareButton);
      expect(button.onPressed, null);
    });

    testWidgets('share button is enabled when contacts selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (_) {},
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      final shareButton = find.widgetWithText(ElevatedButton, 'Share');
      final button = tester.widget<ElevatedButton>(shareButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onShare with selected participants', (tester) async {
      List<Participant>? sharedParticipants;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: const [],
              onShare: (participants) {
                sharedParticipants = participants;
              },
            ),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      final shareButton = find.widgetWithText(ElevatedButton, 'Share');
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      expect(sharedParticipants, isNotNull);
      expect(sharedParticipants!.length, 1);
      expect(sharedParticipants!.first.userId, 'user2');
      expect(sharedParticipants!.first.role, PermissionRole.viewer);
    });

    testWidgets('excludes current participants from list', (tester) async {
      final currentParticipants = [
        Participant(
          userId: 'user2',
          userName: 'User 2',
          userEmail: 'user2@test.com',
          role: PermissionRole.editor,
          addedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: currentParticipants,
              onShare: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('User 2'), findsNothing);
      expect(find.text('User 3'), findsOneWidget);
      expect(find.text('User 4'), findsOneWidget);
    });

    testWidgets('shows message when no contacts available', (tester) async {
      final currentParticipants = contacts
          .map((c) => Participant(
                userId: c.id,
                userName: c.name,
                userEmail: c.email,
                role: PermissionRole.editor,
                addedAt: DateTime.now(),
              ))
          .toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareDialog(
              contacts: contacts,
              currentParticipants: currentParticipants,
              onShare: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No contacts available to share with'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ShareDialog(
                      contacts: contacts,
                      currentParticipants: const [],
                      onShare: (_) {},
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Share List'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Share List'), findsNothing);
    });
  });
}
