import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/app_settings.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'screens/lists_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/list_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AppSettings _settings = AppSettings();
  final NotificationService _notificationService = NotificationService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize(
      onNotificationTap: _navigateToList,
      settings: _settings,
    );
    
    setState(() {
      _initialized = true;
    });
  }

  void _navigateToList(String listId) async {
    final firebaseService = FirebaseService();
    final list = await firebaseService.getList(listId);
    
    if (list != null && _navigatorKey.currentContext != null) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ListDetailScreen(
            list: list,
            userId: 'demo-user',
          ),
        ),
      );
    }
  }

  void _updateSettings(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
    _notificationService.updateSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Reminders App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const MyHomePage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _userId = 'demo-user';

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListsScreen(userId: _userId),
    );
  }
}
