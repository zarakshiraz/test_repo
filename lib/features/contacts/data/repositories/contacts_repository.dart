import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/contact_request.dart';
import '../models/contact_status.dart';
import '../models/user_contact.dart';

class ContactsRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ContactsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<UserContact>> getUserContacts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserContact.fromJson(doc.data()))
            .toList());
  }

  Stream<List<ContactRequest>> getContactRequests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contactRequests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: ContactStatus.pending.toJson())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactRequest.fromJson(doc.data()))
            .toList());
  }

  Stream<List<ContactRequest>> getSentContactRequests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contactRequests')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: ContactStatus.pending.toJson())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactRequest.fromJson(doc.data()))
            .toList());
  }

  Future<bool> requestContactPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<List<Contact>> getDeviceContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      throw Exception('Contacts permission denied');
    }
    return await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
  }

  Future<List<Map<String, dynamic>>> findMatchingUsers(
      List<Contact> deviceContacts) async {
    final emailsAndPhones = <String>[];

    for (final contact in deviceContacts) {
      for (final email in contact.emails) {
        if (email.address.isNotEmpty) {
          emailsAndPhones.add(email.address.toLowerCase());
        }
      }
      for (final phone in contact.phones) {
        final normalized = _normalizePhoneNumber(phone.number);
        if (normalized.isNotEmpty) {
          emailsAndPhones.add(normalized);
        }
      }
    }

    if (emailsAndPhones.isEmpty) return [];

    final uniqueContacts = emailsAndPhones.toSet().toList();
    final matchingUsers = <Map<String, dynamic>>[];

    for (int i = 0; i < uniqueContacts.length; i += 10) {
      final batch = uniqueContacts.skip(i).take(10).toList();

      final emailSnapshot = await _firestore
          .collection('users')
          .where('email', whereIn: batch)
          .get();

      matchingUsers.addAll(emailSnapshot.docs.map((doc) => doc.data()));
    }

    return matchingUsers;
  }

  Future<void> importDeviceContacts(String userId) async {
    final deviceContacts = await getDeviceContacts();
    final matchingUsers = await findMatchingUsers(deviceContacts);

    final batch = _firestore.batch();

    for (final userData in matchingUsers) {
      final contactUserId = userData['id'] as String;
      if (contactUserId == userId) continue;

      final contactId = _uuid.v4();
      final contact = UserContact(
        id: contactId,
        contactUserId: contactUserId,
        displayName: userData['displayName'] as String? ?? 'Unknown',
        email: userData['email'] as String?,
        phoneNumber: userData['phoneNumber'] as String?,
        photoUrl: userData['photoUrl'] as String?,
        status: ContactStatus.accepted,
        createdAt: DateTime.now(),
        source: 'phone',
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('contacts')
            .doc(contactId),
        contact.toJson(),
      );
    }

    await batch.commit();
  }

  Future<void> sendContactRequest({
    required String fromUserId,
    required String toUserId,
    required String fromUserName,
    String? fromUserEmail,
    String? fromUserPhotoUrl,
    String? note,
  }) async {
    final requestId = _uuid.v4();
    final request = ContactRequest(
      id: requestId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserEmail: fromUserEmail,
      fromUserPhotoUrl: fromUserPhotoUrl,
      status: ContactStatus.pending,
      createdAt: DateTime.now(),
      note: note,
    );

    await _firestore
        .collection('users')
        .doc(toUserId)
        .collection('contactRequests')
        .doc(requestId)
        .set(request.toJson());
  }

  Future<void> acceptContactRequest({
    required String currentUserId,
    required ContactRequest request,
  }) async {
    final batch = _firestore.batch();

    final contactId1 = _uuid.v4();
    final contact1 = UserContact(
      id: contactId1,
      contactUserId: request.fromUserId,
      displayName: request.fromUserName,
      email: request.fromUserEmail,
      photoUrl: request.fromUserPhotoUrl,
      status: ContactStatus.accepted,
      createdAt: DateTime.now(),
      source: 'app',
    );

    batch.set(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactId1),
      contact1.toJson(),
    );

    final currentUserDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data();

    final contactId2 = _uuid.v4();
    final contact2 = UserContact(
      id: contactId2,
      contactUserId: currentUserId,
      displayName: currentUserData?['displayName'] as String? ?? 'Unknown',
      email: currentUserData?['email'] as String?,
      photoUrl: currentUserData?['photoUrl'] as String?,
      status: ContactStatus.accepted,
      createdAt: DateTime.now(),
      source: 'app',
    );

    batch.set(
      _firestore
          .collection('users')
          .doc(request.fromUserId)
          .collection('contacts')
          .doc(contactId2),
      contact2.toJson(),
    );

    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contactRequests')
          .doc(request.id),
    );

    await batch.commit();
  }

  Future<void> rejectContactRequest({
    required String currentUserId,
    required String requestId,
  }) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contactRequests')
        .doc(requestId)
        .delete();
  }

  Future<void> blockContact({
    required String userId,
    required String contactUserId,
  }) async {
    final batch = _firestore.batch();

    final contactsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .where('contactUserId', isEqualTo: contactUserId)
        .get();

    for (final doc in contactsSnapshot.docs) {
      batch.update(doc.reference, {
        'status': ContactStatus.blocked.toJson(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    final requestsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('contactRequests')
        .where('fromUserId', isEqualTo: contactUserId)
        .get();

    for (final doc in requestsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> unblockContact({
    required String userId,
    required String contactUserId,
  }) async {
    final contactsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .where('contactUserId', isEqualTo: contactUserId)
        .get();

    final batch = _firestore.batch();

    for (final doc in contactsSnapshot.docs) {
      batch.update(doc.reference, {
        'status': ContactStatus.accepted.toJson(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    await batch.commit();
  }

  Future<void> removeContact({
    required String userId,
    required String contactId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    final snapshot = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    final emailSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: queryLower)
        .limit(5)
        .get();

    final results = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final doc in [...snapshot.docs, ...emailSnapshot.docs]) {
      final data = doc.data();
      final userId = data['id'] as String;
      if (userId != currentUserId && !seenIds.contains(userId)) {
        seenIds.add(userId);
        results.add(data);
      }
    }

    return results;
  }

  String _normalizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
