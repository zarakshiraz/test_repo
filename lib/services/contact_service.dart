import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';

class ContactService {
  final FirebaseFirestore _firestore;

  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Contact>> getContacts(String currentUserId) async {
    final snapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    return snapshot.docs
        .map((doc) => Contact.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Contact?> getContactById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return Contact.fromJson({...doc.data()!, 'id': doc.id});
  }
}
