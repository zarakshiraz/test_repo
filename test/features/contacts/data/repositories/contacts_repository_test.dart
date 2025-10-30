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

  group('ContactsRepository', () {
    const testUserId = 'user123';
    const testContactUserId = 'contact456';

    test('getUserContacts returns stream of contacts', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: testContactUserId,
        displayName: 'Test Contact',
        email: 'test@example.com',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      final stream = repository.getUserContacts(testUserId);
      
      expectLater(
        stream,
        emits(predicate<List<UserContact>>((contacts) {
          return contacts.length == 1 &&
              contacts[0].id == 'contact1' &&
              contacts[0].displayName == 'Test Contact';
        })),
      );
    });

    test('sendContactRequest creates a request', () async {
      await repository.sendContactRequest(
        fromUserId: testUserId,
        toUserId: testContactUserId,
        fromUserName: 'Test User',
        fromUserEmail: 'user@example.com',
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testContactUserId)
          .collection('contactRequests')
          .get();

      expect(snapshot.docs.length, 1);
      final request = ContactRequest.fromJson(snapshot.docs[0].data());
      expect(request.fromUserId, testUserId);
      expect(request.toUserId, testContactUserId);
      expect(request.status, ContactStatus.pending);
    });

    test('acceptContactRequest creates contacts for both users', () async {
      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .set({'displayName': 'Test User', 'email': 'user@example.com'});

      final request = ContactRequest(
        id: 'request1',
        fromUserId: testContactUserId,
        toUserId: testUserId,
        fromUserName: 'Contact User',
        fromUserEmail: 'contact@example.com',
        status: ContactStatus.pending,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contactRequests')
          .doc(request.id)
          .set(request.toJson());

      await repository.acceptContactRequest(
        currentUserId: testUserId,
        request: request,
      );

      final userContacts = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .get();

      final contactUserContacts = await fakeFirestore
          .collection('users')
          .doc(testContactUserId)
          .collection('contacts')
          .get();

      expect(userContacts.docs.length, 1);
      expect(contactUserContacts.docs.length, 1);

      final userContact = UserContact.fromJson(userContacts.docs[0].data());
      expect(userContact.contactUserId, testContactUserId);
      expect(userContact.status, ContactStatus.accepted);
    });

    test('rejectContactRequest deletes the request', () async {
      final request = ContactRequest(
        id: 'request1',
        fromUserId: testContactUserId,
        toUserId: testUserId,
        fromUserName: 'Contact User',
        status: ContactStatus.pending,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contactRequests')
          .doc(request.id)
          .set(request.toJson());

      await repository.rejectContactRequest(
        currentUserId: testUserId,
        requestId: request.id,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contactRequests')
          .doc(request.id)
          .get();

      expect(snapshot.exists, false);
    });

    test('blockContact updates contact status to blocked', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: testContactUserId,
        displayName: 'Test Contact',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      await repository.blockContact(
        userId: testUserId,
        contactUserId: testContactUserId,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .get();

      final updatedContact = UserContact.fromJson(snapshot.data()!);
      expect(updatedContact.status, ContactStatus.blocked);
    });

    test('unblockContact updates contact status to accepted', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: testContactUserId,
        displayName: 'Test Contact',
        status: ContactStatus.blocked,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      await repository.unblockContact(
        userId: testUserId,
        contactUserId: testContactUserId,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .get();

      final updatedContact = UserContact.fromJson(snapshot.data()!);
      expect(updatedContact.status, ContactStatus.accepted);
    });

    test('removeContact deletes the contact', () async {
      final contact = UserContact(
        id: 'contact1',
        contactUserId: testContactUserId,
        displayName: 'Test Contact',
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .set(contact.toJson());

      await repository.removeContact(
        userId: testUserId,
        contactId: contact.id,
      );

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contacts')
          .doc(contact.id)
          .get();

      expect(snapshot.exists, false);
    });

    test('searchUsers returns matching users', () async {
      await fakeFirestore.collection('users').doc('user1').set({
        'id': 'user1',
        'displayName': 'John Doe',
        'email': 'john@example.com',
      });

      await fakeFirestore.collection('users').doc('user2').set({
        'id': 'user2',
        'displayName': 'Jane Doe',
        'email': 'jane@example.com',
      });

      final results = await repository.searchUsers(
        query: 'John',
        currentUserId: testUserId,
      );

      expect(results.length, greaterThan(0));
      expect(results.any((user) => user['displayName'] == 'John Doe'), true);
    });

    test('getContactRequests filters by pending status', () async {
      final request = ContactRequest(
        id: 'request1',
        fromUserId: testContactUserId,
        toUserId: testUserId,
        fromUserName: 'Contact User',
        status: ContactStatus.pending,
        createdAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('contactRequests')
          .doc(request.id)
          .set(request.toJson());

      final stream = repository.getContactRequests(testUserId);

      expectLater(
        stream,
        emits(predicate<List<ContactRequest>>((requests) {
          return requests.length == 1 && requests[0].id == 'request1';
        })),
      );
    });
  });
}
