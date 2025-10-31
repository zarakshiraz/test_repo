# Firebase Quick Start Guide

Get Firebase up and running for Grocli in 15 minutes (development mode).

## Prerequisites

✅ Flutter SDK installed  
✅ Node.js 18+ installed  
✅ Google account  

## Step 1: Install Firebase Tools (2 min)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

## Step 2: Create Firebase Project (3 min)

1. Go to https://console.firebase.google.com/
2. Click **"Add project"**
3. Name: `grocli-dev` (or your choice)
4. Disable Analytics (optional for dev)
5. Click **"Create project"**
6. Wait for project creation
7. **Note your project ID**: `grocli-dev`

## Step 3: Enable Services (2 min)

In Firebase Console left sidebar:
- Click **Authentication** → Get Started
- Click **Firestore Database** → Create Database → Start in **test mode** → Choose location → Enable
- Click **Storage** → Get Started → Start in **test mode** → Done
- Click **Messaging** (under Engage)

## Step 4: Configure Flutter App (3 min)

### Android

1. Firebase Console → Click Android icon
2. Package name: `com.grocli.app`
3. Download `google-services.json`
4. Move to: `android/app/google-services.json`

### iOS

1. Firebase Console → Click iOS icon
2. Bundle ID: `com.grocli.app`
3. Download `GoogleService-Info.plist`
4. Open in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
5. Right-click **Runner** folder → **Add Files to "Runner"**
6. Select `GoogleService-Info.plist`
7. ✓ Check **"Copy items if needed"**
8. ✓ Select **Runner** target

### Generate Firebase Options

```bash
# In project root
flutterfire configure --project=grocli-dev

# Select platforms: Android, iOS
# This updates lib/firebase_options.dart
```

## Step 5: Deploy Firebase Rules (2 min)

```bash
# Initialize Firebase in project (if not done)
firebase init

# Select:
# - Firestore (rules and indexes)
# - Storage (rules)
# - Functions (optional for now)
# - Hosting (NO)

# Use existing project: grocli-dev

# Deploy rules
firebase deploy --only firestore:rules,storage
```

## Step 6: Enable Email/Password Auth (1 min)

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Email/Password**
3. **Enable** both switches
4. Click **Save**

## Step 7: Test the App (2 min)

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Create test account in app
# Email: test@grocli.com
# Password: test123
```

## 🎉 You're Done!

Your app now has:
- ✅ Firebase initialized
- ✅ Email/Password authentication
- ✅ Firestore database
- ✅ Cloud Storage
- ✅ Security rules deployed

## Next Steps

### Add Google Sign-In (Optional - 5 min)

**Android:**
```bash
# Get SHA-1
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
# Password: android
```
- Firebase Console → Authentication → Google → Enable
- Add SHA-1 in Firebase Console → Project Settings → Android app

**iOS:**
- Already configured in code
- Update `ios/Runner/Info.plist`:
  - Find `CFBundleURLSchemes`
  - Replace `REVERSED_CLIENT_ID` with value from `GoogleService-Info.plist`

### Add Cloud Functions (Optional - 10 min)

```bash
# Install dependencies
cd functions
npm install
npm run build

# Deploy
cd ..
firebase deploy --only functions
```

### Add FCM Notifications (Optional - 5 min)

**Android:**
- Already configured, works out of the box
- Grant permission in app

**iOS:**
1. Apple Developer → Keys → Create APNs key
2. Download `.p8` file
3. Firebase Console → Cloud Messaging → Upload APNs key

### Use Firebase Emulators (Development)

```bash
# Start all emulators
firebase emulators:start

# Access UI at http://localhost:4000
```

Add to `lib/main.dart` (in debug mode):
```dart
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

## Common Issues

### "Default app not initialized"
- Run `flutterfire configure` again
- Ensure config files are in correct locations

### "Package name doesn't match"
- Check `android/app/build.gradle.kts`: `applicationId = "com.grocli.app"`
- Check `google-services.json` has correct package

### iOS build fails
- Open Xcode, select team for signing
- Clean build: `flutter clean && flutter pub get`

### Firestore permission denied
- Check rules are deployed: `firebase deploy --only firestore:rules`
- Ensure user is authenticated

## Documentation

- **Full Setup Guide**: [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
- **Configuration Details**: [FIREBASE_CONFIGURATION_SUMMARY.md](./FIREBASE_CONFIGURATION_SUMMARY.md)
- **Complete Checklist**: [FIREBASE_CHECKLIST.md](./FIREBASE_CHECKLIST.md)

## Support

If stuck:
1. Check [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) troubleshooting section
2. Firebase Status: https://status.firebase.google.com/
3. Verify all files are in correct locations

---

**Time to complete**: ~15 minutes  
**Difficulty**: Easy  
**Result**: Working Firebase integration with auth and database
