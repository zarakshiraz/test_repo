import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/lists/presentation/pages/list_detail_with_suggestions_page.dart';
import '../../features/lists/presentation/pages/create_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../pages/splash_page.dart';
import '../pages/main_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String lists = '/lists';
  static const String listDetail = '/list/:id';
  static const String createList = '/create-list';
  static const String profile = '/profile';
  static const String chat = '/chat/:listId';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            path: lists,
            name: 'lists',
            builder: (context, state) => const ListsPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'listDetail',
                builder: (context, state) {
                  final listId = state.pathParameters['id']!;
                  return ListDetailWithSuggestionsPage(listId: listId);
                },
              ),
              GoRoute(
                path: 'create',
                name: 'createList',
                builder: (context, state) => const CreateListPage(),
              ),
              GoRoute(
                path: 'chat/:listId',
                name: 'chat',
                builder: (context, state) {
                  final listId = state.pathParameters['listId']!;
                  return ChatPage(listId: listId);
                },
              ),
            ],
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(lists),
              child: const Text('Go to Lists'),
            ),
          ],
        ),
      ),
    ),
  );
}