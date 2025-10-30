import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:testing_repo/screens/lists_screen.dart';
import 'package:testing_repo/repositories/list_repository.dart';
import 'package:testing_repo/repositories/notification_repository.dart';
import 'package:testing_repo/services/contact_service.dart';
import 'package:testing_repo/services/notification_service.dart';

void main() {
  testWidgets('Lists screen displays correctly', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    const userId = 'test_user';
    const userName = 'Test User';

    final listRepository = ListRepository(
      currentUserId: userId,
      firestore: firestore,
    );

    final notificationRepository = NotificationRepository(
      currentUserId: userId,
      firestore: firestore,
    );

    final contactService = ContactService(firestore: firestore);
    final notificationService = NotificationService(notificationRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: ListsScreen(
          repository: listRepository,
          contactService: contactService,
          notificationService: notificationService,
          currentUserId: userId,
          currentUserName: userName,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Lists'), findsOneWidget);
    expect(find.text('No lists yet. Create one to get started!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Can create a list', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    const userId = 'test_user';
    const userName = 'Test User';

    final listRepository = ListRepository(
      currentUserId: userId,
      firestore: firestore,
    );

    final notificationRepository = NotificationRepository(
      currentUserId: userId,
      firestore: firestore,
    );

    final contactService = ContactService(firestore: firestore);
    final notificationService = NotificationService(notificationRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: ListsScreen(
          repository: listRepository,
          contactService: contactService,
          notificationService: notificationService,
          currentUserId: userId,
          currentUserName: userName,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create New List'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'My Test List');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('My Test List'), findsOneWidget);
  });
}
