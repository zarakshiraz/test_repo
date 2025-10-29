import 'package:uuid/uuid.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/message.dart';
import '../models/sync_status.dart';

class TodoRepository {
  final LocalStorageService _localStorage;
  final SyncService _syncService;
  final _uuid = const Uuid();

  TodoRepository(this._localStorage, this._syncService);

  Future<TodoList> createTodoList(String name) async {
    final now = DateTime.now();
    final list = TodoList(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _localStorage.saveTodoList(list);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }

    return list;
  }

  Future<void> updateTodoList(String id, String name) async {
    final list = _localStorage.getTodoList(id);
    if (list == null) return;

    list.name = name;
    list.updatedAt = DateTime.now();
    list.syncStatus = SyncStatus.pending;
    await list.save();

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  Future<void> deleteTodoList(String id) async {
    await _localStorage.deleteTodoList(id);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  Future<TodoItem> createTodoItem(String listId, String title) async {
    final now = DateTime.now();
    final item = TodoItem(
      id: _uuid.v4(),
      listId: listId,
      title: title,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _localStorage.saveTodoItem(item);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }

    return item;
  }

  Future<void> updateTodoItem(String id, {String? title, bool? completed}) async {
    final item = _localStorage.getTodoItem(id);
    if (item == null) return;

    if (title != null) item.title = title;
    if (completed != null) item.completed = completed;
    item.updatedAt = DateTime.now();
    item.syncStatus = SyncStatus.pending;
    await item.save();

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  Future<void> deleteTodoItem(String id) async {
    await _localStorage.deleteTodoItem(id);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  Future<Message> createMessage(String content) async {
    final now = DateTime.now();
    final message = Message(
      id: _uuid.v4(),
      content: content,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _localStorage.saveMessage(message);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }

    return message;
  }

  Future<void> updateMessage(String id, String content) async {
    final message = _localStorage.getMessage(id);
    if (message == null) return;

    message.content = content;
    message.updatedAt = DateTime.now();
    message.syncStatus = SyncStatus.pending;
    await message.save();

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  Future<void> deleteMessage(String id) async {
    await _localStorage.deleteMessage(id);

    if (_syncService.isOnline) {
      await _syncService.syncPendingChanges();
    }
  }

  List<TodoList> getAllTodoLists() {
    return _localStorage.getAllTodoLists();
  }

  List<TodoItem> getTodoItemsForList(String listId) {
    return _localStorage.getTodoItemsForList(listId);
  }

  List<Message> getAllMessages() {
    return _localStorage.getAllMessages();
  }

  int getPendingCount() {
    return _localStorage.getPendingCount();
  }
}
