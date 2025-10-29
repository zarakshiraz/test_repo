import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/message.dart';
import '../models/activity_log.dart';
import '../models/sync_status.dart';

class LocalStorageService {
  static const String todoListsBox = 'todoLists';
  static const String todoItemsBox = 'todoItems';
  static const String messagesBox = 'messages';
  static const String activityLogsBox = 'activityLogs';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(TodoListAdapter());
    Hive.registerAdapter(TodoItemAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ActivityLogAdapter());

    await Hive.openBox<TodoList>(todoListsBox);
    await Hive.openBox<TodoItem>(todoItemsBox);
    await Hive.openBox<Message>(messagesBox);
    await Hive.openBox<ActivityLog>(activityLogsBox);
  }

  Box<TodoList> get todoListsBoxInstance => Hive.box<TodoList>(todoListsBox);
  Box<TodoItem> get todoItemsBoxInstance => Hive.box<TodoItem>(todoItemsBox);
  Box<Message> get messagesBoxInstance => Hive.box<Message>(messagesBox);
  Box<ActivityLog> get activityLogsBoxInstance => Hive.box<ActivityLog>(activityLogsBox);

  Future<void> saveTodoList(TodoList list) async {
    await todoListsBoxInstance.put(list.id, list);
  }

  Future<void> saveTodoItem(TodoItem item) async {
    await todoItemsBoxInstance.put(item.id, item);
  }

  Future<void> saveMessage(Message message) async {
    await messagesBoxInstance.put(message.id, message);
  }

  Future<void> saveActivityLog(ActivityLog log) async {
    await activityLogsBoxInstance.put(log.id, log);
  }

  List<TodoList> getAllTodoLists() {
    return todoListsBoxInstance.values
        .where((list) => !list.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<TodoItem> getTodoItemsForList(String listId) {
    return todoItemsBoxInstance.values
        .where((item) => item.listId == listId && !item.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Message> getAllMessages() {
    return messagesBoxInstance.values
        .where((message) => !message.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<ActivityLog> getRecentActivityLogs({int limit = 50}) {
    final logs = activityLogsBoxInstance.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  TodoList? getTodoList(String id) {
    return todoListsBoxInstance.get(id);
  }

  TodoItem? getTodoItem(String id) {
    return todoItemsBoxInstance.get(id);
  }

  Message? getMessage(String id) {
    return messagesBoxInstance.get(id);
  }

  Future<void> deleteTodoList(String id) async {
    final list = todoListsBoxInstance.get(id);
    if (list != null) {
      list.isDeleted = true;
      list.syncStatus = SyncStatus.pending;
      list.updatedAt = DateTime.now();
      await list.save();
    }
  }

  Future<void> deleteTodoItem(String id) async {
    final item = todoItemsBoxInstance.get(id);
    if (item != null) {
      item.isDeleted = true;
      item.syncStatus = SyncStatus.pending;
      item.updatedAt = DateTime.now();
      await item.save();
    }
  }

  Future<void> deleteMessage(String id) async {
    final message = messagesBoxInstance.get(id);
    if (message != null) {
      message.isDeleted = true;
      message.syncStatus = SyncStatus.pending;
      message.updatedAt = DateTime.now();
      await message.save();
    }
  }

  List<TodoList> getPendingTodoLists() {
    return todoListsBoxInstance.values
        .where((list) => list.syncStatus == SyncStatus.pending)
        .toList();
  }

  List<TodoItem> getPendingTodoItems() {
    return todoItemsBoxInstance.values
        .where((item) => item.syncStatus == SyncStatus.pending)
        .toList();
  }

  List<Message> getPendingMessages() {
    return messagesBoxInstance.values
        .where((message) => message.syncStatus == SyncStatus.pending)
        .toList();
  }

  int getPendingCount() {
    return getPendingTodoLists().length +
        getPendingTodoItems().length +
        getPendingMessages().length;
  }

  Future<void> clearAll() async {
    await todoListsBoxInstance.clear();
    await todoItemsBoxInstance.clear();
    await messagesBoxInstance.clear();
    await activityLogsBoxInstance.clear();
  }
}
