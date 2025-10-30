import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/features/contacts/data/models/contact_status.dart';
import 'package:grocli/features/contacts/data/models/contact_request.dart';
import 'package:grocli/features/contacts/data/models/user_contact.dart';
import 'package:grocli/features/contacts/data/repositories/contacts_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ContactsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ContactsRepository(firestore: fakeFirestore);
  });

  group('Contacts Integration Tests', () {
    const user1Id = 'user1';
    const user2Id = 'user2';

    setUp(() async {
      await fakeFirestore.collection('users').doc(user1Id).set({
        'id': user1Id,
        'displayName': 'User One',
        'email': 'user1@example.com',
        'photoUrl': null,
      });

      await fakeFirestore.collection('users').doc(user2Id).set({
        'id': user2Id,
        'displayName': 'User Two',
        'email': 'user2@example.com',
        'photoUrl': null,
      });
    });

    test('Complete contact request flow', () async {
      await repository.sendContactRequest(
        fromUserId: user1Id,
        toUserId: user2Id,
        fromUserName: 'User One',
        fromUserEmail: 'user1@example.com',
      );

      final requestsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contactRequests')
          .get();

      expect(requestsSnapshot.docs.length, 1);

      final request = ContactRequest.fromJson(requestsSnapshot.docs[0].data());
      expect(request.fromUserId, user1Id);
      expect(request.toUserId, user2Id);
      expect(request.status, ContactStatus.pending);

      await repository.acceptContactRequest(
        currentUserId: user2Id,
        request: request,
      );

      final user1ContactsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .get();

      final user2ContactsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contacts')
          .get();

      expect(user1ContactsSnapshot.docs.length, 1);
      expect(user2ContactsSnapshot.docs.length, 1);

      final user1Contact =
          UserContact.fromJson(user1ContactsSnapshot.docs[0].data());
      final user2Contact =
          UserContact.fromJson(user2ContactsSnapshot.docs[0].data());

      expect(user1Contact.contactUserId, user2Id);
      expect(user1Contact.status, ContactStatus.accepted);
      expect(user2Contact.contactUserId, user1Id);
      expect(user2Contact.status, ContactStatus.accepted);

      final deletedRequestSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contactRequests')
          .doc(request.id)
          .get();

      expect(deletedRequestSnapshot.exists, false);
    });

    test('Reject contact request flow', () async {
      await repository.sendContactRequest(
        fromUserId: user1Id,
        toUserId: user2Id,
        fromUserName: 'User One',
        fromUserEmail: 'user1@example.com',
      );

      final requestsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contactRequests')
          .get();

      expect(requestsSnapshot.docs.length, 1);

      final request = ContactRequest.fromJson(requestsSnapshot.docs[0].data());

      await repository.rejectContactRequest(
        currentUserId: user2Id,
        requestId: request.id,
      );

      final deletedRequestSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contactRequests')
          .doc(request.id)
          .get();

      expect(deletedRequestSnapshot.exists, false);

      final user1ContactsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .get();

      final user2ContactsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contacts')
          .get();

      expect(user1ContactsSnapshot.docs.length, 0);
      expect(user2ContactsSnapshot.docs.length, 0);
    });

    test('Block and unblock contact flow', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: user2Id,
        displayName: 'User Two',
        email: 'user2@example.com',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      await repository.blockContact(
        userId: user1Id,
        contactUserId: user2Id,
      );

      var contactSnapshot = await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact.id)
          .get();

      var blockedContact = UserContact.fromJson(contactSnapshot.data()!);
      expect(blockedContact.status, ContactStatus.blocked);

      await repository.unblockContact(
        userId: user1Id,
        contactUserId: user2Id,
      );

      contactSnapshot = await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact.id)
          .get();

      var unblockedContact = UserContact.fromJson(contactSnapshot.data()!);
      expect(unblockedContact.status, ContactStatus.accepted);
    });

    test('Remove contact flow', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: user2Id,
        displayName: 'User Two',
        email: 'user2@example.com',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      await repository.removeContact(
        userId: user1Id,
        contactId: contact.id,
      );

      final contactSnapshot = await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact.id)
          .get();

      expect(contactSnapshot.exists, false);
    });

    test('Search users by name', () async {
      await fakeFirestore.collection('users').doc('user3').set({
        'id': 'user3',
        'displayName': 'Alice Smith',
        'email': 'alice@example.com',
      });

      await fakeFirestore.collection('users').doc('user4').set({
        'id': 'user4',
        'displayName': 'Bob Johnson',
        'email': 'bob@example.com',
      });

      final results = await repository.searchUsers(
        query: 'Alice',
        currentUserId: user1Id,
      );

      expect(results.length, greaterThan(0));
      expect(results.any((user) => user['displayName'] == 'Alice Smith'), true);
      expect(results.any((user) => user['id'] == user1Id), false);
    });

    test('Search users by email', () async {
      await fakeFirestore.collection('users').doc('user3').set({
        'id': 'user3',
        'displayName': 'Alice Smith',
        'email': 'alice@example.com',
      });

      final results = await repository.searchUsers(
        query: 'alice@example.com',
        currentUserId: user1Id,
      );

      expect(results.length, greaterThan(0));
      expect(
          results.any((user) => user['email'] == 'alice@example.com'), true);
    });

    test('Multiple pending requests', () async {
      await repository.sendContactRequest(
        fromUserId: user1Id,
        toUserId: user2Id,
        fromUserName: 'User One',
      );

      await fakeFirestore.collection('users').doc('user3').set({
        'id': 'user3',
        'displayName': 'User Three',
        'email': 'user3@example.com',
      });

      await repository.sendContactRequest(
        fromUserId: 'user3',
        toUserId: user2Id,
        fromUserName: 'User Three',
      );

      final requestsSnapshot = await fakeFirestore
          .collection('users')
          .doc(user2Id)
          .collection('contactRequests')
          .get();

      expect(requestsSnapshot.docs.length, 2);

      final requests = requestsSnapshot.docs
          .map((doc) => ContactRequest.fromJson(doc.data()))
          .toList();

      expect(requests.every((r) => r.status == ContactStatus.pending), true);
      expect(requests.every((r) => r.toUserId == user2Id), true);
    });

    test('Real-time updates with streams', () async {
      final contact1 = UserContact(
        id: 'contact1',
        contactUserId: user2Id,
        displayName: 'User Two',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact1.id)
          .set(contact1.toJson());

      final stream = repository.getUserContacts(user1Id);
      
      expect(
        stream,
        emitsInOrder([
          predicate<List<UserContact>>((contacts) => contacts.length == 1),
          predicate<List<UserContact>>((contacts) => contacts.length == 2),
        ]),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final contact2 = UserContact(
        id: 'contact2',
        contactUserId: 'user3',
        displayName: 'User Three',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(user1Id)
          .collection('contacts')
          .doc(contact2.id)
          .set(contact2.toJson());
    });
  });
}
