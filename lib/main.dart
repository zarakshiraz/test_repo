import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_storage_service.dart';
import 'services/firestore_service.dart';
import 'services/sync_service.dart';
import 'services/todo_repository.dart';
import 'screens/todo_lists_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: 'demo-app-id',
      messagingSenderId: 'demo-sender-id',
      projectId: 'demo-project',
    ),
  );
  
  await LocalStorageService.init();
  
  try {
    await FirestoreService.enablePersistence();
  } catch (e) {
    // Firestore persistence already enabled or not supported
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocalStorageService _localStorage;
  late final FirestoreService _firestore;
  late final SyncService _syncService;
  late final TodoRepository _repository;

  @override
  void initState() {
    super.initState();
    _localStorage = LocalStorageService();
    _firestore = FirestoreService();
    _syncService = SyncService(_localStorage, _firestore);
    _repository = TodoRepository(_localStorage, _syncService);
    
    _syncService.pullRemoteChanges();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TodoListsScreen(
        repository: _repository,
        syncService: _syncService,
      ),
    );
  }
}
