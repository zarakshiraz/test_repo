import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/message.dart';
import '../models/activity_log.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore!;
    } catch (e) {
      throw Exception('Firebase not initialized. Tests should mock this service.');
    }
  }

  static Future<void> enablePersistence() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (e) {
      // Could not enable Firestore persistence
    }
  }

  CollectionReference get todoListsCollection =>
      firestore.collection('todoLists');
  CollectionReference get todoItemsCollection =>
      firestore.collection('todoItems');
  CollectionReference get messagesCollection =>
      firestore.collection('messages');
  CollectionReference get activityLogsCollection =>
      firestore.collection('activityLogs');

  Future<void> saveTodoList(TodoList list) async {
    await todoListsCollection.doc(list.id).set(list.toFirestore());
  }

  Future<void> saveTodoItem(TodoItem item) async {
    await todoItemsCollection.doc(item.id).set(item.toFirestore());
  }

  Future<void> saveMessage(Message message) async {
    await messagesCollection.doc(message.id).set(message.toFirestore());
  }

  Future<void> saveActivityLog(ActivityLog log) async {
    await activityLogsCollection.doc(log.id).set(log.toFirestore());
  }

  Stream<List<TodoList>> watchTodoLists() {
    return todoListsCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TodoList.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<TodoItem>> watchTodoItemsForList(String listId) {
    return todoItemsCollection
        .where('listId', isEqualTo: listId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TodoItem.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Message>> watchMessages() {
    return messagesCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Message.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<TodoList?> getTodoList(String id) async {
    final doc = await todoListsCollection.doc(id).get();
    if (doc.exists) {
      return TodoList.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<TodoItem?> getTodoItem(String id) async {
    final doc = await todoItemsCollection.doc(id).get();
    if (doc.exists) {
      return TodoItem.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<Message?> getMessage(String id) async {
    final doc = await messagesCollection.doc(id).get();
    if (doc.exists) {
      return Message.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> deleteTodoList(String id) async {
    await todoListsCollection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteTodoItem(String id) async {
    await todoItemsCollection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteMessage(String id) async {
    await messagesCollection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
