import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_list.dart';
import '../models/list_item.dart';

class ListProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String userId;
  final _uuid = const Uuid();

  List<GroceryList> _lists = [];
  List<GroceryList> _savedLists = [];
  List<GroceryList> _sharedLists = [];
  List<ListItem> _currentListItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  ListProvider({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    _initialize();
  }

  List<GroceryList> get lists => _lists;
  List<GroceryList> get savedLists => _savedLists;
  List<GroceryList> get sharedLists => _sharedLists;
  List<ListItem> get currentListItems => _currentListItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initialize() {
    // Listen to user's lists
    _firestore
        .collection('lists')
        .where('createdByUserId', isEqualTo: userId)
        .snapshots()
        .listen(_onListsChanged);

    // Listen to shared lists
    _firestore
        .collection('lists')
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .listen(_onSharedListsChanged);
  }

  void _onListsChanged(QuerySnapshot snapshot) {
    _lists = snapshot.docs
        .map((doc) => GroceryList.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    
    _savedLists = _lists.where((list) => list.isSaved).toList();
    notifyListeners();
  }

  void _onSharedListsChanged(QuerySnapshot snapshot) {
    _sharedLists = snapshot.docs
        .map((doc) => GroceryList.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<GroceryList?> createList({
    required String title,
    String? description,
    String? category,
    List<String> items = const [],
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final listId = _uuid.v4();
      final now = DateTime.now();

      final list = GroceryList(
        id: listId,
        title: title,
        description: description,
        category: category,
        createdByUserId: userId,
        createdAt: now,
        updatedAt: now,
        totalItems: items.length,
      );

      await _firestore.collection('lists').doc(listId).set(list.toJson());

      // Add items if provided
      if (items.isNotEmpty) {
        final batch = _firestore.batch();
        for (int i = 0; i < items.length; i++) {
          final itemId = _uuid.v4();
          final item = ListItem(
            id: itemId,
            listId: listId,
            content: items[i],
            createdByUserId: userId,
            createdAt: now,
            updatedAt: now,
            order: i,
          );
          batch.set(
            _firestore.collection('lists').doc(listId).collection('items').doc(itemId),
            item.toJson(),
          );
        }
        await batch.commit();
      }

      _isLoading = false;
      notifyListeners();
      return list;
    } catch (e) {
      _errorMessage = 'Failed to create list: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateList(String listId, {
    String? title,
    String? description,
    String? category,
    ListStatus? status,
    bool? isSaved,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (status != null) {
        updates['status'] = status.name;
        if (status == ListStatus.completed) {
          updates['completedAt'] = DateTime.now().toIso8601String();
          // Clear messages when list is completed
          await _clearListMessages(listId);
        }
      }
      if (isSaved != null) updates['isSaved'] = isSaved;

      await _firestore.collection('lists').doc(listId).update(updates);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update list: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearListMessages(String listId) async {
    try {
      final messages = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing messages: $e');
    }
  }

  Future<bool> deleteList(String listId) async {
    try {
      await _firestore.collection('lists').doc(listId).delete();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete list: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> shareList({
    required String listId,
    required String userId,
    required ListPermission permission,
  }) async {
    try {
      final sharedUser = SharedUser(
        userId: userId,
        permission: permission,
        sharedAt: DateTime.now(),
      );

      await _firestore.collection('lists').doc(listId).update({
        'sharedWith': FieldValue.arrayUnion([sharedUser.toJson()]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to share list: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeSharedUser(String listId, String userId) async {
    try {
      final doc = await _firestore.collection('lists').doc(listId).get();
      if (!doc.exists) return false;

      final list = GroceryList.fromJson(doc.data()!);
      final updatedSharedWith = list.sharedWith
          .where((su) => su.userId != userId)
          .map((su) => su.toJson())
          .toList();

      await _firestore.collection('lists').doc(listId).update({
        'sharedWith': updatedSharedWith,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove shared user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<GroceryList?> duplicateList(String listId) async {
    try {
      final doc = await _firestore.collection('lists').doc(listId).get();
      if (!doc.exists) return null;

      final originalList = GroceryList.fromJson(doc.data()!);
      final newListId = _uuid.v4();
      final now = DateTime.now();

      final newList = originalList.copyWith(
        id: newListId,
        title: '${originalList.title} (Copy)',
        createdByUserId: userId,
        createdAt: now,
        updatedAt: now,
        sharedWith: [], // Don't copy sharing
        status: ListStatus.active,
        completedAt: null,
      );

      await _firestore.collection('lists').doc(newListId).set(newList.toJson());

      // Copy items
      final items = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();

      final batch = _firestore.batch();
      for (final itemDoc in items.docs) {
        final item = ListItem.fromJson(itemDoc.data());
        final newItemId = _uuid.v4();
        final newItem = item.copyWith(
          id: newItemId,
          listId: newListId,
          isCompleted: false,
          completedByUserId: null,
          completedAt: null,
          createdAt: now,
          updatedAt: now,
        );
        batch.set(
          _firestore.collection('lists').doc(newListId).collection('items').doc(newItemId),
          newItem.toJson(),
        );
      }
      await batch.commit();

      return newList;
    } catch (e) {
      _errorMessage = 'Failed to duplicate list: $e';
      notifyListeners();
      return null;
    }
  }

  void loadListItems(String listId) {
    _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      _currentListItems = snapshot.docs
          .map((doc) => ListItem.fromJson(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> addListItem({
    required String listId,
    required String content,
    String? notes,
  }) async {
    try {
      final itemId = _uuid.v4();
      final now = DateTime.now();

      final item = ListItem(
        id: itemId,
        listId: listId,
        content: content,
        notes: notes,
        createdByUserId: userId,
        createdAt: now,
        updatedAt: now,
        order: _currentListItems.length,
      );

      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .set(item.toJson());

      // Update list totals
      await _firestore.collection('lists').doc(listId).update({
        'totalItems': FieldValue.increment(1),
        'updatedAt': now.toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListItem(String listId, String itemId, {
    String? content,
    bool? isCompleted,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (content != null) updates['content'] = content;
      if (notes != null) updates['notes'] = notes;
      if (isCompleted != null) {
        updates['isCompleted'] = isCompleted;
        if (isCompleted) {
          updates['completedByUserId'] = userId;
          updates['completedAt'] = DateTime.now().toIso8601String();
          
          // Update completed count
          await _firestore.collection('lists').doc(listId).update({
            'completedItems': FieldValue.increment(1),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } else {
          updates['completedByUserId'] = null;
          updates['completedAt'] = null;
          
          // Decrease completed count
          await _firestore.collection('lists').doc(listId).update({
            'completedItems': FieldValue.increment(-1),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }

      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .update(updates);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListItem(String listId, String itemId) async {
    try {
      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .delete();

      await _firestore.collection('lists').doc(listId).update({
        'totalItems': FieldValue.increment(-1),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reorderItems(String listId, List<ListItem> reorderedItems) async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < reorderedItems.length; i++) {
        final itemRef = _firestore
            .collection('lists')
            .doc(listId)
            .collection('items')
            .doc(reorderedItems[i].id);
        
        batch.update(itemRef, {
          'order': i,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reorder items: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
