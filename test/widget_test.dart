import 'package:flutter/material.dart';
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
import 'package:testing_repo/screens/todo_lists_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('widget_test');
    
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
  });

  testWidgets('App shows empty state initially', (WidgetTester tester) async {
    final localStorage = LocalStorageService();
    final firestore = FirestoreService();
    final syncService = SyncService(localStorage, firestore);
    final repository = TodoRepository(localStorage, syncService);

    await tester.pumpWidget(
      MaterialApp(
        home: TodoListsScreen(
          repository: repository,
          syncService: syncService,
        ),
      ),
    );

    expect(find.text('My Lists'), findsOneWidget);
    expect(find.text('No lists yet. Create one above!'), findsOneWidget);
  });

  testWidgets('Can create a todo list', (WidgetTester tester) async {
    final localStorage = LocalStorageService();
    final firestore = FirestoreService();
    final syncService = SyncService(localStorage, firestore);
    final repository = TodoRepository(localStorage, syncService);

    await tester.pumpWidget(
      MaterialApp(
        home: TodoListsScreen(
          repository: repository,
          syncService: syncService,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Shopping List');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('No lists yet. Create one above!'), findsNothing);
  });

  testWidgets('Shows sync status badge', (WidgetTester tester) async {
    final localStorage = LocalStorageService();
    final firestore = FirestoreService();
    final syncService = SyncService(localStorage, firestore);
    final repository = TodoRepository(localStorage, syncService);

    await repository.createTodoList('Test List');

    await tester.pumpWidget(
      MaterialApp(
        home: TodoListsScreen(
          repository: repository,
          syncService: syncService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
  });
}
