# List Chat Feature

## Overview
This app provides a comprehensive chat system integrated within list details. Users can exchange text and voice messages in real-time with other list participants.

## Features

### 1. Chat UI
- **Message History**: Displays all messages in chronological order
- **Text Messages**: Simple text-based messaging
- **Voice Messages**: Record and send voice notes with visual waveform display
- **Read Receipts**: Shows when messages are read by participants
- **Typing Indicators**: Real-time indication when other users are typing

### 2. Message Storage (Firestore)
All messages are stored in a Firestore subcollection structure:
```
lists/{listId}/messages/{messageId}
```

Each message includes:
- Sender metadata (ID and name)
- Timestamps
- Read receipts (map of userId -> boolean)
- Message type (text or voice)
- Voice note storage references (for voice messages)
- Waveform data and duration (for voice messages)

### 3. Voice Messages
- **Recording**: Press and hold the microphone button to record
- **Waveform Visualization**: Real-time amplitude display during recording
- **Storage**: Voice files are uploaded to Firebase Storage
- **Playback**: Tap play button to listen to voice messages
- **Duration Display**: Shows recording/playback time

### 4. Real-time Updates
- Messages appear instantly using Firestore real-time listeners
- Typing indicators update in real-time
- Read receipts update automatically

### 5. Push Notifications
- Users receive notifications for new messages when not viewing the chat
- Topic-based messaging per list for efficient delivery
- Background and foreground notification handling

### 6. Business Rules
- **Auto-clear on completion**: When a list is marked as complete, all chat messages are automatically deleted
- This ensures chat history is tied to active lists only

## Architecture

### Models
- `ListModel`: Represents a list with participants and completion status
- `MessageModel`: Represents a message (text or voice) with metadata

### Services
- `FirestoreService`: Handles all Firestore operations (messages, lists, typing status)
- `StorageService`: Manages voice note uploads to Firebase Storage
- `MessagingService`: Handles push notification setup and subscriptions

### Screens
- `ListsScreen`: Main screen showing all lists
- `ListDetailScreen`: Shows list details with option to open chat
- `ChatScreen`: Full chat interface with message history and input

### Widgets
- `MessageBubble`: Displays individual messages (text or voice)
- `MessageInput`: Text input with voice recording toggle
- `VoiceRecorderWidget`: Voice recording interface with waveform
- `VoicePlayerWidget`: Voice message playback with waveform
- `TypingIndicator`: Animated typing indicator

## Setup Requirements

### Firebase Configuration
1. Create a Firebase project
2. Enable Firestore Database
3. Enable Firebase Storage
4. Enable Firebase Cloud Messaging
5. Update `lib/firebase_options.dart` with your project credentials

### Firestore Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /lists/{listId} {
      allow read, write: if request.auth != null;
      
      match /messages/{messageId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
        allow update: if request.auth != null && 
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['readBy']);
      }
    }
  }
}
```

### Storage Security Rules (Recommended)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /voice_notes/{listId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Platform Permissions

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS (Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record voice messages.</string>
```

## Usage

### Creating a List
1. Tap the + button on the Lists screen
2. Enter list name and description
3. Tap Create

### Opening Chat
1. Select a list from the main screen
2. Tap "Open Chat" button
3. Start messaging!

### Sending Text Messages
1. Type your message in the input field
2. Tap the send button (appears when text is entered)

### Sending Voice Messages
1. Tap and hold the microphone button
2. Speak your message (watch the waveform!)
3. Tap send to upload and share

### Completing a List
1. Open the list detail screen
2. Tap the checkmark icon in the app bar
3. Confirm - this will delete all chat messages

## Technical Notes

- Voice recordings are in M4A format (AAC-LC codec)
- Waveform data is normalized to 0.1-1.0 range
- Typing indicators timeout after 3 seconds of inactivity
- Messages are automatically marked as read when viewed
- Firebase emulator can be used for local development

## Future Enhancements
- User authentication and profiles
- Image/file attachments
- Message reactions
- Search functionality
- Message deletion
- Edit sent messages
- Reply/thread functionality
