# Offline Sync and Conflict Resolution Rules

## Overview
This app implements an offline-first architecture with automatic sync when connectivity is restored. All data is stored locally using Hive and synced to Firestore when online.

## Data Models
- **TodoList**: Lists that contain todo items
- **TodoItem**: Individual todo items within lists
- **Message**: Standalone messages
- **ActivityLog**: Audit trail for all changes and conflicts

## Offline Behavior

### Local Storage (Hive)
- All data is stored locally first using Hive
- Changes are immediately visible to the user
- Data persists even when the app is closed
- Each entity tracks its sync status: `synced`, `pending`, or `conflict`

### Online Detection
- The app continuously monitors network connectivity
- Uses `connectivity_plus` package to detect:
  - Mobile data
  - WiFi
  - Ethernet connections

### Sync Queue
- All create, update, and delete operations are queued when offline
- The queue is processed automatically when connectivity is restored
- Pending changes are marked with `SyncStatus.pending`
- A badge shows the number of pending changes in the UI

## Conflict Resolution Strategy

### Last-Writer Wins (LWW)
The app uses a **Last-Writer Wins** strategy based on timestamps:

1. **No Conflict**: If an entity doesn't exist remotely, the local version is pushed
2. **Local Wins**: If local `updatedAt` is newer than remote, local version is pushed
3. **Remote Wins**: If remote `updatedAt` is newer than local, remote version is kept
4. **Equal Timestamps**: Rare case where remote version is preferred

### Conflict Detection
When syncing, the app:
1. Fetches the remote version of each pending entity
2. Compares `updatedAt` timestamps
3. If remote is newer:
   - Marks local entity with `SyncStatus.conflict`
   - Shows user alert about the conflict
   - Logs the conflict in ActivityLog
4. If local is newer or equal:
   - Pushes local changes to Firestore
   - Marks entity as `SyncStatus.synced`

### Activity Log
Every sync operation is logged with:
- Entity type (TodoList, TodoItem, Message)
- Entity ID
- Action (created, updated, deleted, conflict_resolved)
- Timestamp
- Conflict details (if applicable)

Users can review the activity log to understand what happened during conflicts.

## User Experience

### Visual Indicators
- **Green cloud icon**: Entity is synced
- **Orange cloud icon**: Entity has pending changes
- **Red warning icon**: Entity has a conflict
- **Top bar badge**: Shows "Offline (X pending)" or "Syncing (X pending)"

### Alerts
- When a conflict is detected, a SnackBar appears explaining:
  - Which item had a conflict
  - That the latest version is being used

### Guaranteed Data Safety
- No data is ever lost
- Local changes are preserved until successfully synced
- Conflicts are resolved transparently but logged for audit

## Testing Offline Mode

### Airplane Mode Simulation
To test offline functionality:

1. **Disable Network**:
   ```dart
   // In test: Set connectivity to none
   await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
     connectivity.methodChannel,
     (call) async => [ConnectivityResult.none]
   );
   ```

2. **Create Data Offline**:
   - Create lists, items, messages
   - Verify they appear immediately
   - Check sync status shows "pending"

3. **Enable Network**:
   ```dart
   // In test: Restore connectivity
   await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
     connectivity.methodChannel,
     (call) async => [ConnectivityResult.wifi]
   );
   ```

4. **Verify Sync**:
   - Pending items should sync automatically
   - Badges should update to "synced"
   - Remote database should contain the data

### Manual Testing
1. Turn on airplane mode on your device
2. Create/edit items in the app
3. Observe pending badges
4. Turn off airplane mode
5. Watch items sync automatically
6. Check Firestore console to verify data

## Best Practices

### For Developers
- Always use the `TodoRepository` for data operations
- Don't directly access Firestore when offline
- Listen to `SyncService.syncStatusStream` for sync updates
- Subscribe to `SyncService.conflictStream` to handle conflicts

### For Users
- Changes made offline will sync when online
- If you see a conflict warning, the most recent change is kept
- Check the activity log if you need to understand what happened
- Pending changes are shown with an orange cloud icon

## Firestore Persistence
- Firestore persistence is enabled on app startup
- Provides an additional caching layer
- Helps with performance even when online
- Works in conjunction with Hive for optimal offline support

## Future Enhancements
Possible improvements to the conflict resolution:
- Three-way merge for text content
- User choice for conflict resolution
- Conflict history view
- Manual conflict resolution UI
- Optimistic UI updates with rollback on server rejection
