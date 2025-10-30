import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:testing_repo/repositories/list_repository.dart';
import 'package:testing_repo/models/participant.dart';
import 'package:testing_repo/constants/permissions.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ListRepository repository;
  const String testUserId = 'user1';
  const String testUserName = 'Test User';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ListRepository(
      currentUserId: testUserId,
      firestore: firestore,
    );
  });

  group('List Repository Permission Tests', () {
    test('Owner can create and read lists', () async {
      final list = await repository.createList('Test List', testUserName);

      expect(list.title, 'Test List');
      expect(list.ownerId, testUserId);

      final role = await repository.getUserRole(list.id);
      expect(role, PermissionRole.owner);
    });

    test('Owner can add items to list', () async {
      final list = await repository.createList('Test List', testUserName);
      final item = await repository.addItem(list.id, 'Test Item');

      expect(item.title, 'Test Item');
      expect(item.createdBy, testUserId);
    });

    test('Owner can update items', () async {
      final list = await repository.createList('Test List', testUserName);
      final item = await repository.addItem(list.id, 'Test Item');

      await repository.updateItem(list.id, item.id, title: 'Updated Item');

      final items = await repository.getListItems(list.id).first;
      expect(items.first.title, 'Updated Item');
    });

    test('Owner can delete items', () async {
      final list = await repository.createList('Test List', testUserName);
      final item = await repository.addItem(list.id, 'Test Item');

      await repository.deleteItem(list.id, item.id);

      final items = await repository.getListItems(list.id).first;
      expect(items.isEmpty, true);
    });

    test('Owner can share list with others', () async {
      final list = await repository.createList('Test List', testUserName);

      await repository.addParticipants(list.id, [
        Participant(
          userId: 'user2',
          userName: 'User 2',
          userEmail: 'user2@test.com',
          role: PermissionRole.editor,
          addedAt: DateTime.now(),
        ),
      ]);

      final participants = await repository.getParticipants(list.id).first;
      expect(participants.length, 2);
      expect(participants.any((p) => p.userId == 'user2'), true);
    });

    test('Owner can update participant roles', () async {
      final list = await repository.createList('Test List', testUserName);

      await repository.addParticipants(list.id, [
        Participant(
          userId: 'user2',
          userName: 'User 2',
          userEmail: 'user2@test.com',
          role: PermissionRole.viewer,
          addedAt: DateTime.now(),
        ),
      ]);

      await repository.updateParticipantRole(
          list.id, 'user2', PermissionRole.editor);

      final doc = await firestore
          .collection('lists')
          .doc(list.id)
          .collection('participants')
          .doc('user2')
          .get();

      expect(doc.data()!['role'], 'editor');
    });

    test('Owner cannot change their own role', () async {
      final list = await repository.createList('Test List', testUserName);

      expect(
        () => repository.updateParticipantRole(
            list.id, testUserId, PermissionRole.viewer),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Owner can remove participants', () async {
      final list = await repository.createList('Test List', testUserName);

      await repository.addParticipants(list.id, [
        Participant(
          userId: 'user2',
          userName: 'User 2',
          userEmail: 'user2@test.com',
          role: PermissionRole.editor,
          addedAt: DateTime.now(),
        ),
      ]);

      await repository.removeParticipant(list.id, 'user2');

      final participants = await repository.getParticipants(list.id).first;
      expect(participants.length, 1);
      expect(participants.any((p) => p.userId == 'user2'), false);
    });

    test('Owner cannot remove themselves', () async {
      final list = await repository.createList('Test List', testUserName);

      expect(
        () => repository.removeParticipant(list.id, testUserId),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Viewer cannot modify items', () async {
      final list = await repository.createList('Test List', testUserName);

      await firestore
          .collection('lists')
          .doc(list.id)
          .collection('participants')
          .doc('user2')
          .set({
        'userId': 'user2',
        'userName': 'User 2',
        'userEmail': 'user2@test.com',
        'role': 'viewer',
        'addedAt': DateTime.now().toIso8601String(),
      });

      await firestore.collection('lists').doc(list.id).update({
        'participantIds': ['user1', 'user2'],
      });

      final viewerRepository = ListRepository(
        currentUserId: 'user2',
        firestore: firestore,
      );

      expect(
        () => viewerRepository.addItem(list.id, 'New Item'),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Editor can modify items', () async {
      final list = await repository.createList('Test List', testUserName);

      await firestore
          .collection('lists')
          .doc(list.id)
          .collection('participants')
          .doc('user2')
          .set({
        'userId': 'user2',
        'userName': 'User 2',
        'userEmail': 'user2@test.com',
        'role': 'editor',
        'addedAt': DateTime.now().toIso8601String(),
      });

      await firestore.collection('lists').doc(list.id).update({
        'participantIds': ['user1', 'user2'],
      });

      final editorRepository = ListRepository(
        currentUserId: 'user2',
        firestore: firestore,
      );

      final item = await editorRepository.addItem(list.id, 'New Item');
      expect(item.title, 'New Item');
    });

    test('Editor cannot share list', () async {
      final list = await repository.createList('Test List', testUserName);

      await firestore
          .collection('lists')
          .doc(list.id)
          .collection('participants')
          .doc('user2')
          .set({
        'userId': 'user2',
        'userName': 'User 2',
        'userEmail': 'user2@test.com',
        'role': 'editor',
        'addedAt': DateTime.now().toIso8601String(),
      });

      await firestore.collection('lists').doc(list.id).update({
        'participantIds': ['user1', 'user2'],
      });

      final editorRepository = ListRepository(
        currentUserId: 'user2',
        firestore: firestore,
      );

      expect(
        () => editorRepository.addParticipants(list.id, [
          Participant(
            userId: 'user3',
            userName: 'User 3',
            userEmail: 'user3@test.com',
            role: PermissionRole.viewer,
            addedAt: DateTime.now(),
          ),
        ]),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Non-participant cannot access list', () async {
      final list = await repository.createList('Test List', testUserName);

      final nonParticipantRepository = ListRepository(
        currentUserId: 'user2',
        firestore: firestore,
      );

      final role = await nonParticipantRepository.getUserRole(list.id);
      expect(role, null);
    });

    test('Owner can delete list', () async {
      final list = await repository.createList('Test List', testUserName);
      await repository.addItem(list.id, 'Item 1');

      await repository.deleteList(list.id);

      final doc = await firestore.collection('lists').doc(list.id).get();
      expect(doc.exists, false);
    });

    test('Non-owner cannot delete list', () async {
      final list = await repository.createList('Test List', testUserName);

      await firestore
          .collection('lists')
          .doc(list.id)
          .collection('participants')
          .doc('user2')
          .set({
        'userId': 'user2',
        'userName': 'User 2',
        'userEmail': 'user2@test.com',
        'role': 'editor',
        'addedAt': DateTime.now().toIso8601String(),
      });

      await firestore.collection('lists').doc(list.id).update({
        'participantIds': ['user1', 'user2'],
      });

      final editorRepository = ListRepository(
        currentUserId: 'user2',
        firestore: firestore,
      );

      expect(
        () => editorRepository.deleteList(list.id),
        throwsA(isA<PermissionException>()),
      );
    });
  });
}
