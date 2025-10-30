# Share and Permissions Feature

This document describes the implementation of the share and permissions feature for the Flutter lists app.

## Overview

Users can now:
- Share lists with other users
- Assign different permission levels (Viewer, Editor, Owner)
- Manage participants and their permissions
- Receive in-app notifications when lists are shared or permissions change
- View and manage shared lists

## Architecture

### Models

Located in `lib/models/`:
- **Contact** - Represents a user that can be shared with
- **Participant** - Represents a user's participation in a list with a specific role
- **TodoList** - The main list model with sharing metadata
- **ListItem** - Individual items within a list
- **AppNotification** - In-app notification model

### Permission Roles

Located in `lib/constants/permissions.dart`:

1. **Viewer** - Can only view list contents
   - Cannot add, edit, or delete items
   - Cannot share the list
   - Cannot modify permissions

2. **Editor** - Can view and modify list contents
   - Can add, edit, and delete items
   - Cannot share the list
   - Cannot modify permissions

3. **Owner** - Full control over the list
   - Can add, edit, and delete items
   - Can share the list with others
   - Can modify participant permissions
   - Can delete the list
   - Cannot be removed or have role changed

### Repositories

Located in `lib/repositories/`:

#### ListRepository
Handles all list and item operations with permission enforcement:
- `getUserRole()` - Get the current user's role for a list
- `createList()` - Create a new list (auto-assigns owner role)
- `updateList()` - Update list metadata (requires edit permission)
- `deleteList()` - Delete a list (requires owner permission)
- `addItem()` - Add item to list (requires edit permission)
- `updateItem()` - Update item (requires edit permission)
- `deleteItem()` - Delete item (requires edit permission)
- `getParticipants()` - Get all participants of a list
- `addParticipants()` - Share list with users (requires owner permission)
- `updateParticipantRole()` - Change participant permissions (requires owner permission)
- `removeParticipant()` - Remove participant from list (requires owner permission)

All modification operations check permissions and throw `PermissionException` if unauthorized.

#### NotificationRepository
Handles notification CRUD operations:
- `getNotifications()` - Stream of user's notifications
- `createNotification()` - Create a new notification
- `markAsRead()` - Mark notification as read
- `markAllAsRead()` - Mark all notifications as read
- `deleteNotification()` - Delete a notification

### Services

Located in `lib/services/`:

#### NotificationService
Manages FCM and in-app notifications:
- `initialize()` - Request FCM permissions and set up message handlers
- `notifyListShared()` - Send notification when list is shared
- `notifyPermissionChanged()` - Send notification when permissions change
- `notifyListUpdated()` - Send notification when list is updated

#### ContactService
Manages contacts for sharing:
- `getContacts()` - Fetch available contacts to share with
- `getContactById()` - Get specific contact details

### UI Components

Located in `lib/widgets/` and `lib/screens/`:

#### ShareDialog
Modal dialog for sharing lists:
- Displays available contacts
- Multi-select with checkboxes
- Permission role dropdown for each selected contact
- Share button to confirm

#### ParticipantsSheet
Bottom sheet for managing participants:
- Lists all current participants
- Shows owner badge
- Allows changing roles (owner only)
- Allows removing participants (owner only)
- Displays current user's permission limitations

#### ListDetailScreen
Main screen for viewing and editing a list:
- Shows list items
- Add new items (editor/owner)
- Toggle item completion (editor/owner)
- Delete items (editor/owner)
- Share button (owner)
- Participants button (all)

#### ListsScreen
Main screen showing all lists user has access to:
- Shows owned and shared lists
- Indicates sharing status
- Create new list button

## Firestore Structure

### Collections

```
/lists/{listId}
  - id: string
  - title: string
  - ownerId: string
  - ownerName: string
  - createdAt: timestamp
  - updatedAt: timestamp
  - isShared: boolean
  - participantCount: number
  - participantIds: array<string>
  
  /participants/{userId}
    - userId: string
    - userName: string
    - userEmail: string
    - role: string (viewer|editor|owner)
    - addedAt: timestamp
  
  /items/{itemId}
    - id: string
    - title: string
    - isCompleted: boolean
    - createdAt: timestamp
    - createdBy: string

/notifications/{notificationId}
  - id: string
  - userId: string
  - type: string (list_shared|permission_changed|list_updated)
  - title: string
  - message: string
  - data: map
  - isRead: boolean
  - createdAt: timestamp

/users/{userId}
  - id: string
  - name: string
  - email: string
```

## Firestore Security Rules

Located in `firestore.rules`:

Key rules:
- Users can only read lists they are participants of
- Only editors and owners can modify list items
- Only owners can modify participants
- Only owners can delete lists
- Users can only read their own notifications
- Participant data validates against list ownership

## Testing

### Unit Tests

**Repository Tests** (`test/repositories/list_repository_test.dart`):
- Owner permissions (create, edit, delete, share)
- Editor permissions (can edit, cannot share)
- Viewer permissions (read-only)
- Permission denial enforcement
- Participant management
- Edge cases (cannot remove owner, etc.)

### Widget Tests

**ShareDialog Tests** (`test/widgets/share_dialog_test.dart`):
- Contact selection
- Permission role changes
- Share functionality
- Participant filtering
- UI states

**ParticipantsSheet Tests** (`test/widgets/participants_sheet_test.dart`):
- Participant display
- Role modification (owner only)
- Participant removal (owner only)
- Permission-based UI states

**Integration Tests** (`test/widget_test.dart`):
- List creation flow
- UI navigation
- State management

## Usage Example

```dart
// Initialize repositories
final listRepository = ListRepository(currentUserId: userId);
final notificationService = NotificationService(notificationRepository);

// Create a list
final list = await listRepository.createList('My List', userName);

// Share with users
await listRepository.addParticipants(list.id, [
  Participant(
    userId: 'user2',
    userName: 'John Doe',
    userEmail: 'john@example.com',
    role: PermissionRole.editor,
    addedAt: DateTime.now(),
  ),
]);

// Send notification
await notificationService.notifyListShared(
  userId: 'user2',
  listTitle: list.title,
  sharedByName: userName,
  role: PermissionRole.editor,
  listId: list.id,
);

// Check permissions before operations
final role = await listRepository.getUserRole(list.id);
if (role?.canEdit ?? false) {
  await listRepository.addItem(list.id, 'New Item');
}
```

## Setup Requirements

1. **Firebase Configuration**:
   - Replace placeholder values in `lib/firebase_options.dart`
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for iOS

2. **Firestore Rules**:
   - Deploy `firestore.rules` to Firebase project

3. **FCM Setup**:
   - Configure FCM in Firebase Console
   - Set up platform-specific configuration

4. **Dependencies**:
   ```yaml
   firebase_core: ^3.8.1
   cloud_firestore: ^5.5.0
   firebase_messaging: ^15.1.5
   provider: ^6.1.2
   uuid: ^4.5.1
   ```

## Acceptance Criteria ✅

- ✅ Users can share lists with contacts
- ✅ Multi-select contacts with permission toggles (view-only, edit, owner)
- ✅ Participant entries persisted in Firestore (`lists/{id}/participants`)
- ✅ List document reflects share state (`isShared`, `participantCount`)
- ✅ Permissions enforced in repositories (editors can modify, viewers read-only)
- ✅ Firestore rules enforce permissions server-side
- ✅ In-app notification mechanism (Firestore collection + FCM integration)
- ✅ Recipients receive notifications when lists shared or permissions changed
- ✅ Unauthorized edits are blocked with `PermissionException`
- ✅ Comprehensive tests for permission enforcement and UI states
