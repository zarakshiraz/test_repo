# Offline-First Todo App

A Flutter application demonstrating offline-first architecture with automatic sync, conflict resolution, and comprehensive UI indicators.

## Features

### 🔌 Offline Support
- **Local-First Storage**: All data stored locally using Hive for instant access
- **Firestore Integration**: Automatic sync with Firestore when online
- **Persistent Cache**: Firestore persistence enabled for optimal performance
- **Queue Management**: Offline changes queued and synced automatically

### ✨ User Experience
- **Instant Responsiveness**: All operations complete immediately offline
- **Sync Status Badges**: Visual indicators for sync state (synced, pending, conflict)
- **Network Indicator**: Top bar shows online/offline status and pending count
- **Conflict Alerts**: Users notified when conflicts are resolved

### 🔄 Sync & Conflict Resolution
- **Last-Writer Wins**: Automatic conflict resolution based on timestamps
- **Activity Logging**: All changes and conflicts logged for audit trail
- **Soft Deletes**: Items marked as deleted but preserved for sync
- **Automatic Retry**: Pending changes sync automatically when connection restored

## Architecture

### Data Models
- `TodoList`: Container for todo items
- `TodoItem`: Individual tasks with completion status
- `Message`: Standalone messages
- `ActivityLog`: Audit trail for all operations

### Services
- `LocalStorageService`: Hive-based local storage
- `FirestoreService`: Cloud Firestore integration
- `SyncService`: Handles synchronization and conflict resolution
- `TodoRepository`: Unified interface for data operations

### UI Components
- `TodoListsScreen`: Main screen showing all lists
- `TodoItemsScreen`: Detail view for list items
- `SyncStatusBadge`: Per-item sync indicator
- `OfflineIndicator`: Global connectivity status

## Conflict Resolution Strategy

The app uses a **Last-Writer Wins (LWW)** strategy:

1. Each entity tracks `createdAt` and `updatedAt` timestamps
2. When syncing, local and remote versions are compared
3. The version with the newer `updatedAt` is kept
4. Conflicts are logged in the activity log
5. Users are notified via SnackBar when conflicts occur

See [OFFLINE_SYNC_RULES.md](OFFLINE_SYNC_RULES.md) for detailed documentation.

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/offline_mode_test.dart
flutter test test/sync_conflict_test.dart
flutter test test/airplane_mode_integration_test.dart
```

### Test Coverage
- **Offline Operations**: Create, read, update, delete while offline
- **Sync Behavior**: Pending changes, conflict resolution
- **Airplane Mode**: Complete workflows without connectivity
- **Edge Cases**: Rapid operations, immediate updates/deletes

### Manual Testing
1. Enable airplane mode on your device
2. Create and edit lists/items
3. Observe pending badges (orange cloud icon)
4. Disable airplane mode
5. Watch automatic sync and status updates

## Usage

### Creating a List
```dart
final list = await repository.createTodoList('Shopping List');
// Works offline - item marked as pending
```

### Adding Items
```dart
final item = await repository.createTodoItem(list.id, 'Buy milk');
// Immediately available in UI
```

### Updating Items
```dart
await repository.updateTodoItem(item.id, completed: true);
// Syncs when online
```

### Checking Sync Status
```dart
final pendingCount = repository.getPendingCount();
// Shows number of items waiting to sync
```

## Dependencies

- `firebase_core`: Firebase initialization
- `cloud_firestore`: Cloud database with persistence
- `hive` & `hive_flutter`: Local storage
- `connectivity_plus`: Network status monitoring
- `uuid`: ID generation
- `provider`: State management

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Configure Firebase:
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
   - Update Firebase options in `main.dart`

4. Run the app:
```bash
flutter run
```

## File Structure

```
lib/
├── models/           # Data models with Hive annotations
├── services/         # Business logic and sync services
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── main.dart         # App entry point

test/
├── offline_mode_test.dart              # Offline CRUD tests
├── sync_conflict_test.dart             # Sync and conflict tests
└── airplane_mode_integration_test.dart # Integration scenarios
```

## Acceptance Criteria ✅

- [x] Users can create lists offline
- [x] Users can edit lists offline
- [x] Changes persist across app restarts
- [x] Changes sync automatically when online
- [x] Conflict resolution with last-writer wins
- [x] Activity log records conflicts
- [x] UI shows sync status badges
- [x] UI shows offline/online indicator
- [x] UI shows pending changes count
- [x] Tests simulate airplane mode
- [x] Tests verify offline operations work
- [x] Tests verify sync on reconnect
- [x] Documentation of conflict rules
- [x] Minimal conflicts through timestamps

## Future Enhancements

- Three-way merge for text content
- User-selectable conflict resolution
- Manual conflict resolution UI
- Background sync service
- Optimistic UI with rollback
- Batch sync operations
- Compression for large datasets
- Encrypted local storage

## License

This project is created for demonstration purposes.
