import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/models/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<User> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return User.fromJson(doc.data()!);
  }

  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return User.fromJson(snapshot.data()!);
    });
  }

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(
          user.copyWith(updatedAt: DateTime.now()).toJson(),
        );
  }

  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      await ref.delete();
    } catch (e) {
      // Photo might not exist, that's ok
    }
  }

  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }
}
