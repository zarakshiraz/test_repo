# Firebase Setup Guide for Grocli

This guide will walk you through setting up Firebase for the Grocli app, including Authentication, Firestore, Cloud Storage, Cloud Functions, and Cloud Messaging (FCM).

## Table of Contents
- [Prerequisites](#prerequisites)
- [Firebase Project Setup](#firebase-project-setup)
- [Platform Configuration](#platform-configuration)
- [Authentication Setup](#authentication-setup)
- [Firestore Setup](#firestore-setup)
- [Cloud Storage Setup](#cloud-storage-setup)
- [Cloud Functions Setup](#cloud-functions-setup)
- [Cloud Messaging (FCM) Setup](#cloud-messaging-fcm-setup)
- [Firebase Emulators](#firebase-emulators)
- [Environment Variables & Secrets](#environment-variables--secrets)
- [Testing](#testing)
- [Deployment](#deployment)

## Prerequisites

- Flutter SDK 3.9.2+
- Node.js 18+ (for Cloud Functions)
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- A Google account for Firebase Console access

## Firebase Project Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `grocli-app` (or your preferred name)
4. Enable/disable Google Analytics as preferred
5. Click "Create project"

### 2. Upgrade to Blaze Plan (Pay-as-you-go)

Cloud Functions and some advanced features require the Blaze plan:
1. Go to project settings
2. Navigate to Usage and billing
3. Click "Modify plan" and select "Blaze"

### 3. Enable Required Firebase Services

In the Firebase Console, enable:
- **Authentication** (left sidebar)
- **Firestore Database** (left sidebar)
- **Storage** (left sidebar)
- **Functions** (left sidebar)
- **Cloud Messaging** (left sidebar, under "Engage")

## Platform Configuration

### Android Setup

#### 1. Register Android App

1. In Firebase Console, click the Android icon
2. Enter package name: `com.grocli.app`
3. Enter app nickname: `Grocli Android`
4. Enter Debug signing certificate SHA-1 (for Google Sign-In)
   
   Get your SHA-1:
   ```bash
   # For debug keystore
   keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
   # Password: android
   
   # For release keystore (when you have one)
   keytool -list -v -alias your_alias -keystore path/to/your/keystore.jks
   ```

5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

#### 2. Update Configuration

The following files have already been configured:
- ✅ `android/settings.gradle.kts` - Google Services plugin added
- ✅ `android/app/build.gradle.kts` - Plugin applied, package updated to `com.grocli.app`
- ✅ `android/app/src/main/AndroidManifest.xml` - Permissions and FCM metadata added
- ✅ `android/app/src/main/kotlin/com/grocli/app/MainActivity.kt` - Package updated

### iOS Setup

#### 1. Register iOS App

1. In Firebase Console, click the iOS icon
2. Enter bundle ID: `com.grocli.app`
3. Enter app nickname: `Grocli iOS`
4. Enter App Store ID (optional, for later)
5. Download `GoogleService-Info.plist`
6. In Xcode, right-click `Runner` folder → Add Files → Select the plist
   - ⚠️ Make sure "Copy items if needed" is checked
   - ⚠️ Make sure target "Runner" is selected

#### 2. Update Bundle Identifier

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Runner target
3. Change Bundle Identifier to: `com.grocli.app`
4. Update Team (for code signing)

#### 3. Configuration Already Applied

The following have been pre-configured:
- ✅ `ios/Runner/Info.plist` - Permissions and URL schemes
- ✅ `ios/Runner/AppDelegate.swift` - FCM notification handling

### Generate Firebase Options with FlutterFire

After placing the config files, regenerate `firebase_options.dart`:

```bash
flutterfire configure --project=grocli-app
```

This will:
- Update `lib/firebase_options.dart` with your actual Firebase configuration
- Ensure all platforms are properly configured

## Authentication Setup

### Email/Password Authentication

1. In Firebase Console → Authentication → Sign-in method
2. Click "Email/Password"
3. Enable both switches
4. Click "Save"

### Google Sign-In

#### Android
1. In Firebase Console → Authentication → Sign-in method
2. Click "Google"
3. Enable the switch
4. Select support email
5. Click "Save"
6. **Important**: Make sure you added SHA-1 certificate when registering the Android app

#### iOS
1. Same as above for enabling in Firebase Console
2. In Xcode, add custom URL scheme:
   - Open `Info.plist`
   - Find `CFBundleURLTypes` (already added)
   - Replace `REVERSED_CLIENT_ID` with the value from `GoogleService-Info.plist`
   
   Example: If `REVERSED_CLIENT_ID` in plist is:
   ```
   com.googleusercontent.apps.123456789-abc
   ```
   
   Update `Info.plist`:
   ```xml
   <string>com.googleusercontent.apps.123456789-abc</string>
   ```

### Apple Sign-In (iOS only)

#### 1. Apple Developer Setup

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Certificates, Identifiers & Profiles → Identifiers
3. Find your app's identifier (`com.grocli.app`)
4. Enable "Sign in with Apple" capability
5. Configure:
   - Enable as primary App ID
   - Add any grouped App IDs if needed

#### 2. Xcode Configuration

1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability"
4. Add "Sign in with Apple"

#### 3. Firebase Configuration

1. Firebase Console → Authentication → Sign-in method
2. Click "Apple"
3. Enable the switch
4. Configure service ID:
   - Create a service ID in Apple Developer Portal
   - Service ID: `com.grocli.app.signin`
   - Register it with Firebase following the wizard
5. Add OAuth redirect URL from Firebase to Apple Developer Portal

#### 4. Web Support (Optional)

For Apple Sign-In on web/Android:
1. Download the service key from Apple Developer Portal
2. Upload it in Firebase Console under Apple provider settings

## Firestore Setup

### 1. Create Firestore Database

1. Firebase Console → Firestore Database
2. Click "Create database"
3. Select location (e.g., `us-central1` or closest to your users)
4. Start in **test mode** (we'll deploy proper rules shortly)

### 2. Deploy Security Rules

The security rules are already defined in `firestore.rules`. Deploy them:

```bash
firebase deploy --only firestore:rules
```

### 3. Deploy Indexes

Composite indexes are defined in `firestore.indexes.json`:

```bash
firebase deploy --only firestore:indexes
```

### 4. Verify Rules

Test the rules in Firebase Console → Firestore → Rules tab, or use the emulator (see below).

## Cloud Storage Setup

### 1. Create Storage Bucket

1. Firebase Console → Storage
2. Click "Get started"
3. Select "Start in production mode"
4. Choose same location as Firestore

### 2. Deploy Security Rules

Storage rules are in `storage.rules`:

```bash
firebase deploy --only storage
```

### 3. Test File Upload

In Firebase Console → Storage, you should see the bucket ready.

## Cloud Functions Setup

### 1. Install Dependencies

```bash
cd functions
npm install
cd ..
```

### 2. Build Functions

```bash
cd functions
npm run build
cd ..
```

### 3. Environment Configuration

Set required environment variables:

```bash
# For AI API (if using external service like OpenAI)
firebase functions:config:set ai.api_key="your_api_key_here"
firebase functions:config:set ai.api_url="https://api.openai.com/v1"

# Get current config
firebase functions:config:get
```

### 4. Deploy Functions

```bash
firebase deploy --only functions
```

Or deploy specific function:
```bash
firebase deploy --only functions:aiProxyFunction
```

### 5. Available Functions

The following Cloud Functions are deployed:

- **helloWorld**: Test function (callable)
- **aiProxyFunction**: AI item extraction and suggestions (callable)
- **onUserCreated**: Trigger when user account is created
- **onUserDeleted**: Cleanup when user account is deleted
- **sendListInvitationNotification**: Send FCM notification on list invitation

## Cloud Messaging (FCM) Setup

### Android

#### 1. Add Server Key to Firebase

1. Firebase Console → Project Settings → Cloud Messaging
2. Under "Cloud Messaging API", enable the API if needed
3. Note your Server Key (for testing)

#### 2. Test with Android Device

Build and run:
```bash
flutter run
```

The app will automatically:
- Request notification permission
- Register for FCM token
- Handle foreground and background notifications

#### 3. Verify Token

Check logs for FCM token:
```bash
flutter logs | grep "FCM Token"
```

### iOS

#### 1. Upload APNs Key to Firebase

1. Apple Developer Portal → Keys
2. Create a new key with "Apple Push Notifications service (APNs)" enabled
3. Download the `.p8` key file
4. Note the Key ID and Team ID
5. Firebase Console → Project Settings → Cloud Messaging → iOS app
6. Upload the APNs key with Key ID and Team ID

#### 2. Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability"
4. Add "Push Notifications"
5. Add "Background Modes"
   - Check "Remote notifications"

#### 3. Test on iOS Device

You must use a real device (push notifications don't work on simulator):

```bash
flutter run -d <device_id>
```

## Firebase Emulators

The Firebase Emulator Suite allows local development and testing.

### 1. Install Emulators

```bash
firebase init emulators
```

Select:
- Authentication Emulator
- Firestore Emulator
- Storage Emulator
- Functions Emulator

Or install all:
```bash
firebase emulators:start
```

### 2. Start Emulators

```bash
firebase emulators:start
```

The Emulator UI will be available at: http://localhost:4000

### 3. Connect App to Emulators

During development, you can point the app to emulators. Add this code in `lib/main.dart` after Firebase initialization:

```dart
if (kDebugMode) {
  try {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  } catch (e) {
    // Already using emulators
  }
}
```

### 4. Import/Export Data

Export data from emulators:
```bash
firebase emulators:export ./emulator-data
```

Import on next start:
```bash
firebase emulators:start --import=./emulator-data
```

## Environment Variables & Secrets

### Firebase Functions Secrets

Use Firebase's secret manager for sensitive data:

```bash
# Set secret
firebase functions:secrets:set AI_API_KEY

# View secrets
firebase functions:secrets:access AI_API_KEY
```

Update function to use secrets:
```typescript
import {defineSecret} from 'firebase-functions/params';

const apiKey = defineSecret('AI_API_KEY');

export const myFunction = functions
  .runWith({secrets: [apiKey]})
  .https.onCall(async (data, context) => {
    const key = apiKey.value();
    // Use key...
  });
```

### Flutter Environment Variables (Optional)

For API keys used in Flutter app, consider using `flutter_dotenv`:

1. Add dependency:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Create `.env` file (add to `.gitignore`):
   ```
   AI_API_KEY=your_key_here
   ```

3. Load in app:
   ```dart
   await dotenv.load();
   final apiKey = dotenv.env['AI_API_KEY'];
   ```

## Testing

### Test Authentication

```bash
# Start app with emulators
firebase emulators:start

# In another terminal
flutter run
```

Try:
- Creating account with email/password
- Signing in with Google (requires real Firebase)
- Signing in with Apple (iOS only, requires real Firebase)

### Test Firestore Rules

Use the Firestore emulator UI or:

```bash
firebase emulators:start --only firestore
npm install -g @firebase/rules-unit-testing

# Create test file
# Run: node test-firestore-rules.js
```

### Test Cloud Functions Locally

```bash
cd functions
npm run serve
```

Call functions from emulator UI or with curl:
```bash
curl -X POST http://localhost:5001/grocli-app/us-central1/helloWorld \
  -H "Content-Type: application/json" \
  -d '{"data": {}}'
```

### Test FCM

Use Firebase Console → Cloud Messaging → Send test message:
1. Paste FCM token from app logs
2. Enter notification title and body
3. Send

## Deployment

### Deploy Everything

```bash
firebase deploy
```

### Deploy Specific Services

```bash
# Deploy Firestore rules and indexes
firebase deploy --only firestore

# Deploy Storage rules
firebase deploy --only storage

# Deploy Functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:aiProxyFunction
```

### Production Checklist

Before going to production:

- [ ] Update Firestore rules from test mode to production rules
- [ ] Verify all security rules are properly restrictive
- [ ] Set up Firebase App Check for additional security
- [ ] Enable Google Analytics (if desired)
- [ ] Set up budget alerts in Google Cloud Console
- [ ] Configure proper CORS for Storage bucket
- [ ] Set up error reporting/logging (Firebase Crashlytics)
- [ ] Test all auth providers on production
- [ ] Verify Cloud Functions are working in production
- [ ] Test FCM on both Android and iOS devices
- [ ] Set up monitoring and alerts

## Troubleshooting

### Common Issues

#### "Default Firebase App not initialized"
- Ensure `await Firebase.initializeApp()` is called before any Firebase usage
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations

#### Google Sign-In not working on Android
- Verify SHA-1 certificate is added in Firebase Console
- Check package name matches in all places: `build.gradle.kts`, Firebase Console, and `google-services.json`

#### Apple Sign-In failing
- Ensure capability is added in Xcode
- Verify service ID is properly configured
- Check bundle identifier matches

#### FCM not receiving notifications
- Android: Check notification channel is created
- iOS: Verify APNs key is uploaded and device is real device (not simulator)
- Verify app has notification permission

#### Firestore permission denied
- Check security rules
- Verify user is authenticated
- Use emulator to debug rules

#### Cloud Functions timeout
- Check function logs: `firebase functions:log`
- Ensure function doesn't exceed time limit (60s for HTTP, 540s for background)
- Verify network requests in function complete successfully

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)

## Support

For issues specific to this setup:
1. Check logs: `flutter logs` and `firebase functions:log`
2. Use Firebase Emulator for debugging
3. Review Firebase Console error logs
4. Check this project's GitHub issues

---

**Last Updated**: 2024
**Firebase SDK Version**: 3.6.0+
**FlutterFire Version**: Latest compatible versions
