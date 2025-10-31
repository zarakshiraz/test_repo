# Grocli Architecture Documentation

## Overview

Grocli follows a **feature-first architecture** pattern combined with clean architecture principles. The application is built using Flutter 3 with Dart and leverages modern state management and dependency injection patterns.

## Technology Stack

### Core Technologies
- **Flutter 3**: UI framework
- **Dart SDK**: ^3.9.2
- **Material Design 3**: UI components and theming

### State Management & Dependency Injection
- **Riverpod** (flutter_riverpod ^2.6.1): State management and dependency injection
- **Riverpod Generator**: Code generation for providers
- **Riverpod Annotation**: Annotations for code generation

### Navigation
- **GoRouter** (^14.2.7): Declarative routing with deep linking support

### Code Generation
- **Freezed** (^2.5.7): Immutable data classes with union types
- **JsonSerializable** (^6.8.0): JSON serialization/deserialization
- **Build Runner**: Code generation tooling

### Data Persistence
- **Hive** (^2.2.3): Local NoSQL database
- **Hive Flutter**: Flutter integration for Hive
- **Sqflite** (^2.3.3): SQLite database
- **Shared Preferences** (^2.2.3): Key-value storage

### Backend & Authentication
- **Firebase Core** (^3.6.0): Firebase SDK
- **Firebase Auth** (^5.3.1): Authentication
- **Cloud Firestore** (^5.4.4): Real-time database
- **Firebase Storage** (^12.3.4): File storage
- **Firebase Messaging** (^15.1.3): Push notifications
- **Cloud Functions** (^5.1.3): Serverless functions

### Environment Configuration
- **Flutter Dotenv** (^5.1.0): Environment variable management

### Localization
- **Intl** (^0.19.0): Internationalization and localization

## Project Structure

```
lib/
├── core/                           # Core application infrastructure
│   ├── config/                     # Configuration files
│   │   └── env_config.dart        # Environment configuration
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart     # Application constants
│   ├── models/                     # Core domain models
│   │   ├── user.dart              # User model with Hive adapters
│   │   ├── grocery_list.dart      # List model
│   │   ├── list_item.dart         # Item model
│   │   ├── message.dart           # Message model
│   │   ├── contact.dart           # Contact model
│   │   └── app_notification.dart  # Notification model
│   ├── providers/                  # Global Riverpod providers
│   │   ├── auth_provider.dart     # Authentication state
│   │   ├── list_provider.dart     # List management
│   │   ├── message_provider.dart  # Messaging
│   │   ├── contact_provider.dart  # Contacts
│   │   └── notification_provider.dart # Notifications
│   ├── router/                     # Navigation configuration
│   │   └── app_router.dart        # GoRouter setup
│   ├── services/                   # Global services
│   │   ├── ai_service.dart        # AI integration
│   │   └── speech_service.dart    # Speech-to-text
│   └── pages/                      # Core app pages
│       ├── splash_page.dart       # Splash screen
│       └── main_page.dart         # Main shell with navigation
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   └── presentation/
│   │       └── pages/
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   │
│   ├── lists/                      # Lists feature
│   │   ├── domain/                # Business logic (future)
│   │   ├── data/                  # Data layer (future)
│   │   └── presentation/          # UI layer
│   │       ├── pages/
│   │       │   ├── lists_page.dart
│   │       │   ├── list_detail_page.dart
│   │       │   └── create_list_page.dart
│   │       └── widgets/
│   │           └── list_card.dart
│   │
│   ├── chat/                       # Chat feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── chat_page.dart
│   │
│   └── profile/                    # Profile feature
│       └── presentation/
│           └── pages/
│               └── profile_page.dart
│
├── shared/                         # Shared widgets and utilities
│   ├── theme/                      # Theme configuration
│   │   └── app_theme.dart         # Material theme setup
│   ├── widgets/                    # Reusable widgets (future)
│   └── utils/                      # Utility functions (future)
│
└── main.dart                       # Application entry point
```

## Feature-First Approach

