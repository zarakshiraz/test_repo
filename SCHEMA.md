# Grocli Database Schema Documentation

## Overview

This document describes the Firestore database schema for Grocli, including collections, subcollections, field definitions, and relationships between entities.

## ER Diagram

```
┌─────────────────┐
│   UserProfile   │
│─────────────────│
│ id (PK)         │
│ email           │
│ displayName     │
│ photoUrl        │
│ phoneNumber     │
│ createdAt       │
│ updatedAt       │
│ contactIds[]    │
│ blockedUserIds[]│
│ isActive        │
│ preferences     │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐       ┌──────────────────┐
│    Contact      │       │   ListSummary    │
│─────────────────│       │──────────────────│
│ id (PK)         │       │ id (PK)          │
│ userId (FK)     │       │ title            │
│ contactUserId   │       │ description      │
│ displayName     │       │ createdByUserId  │◄──┐
│ email           │       │ createdAt        │   │
│ photoUrl        │       │ updatedAt        │   │
│ phoneNumber     │       │ participants[]   │   │
│ addedAt         │       │ status           │   │ 1:N
│ isFavorite      │       │ completedAt      │   │
│ notes           │       │ category         │   │
└─────────────────┘       │ totalItems       │   │
                          │ completedItems   │   │
                          │ isSaved          │   │
                          │ hasReminder      │   │
                          │ metadata         │   │
                          └────────┬─────────┘   │
                                   │             │
                    ┌──────────────┼─────────────┤
                    │              │             │
                    │ 1:N          │ 1:N         │ 1:N
                    │              │             │
                    ▼              ▼             ▼
         ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
         │  ListItem   │  │   Message    │  │ListActivity │
         │─────────────│  │──────────────│  │─────────────│
         │ id (PK)     │  │ id (PK)      │  │ id (PK)     │
         │ listId (FK) │  │ listId (FK)  │  │ listId (FK) │
         │ content     │  │ type         │  │ type        │
         │ state       │  │ senderId     │  │ userId      │
         │ completed..│  │ senderName   │  │ userName    │
         │ createdAt   │  │ content      │  │ timestamp   │
         │ updatedAt   │  │ voiceUrl     │  │ description │
         │ created..   │  │ sentAt       │  │ itemId      │
         │ order       │  │ readBy[]     │  │ itemContent │
         │ notes       │  │ isDeleted    │  │ targetUserId│
         │ category    │  │ deletedAt    │  │ metadata    │
         │ quantity    │  │ metadata     │  └─────────────┘
         │ unit        │  └──────────────┘
         │ metadata    │
         └─────────────┘
                                          ┌─────────────┐
                                          │  Template   │
         ┌────────────────┐               │─────────────│
         │ListPermission  │               │ id (PK)     │
         │────────────────│               │ name        │
         │ userId (FK)    │               │ description │
         │ permission     │               │ created...  │
         │ grantedAt      │               │ createdAt   │
         │ grantedBy      │               │ updatedAt   │
         │ revokedAt      │               │ items[]     │
         │ revokedBy      │               │ category    │
         └────────────────┘               │ isPublic    │
                                          │ usageCount  │
                                          │ tags[]      │
                                          │ metadata    │
                                          └─────────────┘

         ┌─────────────┐
         │  Reminder   │
         │─────────────│
         │ id (PK)     │
         │ listId (FK) │
         │ listTitle   │
         │ created...  │
         │ reminderTime│
         │ scope       │
         │ targetUsers│
         │ message     │
         │ isRecurring │
         │ recurring..│
         │ createdAt   │
         │ isSent      │
         │ sentAt      │
         │ isCancelled │
         │ cancelled..│
         │ metadata    │
         └─────────────┘
```

## Collection Structure

### Root Collections

#### `/users/{userId}`
Main user profile collection.

**Fields:**
- `email`: string - User's email address
- `displayName`: string - User's display name
- `photoUrl`: string? - Profile photo URL
- `phoneNumber`: string? - Phone number
- `createdAt`: Timestamp - Account creation timestamp
- `updatedAt`: Timestamp - Last update timestamp
- `contactIds`: string[] - Array of contact user IDs
- `blockedUserIds`: string[] - Array of blocked user IDs
- `isActive`: boolean - Account active status
- `preferences`: map - User preferences and settings

**Subcollections:**
- `/users/{userId}/contacts/{contactId}` - User's contacts

**Indexes:**
- `email` (ASC)
- `createdAt` (DESC)

---

#### `/lists/{listId}`
Main list collection storing list summaries.

