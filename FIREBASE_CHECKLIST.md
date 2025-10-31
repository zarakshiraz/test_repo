# Firebase Configuration Checklist

Use this checklist to track your Firebase setup progress for the Grocli app.

## ✅ Code Configuration (COMPLETED)

All code-level configuration has been completed. The following files are ready:

- [x] `lib/firebase_options.dart` - Placeholder configuration
- [x] `lib/main.dart` - Firebase initialization
- [x] `lib/core/services/fcm_service.dart` - FCM implementation
- [x] Android configuration files updated
- [x] iOS configuration files updated
- [x] `firestore.rules` - Security rules for Firestore
- [x] `storage.rules` - Security rules for Storage
- [x] `firebase.json` - Firebase project configuration
- [x] `firestore.indexes.json` - Composite indexes
- [x] `functions/` - Cloud Functions scaffold
- [x] Documentation created

## 🔧 Firebase Console Setup (TODO)

### 1. Create Firebase Project
- [ ] Go to https://console.firebase.google.com/
- [ ] Click "Add project"
- [ ] Name: `grocli-app` (or your choice)
- [ ] Enable/disable Google Analytics
- [ ] Note your project ID: ________________

### 2. Upgrade to Blaze Plan (for Cloud Functions)
- [ ] Go to Project Settings → Usage and billing
- [ ] Click "Modify plan"
- [ ] Select "Blaze (Pay as you go)"
- [ ] Set up billing account

### 3. Enable Required Services
- [ ] Authentication (sidebar → Build → Authentication)
- [ ] Firestore Database (sidebar → Build → Firestore Database)
- [ ] Storage (sidebar → Build → Storage)
- [ ] Functions (sidebar → Build → Functions)
- [ ] Cloud Messaging (sidebar → Engage → Messaging)

## 📱 Platform Setup

### Android Configuration
- [ ] In Firebase Console, click Android icon to add app
- [ ] Enter package name: `com.grocli.app`
- [ ] Enter app nickname: `Grocli Android`
- [ ] Get SHA-1 certificate:
  ```bash
  keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
  # Password: android
  ```
- [ ] Enter SHA-1 in Firebase Console: ________________
- [ ] Download `google-services.json`
- [ ] Place file in: `android/app/google-services.json`
- [ ] Verify file is NOT in git (should be in .gitignore)

### iOS Configuration
- [ ] In Firebase Console, click iOS icon to add app
- [ ] Enter bundle ID: `com.grocli.app`
- [ ] Enter app nickname: `Grocli iOS`
- [ ] Download `GoogleService-Info.plist`
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Right-click Runner folder → Add Files
- [ ] Select `GoogleService-Info.plist`
- [ ] ✓ Check "Copy items if needed"
- [ ] ✓ Check target "Runner"
- [ ] In Xcode, select Runner target
- [ ] Change Bundle Identifier to: `com.grocli.app`
- [ ] Select your Development Team
- [ ] Update `ios/Runner/Info.plist`:
  - [ ] Replace `REVERSED_CLIENT_ID` with actual value from plist
- [ ] Verify plist file is NOT in git

### Generate Firebase Options
- [ ] Run: `flutterfire configure --project=YOUR_PROJECT_ID`
- [ ] Verify `lib/firebase_options.dart` updated with real values
- [ ] Test build on both platforms

## 🔐 Authentication Setup

### Email/Password
- [ ] Firebase Console → Authentication → Sign-in method
- [ ] Click "Email/Password"
- [ ] Enable both options
- [ ] Click "Save"
- [ ] Test: Create account in app
- [ ] Test: Sign in with email/password

### Google Sign-In

#### Android
- [ ] Firebase Console → Authentication → Sign-in method
- [ ] Click "Google"
- [ ] Enable
- [ ] Select support email
- [ ] Save
- [ ] Verify SHA-1 certificate added (above)
- [ ] Test: Sign in with Google on Android device

#### iOS
- [ ] Same as Android for enabling in console
- [ ] Open `GoogleService-Info.plist`
- [ ] Copy value of `REVERSED_CLIENT_ID`
- [ ] Open `ios/Runner/Info.plist`
- [ ] Replace placeholder `REVERSED_CLIENT_ID` with actual value
- [ ] Test: Sign in with Google on iOS device

#### Web (Optional)
- [ ] Firebase Console → Authentication → Google provider
- [ ] Copy Web client ID
- [ ] Configure in web app

### Apple Sign-In (iOS)

#### Apple Developer Portal
- [ ] Go to https://developer.apple.com/
- [ ] Certificates, Identifiers & Profiles
- [ ] Identifiers → Find `com.grocli.app`
- [ ] Enable "Sign in with Apple" capability
- [ ] Click "Edit" → Configure
- [ ] Save changes