Each feature module can contain:
- **domain/**: Business logic, entities, repositories
- **data/**: Data sources, repository implementations, DTOs
- **presentation/**: UI pages, widgets, view models (providers)

Benefits:
- Clear feature boundaries
- Easy to navigate and maintain
- Scalable for team collaboration
- Features can be developed independently

## State Management with Riverpod

### Why Riverpod?

1. **Compile-time safety**: Errors caught at compile time, not runtime
2. **No BuildContext**: Access providers from anywhere
3. **Better testability**: Easy to mock and test
4. **Performance**: Automatic optimization and caching
5. **Developer experience**: Better debugging and DevTools integration

### Provider Types

```dart
// Simple provider (computed values)
final configProvider = Provider((ref) => EnvConfig());

// State provider (simple mutable state)
final counterProvider = StateProvider<int>((ref) => 0);

// StateNotifier provider (complex state)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// FutureProvider (async data)
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});

// StreamProvider (stream data)
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return messageStream();
});
```

### Provider Usage

```dart
// In a ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Text('User: ${authState.user?.name}');
  }
}

// In a ConsumerStatefulWidget
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).state++,
      child: Text('Count: $count'),
    );
  }
}
```

## Navigation with GoRouter

### Route Structure

- **Splash** (`/`): Initial loading screen
- **Auth Routes**: Login, Register
- **Main Shell**: Bottom navigation with nested routes
  - **Lists** (`/lists`): List overview
    - **List Detail** (`/lists/detail/:id`): Individual list
    - **Create List** (`/lists/create`): New list form
    - **Chat** (`/lists/chat/:listId`): List chat
  - **Profile** (`/profile`): User profile

### Navigation Examples

```dart
// Navigate to a route
context.go('/lists');

// Navigate with parameters
context.go('/lists/detail/123');

// Named route navigation
context.goNamed('listDetail', pathParameters: {'id': '123'});

// Push (add to stack)
context.push('/profile');

// Pop
context.pop();
```

## Code Generation

### Freezed (Immutable Models)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### Running Code Generation

```bash
# Watch mode (recommended for development)
flutter pub run build_runner watch --delete-conflicting-outputs

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Environment Configuration

### Setup

1. Copy `.env.example` to `.env`
2. Fill in your API keys and configuration
3. For different environments, use `.env.development` or `.env.production`

### Usage

```dart
import 'package:grocli/core/config/env_config.dart';

// Access environment variables
final apiKey = EnvConfig.openAiApiKey;
final isDev = EnvConfig.isDevelopment;

if (EnvConfig.enableAiFeatures) {
  // AI features code
}
```

### Environment Variables

- `OPENAI_API_KEY`: OpenAI API key for AI features
- `OPENAI_MODEL`: GPT model to use (default: gpt-4)
- `FIREBASE_*`: Firebase configuration (optional, use flutterfire configure)
- `ENABLE_AI_FEATURES`: Feature flag for AI functionality
- `ENABLE_VOICE_INPUT`: Feature flag for voice input
- `ENABLE_ANALYTICS`: Feature flag for analytics

## Theming

### Colors

- **Primary**: Green (`#2E7D32`) - Main brand color
- **Secondary**: Orange (`#FF6F00`) - Accent color
- **Success**: Green (`#388E3C`)
- **Warning**: Orange (`#F57C00`)
- **Error**: Red (`#D32F2F`)

### Usage

```dart
// Access theme colors
final theme = Theme.of(context);
final primaryColor = theme.colorScheme.primary;

// Custom colors from AppTheme
Container(
  color: AppTheme.primaryColor,
  child: Text(
    'Hello',
    style: theme.textTheme.headlineMedium,
  ),
)
```

## Firebase Setup

### Initial Configuration

Run the FlutterFire CLI to configure Firebase:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
1. Create `firebase_options.dart` with your configuration
2. Set up Firebase for all platforms
3. Link your Firebase project

### Authentication

Supported methods:
- Email/Password
- Google Sign-In
- Apple Sign-In (iOS/macOS)

### Cloud Firestore

Data structure:
- `/users/{userId}`: User profiles
- `/lists/{listId}`: Grocery lists
- `/lists/{listId}/items/{itemId}`: List items
- `/lists/{listId}/messages/{messageId}`: Chat messages

## Development Workflow

### Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Code Analysis

```bash
# Run static analysis
flutter analyze

# Fix formatting
dart format .

# Run tests
flutter test
```

### Adding a New Feature

1. Create feature directory: `lib/features/my_feature/`
2. Add subdirectories: `domain/`, `data/`, `presentation/`
3. Create models with Freezed in `domain/models/`
4. Create providers in `presentation/providers/`
5. Create UI in `presentation/pages/` and `presentation/widgets/`
6. Register routes in `core/router/app_router.dart`

### Adding a New Model

1. Create model file with Freezed annotations
2. Run `flutter pub run build_runner build`
3. Use the generated code

### Adding a New Provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() {
    return MyState.initial();
  }
  
  void doSomething() {
    state = state.copyWith(value: 'new value');
  }
}
```

## Best Practices

### State Management
- Use `ConsumerWidget` for stateless widgets that need providers
- Use `ConsumerStatefulWidget` for stateful widgets that need providers
- Keep business logic in providers, not in widgets
- Use `ref.watch` to rebuild on changes
- Use `ref.read` for one-time reads or callbacks
- Use `ref.listen` to react to changes without rebuilding

### Code Organization
- One widget per file
- Group related files in the same directory
- Use barrel files (`index.dart`) for exports
- Keep files under 300 lines when possible

### Models
- Use Freezed for all data models
- Add `copyWith` for easy updates
- Add `fromJson`/`toJson` for serialization
- Use union types for state management

### Navigation
- Use named routes for better maintainability
- Pass data via route parameters or extra
- Use `ShellRoute` for persistent navigation shells

### Testing
- Write unit tests for providers
- Write widget tests for UI components
- Mock providers for testing
- Use `ProviderContainer` for provider testing

## Common Patterns

### Loading State

```dart
@freezed
class DataState<T> with _$DataState<T> {
  const factory DataState.initial() = _Initial;
  const factory DataState.loading() = _Loading;
  const factory DataState.success(T data) = _Success;
  const factory DataState.error(String message) = _Error;
}
```

### Repository Pattern

```dart
abstract class ListRepository {
  Future<List<GroceryList>> getLists();
  Future<GroceryList> getList(String id);
  Future<void> createList(GroceryList list);
  Future<void> updateList(GroceryList list);
  Future<void> deleteList(String id);
}
```

### Service Locator (via Riverpod)

```dart
final listRepositoryProvider = Provider<ListRepository>((ref) {
  return FirebaseListRepository();
});

final listServiceProvider = Provider<ListService>((ref) {
  final repository = ref.watch(listRepositoryProvider);
  return ListService(repository);
});
```

## Troubleshooting

### Build Runner Issues
```bash
# Clean build cache
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Issues
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present
- Run `flutterfire configure` again if needed
- Check Firebase console for project setup

### Environment Variables Not Loading
- Ensure `.env` file is in project root
- Verify `.env` is listed in `pubspec.yaml` assets
- Restart the app after changing `.env`

## Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)

## Migration Notes

### From Provider to Riverpod

This project has been migrated from Provider to Riverpod:
- `Provider` → `Provider` (same name, different package)
- `ChangeNotifierProvider` → `StateNotifierProvider`
- `Consumer` → `Consumer` (similar API)
- `context.read` → `ref.read`
- `context.watch` → `ref.watch`

### Future Enhancements

1. **Domain Layer**: Add use cases and domain models
2. **Data Layer**: Separate data sources and repository implementations
3. **Testing**: Add comprehensive test coverage
4. **CI/CD**: Set up automated testing and deployment
5. **Localization**: Add support for multiple languages using `intl`
6. **Offline Support**: Implement offline-first architecture
7. **Analytics**: Add analytics tracking
8. **Error Tracking**: Integrate error tracking service