**Fields:**
- `title`: string - List title
- `description`: string? - Optional description
- `createdByUserId`: string - Creator's user ID
- `createdAt`: Timestamp - Creation timestamp
- `updatedAt`: Timestamp - Last update timestamp
- `participants`: ListPermission[] - Array of participant permissions
- `status`: string - List status (active, completed, archived)
- `completedAt`: Timestamp? - Completion timestamp
- `category`: string? - List category
- `totalItems`: number - Total number of items
- `completedItems`: number - Number of completed items
- `isSaved`: boolean - Saved/template flag
- `hasReminder`: boolean - Has active reminder flag
- `metadata`: map - Additional metadata

**Subcollections:**
- `/lists/{listId}/items/{itemId}` - List items
- `/lists/{listId}/messages/{messageId}` - List messages
- `/lists/{listId}/participants/{userId}` - Participant details
- `/lists/{listId}/activities/{activityId}` - Activity log

**Indexes:**
- `createdByUserId` (ASC), `status` (ASC), `updatedAt` (DESC)
- `participants.userId` (ARRAY_CONTAINS), `updatedAt` (DESC)
- `status` (ASC), `updatedAt` (DESC)

---

#### `/lists/{listId}/items/{itemId}`
Subcollection storing individual list items.

**Fields:**
- `listId`: string - Parent list ID
- `content`: string - Item content/description
- `state`: string - Item state (pending, completed, cancelled)
- `completedByUserId`: string? - User who completed item
- `completedAt`: Timestamp? - Completion timestamp
- `createdAt`: Timestamp - Creation timestamp
- `updatedAt`: Timestamp - Last update timestamp
- `createdByUserId`: string - Creator's user ID
- `order`: number - Display order
- `notes`: string? - Additional notes
- `category`: string? - Item category
- `quantity`: number? - Quantity
- `unit`: string? - Unit of measurement
- `metadata`: map - Additional metadata

**Indexes:**
- `listId` (ASC), `order` (ASC)
- `listId` (ASC), `state` (ASC)

---

#### `/lists/{listId}/messages/{messageId}`
Subcollection storing list chat messages.

**Fields:**
- `listId`: string - Parent list ID
- `type`: string - Message type (text, voice, system)
- `senderId`: string - Sender's user ID
- `senderName`: string? - Sender's display name
- `senderPhotoUrl`: string? - Sender's photo URL
- `content`: string? - Text content
- `voiceUrl`: string? - Voice message URL
- `voiceDuration`: number? - Voice message duration in seconds
- `sentAt`: Timestamp - Send timestamp
- `readBy`: string[] - Array of user IDs who read the message
- `isDeleted`: boolean - Deleted flag
- `deletedAt`: Timestamp? - Deletion timestamp
- `metadata`: map - Additional metadata

**Indexes:**
- `listId` (ASC), `sentAt` (DESC)

---

#### `/lists/{listId}/activities/{activityId}`
Subcollection storing list activity log.

**Fields:**
- `listId`: string - Parent list ID
- `type`: string - Activity type (listCreated, itemAdded, etc.)
- `userId`: string - User who performed the action
- `userName`: string? - User's display name
- `timestamp`: Timestamp - Activity timestamp
- `description`: string? - Activity description
- `itemId`: string? - Related item ID
- `itemContent`: string? - Related item content
- `targetUserId`: string? - Target user ID (for user-related activities)
- `metadata`: map - Additional metadata

**Indexes:**
- `listId` (ASC), `timestamp` (DESC)

---

#### `/templates/{templateId}`
Reusable list templates.

**Fields:**
- `name`: string - Template name
- `description`: string? - Template description
- `createdByUserId`: string - Creator's user ID
- `createdAt`: Timestamp - Creation timestamp
- `updatedAt`: Timestamp - Last update timestamp
- `items`: TemplateItem[] - Array of template items
- `category`: string? - Template category
- `isPublic`: boolean - Public visibility flag
- `usageCount`: number - Usage count
- `tags`: string[] - Search tags
- `metadata`: map - Additional metadata

**TemplateItem Structure:**
- `content`: string - Item content
- `category`: string? - Item category
- `quantity`: number? - Quantity
- `unit`: string? - Unit of measurement
- `order`: number - Display order

**Indexes:**
- `createdByUserId` (ASC), `updatedAt` (DESC)
- `isPublic` (ASC), `usageCount` (DESC)
- `tags` (ARRAY_CONTAINS), `usageCount` (DESC)

---

#### `/reminders/{reminderId}`
Scheduled reminders for lists.

