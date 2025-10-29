# Reminders Feature Documentation

## Overview

This app includes a comprehensive reminder notification system that allows users to:
- Create and manage reminders for lists
- Schedule notifications with date/time selection
- Choose between self-only or all-participants notifications
- Set quiet hours to delay notifications
- Navigate directly to lists when tapping notifications

## Features

### 1. Reminder Management
- **Create Reminders**: Set title, description, date/time, and audience
- **Edit Reminders**: Modify existing reminders before they trigger
- **Delete Reminders**: Cancel and remove unwanted reminders
- **View Reminders**: See all upcoming reminders for a list

### 2. Notification System
- **Local Notifications**: Uses flutter_local_notifications for offline support
- **FCM Push Notifications**: Firebase Cloud Messaging for remote notifications
- **Deep Linking**: Tapping notifications opens the specific list
- **Quiet Hours**: Automatic delay of notifications during quiet hours

### 3. Cloud Functions
- **Scheduled Processing**: Runs every minute to check for due reminders
- **Batch Notifications**: Sends notifications to target users
- **Token Management**: Handles FCM token registration and cleanup
- **Auto-disable**: Marks reminders as inactive after notification

## Setup Instructions

### 1. Firebase Configuration

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Firestore Database
3. Enable Cloud Functions
4. Enable Firebase Cloud Messaging

### 2. Configure Firebase in the App

Replace the demo values in `lib/firebase_options.dart` with your actual Firebase project values:
- apiKey
- appId
- messagingSenderId
- projectId
- authDomain
- storageBucket

### 3. Deploy Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 4. Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<application>
    <!-- Add inside <application> -->
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
        </intent-filter>
    </receiver>
</application>
```

### 5. iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

Enable Push Notifications capability in Xcode.

## Usage

### Creating a Reminder

1. Navigate to a list
2. Tap the + button
3. Enter reminder details:
   - Title (required)
   - Description (optional)
   - Date and time
   - Audience (self or all participants)
4. Tap Save

### Editing a Reminder

1. Tap the three-dot menu on a reminder card
2. Select "Edit"
3. Modify the details
4. Tap Save

### Deleting a Reminder

1. Tap the three-dot menu on a reminder card
2. Select "Delete"
3. Confirm deletion

### Quiet Hours

1. Tap the settings icon in the app bar
2. Enable "Quiet Hours"
3. Set start and end times
4. Notifications scheduled during quiet hours will be delayed until the end time

## Architecture

### Models
- `Reminder`: Core reminder data model
- `TodoList`: List data model
- `AppSettings`: User settings including quiet hours

### Services
- `NotificationService`: Handles local and FCM notifications
- `RemindersService`: Manages reminder CRUD operations
- `FirebaseService`: Handles Firestore operations for lists

### Cloud Functions
- `scheduleReminderNotifications`: Scheduled function that runs every minute
- `onReminderCreated`: Trigger on new reminder creation
- `onReminderUpdated`: Trigger on reminder updates
- `saveFCMToken`: Saves user's FCM token
- `removeFCMToken`: Removes user's FCM token

## Firestore Schema

### Collections

#### reminders
```
{
  id: string
  listId: string
  title: string
  description?: string
  scheduledTime: timestamp
  audience: "self" | "allParticipants"
  createdBy: string
  isActive: boolean
  notifiedUsers: string[]
}
```

#### lists
```
{
  id: string
  name: string
  ownerId: string
  participantIds: string[]
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### userTokens
```
{
  tokens: string[]
  updatedAt: timestamp
}
```

## Testing

### Local Testing
1. Run the app: `flutter run`
2. Create a list
3. Add a reminder scheduled for 1-2 minutes in the future
4. Wait for the notification to arrive
5. Tap the notification to verify navigation

### Cloud Functions Testing
```bash
cd functions
npm run serve
```

This starts the Firebase emulator for local testing.

## Troubleshooting

### Notifications Not Appearing
- Check that notification permissions are granted
- Verify FCM token is being saved
- Check Cloud Functions logs: `firebase functions:log`
- Ensure the app is not in quiet hours

### Navigation Not Working
- Verify the list ID is being passed in notification payload
- Check that the list exists in Firestore

### Cloud Functions Not Triggering
- Verify the function is deployed: `firebase functions:list`
- Check the schedule: The function runs every minute
- Review Cloud Functions logs for errors

## Future Enhancements

Potential improvements:
- Recurring reminders (daily, weekly, etc.)
- Snooze functionality
- Rich notifications with actions
- Multiple reminder times per list
- Custom notification sounds
- Reminder templates
- Notification history
