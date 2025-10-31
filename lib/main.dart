import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'shared/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/models/user.dart';
import 'core/models/grocery_list.dart';
import 'core/models/list_item.dart';
import 'core/models/message.dart';
import 'core/models/contact.dart';
import 'core/models/app_notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Setup FCM background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize FCM service
    await FCMService().initialize();
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
  
  runApp(const GrocliApp());
}

class GrocliApp extends StatelessWidget {
  const GrocliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Other providers will be created after auth is initialized
        // See AppRouter for provider creation based on auth state
      ],
      child: Consumer<AuthProvider>(
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
