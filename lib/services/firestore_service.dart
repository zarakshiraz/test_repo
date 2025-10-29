import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/list_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ListModel>> getLists() {
    return _firestore
        .collection('lists')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListModel.fromFirestore(doc)).toList());
  }

  Future<void> createList(ListModel list) async {
    await _firestore.collection('lists').add(list.toFirestore());
  }

  Future<void> updateList(ListModel list) async {
    await _firestore.collection('lists').doc(list.id).update(list.toFirestore());
  }

  Future<void> completeList(String listId) async {
    final batch = _firestore.batch();

    batch.update(_firestore.collection('lists').doc(listId), {
      'isCompleted': true,
      'completedAt': Timestamp.now(),
    });

    final messagesSnapshot = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('messages')
        .get();

    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<MessageModel>> getMessages(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage(MessageModel message) async {
    await _firestore
        .collection('lists')
        .doc(message.listId)
        .collection('messages')
        .add(message.toFirestore());
  }

  Future<void> markMessageAsRead(
      String listId, String messageId, String userId) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('messages')
        .doc(messageId)
        .update({
      'readBy.$userId': true,
    });
  }

  Future<void> setTypingStatus(
      String listId, String userId, bool isTyping) async {
    await _firestore.collection('lists').doc(listId).update({
      'typingUsers.$userId': isTyping,
    });
  }

  Stream<Map<String, bool>> getTypingUsers(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null && data['typingUsers'] != null) {
        return Map<String, bool>.from(data['typingUsers']);
      }
      return <String, bool>{};
    });
  }
}
