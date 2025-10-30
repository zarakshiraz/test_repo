import '../models/list_summary.dart';
import '../models/list_item.dart';
import '../models/list_activity.dart';
import '../models/list_permission.dart';
import '../enums/list_status.dart';

/// Repository interface for list operations.
/// Supports dependency inversion by defining contracts for data operations.
abstract class ListRepository {
  // List CRUD operations
  Future<ListSummary> createList(ListSummary list);
  Future<ListSummary?> getList(String listId);
  Future<void> updateList(ListSummary list);
  Future<void> deleteList(String listId);

  // List queries
  Future<List<ListSummary>> getUserLists(String userId);
  Future<List<ListSummary>> getSharedLists(String userId);
  Future<List<ListSummary>> getListsByStatus(String userId, ListStatus status);
  Stream<List<ListSummary>> watchUserLists(String userId);
  Stream<ListSummary?> watchList(String listId);

  // Item operations
  Future<ListItem> addItem(ListItem item);
  Future<ListItem?> getItem(String listId, String itemId);
  Future<void> updateItem(ListItem item);
  Future<void> deleteItem(String listId, String itemId);
  Future<List<ListItem>> getListItems(String listId);
  Stream<List<ListItem>> watchListItems(String listId);

  // Permission operations
  Future<void> addParticipant(String listId, ListPermission permission);
  Future<void> updateParticipant(String listId, ListPermission permission);
  Future<void> removeParticipant(String listId, String userId);
  Future<List<ListPermission>> getParticipants(String listId);

  // Activity operations
  Future<void> logActivity(ListActivity activity);
  Future<List<ListActivity>> getListActivities(String listId, {int limit = 50});
  Stream<List<ListActivity>> watchListActivities(String listId, {int limit = 50});

  // Batch operations
  Future<void> completeList(String listId);
  Future<void> archiveList(String listId);
  Future<void> restoreList(String listId);

  // Offline support placeholders
  Future<void> syncPendingChanges();
  Future<bool> hasPendingChanges();
}
