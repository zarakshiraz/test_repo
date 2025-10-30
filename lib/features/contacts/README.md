# Contacts Module

This module provides comprehensive contact management functionality with Firestore synchronization, device contact import, and real-time updates.

## Features

- **Contact Management**: Add, remove, block, and unblock contacts
- **Contact Requests**: Send, accept, and reject contact invitations
- **Device Import**: Import contacts from device with permission handling
- **Real-time Updates**: Live updates using Firestore streams
- **Search**: Find users by name or email
- **Status Management**: Track contact status (pending, accepted, blocked)

## Architecture

### Data Layer

- **Models**:
  - `ContactStatus`: Enum for contact states (pending, accepted, blocked)
  - `ContactRequest`: Represents a contact invitation
  - `UserContact`: Represents a user's contact with status

- **Repository**:
  - `ContactsRepository`: Handles all Firestore operations and device contact access

### Presentation Layer

- **Providers** (Riverpod):
  - `contactsRepositoryProvider`: Provides repository instance
  - `userContactsProvider`: Stream of user's contacts
  - `contactRequestsProvider`: Stream of pending contact requests
  - `acceptedContactsProvider`: Filtered list of accepted contacts
  - `blockedContactsProvider`: Filtered list of blocked contacts

- **Screens**:
  - `ContactsScreen`: Main contacts list
  - `ContactRequestsScreen`: Pending contact requests
  - `AddContactScreen`: Search and add new contacts
  - `ImportContactsScreen`: Import from device contacts

- **Widgets**:
  - `ContactListItem`: Display individual contact
  - `ContactRequestItem`: Display pending request with accept/reject actions
  - `UserSearchItem`: Display search result with add action

## Usage

### 1. Wrap your app with ProviderScope

```dart
runApp(
  const ProviderScope(
    child: MyApp(),
  ),
);
```

### 2. Navigate to Contacts Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ContactsScreen(userId: currentUserId),
  ),
);
```

### 3. Access Providers

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(userContactsProvider(userId));
    
    return contactsAsync.when(
      data: (contacts) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Firestore Schema

### `/users/{userId}/contacts/{contactId}`

```json
{
  "id": "contact_id",
  "contactUserId": "other_user_id",
  "displayName": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "photoUrl": "https://...",
  "status": "accepted",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "source": "phone"
}
```

### `/users/{userId}/contactRequests/{requestId}`

```json
{
  "id": "request_id",
  "fromUserId": "sender_user_id",
  "toUserId": "recipient_user_id",
  "fromUserName": "Jane Smith",
  "fromUserEmail": "jane@example.com",
  "fromUserPhotoUrl": "https://...",
  "status": "pending",
  "createdAt": Timestamp,
  "note": "Let's connect!"
}
```

## Security Rules

The Firestore rules ensure:
- Users can only access their own contacts and requests
- Contact requests cannot be sent to users who have blocked the sender
- Only authenticated users can perform operations

See `firestore.rules` for complete security rules.

## Testing

### Unit Tests

```bash
flutter test test/features/contacts/data/repositories/contacts_repository_test.dart
```

### Integration Tests

```bash
flutter test integration_test/contacts_integration_test.dart
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to help you connect with friends.</string>
```

## Dependencies

- `flutter_riverpod`: State management
- `cloud_firestore`: Backend storage
- `flutter_contacts`: Device contact access
- `permission_handler`: Permission requests
- `fake_cloud_firestore`: Testing