#### Xcode
- [ ] Open `ios/Runner.xcworkspace`
- [ ] Select Runner target
- [ ] Signing & Capabilities tab
- [ ] Click "+ Capability"
- [ ] Add "Sign in with Apple"
- [ ] Verify capability is enabled

#### Firebase Console
- [ ] Authentication → Sign-in method → Apple
- [ ] Enable
- [ ] Note: For advanced setup (web/Android):
  - [ ] Create Service ID in Apple Developer Portal
  - [ ] Service ID: `com.grocli.app.signin`
  - [ ] Configure with Firebase redirect URL
  - [ ] Create and download key (.p8 file)
  - [ ] Upload key to Firebase Console

#### Test
- [ ] Test: Sign in with Apple on iOS device
- [ ] Test: Existing Apple ID works
- [ ] Test: Create new Apple ID works

## 🗄️ Firestore Setup

### Create Database
- [ ] Firebase Console → Firestore Database
- [ ] Click "Create database"
- [ ] Choose location (e.g., `us-central1`): ________________
- [ ] Start in test mode (temporary)
- [ ] Click "Create"

### Deploy Security Rules
```bash
firebase login
firebase use YOUR_PROJECT_ID
firebase deploy --only firestore:rules
```
- [ ] Run commands above
- [ ] Verify deployment success
- [ ] Check rules in Firebase Console → Firestore → Rules tab

### Deploy Indexes
```bash
firebase deploy --only firestore:indexes
```
- [ ] Run command above
- [ ] Monitor index building (can take several minutes)
- [ ] Check indexes in Firebase Console → Firestore → Indexes tab

### Test Rules (Optional but Recommended)
- [ ] Firebase Console → Firestore → Rules → Rules Playground
- [ ] Test read operation as authenticated user
- [ ] Test write operation as authenticated user
- [ ] Test access to other user's data (should fail)

## 📦 Cloud Storage Setup

### Create Bucket
- [ ] Firebase Console → Storage
- [ ] Click "Get started"
- [ ] Start in production mode
- [ ] Choose same location as Firestore
- [ ] Click "Done"

### Deploy Security Rules
```bash
firebase deploy --only storage
```
- [ ] Run command above
- [ ] Verify in Firebase Console → Storage → Rules tab

### Test Upload (Optional)
- [ ] Upload test file manually in console
- [ ] Verify file appears in bucket
- [ ] Delete test file

## ⚡ Cloud Functions Setup

### Install Dependencies
```bash
cd functions
npm install
```
- [ ] Run commands above
- [ ] Verify no errors
- [ ] Check `node_modules/` created

### Configure Environment
```bash
firebase functions:config:set ai.api_key="YOUR_API_KEY"
firebase functions:config:set ai.api_url="https://api.openai.com/v1"
```
- [ ] Set API key for AI service (if using)
- [ ] Verify config: `firebase functions:config:get`

### Build Functions
```bash
npm run build
```
- [ ] Run command in `functions/` directory
- [ ] Verify `lib/` directory created
- [ ] Check for TypeScript errors

### Deploy Functions
```bash
firebase deploy --only functions
```
- [ ] Deploy all functions
- [ ] Note deployed function URLs
- [ ] Check in Firebase Console → Functions

### Test Functions
- [ ] Test `helloWorld` function from app
- [ ] Test `aiProxyFunction` with sample data
- [ ] Check function logs: `firebase functions:log`

## 🔔 Cloud Messaging (FCM) Setup

### Android

#### Verify Configuration
- [ ] Check `AndroidManifest.xml` has permissions
- [ ] Check `AndroidManifest.xml` has FCM metadata
- [ ] Check `build.gradle.kts` has Google Services plugin

#### Test on Real Device
- [ ] Build app: `flutter run`
- [ ] Check logs for FCM token
- [ ] Note FCM token: ________________
- [ ] Grant notification permission when prompted

#### Test Notification
- [ ] Firebase Console → Cloud Messaging
- [ ] Click "Send your first message"
- [ ] Enter title and body
- [ ] Click "Send test message"
- [ ] Paste FCM token from above
- [ ] Send
- [ ] Verify notification received (foreground & background)

### iOS