**Fields:**
- `listId`: string - Related list ID
- `listTitle`: string? - List title (cached)
- `createdByUserId`: string - Creator's user ID
- `reminderTime`: Timestamp - Scheduled reminder time
- `scope`: string - Reminder scope (onlyMe, allParticipants, specific)
- `targetUserIds`: string[] - Target user IDs (for specific scope)
- `message`: string? - Custom reminder message
- `isRecurring`: boolean - Recurring flag
- `recurringPattern`: string? - Recurrence pattern
- `createdAt`: Timestamp - Creation timestamp
- `isSent`: boolean - Sent flag
- `sentAt`: Timestamp? - Send timestamp
- `isCancelled`: boolean - Cancelled flag
- `cancelledAt`: Timestamp? - Cancellation timestamp
- `metadata`: map - Additional metadata

**Indexes:**
- `listId` (ASC), `reminderTime` (ASC)
- `targetUserIds` (ARRAY_CONTAINS), `isSent` (ASC), `reminderTime` (ASC)
- `isSent` (ASC), `isCancelled` (ASC), `reminderTime` (ASC)

---

## Enums

### ListStatus
- `active` - List is currently active
- `completed` - List has been completed
- `archived` - List has been archived

### ListPermissionType
- `viewOnly` - Can only view the list
- `canEdit` - Can edit the list and items
- `owner` - Full control over the list

### ItemState
- `pending` - Item is pending completion
- `completed` - Item has been completed
- `cancelled` - Item has been cancelled

### ReminderScope
- `onlyMe` - Reminder only for creator
- `allParticipants` - Reminder for all list participants
- `specific` - Reminder for specific users

### ActivityType
- `listCreated` - List was created
- `listUpdated` - List details were updated
- `listCompleted` - List was marked as completed
- `listArchived` - List was archived
- `itemAdded` - Item was added
- `itemUpdated` - Item was updated
- `itemCompleted` - Item was completed
- `itemDeleted` - Item was deleted
- `userAdded` - User was added as participant
- `userRemoved` - User was removed
- `permissionChanged` - User permission was changed

### MessageType
- `text` - Text message
- `voice` - Voice message
- `system` - System-generated message

---

## Offline Strategy

### Local Storage with Hive
All Firestore data is cached locally using Hive for offline functionality:
- User profiles cached in `user_box`
- Lists cached in `list_box`
- Items cached in `item_box`
- Messages cached in `message_box`

### Sync Strategy
1. **Optimistic Updates**: Local changes are applied immediately to cache
2. **Pending Queue**: Changes are queued when offline
3. **Background Sync**: Automatic sync when connection is restored
4. **Conflict Resolution**: Last-write-wins with timestamp comparison

### Repository Pattern
All data access goes through repository interfaces:
- `ListRepository` - List and item operations
- `TemplateRepository` - Template operations
- `MessageRepository` - Message operations
- `ReminderRepository` - Reminder operations

---

## Security Rules Considerations

### User Data
- Users can only read/write their own profile
- User contacts are private to the owner

### Lists
- List creator has owner permission
- Participants can read based on their permission level
- Only owner can delete lists or manage permissions
- Users with `canEdit` permission can modify items

### Messages
- Only list participants can read messages
- Users can only delete their own messages
- System messages cannot be manually created

### Templates
- Public templates are readable by all users
- Private templates are only accessible to creator
- Only creator can update/delete templates

### Reminders
- Only reminder creator and target users can read reminders
- Only creator can update/cancel reminders

---

## Migration Notes

### From Existing Models
The new Freezed models replace the existing Hive-based models:
- `User` → `UserProfile`
- `GroceryList` → `ListSummary`
- `ListItem` → `ListItem` (enhanced)
- `Message` → `Message` (enhanced)

### Data Migration
When migrating from old to new models:
1. Export data from Hive boxes
2. Transform to new model format
3. Upload to Firestore
4. Clear old Hive boxes
5. Re-populate with synced data

---

## Performance Considerations

### Pagination
- Messages: Load 100 most recent, paginate older
- Activities: Load 50 most recent, paginate older
- Lists: Load 20 at a time, infinite scroll

### Denormalization
- User names cached in messages and activities
- List title cached in reminders
- Item counts cached in list summary

### Composite Indexes
Required composite indexes defined in `firestore.indexes.json`

---

## Future Enhancements

### Planned Features
- [ ] List history/versioning
- [ ] Item attachments (photos)
- [ ] Advanced search with full-text
- [ ] Analytics and insights
- [ ] Collaborative filtering for suggestions

### Schema Evolution
- Version field in metadata for schema migrations
- Backward compatibility for older clients
- Gradual rollout of breaking changes

---

Generated: 2024
Last Updated: Task completion date
