import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'repositories/list_repository.dart';
import 'repositories/notification_repository.dart';
import 'services/contact_service.dart';
import 'services/notification_service.dart';
import 'screens/lists_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Lists',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ListRepository _listRepository;
  late final NotificationRepository _notificationRepository;
  late final ContactService _contactService;
  late final NotificationService _notificationService;
  bool _initialized = false;

  final String _currentUserId = 'user1';
  final String _currentUserName = 'Test User';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _listRepository = ListRepository(currentUserId: _currentUserId);
    _notificationRepository =
        NotificationRepository(currentUserId: _currentUserId);
    _contactService = ContactService();
    _notificationService = NotificationService(
      _notificationRepository,
      messaging: FirebaseMessaging.instance,
    );

    await _notificationService.initialize();

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListsScreen(
      repository: _listRepository,
      contactService: _contactService,
      notificationService: _notificationService,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }
}