#### Upload APNs Key
- [ ] Apple Developer Portal → Keys
- [ ] Click "+" to create new key
- [ ] Name: "Grocli APNs Key"
- [ ] Enable "Apple Push Notifications service (APNs)"
- [ ] Click "Continue" → "Register"
- [ ] Download `.p8` file
- [ ] Note Key ID: ________________
- [ ] Note Team ID: ________________
- [ ] Firebase Console → Project Settings → Cloud Messaging
- [ ] iOS app configuration → APNs Certificates
- [ ] Click "Upload"
- [ ] Upload `.p8` file
- [ ] Enter Key ID and Team ID
- [ ] Save

#### Add Capabilities in Xcode
- [ ] Open `ios/Runner.xcworkspace`
- [ ] Select Runner target
- [ ] Signing & Capabilities
- [ ] Click "+ Capability"
- [ ] Add "Push Notifications"
- [ ] Click "+ Capability"
- [ ] Add "Background Modes"
- [ ] Check "Remote notifications"

#### Test on Real Device (required - simulator won't work)
- [ ] Connect iPhone/iPad
- [ ] Build: `flutter run -d <device_id>`
- [ ] Check logs for FCM token
- [ ] Note FCM token: ________________
- [ ] Grant notification permission

#### Test Notification
- [ ] Firebase Console → Cloud Messaging
- [ ] Send test message (same as Android)
- [ ] Paste iOS FCM token
- [ ] Send
- [ ] Test with app in foreground
- [ ] Test with app in background
- [ ] Test with app terminated

## 🧪 Testing

### Local Development with Emulators
```bash
firebase emulators:start
```
- [ ] Run command above
- [ ] Access Emulator UI: http://localhost:4000
- [ ] Test Authentication flow
- [ ] Test Firestore operations
- [ ] Test Storage upload
- [ ] Test Functions locally

### Update App for Emulators (Optional)
Add to `lib/main.dart` after Firebase init:
```dart
if (kDebugMode) {
  try {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  } catch (e) {
    debugPrint('Already using emulators');
  }
}
```

### Integration Testing
- [ ] Create test account
- [ ] Sign in with email/password
- [ ] Sign in with Google
- [ ] Sign in with Apple (iOS)
- [ ] Create a list
- [ ] Add items to list
- [ ] Share list with another user
- [ ] Send message in list
- [ ] Upload voice message
- [ ] Verify notifications work
- [ ] Test offline mode
- [ ] Test sync after coming online

## 🚀 Production Preparation

### Security Review
- [ ] Review Firestore rules thoroughly
- [ ] Review Storage rules
- [ ] Test rules with different user scenarios
- [ ] Ensure no data leaks between users
- [ ] Consider Firebase App Check for API protection

### Performance
- [ ] Set up Firestore indexes for all queries
- [ ] Test app with large datasets
- [ ] Monitor Firebase usage in console
- [ ] Set up budget alerts in Google Cloud Console

### Monitoring & Logging
- [ ] Enable Firebase Crashlytics (optional)
- [ ] Set up Firebase Performance Monitoring (optional)
- [ ] Review Cloud Functions logs regularly
- [ ] Set up error alerting

### Documentation
- [ ] Document Firebase project structure
- [ ] Document security rules decisions
- [ ] Document Cloud Functions API
- [ ] Create runbook for common operations
- [ ] Document backup/restore procedures

### Deployment
- [ ] Create production Firebase project (if using separate dev/prod)
- [ ] Deploy all services to production
- [ ] Test on production before app release
- [ ] Create release builds with production config
- [ ] Store production config securely

## 📋 Pre-Launch Checklist

- [ ] All authentication methods tested
- [ ] Security rules deployed and tested
- [ ] Cloud Functions deployed and tested
- [ ] FCM working on both platforms
- [ ] App tested with real users (beta)
- [ ] Performance acceptable under load
- [ ] Budget alerts configured
- [ ] Team has access to Firebase Console
- [ ] Backup strategy in place
- [ ] Incident response plan ready
- [ ] Terms of Service updated for data collection
- [ ] Privacy Policy updated for Firebase usage

## 🆘 Troubleshooting

If you encounter issues, check:
- [ ] `FIREBASE_SETUP.md` - Comprehensive troubleshooting guide
- [ ] Firebase Console error logs
- [ ] `flutter logs` for app-side errors
- [ ] `firebase functions:log` for function errors
- [ ] Firebase Status Page: https://status.firebase.google.com/

## 📚 Resources

- [Firebase Setup Guide](./FIREBASE_SETUP.md) - Detailed setup instructions
- [Configuration Summary](./FIREBASE_CONFIGURATION_SUMMARY.md) - What's been configured
- [Cloud Functions README](./functions/README.md) - Functions documentation
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

**Last Updated**: 2024
**Status**: Code configuration complete, Firebase Console setup required
**Estimated Setup Time**: 2-4 hours for first-time setup
