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
    Hive.init('airplane_test');
    
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

  group('Airplane Mode Simulation', () {
    test('Scenario: User creates lists while offline', () async {
      final groceryList = await repository.createTodoList('Grocery Shopping');
      expect(groceryList.syncStatus, SyncStatus.pending);

      final workList = await repository.createTodoList('Work Tasks');
      expect(workList.syncStatus, SyncStatus.pending);

      expect(repository.getPendingCount(), 2);

      final lists = repository.getAllTodoLists();
      expect(lists.length, 2);
      expect(lists.any((l) => l.name == 'Grocery Shopping'), true);
      expect(lists.any((l) => l.name == 'Work Tasks'), true);
    });

    test('Scenario: User adds items to lists while offline', () async {
      final list = await repository.createTodoList('Shopping');
      
      final item1 = await repository.createTodoItem(list.id, 'Milk');
      final item2 = await repository.createTodoItem(list.id, 'Bread');
      final item3 = await repository.createTodoItem(list.id, 'Eggs');

      expect(item1.syncStatus, SyncStatus.pending);
      expect(item2.syncStatus, SyncStatus.pending);
      expect(item3.syncStatus, SyncStatus.pending);

      final items = repository.getTodoItemsForList(list.id);
      expect(items.length, 3);
      
      expect(repository.getPendingCount(), 4);
    });

    test('Scenario: User completes tasks while offline', () async {
      final list = await repository.createTodoList('Tasks');
      final item1 = await repository.createTodoItem(list.id, 'Task 1');
      final item2 = await repository.createTodoItem(list.id, 'Task 2');

      await repository.updateTodoItem(item1.id, completed: true);

      final updated = localStorage.getTodoItem(item1.id);
      expect(updated!.completed, true);
      expect(updated.syncStatus, SyncStatus.pending);

      final notUpdated = localStorage.getTodoItem(item2.id);
      expect(notUpdated!.completed, false);
    });

    test('Scenario: User edits list and item names while offline', () async {
      final list = await repository.createTodoList('Original List');
      final item = await repository.createTodoItem(list.id, 'Original Item');

      await repository.updateTodoList(list.id, 'Edited List');
      await repository.updateTodoItem(item.id, title: 'Edited Item');

      final updatedList = localStorage.getTodoList(list.id);
      final updatedItem = localStorage.getTodoItem(item.id);

      expect(updatedList!.name, 'Edited List');
      expect(updatedItem!.title, 'Edited Item');
      
      expect(updatedList.syncStatus, SyncStatus.pending);
      expect(updatedItem.syncStatus, SyncStatus.pending);
    });

    test('Scenario: User deletes items while offline', () async {
      final list = await repository.createTodoList('My List');
      final item1 = await repository.createTodoItem(list.id, 'Keep this');
      final item2 = await repository.createTodoItem(list.id, 'Delete this');

      await repository.deleteTodoItem(item2.id);

      final items = repository.getTodoItemsForList(list.id);
      expect(items.length, 1);
      expect(items[0].id, item1.id);

      final deletedItem = localStorage.getTodoItem(item2.id);
      expect(deletedItem!.isDeleted, true);
      expect(deletedItem.syncStatus, SyncStatus.pending);
    });

    test('Scenario: Complex workflow - create, edit, complete, delete offline', 
        () async {
      final shoppingList = await repository.createTodoList('Shopping List');
      
      final milk = await repository.createTodoItem(shoppingList.id, 'Milk');
      await repository.createTodoItem(shoppingList.id, 'Bread');
      final eggs = await repository.createTodoItem(shoppingList.id, 'Eggs');
      
      await repository.updateTodoItem(
        milk.id,
        title: 'Almond Milk',
        completed: true,
      );
      
      await repository.deleteTodoItem(eggs.id);
      
      await repository.updateTodoList(shoppingList.id, 'Grocery List');

      final list = localStorage.getTodoList(shoppingList.id);
      expect(list!.name, 'Grocery List');
      expect(list.syncStatus, SyncStatus.pending);

      final items = repository.getTodoItemsForList(shoppingList.id);
      expect(items.length, 2);
      
      final milkItem = localStorage.getTodoItem(milk.id);
      expect(milkItem!.title, 'Almond Milk');
      expect(milkItem.completed, true);

      expect(repository.getPendingCount(), greaterThan(0));
    });

    test('Scenario: UI shows pending count for sync badge', () async {
      expect(repository.getPendingCount(), 0);

      await repository.createTodoList('List 1');
      expect(repository.getPendingCount(), 1);

      await repository.createTodoList('List 2');
      expect(repository.getPendingCount(), 2);

      final list = await repository.createTodoList('List 3');
      await repository.createTodoItem(list.id, 'Item 1');
      await repository.createTodoItem(list.id, 'Item 2');
      
      expect(repository.getPendingCount(), 5);
    });

    test('Scenario: Data persists across app restarts (simulated)', () async {
      final list = await repository.createTodoList('Persistent List');
      final item = await repository.createTodoItem(list.id, 'Persistent Item');

      final listId = list.id;
      final itemId = item.id;

      final retrievedList = localStorage.getTodoList(listId);
      final retrievedItem = localStorage.getTodoItem(itemId);

      expect(retrievedList, isNotNull);
      expect(retrievedItem, isNotNull);
      expect(retrievedList!.name, 'Persistent List');
      expect(retrievedItem!.title, 'Persistent Item');
      expect(retrievedList.syncStatus, SyncStatus.pending);
      expect(retrievedItem.syncStatus, SyncStatus.pending);
    });
  });

  group('Reconnection Scenarios', () {
    test('Scenario: Pending items queued for sync', () async {
      await repository.createTodoList('List 1');
      await repository.createTodoList('List 2');
      final list = await repository.createTodoList('List 3');
      await repository.createTodoItem(list.id, 'Item 1');

      final pendingLists = localStorage.getPendingTodoLists();
      final pendingItems = localStorage.getPendingTodoItems();

      expect(pendingLists.length, 3);
      expect(pendingItems.length, 1);
      
      expect(pendingLists.every((l) => l.syncStatus == SyncStatus.pending), true);
      expect(pendingItems.every((i) => i.syncStatus == SyncStatus.pending), true);
    });

    test('Scenario: Sync status changes after successful sync', () async {
      final list = await repository.createTodoList('Test List');
      expect(list.syncStatus, SyncStatus.pending);

      list.syncStatus = SyncStatus.synced;
      await list.save();

      final syncedList = localStorage.getTodoList(list.id);
      expect(syncedList!.syncStatus, SyncStatus.synced);
      
      final pendingLists = localStorage.getPendingTodoLists();
      expect(pendingLists.any((l) => l.id == list.id), false);
    });
  });

  group('Edge Cases', () {
    test('Scenario: Empty app state - no pending items', () {
      expect(repository.getPendingCount(), 0);
      expect(repository.getAllTodoLists().length, 0);
    });

    test('Scenario: Rapid create operations', () async {
      final lists = <TodoList>[];
      for (int i = 0; i < 10; i++) {
        final list = await repository.createTodoList('List $i');
        lists.add(list);
      }

      expect(lists.length, 10);
      expect(repository.getPendingCount(), 10);
      expect(repository.getAllTodoLists().length, 10);
    });

    test('Scenario: Update immediately after create', () async {
      final list = await repository.createTodoList('Original');
      await repository.updateTodoList(list.id, 'Updated');

      final updated = localStorage.getTodoList(list.id);
      expect(updated!.name, 'Updated');
      expect(updated.updatedAt.isAfter(updated.createdAt), true);
    });

    test('Scenario: Delete immediately after create', () async {
      final list = await repository.createTodoList('Temporary');
      await repository.deleteTodoList(list.id);

      final deleted = localStorage.getTodoList(list.id);
      expect(deleted!.isDeleted, true);
      
      final visibleLists = repository.getAllTodoLists();
      expect(visibleLists.any((l) => l.id == list.id), false);
    });
  });
}
