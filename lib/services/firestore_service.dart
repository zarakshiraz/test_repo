import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/list_item.dart';
import '../models/collaboration_list.dart';
import '../models/activity.dart';
import '../models/chat_message.dart';
import '../models/participant.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CollaborationList>> getLists(String userId) {
    return _firestore
        .collection('lists')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollaborationList.fromFirestore(doc))
            .toList());
  }

  Stream<CollaborationList?> getList(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .snapshots()
        .map((doc) => doc.exists ? CollaborationList.fromFirestore(doc) : null);
  }

  Stream<List<ListItem>> getListItems(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListItem.fromFirestore(doc)).toList());
  }

  Stream<List<Participant>> getParticipants(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Participant.fromFirestore(doc))
            .toList());
  }

  Stream<List<Activity>> getActivities(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('listActivities')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
  }

  Stream<List<ChatMessage>> getChatMessages(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  Future<String> createList({
    required String title,
    required String userId,
    required String userName,
  }) async {
    final list = CollaborationList(
      id: '',
      title: title,
      createdBy: userId,
      createdAt: DateTime.now(),
      participants: [userId],
    );

    final docRef = await _firestore.collection('lists').add(list.toFirestore());

    await docRef.collection('participants').doc(userId).set(
          Participant(
            id: userId,
            name: userName,
            joinedAt: DateTime.now(),
            isOnline: true,
          ).toFirestore(),
        );

    return docRef.id;
  }

  Future<void> addItem({
    required String listId,
    required String title,
    required String userId,
    required String userName,
  }) async {
    final item = ListItem(
      id: '',
      title: title,
      isChecked: false,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .add(item.toFirestore());

    await _logActivity(
      listId: listId,
      type: ActivityType.itemAdded,
      userId: userId,
      userName: userName,
      metadata: {'itemTitle': title, 'itemId': docRef.id},
    );
  }

  Future<void> updateItem({
    required String listId,
    required String itemId,
    required String title,
    required String userId,
    required String userName,
  }) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update({'title': title});

    await _logActivity(
      listId: listId,
      type: ActivityType.itemEdited,
      userId: userId,
      userName: userName,
      metadata: {'itemTitle': title, 'itemId': itemId},
    );
  }

  Future<void> toggleItemChecked({
    required String listId,
    required String itemId,
    required bool isChecked,
    required String userId,
    required String userName,
    required String itemTitle,
  }) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update({
      'isChecked': isChecked,
      'checkedBy': isChecked ? userId : null,
      'checkedAt': isChecked ? Timestamp.now() : null,
    });

    await _logActivity(
      listId: listId,
      type: isChecked ? ActivityType.itemChecked : ActivityType.itemUnchecked,
      userId: userId,
      userName: userName,
      metadata: {'itemTitle': itemTitle, 'itemId': itemId},
    );
  }

  Future<void> deleteItem({
    required String listId,
    required String itemId,
  }) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Future<void> sendChatMessage({
    required String listId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final chatMessage = ChatMessage(
      id: '',
      userId: userId,
      userName: userName,
      message: message,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('chat')
        .add(chatMessage.toFirestore());
  }

  Future<void> updateParticipantStatus({
    required String listId,
    required String userId,
    required bool isOnline,
  }) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .doc(userId)
        .update({'isOnline': isOnline});
  }

  Future<void> _logActivity({
    required String listId,
    required ActivityType type,
    required String userId,
    required String userName,
    Map<String, dynamic>? metadata,
  }) async {
    final activity = Activity(
      id: '',
      type: type,
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('listActivities')
        .add(activity.toFirestore());
  }
}
