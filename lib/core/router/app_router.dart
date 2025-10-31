import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/lists/presentation/pages/list_detail_page.dart';
import '../../features/lists/presentation/pages/create_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../pages/splash_page.dart';
import '../pages/main_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String lists = '/lists';
  static const String listDetail = '/list/:id';
  static const String createList = '/create-list';
  static const String profile = '/profile';
  static const String chat = '/chat/:listId';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRouter.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRouter.login ||
          state.matchedLocation == AppRouter.register ||
          state.matchedLocation == AppRouter.forgotPassword ||
          state.matchedLocation == AppRouter.splash;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRouter.login;
      }

      if (isAuthenticated && isAuthRoute && state.matchedLocation != AppRouter.splash) {
        return AppRouter.lists;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRouter.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRouter.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRouter.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRouter.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            path: AppRouter.lists,
            name: 'lists',
            builder: (context, state) => const ListsPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'listDetail',
                builder: (context, state) {
                  final listId = state.pathParameters['id']!;
                  return ListDetailPage(listId: listId);
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
            path: AppRouter.profile,
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
              onPressed: () => context.go(AppRouter.lists),
              child: const Text('Go to Lists'),
            ),
          ],
        ),
      ),
    ),
  );
});
