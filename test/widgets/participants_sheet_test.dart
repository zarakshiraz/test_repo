import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_repo/widgets/participants_sheet.dart';
import 'package:testing_repo/models/participant.dart';
import 'package:testing_repo/constants/permissions.dart';

void main() {
  group('ParticipantsSheet Widget Tests', () {
    final participants = [
      Participant(
        userId: 'user1',
        userName: 'Owner User',
        userEmail: 'owner@test.com',
        role: PermissionRole.owner,
        addedAt: DateTime.now(),
      ),
      Participant(
        userId: 'user2',
        userName: 'Editor User',
        userEmail: 'editor@test.com',
        role: PermissionRole.editor,
        addedAt: DateTime.now(),
      ),
      Participant(
        userId: 'user3',
        userName: 'Viewer User',
        userEmail: 'viewer@test.com',
        role: PermissionRole.viewer,
        addedAt: DateTime.now(),
      ),
    ];

    testWidgets('displays all participants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Participants'), findsOneWidget);
      expect(find.text('Owner User'), findsOneWidget);
      expect(find.text('Editor User'), findsOneWidget);
      expect(find.text('Viewer User'), findsOneWidget);
    });

    testWidgets('shows owner badge for owner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Owner'), findsAtLeastNWidgets(1));
      
      final ownerBadge = find.ancestor(
        of: find.text('Owner'),
        matching: find.byType(Container),
      );
      expect(ownerBadge, findsWidgets);
    });

    testWidgets('owner can modify non-owner participants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      final dropdowns = find.byType(DropdownButton<PermissionRole>);
      expect(dropdowns, findsNWidgets(2));

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      expect(removeButtons, findsNWidgets(2));
    });

    testWidgets('owner cannot modify themselves', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      final ownerTile = find.ancestor(
        of: find.text('Owner User'),
        matching: find.byType(ListTile),
      );

      expect(ownerTile, findsOneWidget);

      final ownerDropdown = find.descendant(
        of: ownerTile,
        matching: find.byType(DropdownButton<PermissionRole>),
      );
      expect(ownerDropdown, findsNothing);
    });

    testWidgets('editor cannot modify participants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.editor,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      final dropdowns = find.byType(DropdownButton<PermissionRole>);
      expect(dropdowns, findsNothing);

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      expect(removeButtons, findsNothing);
    });

    testWidgets('viewer cannot modify participants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.viewer,
              onRoleChange: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      final dropdowns = find.byType(DropdownButton<PermissionRole>);
      expect(dropdowns, findsNothing);

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      expect(removeButtons, findsNothing);
    });

    testWidgets('calls onRoleChange when role is changed', (tester) async {
      Participant? changedParticipant;
      PermissionRole? newRole;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (participant, role) {
                changedParticipant = participant;
                newRole = role;
              },
              onRemove: (_) {},
            ),
          ),
        ),
      );

      final dropdown = find.byType(DropdownButton<PermissionRole>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final viewerOption = find.text('View Only').last;
      await tester.tap(viewerOption);
      await tester.pumpAndSettle();

      expect(changedParticipant, isNotNull);
      expect(changedParticipant!.userId, 'user2');
      expect(newRole, PermissionRole.viewer);
    });

    testWidgets('calls onRemove when remove button is tapped', (tester) async {
      Participant? removedParticipant;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSheet(
              participants: participants,
              ownerId: 'user1',
              currentUserRole: PermissionRole.owner,
              onRoleChange: (_, __) {},
              onRemove: (participant) {
                removedParticipant = participant;
              },
            ),
          ),
        ),
      );

      final removeButton = find.byIcon(Icons.remove_circle_outline).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(removedParticipant, isNotNull);
      expect(removedParticipant!.userId, 'user2');
    });

    testWidgets('close button dismisses sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => ParticipantsSheet(
                      participants: participants,
                      ownerId: 'user1',
                      currentUserRole: PermissionRole.owner,
                      onRoleChange: (_, __) {},
                      onRemove: (_) {},
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

      expect(find.text('Participants'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Participants'), findsNothing);
    });
  });
}
