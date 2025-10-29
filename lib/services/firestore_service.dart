import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list.dart';
import '../models/list_template.dart';
import '../models/list_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Stream<List<TodoList>> getLists(String userId) {
    return _firestore
        .collection('lists')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoList.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<List<TodoList>> getSharedLists(String userId) {
    return _firestore
        .collection('lists')
        .where('sharedWith', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoList.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> saveList(TodoList list) async {
    await _firestore.collection('lists').doc(list.id).set(list.toMap());
  }

  Future<void> deleteList(String listId) async {
    await _firestore.collection('lists').doc(listId).delete();
  }

  Stream<List<ListTemplate>> getTemplates(String userId) {
    return _firestore
        .collection('templates')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ListTemplate.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> saveTemplate(ListTemplate template) async {
    await _firestore
        .collection('templates')
        .doc(template.id)
        .set(template.toMap());
  }

  Future<void> deleteTemplate(String templateId) async {
    await _firestore.collection('templates').doc(templateId).delete();
  }

  Future<ListTemplate> saveListAsTemplate({
    required String templateId,
    required String userId,
    required TodoList list,
  }) async {
    final itemsCopy = list.items
        .map((item) => ListItem(
              id: item.id,
              text: item.text,
              isCompleted: false,
              createdAt: item.createdAt,
            ))
        .toList();

    final template = ListTemplate(
      id: templateId,
      title: list.title,
      userId: userId,
      items: itemsCopy,
      createdAt: DateTime.now(),
      originalListId: list.id,
    );

    await saveTemplate(template);
    return template;
  }

  Future<TodoList> duplicateTemplateToList({
    required String newListId,
    required String userId,
    required ListTemplate template,
  }) async {
    final now = DateTime.now();
    final itemsCopy = template.items
        .map((item) => ListItem(
              id: item.id,
              text: item.text,
              isCompleted: false,
              createdAt: now,
            ))
        .toList();

    final newList = TodoList(
      id: newListId,
      title: template.title,
      userId: userId,
      items: itemsCopy,
      createdAt: now,
      updatedAt: now,
    );

    await saveList(newList);
    return newList;
  }
}
