# Domain Models Implementation Guide

## Overview

This document provides a guide for working with the new Freezed-based domain models in Grocli.

## Quick Start

### Import the domain layer

```dart
import 'package:grocli/core/domain/domain.dart';
```

This single import gives you access to all models, enums, repositories, and Firestore helpers.

## Core Models

### UserProfile

Represents a user account with profile information.

```dart
final user = UserProfile(
  id: 'user123',
  email: 'john@example.com',
  displayName: 'John Doe',
  photoUrl: 'https://example.com/photo.jpg',
  phoneNumber: '+1234567890',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  contactIds: ['contact1', 'contact2'],
  blockedUserIds: [],
  isActive: true,
  preferences: {'theme': 'dark'},
);

// Update with copyWith
final updated = user.copyWith(displayName: 'Jane Doe');

// Serialize to JSON
final json = user.toJson();

// Deserialize from JSON
final restored = UserProfile.fromJson(json);
```

### ListSummary

Represents a list with metadata and participants.

```dart
final list = ListSummary(
  id: 'list123',
  title: 'Weekly Groceries',
  description: 'Items for this week',
  createdByUserId: 'user123',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  participants: [
    ListPermission(
      userId: 'user123',
      permission: ListPermissionType.owner,
      grantedAt: DateTime.now(),
    ),
  ],
  status: ListStatus.active,
  category: 'Groceries',
  totalItems: 10,
  completedItems: 5,
);

// Check properties
print('Completion: ${list.completionPercentage * 100}%');
print('Is shared: ${list.isShared}');
print('Is active: ${list.isActive}');
```

### ListItem

Represents an individual item in a list.

```dart
final item = ListItem(
  id: 'item123',
  listId: 'list123',
  content: 'Milk',
  state: ItemState.pending,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdByUserId: 'user123',
  order: 1,
  notes: 'Whole milk preferred',
  category: 'Dairy',
  quantity: 2.0,
  unit: 'gallons',
);

// Mark as completed
final completed = item.copyWith(
  state: ItemState.completed,
  completedByUserId: 'user123',
  completedAt: DateTime.now(),
);
```

### Message

Represents a chat message in a list.

```dart
// Text message
final textMsg = Message(
  id: 'msg123',
  listId: 'list123',
  type: MessageType.text,
  senderId: 'user123',
  senderName: 'John Doe',
  content: 'Don\'t forget the milk!',
  sentAt: DateTime.now(),
  readBy: ['user123'],
);

// Voice message
final voiceMsg = Message(
  id: 'msg124',
  listId: 'list123',
  type: MessageType.voice,
  senderId: 'user123',
  senderName: 'John Doe',
  voiceUrl: 'https://storage.example.com/voice/123.m4a',
  voiceDuration: 5,
  sentAt: DateTime.now(),
);

// Check if user has read message
if (textMsg.isReadBy('user456')) {
  print('Message has been read');
}
```

### Template

Represents a reusable list template.

```dart
final template = Template(
  id: 'template123',
  name: 'Weekly Groceries',
  description: 'My standard weekly grocery list',
  createdByUserId: 'user123',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  items: [
    const TemplateItem(
      content: 'Milk',
      category: 'Dairy',
      quantity: 1.0,
      unit: 'gallon',
      order: 0,
    ),
    const TemplateItem(
      content: 'Bread',
      category: 'Bakery',
      order: 1,
    ),
  ],
  category: 'Groceries',
  isPublic: false,
  tags: ['grocery', 'weekly'],
);

print('Template has ${template.itemCount} items');
```

### Reminder

Represents a scheduled reminder for a list.

```dart
final reminder = Reminder(
  id: 'reminder123',
  listId: 'list123',
  listTitle: 'Weekly Groceries',
  createdByUserId: 'user123',
  reminderTime: DateTime.now().add(const Duration(hours: 2)),
  scope: ReminderScope.allParticipants,
  message: 'Don\'t forget to shop today!',
  createdAt: DateTime.now(),
);

// Check status
print('Is active: ${reminder.isActive}');
print('Is pending: ${reminder.isPending}');
print('Is personal: ${reminder.isPersonal}');
```

## Enums

### ListStatus

```dart
enum ListStatus {
  active,    // Currently being worked on
  completed, // All items done
  archived,  // Archived for history
}
```

### ListPermissionType

```dart
enum ListPermissionType {
  viewOnly, // Can only view
  editor,   // Can edit items
  owner,    // Full control
}
```

### ItemState

```dart
enum ItemState {
  pending,   // Not yet done
  completed, // Completed
  cancelled, // Cancelled/skipped
}
```

### ReminderScope

```dart
enum ReminderScope {
  onlyMe,          // Just the creator
  allParticipants, // Everyone in the list
  specific,        // Specific users
}
```

## Firestore Integration

### Using Converters

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocli/core/domain/domain.dart';

final firestore = FirebaseFirestore.instance;

// Get a typed collection reference
final listsRef = firestore
    .collection(FirestorePaths.lists)
    .withListSummaryConverter();

// Read a list
final listDoc = await listsRef.doc('list123').get();
final list = listDoc.data(); // Type: ListSummary?

