import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_list.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<TodoList>> getLists(String userId) {
    return _firestore
        .collection('lists')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoList.fromMap(doc.data()))
            .toList());
  }

  Future<TodoList?> getList(String listId) async {
    final doc = await _firestore.collection('lists').doc(listId).get();
    if (!doc.exists) return null;
    return TodoList.fromMap(doc.data()!);
  }

  Future<void> createList({
    required String name,
    required String ownerId,
  }) async {
    final listId = _uuid.v4();
    final now = DateTime.now();

    final list = TodoList(
      id: listId,
      name: name,
      ownerId: ownerId,
      participantIds: [ownerId],
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('lists').doc(listId).set(list.toMap());
  }

  Future<void> updateList(TodoList list) async {
    await _firestore
        .collection('lists')
        .doc(list.id)
        .update(list.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteList(String listId) async {
    await _firestore.collection('lists').doc(listId).delete();
  }
}
