import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/models/user.dart';
import 'core/models/grocery_list.dart';
import 'core/models/list_item.dart';
import 'core/models/message.dart';
import 'core/models/contact.dart';
import 'core/models/app_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: Run `flutterfire configure` to generate firebase_options.dart
  // For now using default initialization
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue without Firebase for development
  }
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ListItemAdapter());
  Hive.registerAdapter(ListPermissionAdapter());
  Hive.registerAdapter(ListStatusAdapter());
  Hive.registerAdapter(SharedUserAdapter());
  Hive.registerAdapter(GroceryListAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  runApp(const ProviderScope(child: GrocliApp()));
}

class GrocliApp extends StatelessWidget {
  const GrocliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Other providers will be created after auth is initialized
        // See AppRouter for provider creation based on auth state
      ],
      child: provider.Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Grocli - Collaborative Smart Lists',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
