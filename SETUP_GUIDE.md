# Grocli - Setup Guide

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase CLI
- Node.js (for Firebase tools)
- Android Studio / Xcode for mobile development
- VS Code or Android Studio as IDE

## Step-by-Step Setup

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd /workspace

# Get Flutter dependencies
flutter pub get

# Check Flutter doctor
flutter doctor
```

### 2. Firebase Setup

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Name it "Grocli" (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create Project"

#### B. Add Firebase to Flutter

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This will:
- Ask you to select your Firebase project
- Generate `firebase_options.dart`
- Add necessary configuration files for iOS and Android

#### C. Enable Firebase Services

In Firebase Console, enable:

1. **Authentication**
   - Email/Password
   - Google Sign-In
   - Apple Sign-In (for iOS)

2. **Cloud Firestore**
   - Start in test mode (change to production rules later)
   - Create database

3. **Cloud Storage**
   - Start in test mode
   - Create default bucket

4. **Cloud Messaging**
   - No additional setup needed

#### D. Set up Firestore Security Rules

Go to Firestore → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      match /contacts/{contactId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Lists
    match /lists/{listId} {
      allow read: if request.auth != null && (
        resource.data.createdByUserId == request.auth.uid ||
        request.auth.uid in resource.data.sharedWith
      );
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.createdByUserId == request.auth.uid;
      
      match /items/{itemId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
      
      match /messages/{messageId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
        allow delete: if request.auth != null && 
          resource.data.senderId == request.auth.uid;
      }
    }
  }
}
```

#### E. Set up Storage Security Rules

Go to Storage → Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /voice_messages/{userId}/{messageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profile_pictures/{userId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Generate Hive Adapters

```bash
# Generate Hive type adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create `.g.dart` files for all your models.

### 4. Platform-Specific Setup

#### Android Setup

1. **Update `android/app/build.gradle`** (already done):
   - Min SDK version: 21
   - Compile SDK: 34

2. **Add Google Services** (after running flutterfire configure):
   - File should be at `android/app/google-services.json`

3. **Update `AndroidManifest.xml`** (already done):
   - Permissions for: Internet, Camera, Microphone, Contacts, Notifications

4. **For Google Sign-In**:
   - Get SHA-1 certificate fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Add SHA-1 to Firebase Console → Project Settings → Your Apps → Android app

#### iOS Setup

1. **Update `ios/Runner/Info.plist`** (add if missing):
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>We need microphone access for voice recording</string>
   <key>NSContactsUsageDescription</key>
   <string>We need contacts access to help you share lists</string>
   <key>NSCameraUsageDescription</key>
   <string>We need camera access for profile pictures</string>
   ```

2. **Add GoogleService-Info.plist** (after running flutterfire configure):
   - Should be at `ios/Runner/GoogleService-Info.plist`

3. **For Apple Sign-In**:
   - Enable in Xcode: Signing & Capabilities → + Capability → Sign in with Apple

4. **Update Podfile** (if needed):
   ```bash
   cd ios
   pod install
   ```

### 5. Optional: AI Integration

For production-ready AI features, integrate with an AI service:

#### Option A: OpenAI API

Update `lib/core/services/ai_service.dart`:

```dart
static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
static const String _apiKey = 'YOUR_OPENAI_API_KEY';
```

#### Option B: Google Cloud AI

1. Enable Vertex AI in Google Cloud
2. Update AI service to use Google Cloud endpoints

#### Option C: Firebase Cloud Functions

Create a Cloud Function for AI processing:

```bash
firebase init functions
```

Then deploy your AI logic to Cloud Functions.

### 6. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

### 7. Testing

```bash
# Run tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

### 8. Build for Production

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release

# Open Xcode to archive
open ios/Runner.xcworkspace
```

## Troubleshooting

### Common Issues

1. **Hive Adapter Errors**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Firebase Not Initialized**
   - Make sure `firebase_options.dart` exists
   - Check `main.dart` has `Firebase.initializeApp()`

3. **Gradle Build Fails (Android)**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

4. **Pod Install Issues (iOS)**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter clean
   ```

5. **Permission Denied Errors**
   - Check AndroidManifest.xml has all required permissions
   - Check Info.plist has usage descriptions

## Environment Variables

For sensitive data, use environment variables:

1. Create `.env` file (add to .gitignore)
2. Use `flutter_dotenv` package
3. Load in main.dart

## Continuous Integration

Set up CI/CD with:
- GitHub Actions
- Codemagic
- Bitrise
- Firebase App Distribution

## Monitoring

Set up monitoring with:
- Firebase Crashlytics
- Firebase Performance Monitoring
- Firebase Analytics

## Support

For issues or questions:
- Check Flutter documentation
- Check Firebase documentation  
- Review error logs in Firebase Console
- Check device logs: `flutter logs`

---

**You're all set! Happy coding! 🚀**
