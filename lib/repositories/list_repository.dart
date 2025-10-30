import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list.dart';
import '../models/list_item.dart';
import '../models/participant.dart';
import '../constants/permissions.dart';

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);

  @override
  String toString() => message;
}

class ListRepository {
  final FirebaseFirestore _firestore;
  final String currentUserId;

  ListRepository({
    required this.currentUserId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<PermissionRole?> getUserRole(String listId) async {
    final participantDoc = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .doc(currentUserId)
        .get();

    if (!participantDoc.exists) {
      return null;
    }

    final data = participantDoc.data()!;
    return permissionRoleFromString(data['role'] as String);
  }

  Future<void> _checkPermission(
      String listId, bool Function(PermissionRole) check) async {
    final role = await getUserRole(listId);
    if (role == null || !check(role)) {
      throw PermissionException('Insufficient permissions to perform this action');
    }
  }

  Stream<List<TodoList>> getUserLists() {
    return _firestore
        .collection('lists')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoList.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<TodoList> createList(String title, String ownerName) async {
    final now = DateTime.now();
    final listData = {
      'title': title,
      'ownerId': currentUserId,
      'ownerName': ownerName,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isShared': false,
      'participantCount': 1,
      'participantIds': [currentUserId],
    };

    final docRef = await _firestore.collection('lists').add(listData);

    await docRef.collection('participants').doc(currentUserId).set({
      'userId': currentUserId,
      'userName': ownerName,
      'userEmail': '',
      'role': PermissionRole.owner.value,
      'addedAt': now.toIso8601String(),
    });

    return TodoList.fromJson({...listData, 'id': docRef.id});
  }

  Future<void> updateList(String listId, String title) async {
    await _checkPermission(listId, (role) => role.canEdit);

    await _firestore.collection('lists').doc(listId).update({
      'title': title,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteList(String listId) async {
    await _checkPermission(listId, (role) => role.canDelete);

    final batch = _firestore.batch();
    batch.delete(_firestore.collection('lists').doc(listId));

    final participants = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .get();

    for (final doc in participants.docs) {
      batch.delete(doc.reference);
    }

    final items = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .get();

    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<ListItem>> getListItems(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListItem.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<ListItem> addItem(String listId, String title) async {
    await _checkPermission(listId, (role) => role.canEdit);

    final now = DateTime.now();
    final itemData = {
      'title': title,
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'createdBy': currentUserId,
    };

    final docRef = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .add(itemData);

    await _firestore.collection('lists').doc(listId).update({
      'updatedAt': now.toIso8601String(),
    });

    return ListItem.fromJson({...itemData, 'id': docRef.id});
  }

  Future<void> updateItem(String listId, String itemId, {String? title, bool? isCompleted}) async {
    await _checkPermission(listId, (role) => role.canEdit);

    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (isCompleted != null) updates['isCompleted'] = isCompleted;

    if (updates.isEmpty) return;

    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update(updates);

    await _firestore.collection('lists').doc(listId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await _checkPermission(listId, (role) => role.canEdit);

    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .delete();

    await _firestore.collection('lists').doc(listId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Participant>> getParticipants(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .orderBy('addedAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Participant.fromJson(doc.data())).toList());
  }

  Future<void> addParticipants(
      String listId, List<Participant> participants) async {
    await _checkPermission(listId, (role) => role.canShare);

    final batch = _firestore.batch();
    final listRef = _firestore.collection('lists').doc(listId);

    for (final participant in participants) {
      final participantRef =
          listRef.collection('participants').doc(participant.userId);
      batch.set(participantRef, participant.toJson());
    }

    final listDoc = await listRef.get();
    final currentParticipantIds =
        List<String>.from(listDoc.data()?['participantIds'] ?? []);
    final newParticipantIds =
        participants.map((p) => p.userId).where((id) => !currentParticipantIds.contains(id)).toList();

    batch.update(listRef, {
      'isShared': true,
      'participantCount': FieldValue.increment(newParticipantIds.length),
      'participantIds': FieldValue.arrayUnion(newParticipantIds),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  Future<void> updateParticipantRole(
      String listId, String participantId, PermissionRole newRole) async {
    await _checkPermission(listId, (role) => role.canShare);

    final listDoc = await _firestore.collection('lists').doc(listId).get();
    if (participantId == listDoc.data()?['ownerId']) {
      throw PermissionException('Cannot change the owner\'s role');
    }

    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .doc(participantId)
        .update({
      'role': newRole.value,
    });
  }

  Future<void> removeParticipant(String listId, String participantId) async {
    await _checkPermission(listId, (role) => role.canShare);

    final listDoc = await _firestore.collection('lists').doc(listId).get();
    if (participantId == listDoc.data()?['ownerId']) {
      throw PermissionException('Cannot remove the owner from the list');
    }

    final batch = _firestore.batch();

    batch.delete(_firestore
        .collection('lists')
        .doc(listId)
        .collection('participants')
        .doc(participantId));

    batch.update(_firestore.collection('lists').doc(listId), {
      'participantCount': FieldValue.increment(-1),
      'participantIds': FieldValue.arrayRemove([participantId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }
}
