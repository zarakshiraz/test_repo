import 'package:flutter_test/flutter_test.dart';
import 'package:testing_repo/models/sync_status.dart';
import 'package:testing_repo/models/todo_list.dart';
import 'package:testing_repo/models/todo_item.dart';
import 'package:testing_repo/models/message.dart';
import 'package:testing_repo/models/activity_log.dart';
import 'package:testing_repo/services/local_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late LocalStorageService localStorage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('test_sync');
    
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
  });

  tearDown(() async {
    await localStorage.clearAll();
  });

  group('Sync Status Management', () {
    test('New items have pending status', () async {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Test List',
        createdAt: now,
        updatedAt: now,
      );

      await localStorage.saveTodoList(list);

      final saved = localStorage.getTodoList('test-1');
      expect(saved!.syncStatus, SyncStatus.pending);
    });

    test('Update sync status to synced', () async {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Test List',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );

      await localStorage.saveTodoList(list);
      
      list.syncStatus = SyncStatus.synced;
      await list.save();

      final saved = localStorage.getTodoList('test-1');
      expect(saved!.syncStatus, SyncStatus.synced);
    });

    test('Update sync status to conflict', () async {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Test List',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );

      await localStorage.saveTodoList(list);
      
      list.syncStatus = SyncStatus.conflict;
      await list.save();

      final saved = localStorage.getTodoList('test-1');
      expect(saved!.syncStatus, SyncStatus.conflict);
    });
  });

  group('Conflict Resolution - Last Writer Wins', () {
    test('Local newer than remote - local wins', () {
      final localTime = DateTime.now();
      final remoteTime = localTime.subtract(const Duration(minutes: 5));

      final shouldUseRemote = remoteTime.isAfter(localTime);
      
      expect(shouldUseRemote, false);
    });

    test('Remote newer than local - remote wins', () {
      final localTime = DateTime.now();
      final remoteTime = localTime.add(const Duration(minutes: 5));

      final shouldUseRemote = remoteTime.isAfter(localTime);
      
      expect(shouldUseRemote, true);
    });

    test('Same timestamp - no conflict', () {
      final timestamp = DateTime.now();

      final shouldUseRemote = timestamp.isAfter(timestamp);
      
      expect(shouldUseRemote, false);
    });
  });

  group('Firestore Data Conversion', () {
    test('TodoList converts to and from Firestore format', () {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Test List',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
        isDeleted: false,
      );

      final firestoreData = list.toFirestore();
      expect(firestoreData['id'], 'test-1');
      expect(firestoreData['name'], 'Test List');
      expect(firestoreData['isDeleted'], false);
      expect(firestoreData['createdAt'], isA<String>());

      final reconstructed = TodoList.fromFirestore(firestoreData);
      expect(reconstructed.id, list.id);
      expect(reconstructed.name, list.name);
      expect(reconstructed.isDeleted, list.isDeleted);
      expect(reconstructed.syncStatus, SyncStatus.synced);
    });

    test('TodoItem converts to and from Firestore format', () {
      final now = DateTime.now();
      final item = TodoItem(
        id: 'item-1',
        listId: 'list-1',
        title: 'Test Item',
        completed: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
        isDeleted: false,
      );

      final firestoreData = item.toFirestore();
      expect(firestoreData['id'], 'item-1');
      expect(firestoreData['listId'], 'list-1');
      expect(firestoreData['title'], 'Test Item');
      expect(firestoreData['completed'], false);

      final reconstructed = TodoItem.fromFirestore(firestoreData);
      expect(reconstructed.id, item.id);
      expect(reconstructed.listId, item.listId);
      expect(reconstructed.title, item.title);
      expect(reconstructed.completed, item.completed);
    });
  });

  group('Copy With Pattern', () {
    test('TodoList copyWith creates new instance with updated fields', () {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.copyWith(
        name: 'Updated',
        syncStatus: SyncStatus.synced,
      );

      expect(updated.id, list.id);
      expect(updated.name, 'Updated');
      expect(updated.syncStatus, SyncStatus.synced);
      expect(list.name, 'Original');
    });

    test('TodoItem copyWith creates new instance with updated fields', () {
      final now = DateTime.now();
      final item = TodoItem(
        id: 'item-1',
        listId: 'list-1',
        title: 'Original',
        completed: false,
        createdAt: now,
        updatedAt: now,
      );

      final updated = item.copyWith(
        title: 'Updated',
        completed: true,
      );

      expect(updated.id, item.id);
      expect(updated.title, 'Updated');
      expect(updated.completed, true);
      expect(item.title, 'Original');
      expect(item.completed, false);
    });
  });

  group('Pending Changes Filtering', () {
    test('Get only pending lists', () async {
      final now = DateTime.now();
      
      await localStorage.saveTodoList(TodoList(
        id: '1',
        name: 'Pending',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ));
      
      await localStorage.saveTodoList(TodoList(
        id: '2',
        name: 'Synced',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ));
      
      await localStorage.saveTodoList(TodoList(
        id: '3',
        name: 'Conflict',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.conflict,
      ));

      final pending = localStorage.getPendingTodoLists();
      
      expect(pending.length, 1);
      expect(pending[0].id, '1');
      expect(pending[0].syncStatus, SyncStatus.pending);
    });
  });

  group('Soft Delete Behavior', () {
    test('Deleted items are marked but not removed', () async {
      final now = DateTime.now();
      final list = TodoList(
        id: 'test-1',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      await localStorage.saveTodoList(list);
      await localStorage.deleteTodoList('test-1');

      final deleted = localStorage.getTodoList('test-1');
      expect(deleted, isNotNull);
      expect(deleted!.isDeleted, true);
    });

    test('Deleted items not returned in getAllTodoLists', () async {
      final now = DateTime.now();
      
      await localStorage.saveTodoList(TodoList(
        id: '1',
        name: 'Active',
        createdAt: now,
        updatedAt: now,
      ));
      
      await localStorage.saveTodoList(TodoList(
        id: '2',
        name: 'To Delete',
        createdAt: now,
        updatedAt: now,
      ));

      await localStorage.deleteTodoList('2');

      final lists = localStorage.getAllTodoLists();
      expect(lists.length, 1);
      expect(lists[0].id, '1');
    });
  });
}