// Create a list
final newList = ListSummary(
  id: 'list456',
  title: 'New List',
  createdByUserId: 'user123',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await listsRef.doc(newList.id).set(newList);

// Query lists
final query = listsRef
    .where(FirestorePaths.createdByUserIdField, isEqualTo: 'user123')
    .where(FirestorePaths.statusField, isEqualTo: ListStatus.active.name)
    .orderBy(FirestorePaths.updatedAtField, descending: true);

final snapshot = await query.get();
final lists = snapshot.docs.map((doc) => doc.data()).toList();
```

### Subcollections

```dart
// Access list items
final itemsRef = firestore
    .collection(FirestorePaths.listItems('list123'))
    .withListItemConverter();

// Access messages
final messagesRef = firestore
    .collection(FirestorePaths.listMessages('list123'))
    .withMessageConverter();

// Access activities
final activitiesRef = firestore
    .collection(FirestorePaths.listActivities('list123'))
    .withListActivityConverter();
```

## Repository Pattern

### Using Repository Interfaces

All data access should go through repository interfaces for testability and dependency inversion.

```dart
// Example repository implementation
class FirestoreListRepository implements ListRepository {
  final FirebaseFirestore _firestore;

  FirestoreListRepository(this._firestore);

  @override
  Future<ListSummary> createList(ListSummary list) async {
    final ref = _firestore
        .collection(FirestorePaths.lists)
        .withListSummaryConverter();
    await ref.doc(list.id).set(list);
    return list;
  }

  @override
  Future<ListSummary?> getList(String listId) async {
    final doc = await _firestore
        .collection(FirestorePaths.lists)
        .withListSummaryConverter()
        .doc(listId)
        .get();
    return doc.data();
  }

  @override
  Stream<List<ListSummary>> watchUserLists(String userId) {
    return _firestore
        .collection(FirestorePaths.lists)
        .withListSummaryConverter()
        .where(FirestorePaths.createdByUserIdField, isEqualTo: userId)
        .orderBy(FirestorePaths.updatedAtField, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Implement other methods...
}
```

## Testing

### Unit Tests

All models include comprehensive unit tests for serialization:

```dart
test('fromJson and toJson should be inverse operations', () {
  final original = UserProfile(
    id: 'user123',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  final json = original.toJson();
  final restored = UserProfile.fromJson(json);

  expect(restored.id, equals(original.id));
  expect(restored.email, equals(original.email));
  expect(restored.displayName, equals(original.displayName));
});
```

### Running Tests

```bash
# Run all domain model tests
flutter test test/core/domain/models/

# Run specific test file
flutter test test/core/domain/models/user_profile_test.dart
```

## Best Practices

### 1. Always use copyWith for updates

```dart
// ❌ Don't create new instances manually
final updated = ListSummary(
  id: list.id,
  title: 'New Title',
  // ... all other fields
);

// ✅ Use copyWith
final updated = list.copyWith(title: 'New Title');
```

### 2. Use repository interfaces

```dart
// ❌ Don't access Firestore directly in UI
FirebaseFirestore.instance.collection('lists').doc(id).get();

// ✅ Use repository
class ListScreen extends StatelessWidget {
  final ListRepository repository;
  
  // Access data through repository
  Future<ListSummary?> loadList(String id) {
    return repository.getList(id);
  }
}
```

### 3. Handle nullable fields properly

```dart
// Models use nullable fields where appropriate
final user = UserProfile(/* ... */);

// Check nullable fields before using
if (user.photoUrl != null) {
  displayPhoto(user.photoUrl!);
}

// Or use null-aware operators
final photo = user.photoUrl ?? 'default_photo.jpg';
```

### 4. Use enums instead of strings

```dart
// ❌ Don't use strings
if (list.status == 'active') { }

// ✅ Use enums
if (list.status == ListStatus.active) { }
if (list.status.isActive) { }
```

## Migration from Legacy Models

### Old to New Model Mapping

- `User` → `UserProfile`
- `GroceryList` → `ListSummary`
- `ListItem` → `ListItem` (enhanced with new fields)
- `Message` → `Message` (enhanced with voice support)
- New: `Contact`, `ListPermission`, `ListActivity`, `Template`, `Reminder`

### Migration Steps

1. Update imports from `core/models` to `core/domain/domain`
2. Replace old model constructors with new ones
3. Update field names if changed
4. Handle new required fields with appropriate defaults
5. Update serialization code to use new JSON methods
6. Test thoroughly!

## Offline Support

### Caching Strategy

Models work seamlessly with both Firestore and local Hive storage:

1. **Optimistic Updates**: Update local cache immediately
2. **Background Sync**: Queue changes for Firestore when online
3. **Conflict Resolution**: Last-write-wins based on timestamps

### Using with Hive

While models are designed for Firestore, you can still cache them locally:

```dart
// Store as JSON in Hive
final box = await Hive.openBox('lists');
await box.put('list123', list.toJson());

// Retrieve and deserialize
final json = box.get('list123') as Map<String, dynamic>;
final list = ListSummary.fromJson(json);
```

## Additional Resources

- [SCHEMA.md](SCHEMA.md) - Complete database schema documentation
- [API Documentation](https://pub.dev/documentation/freezed/latest/) - Freezed package docs
- [Firestore Documentation](https://firebase.google.com/docs/firestore) - Firebase Firestore docs

## Support

For questions or issues with domain models:
1. Check this guide and SCHEMA.md
2. Review the unit tests for examples
3. Open an issue in the project repository
