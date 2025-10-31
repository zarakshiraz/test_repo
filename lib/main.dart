import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/models/user.dart';
import 'core/models/grocery_list.dart';
import 'core/models/list_item.dart';
import 'core/models/message.dart';
import 'core/models/contact.dart';
import 'core/models/app_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await Hive.initFlutter();

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

  tz.initializeTimeZones();

  runApp(const ProviderScope(child: GrocliApp()));
}

class GrocliApp extends ConsumerWidget {
  const GrocliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Grocli - Collaborative Smart Lists',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
