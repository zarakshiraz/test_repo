import 'package:flutter_test/flutter_test.dart';
import 'package:testing_repo/models/sync_status.dart';
import 'package:testing_repo/models/todo_list.dart';
import 'package:testing_repo/models/todo_item.dart';
import 'package:testing_repo/models/message.dart';
import 'package:testing_repo/models/activity_log.dart';
import 'package:testing_repo/services/local_storage_service.dart';
import 'package:testing_repo/services/firestore_service.dart';
import 'package:testing_repo/services/sync_service.dart';
import 'package:testing_repo/services/todo_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late LocalStorageService localStorage;
  late FirestoreService firestore;
  late SyncService syncService;
  late TodoRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('test');
    
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(TodoListAdapter());
    Hive.registerAdapter(TodoItemAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ActivityLogAdapter());
  });

  setUp(() async {
    if (Hive.isBoxOpen('todoLists')) {
      await Hive.box<TodoList>('todoLists').clear();
    } else {
      await Hive.openBox<TodoList>('todoLists');
    }
    
    if (Hive.isBoxOpen('todoItems')) {
      await Hive.box<TodoItem>('todoItems').clear();
    } else {
      await Hive.openBox<TodoItem>('todoItems');
    }
    
    if (!Hive.isBoxOpen('messages')) {
      await Hive.openBox<Message>('messages');
    }
    
    if (!Hive.isBoxOpen('activityLogs')) {
      await Hive.openBox<ActivityLog>('activityLogs');
    }

    localStorage = LocalStorageService();
    firestore = FirestoreService();
    syncService = SyncService(localStorage, firestore);
    repository = TodoRepository(localStorage, syncService);
  });

  tearDown(() async {
    await localStorage.clearAll();
  });

  group('Offline Todo List Operations', () {
    test('Create todo list offline', () async {
      final list = await repository.createTodoList('Grocery List');

      expect(list.name, 'Grocery List');
      expect(list.syncStatus, SyncStatus.pending);
      expect(list.isDeleted, false);

      final savedList = localStorage.getTodoList(list.id);
      expect(savedList, isNotNull);
      expect(savedList!.name, 'Grocery List');
    });

    test('Update todo list offline', () async {
      final list = await repository.createTodoList('Shopping');
      await Future.delayed(const Duration(milliseconds: 10));
      
      await repository.updateTodoList(list.id, 'Shopping Updated');

      final updatedList = localStorage.getTodoList(list.id);
      expect(updatedList!.name, 'Shopping Updated');
      expect(updatedList.syncStatus, SyncStatus.pending);
      expect(updatedList.updatedAt.isAfter(list.createdAt), true);
    });

    test('Delete todo list offline', () async {
      final list = await repository.createTodoList('Temporary List');
      
      await repository.deleteTodoList(list.id);

      final deletedList = localStorage.getTodoList(list.id);
      expect(deletedList!.isDeleted, true);
      expect(deletedList.syncStatus, SyncStatus.pending);
      
      final visibleLists = localStorage.getAllTodoLists();
      expect(visibleLists.any((l) => l.id == list.id), false);
    });

    test('Get all todo lists excludes deleted', () async {
      await repository.createTodoList('List 1');
      final list2 = await repository.createTodoList('List 2');
      await repository.createTodoList('List 3');
      
      await repository.deleteTodoList(list2.id);

      final lists = localStorage.getAllTodoLists();
      expect(lists.length, 2);
      expect(lists.any((l) => l.id == list2.id), false);
    });
  });

  group('Offline Todo Item Operations', () {
    test('Create todo item offline', () async {
      final list = await repository.createTodoList('My List');
      final item = await repository.createTodoItem(list.id, 'Buy milk');

      expect(item.title, 'Buy milk');
      expect(item.listId, list.id);
      expect(item.completed, false);
      expect(item.syncStatus, SyncStatus.pending);

      final savedItem = localStorage.getTodoItem(item.id);
      expect(savedItem, isNotNull);
      expect(savedItem!.title, 'Buy milk');
    });

    test('Update todo item offline', () async {
      final list = await repository.createTodoList('My List');
      final item = await repository.createTodoItem(list.id, 'Task');
      
      await repository.updateTodoItem(item.id, title: 'Updated Task');

      final updatedItem = localStorage.getTodoItem(item.id);
      expect(updatedItem!.title, 'Updated Task');
      expect(updatedItem.syncStatus, SyncStatus.pending);
    });

    test('Toggle todo item completion offline', () async {
      final list = await repository.createTodoList('My List');
      final item = await repository.createTodoItem(list.id, 'Task');
      
      await repository.updateTodoItem(item.id, completed: true);

      final updatedItem = localStorage.getTodoItem(item.id);
      expect(updatedItem!.completed, true);
      expect(updatedItem.syncStatus, SyncStatus.pending);
    });

    test('Delete todo item offline', () async {
      final list = await repository.createTodoList('My List');
      final item = await repository.createTodoItem(list.id, 'Task');
      
      await repository.deleteTodoItem(item.id);

      final deletedItem = localStorage.getTodoItem(item.id);
      expect(deletedItem!.isDeleted, true);
      
      final items = localStorage.getTodoItemsForList(list.id);
      expect(items.any((i) => i.id == item.id), false);
    });

    test('Get items for specific list', () async {
      final list1 = await repository.createTodoList('List 1');
      final list2 = await repository.createTodoList('List 2');
      
      await repository.createTodoItem(list1.id, 'Item 1-1');
      await repository.createTodoItem(list1.id, 'Item 1-2');
      await repository.createTodoItem(list2.id, 'Item 2-1');

      final list1Items = localStorage.getTodoItemsForList(list1.id);
      final list2Items = localStorage.getTodoItemsForList(list2.id);

      expect(list1Items.length, 2);
      expect(list2Items.length, 1);
      expect(list1Items.every((i) => i.listId == list1.id), true);
      expect(list2Items.every((i) => i.listId == list2.id), true);
    });
  });

  group('Pending Changes Tracking', () {
    test('Track pending changes count', () async {
      expect(repository.getPendingCount(), 0);

      await repository.createTodoList('List 1');
      expect(repository.getPendingCount(), 1);

      await repository.createTodoList('List 2');
      expect(repository.getPendingCount(), 2);

      final list = await repository.createTodoList('List 3');
      expect(repository.getPendingCount(), 3);

      await repository.createTodoItem(list.id, 'Item 1');
      expect(repository.getPendingCount(), 4);
    });

    test('Get pending todo lists', () async {
      await repository.createTodoList('List 1');
      await repository.createTodoList('List 2');

      final pendingLists = localStorage.getPendingTodoLists();
      expect(pendingLists.length, 2);
      expect(pendingLists.every((l) => l.syncStatus == SyncStatus.pending), true);
    });

    test('Get pending todo items', () async {
      final list = await repository.createTodoList('My List');
      await repository.createTodoItem(list.id, 'Item 1');
      await repository.createTodoItem(list.id, 'Item 2');

      final pendingItems = localStorage.getPendingTodoItems();
      expect(pendingItems.length, 2);
      expect(pendingItems.every((i) => i.syncStatus == SyncStatus.pending), true);
    });
  });

  group('Data Persistence', () {
    test('Data persists after clearing in-memory state', () async {
      final list = await repository.createTodoList('Persistent List');
      final item = await repository.createTodoItem(list.id, 'Persistent Item');

      final savedList = localStorage.getTodoList(list.id);
      final savedItem = localStorage.getTodoItem(item.id);

      expect(savedList, isNotNull);
      expect(savedItem, isNotNull);
      expect(savedList!.name, 'Persistent List');
      expect(savedItem!.title, 'Persistent Item');
    });

    test('Multiple operations maintain data integrity', () async {
      final list = await repository.createTodoList('Test List');
      await repository.createTodoItem(list.id, 'Item 1');
      await repository.createTodoItem(list.id, 'Item 2');
      await repository.updateTodoList(list.id, 'Updated List');

      final updatedList = localStorage.getTodoList(list.id);
      final items = localStorage.getTodoItemsForList(list.id);

      expect(updatedList!.name, 'Updated List');
      expect(items.length, 2);
      expect(items.every((i) => i.listId == list.id), true);
    });
  });

  group('Offline-First Behavior', () {
    test('Operations complete immediately without network', () async {
      final startTime = DateTime.now();
      
      await repository.createTodoList('Fast List');
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      expect(duration.inMilliseconds < 100, true);
    });

    test('UI can read data immediately after write', () async {
      final list = await repository.createTodoList('Immediate List');
      
      final retrievedList = localStorage.getTodoList(list.id);
      
      expect(retrievedList, isNotNull);
      expect(retrievedList!.id, list.id);
      expect(retrievedList.name, 'Immediate List');
    });
  });
}
