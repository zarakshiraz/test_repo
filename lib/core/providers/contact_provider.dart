import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart' as contacts;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../models/user.dart';

class ContactProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String userId;
  final _uuid = const Uuid();

  List<Contact> _contacts = [];
  List<User> _appUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  ContactProvider({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    _initialize();
  }

  List<Contact> get contacts => _contacts;
  List<User> get appUsers => _appUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initialize() {
    // Listen to user's contacts
    _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .snapshots()
        .listen(_onContactsChanged);
  }

  void _onContactsChanged(QuerySnapshot snapshot) {
    _contacts = snapshot.docs
        .map((doc) => Contact.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<bool> syncPhoneContacts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Request permission
      final status = await Permission.contacts.request();
      if (!status.isGranted) {
        _errorMessage = 'Contacts permission denied';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get phone contacts
      final phoneContacts = await contacts.ContactsService.getContacts();

      // Extract emails and phone numbers
      final emailsAndPhones = <String>[];
      for (final contact in phoneContacts) {
        if (contact.emails != null && contact.emails!.isNotEmpty) {
          emailsAndPhones.addAll(contact.emails!.map((e) => e.value ?? ''));
        }
        if (contact.phones != null && contact.phones!.isNotEmpty) {
          emailsAndPhones.addAll(contact.phones!.map((p) => p.value ?? ''));
        }
      }

      // Find matching app users
      if (emailsAndPhones.isNotEmpty) {
        final usersSnapshot = await _firestore
            .collection('users')
            .where('email', whereIn: emailsAndPhones.take(10).toList()) // Firestore limit
            .get();

        final batch = _firestore.batch();
        for (final doc in usersSnapshot.docs) {
          final user = User.fromJson(doc.data());
          
          // Check if contact already exists
          final existingContact = _contacts.firstWhere(
            (c) => c.userId == user.id,
            orElse: () => Contact(
              id: '',
              userId: '',
              displayName: '',
              addedAt: DateTime.now(),
            ),
          );

          if (existingContact.id.isEmpty) {
            final contactId = _uuid.v4();
            final newContact = Contact(
              id: contactId,
              userId: user.id,
              displayName: user.displayName,
              email: user.email,
              photoUrl: user.photoUrl,
              addedAt: DateTime.now(),
              isSynced: true,
              source: 'phone',
            );

            batch.set(
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('contacts')
                  .doc(contactId),
              newContact.toJson(),
            );
          }
        }
        await batch.commit();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sync contacts: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addContact({
    required String contactUserId,
    required String displayName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final contactId = _uuid.v4();
      final contact = Contact(
        id: contactId,
        userId: contactUserId,
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        addedAt: DateTime.now(),
        source: 'app',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .set(contact.toJson());

      // Also add to main user's contactIds
      await _firestore.collection('users').doc(userId).update({
        'contactIds': FieldValue.arrayUnion([contactUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add contact: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeContact(String contactId, String contactUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .delete();

      // Remove from main user's contactIds
      await _firestore.collection('users').doc(userId).update({
        'contactIds': FieldValue.arrayRemove([contactUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove contact: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> blockUser(String blockedUserId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'blockedUserIds': FieldValue.arrayUnion([blockedUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Remove from contacts if exists
      final contact = _contacts.firstWhere(
        (c) => c.userId == blockedUserId,
        orElse: () => Contact(
          id: '',
          userId: '',
          displayName: '',
          addedAt: DateTime.now(),
        ),
      );

      if (contact.id.isNotEmpty) {
        await removeContact(contact.id, blockedUserId);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to block user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unblockUser(String blockedUserId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'blockedUserIds': FieldValue.arrayRemove([blockedUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to unblock user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      _appUsers = snapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .where((user) => user.id != userId) // Exclude self
          .toList();

      notifyListeners();
      return _appUsers;
    } catch (e) {
      _errorMessage = 'Failed to search users: $e';
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
