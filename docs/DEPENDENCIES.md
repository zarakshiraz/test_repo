# Grocli Dependencies Guide

This document provides detailed information about all dependencies used in the Grocli project, their purpose, and usage examples.

## Table of Contents

- [State Management](#state-management)
- [Navigation](#navigation)
- [Code Generation](#code-generation)
- [Data Persistence](#data-persistence)
- [Backend & Authentication](#backend--authentication)
- [Audio & AI](#audio--ai)
- [Utilities](#utilities)
- [UI Enhancements](#ui-enhancements)
- [Development Tools](#development-tools)

## State Management

### flutter_riverpod (^2.6.1)
**Purpose**: Modern state management and dependency injection

**Key Features**:
- Compile-time safety
- No BuildContext required
- Excellent testability
- Auto-dispose capabilities

**Usage**:
```dart
// Define a provider
final counterProvider = StateProvider<int>((ref) => 0);

// Use in widget
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### riverpod_annotation (^2.6.1)
**Purpose**: Annotations for Riverpod code generation

**Usage**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
Future<String> fetchData(FetchDataRef ref) async {
  return await apiCall();
}
```

### equatable (^2.0.5)
**Purpose**: Value equality for Dart objects

**Usage**:
```dart
class User extends Equatable {
  final String id;
  final String name;
  
  const User(this.id, this.name);
  
  @override
  List<Object> get props => [id, name];
}
```

## Navigation

### go_router (^14.2.7)
**Purpose**: Declarative routing with deep linking support

**Key Features**:
- Type-safe navigation
- Deep linking
- Nested navigation
- Shell routes for persistent UI

**Usage**:
```dart
// Navigate
context.go('/profile');

// With parameters
context.goNamed('listDetail', pathParameters: {'id': '123'});

// Push
context.push('/settings');
```

## Code Generation

### freezed_annotation (^2.4.4)
**Purpose**: Annotations for Freezed code generation

**Key Features**:
- Immutable data classes
- Union types
- copyWith method
- Pattern matching

**Usage**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### json_annotation (^4.9.0)
**Purpose**: Annotations for JSON serialization

**Usage**:
```dart
@JsonSerializable()
class ApiResponse {
  final String message;
  final int code;
  
  ApiResponse(this.message, this.code);
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
      
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}
```

## Data Persistence

### hive (^2.2.3) & hive_flutter (^1.1.0)
**Purpose**: Fast, lightweight NoSQL database

**Key Features**:
- Very fast operations
- No native dependencies
- Type adapters
- Lazy loading

**Usage**:
```dart
// Initialize
await Hive.initFlutter();

// Register adapter
Hive.registerAdapter(UserAdapter());

// Open box
final box = await Hive.openBox<User>('users');

// CRUD operations
await box.put('user1', user);
final user = box.get('user1');
await box.delete('user1');
```

### sqflite (^2.3.3+1)
**Purpose**: SQLite plugin for Flutter

**Usage**:
```dart
final db = await openDatabase(
  'my_db.db',
  version: 1,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT
      )
    ''');
  },
);

await db.insert('users', {'id': '1', 'name': 'John'});
final users = await db.query('users');
```

### shared_preferences (^2.2.3)
**Purpose**: Simple key-value storage

**Usage**:
```dart
final prefs = await SharedPreferences.getInstance();

// Write
await prefs.setString('username', 'john_doe');
await prefs.setInt('counter', 42);
await prefs.setBool('isLoggedIn', true);

// Read
final username = prefs.getString('username');
final counter = prefs.getInt('counter') ?? 0;
```

### path_provider (^2.1.4)
**Purpose**: Platform-specific directory paths

**Usage**:
```dart
final documentsDir = await getApplicationDocumentsDirectory();
final tempDir = await getTemporaryDirectory();
final supportDir = await getApplicationSupportDirectory();
```

## Backend & Authentication

### firebase_core (^3.6.0)
**Purpose**: Firebase SDK initialization

**Setup**:
```bash
flutterfire configure
```

**Usage**:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### firebase_auth (^5.3.1)
**Purpose**: Firebase authentication

**Usage**:
```dart
final auth = FirebaseAuth.instance;

// Email/Password
await auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

await auth.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await auth.signOut();

// Current user
final user = auth.currentUser;
```

### google_sign_in (^6.2.1)
**Purpose**: Google Sign-In integration

**Usage**:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn();

final GoogleSignInAccount? account = await googleSignIn.signIn();
final GoogleSignInAuthentication auth = await account!.authentication;

final credential = GoogleAuthProvider.credential(
  accessToken: auth.accessToken,
  idToken: auth.idToken,
);

await FirebaseAuth.instance.signInWithCredential(credential);
```

### sign_in_with_apple (^6.1.2)
**Purpose**: Apple Sign-In (iOS/macOS)

**Usage**:
```dart
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

final oauthCredential = OAuthProvider('apple.com').credential(
  idToken: credential.identityToken,
  accessToken: credential.authorizationCode,
);

await FirebaseAuth.instance.signInWithCredential(oauthCredential);
```

### cloud_firestore (^5.4.4)
**Purpose**: NoSQL cloud database

**Usage**:
```dart
final firestore = FirebaseFirestore.instance;

// Add document
await firestore.collection('users').doc(userId).set({
  'name': 'John',
  'email': 'john@example.com',
});

// Get document
final doc = await firestore.collection('users').doc(userId).get();
final data = doc.data();

// Stream
firestore.collection('messages')
  .orderBy('timestamp')
  .snapshots()
  .listen((snapshot) {
    for (var doc in snapshot.docs) {
      print(doc.data());
    }
  });
```

### firebase_storage (^12.3.4)
**Purpose**: Cloud file storage

**Usage**:
```dart
final storage = FirebaseStorage.instance;

// Upload file
final ref = storage.ref().child('images/${userId}/profile.jpg');
await ref.putFile(file);

// Get download URL
final url = await ref.getDownloadURL();

// Delete
await ref.delete();
```

### firebase_messaging (^15.1.3)
**Purpose**: Push notifications

**Usage**:
```dart
final messaging = FirebaseMessaging.instance;

// Request permission
await messaging.requestPermission();

// Get token
final token = await messaging.getToken();

// Listen to messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message: ${message.notification?.title}');
});
```

### cloud_functions (^5.1.3)
**Purpose**: Call serverless functions

**Usage**:
```dart
final functions = FirebaseFunctions.instance;

final callable = functions.httpsCallable('myFunction');
final result = await callable.call({'param': 'value'});
print(result.data);
```

## Audio & AI

### speech_to_text (^7.0.0)
**Purpose**: Convert speech to text

**Usage**:
```dart
final speech = SpeechToText();
final available = await speech.initialize();

if (available) {
  speech.listen(
    onResult: (result) {
      print('Recognized: ${result.recognizedWords}');
    },
  );
}

speech.stop();
```

### record (^5.1.2)
**Purpose**: Audio recording

**Usage**:
```dart
final record = AudioRecorder();

// Start recording
await record.start(
  const RecordConfig(),
  path: 'path/to/file.m4a',
);

// Stop and get path
final path = await record.stop();
```

### audioplayers (^6.1.0)
**Purpose**: Audio playback

**Usage**:
```dart
final player = AudioPlayer();

// Play from URL
await player.play(UrlSource('https://example.com/audio.mp3'));

// Play from file
await player.play(DeviceFileSource(path));

// Control
await player.pause();
await player.resume();
await player.stop();
```

### http (^1.2.2)
**Purpose**: HTTP requests for AI APIs

**Usage**:
```dart
final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': 'gpt-4',
    'messages': [
      {'role': 'user', 'content': 'Hello!'}
    ],
  }),
);

final data = jsonDecode(response.body);
```

## Utilities

### intl (^0.19.0)
**Purpose**: Internationalization and localization

**Usage**:
```dart
// Date formatting
final formatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

// Number formatting
final currency = NumberFormat.currency(symbol: '\$').format(42.50);

// Plurals
String items(int count) => Intl.plural(
  count,
  zero: 'No items',
  one: '1 item',
  other: '$count items',
);
```

### uuid (^4.5.1)
**Purpose**: Generate unique identifiers

**Usage**:
```dart
final uuid = Uuid();
final id = uuid.v4(); // Random UUID
final timeBasedId = uuid.v1(); // Time-based UUID
```

### flutter_dotenv (^5.1.0)
**Purpose**: Environment variable management

**Setup**:
1. Add `.env` file to project root
2. Add to `pubspec.yaml` assets
3. Load in main:
```dart
await dotenv.load(fileName: '.env');
```

**Usage**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['API_KEY'];
final isProduction = dotenv.env['ENVIRONMENT'] == 'production';
```

### permission_handler (^11.3.1)
**Purpose**: Request device permissions

**Usage**:
```dart
final status = await Permission.camera.request();

if (status.isGranted) {
  // Permission granted
} else if (status.isDenied) {
  // Permission denied
} else if (status.isPermanentlyDenied) {
  // Open app settings
  await openAppSettings();
}
```

### connectivity_plus (^6.0.5)
**Purpose**: Check network connectivity

**Usage**:
```dart
final connectivity = Connectivity();

// Check current status
final result = await connectivity.checkConnectivity();
if (result == ConnectivityResult.mobile) {
  // Mobile network
} else if (result == ConnectivityResult.wifi) {
  // WiFi
}

// Listen to changes
connectivity.onConnectivityChanged.listen((result) {
  print('Connectivity: $result');
});
```

### share_plus (^10.0.2)
**Purpose**: Share content

**Usage**:
```dart
// Share text
await Share.share('Check out this list!');

// Share with subject
await Share.share(
  'Check out this list!',
  subject: 'Grocli List',
);

// Share file
await Share.shareXFiles([XFile('path/to/file')]);
```

### flutter_local_notifications (^17.2.3)
**Purpose**: Local notifications

**Usage**:
```dart
final notifications = FlutterLocalNotificationsPlugin();

// Initialize
await notifications.initialize(
  InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ),
);

// Show notification
await notifications.show(
  0,
  'Title',
  'Body',
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'channel_name',
    ),
  ),
);
```

### timezone (^0.9.4)
**Purpose**: Timezone data for scheduled notifications

**Usage**:
```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

tz.initializeTimeZones();
final location = tz.getLocation('America/New_York');
final scheduledDate = tz.TZDateTime.from(dateTime, location);
```

## UI Enhancements

### cupertino_icons (^1.0.8)
**Purpose**: iOS-style icons

**Usage**:
```dart
Icon(CupertinoIcons.heart_fill)
Icon(CupertinoIcons.person_circle)
```

### flutter_slidable (^3.1.1)
**Purpose**: Swipeable list items

**Usage**:
```dart
Slidable(
  startActionPane: ActionPane(
    motion: ScrollMotion(),
    children: [
      SlidableAction(
        onPressed: (context) => delete(),
        backgroundColor: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ],
  ),
  child: ListTile(title: Text('Item')),
)
```

### cached_network_image (^3.4.1)
**Purpose**: Image caching

**Usage**:
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### shimmer (^3.0.0)
**Purpose**: Loading skeleton effect

**Usage**:
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    width: double.infinity,
    height: 100,
    color: Colors.white,
  ),
)
```

## Development Tools

### flutter_lints (^5.0.0)
**Purpose**: Recommended linting rules

**Configuration**: See `analysis_options.yaml`

### build_runner (^2.4.13)
**Purpose**: Code generation runner

**Commands**:
```bash
# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Clean
flutter pub run build_runner clean
```

### hive_generator (^2.0.1)
**Purpose**: Generate Hive type adapters

**Usage**: Automatic with `@HiveType()` annotation

### freezed (^2.5.7)
**Purpose**: Code generation for immutable classes

**Usage**: Runs via build_runner

### json_serializable (^6.8.0)
**Purpose**: JSON serialization code generation

**Usage**: Runs via build_runner

### riverpod_generator (^2.6.2)
**Purpose**: Generate Riverpod providers

**Usage**: Runs via build_runner with `@riverpod` annotation

### riverpod_lint (^2.6.2)
**Purpose**: Custom lint rules for Riverpod

**Benefits**:
- Catch common Riverpod mistakes
- Suggest best practices
- Improve code quality

## Dependency Management

### Adding Dependencies
```bash
flutter pub add package_name
```

### Adding Dev Dependencies
```bash
flutter pub add --dev package_name
```

### Updating Dependencies
```bash
# Update all
flutter pub upgrade

# Update specific
flutter pub upgrade package_name

# Check outdated
flutter pub outdated
```

### Removing Dependencies
```bash
flutter pub remove package_name
```

## Version Compatibility

All dependencies are tested and compatible with:
- **Flutter**: 3.x
- **Dart SDK**: ^3.9.2
- **Platform**: iOS, Android, Web, Windows, macOS, Linux

## Troubleshooting

### Common Issues

**Build failures after adding dependencies**:
```bash
flutter clean
flutter pub get
```

**Code generation not working**:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Platform-specific issues**:
- Check platform-specific setup in package documentation
- Verify native permissions in AndroidManifest.xml / Info.plist
- Run `flutter doctor` to check setup

## Additional Resources

- [pub.dev](https://pub.dev/) - Package repository
- [Flutter Packages](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
- [Riverpod Docs](https://riverpod.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
