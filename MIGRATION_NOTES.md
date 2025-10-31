# Migration Notes

## Package Name Change

The Android package name has been changed from `com.example.testing_repo` to `com.grocli.app`.

### What Changed

- `android/app/build.gradle.kts`: `namespace` and `applicationId` updated
- `android/app/src/main/kotlin/com/grocli/app/MainActivity.kt`: New file with correct package
- Old file still exists at: `android/app/src/main/kotlin/com/example/testing_repo/MainActivity.kt`

### Cleanup (Optional)

You can safely delete the old package directory:

```bash
rm -rf android/app/src/main/kotlin/com/example/
```

This won't affect the app as the new package path is already configured.

## App Name Change

- Android: "testing_repo" → "Grocli"
- iOS: "Testing Repo" → "Grocli"

### What Changed

- `android/app/src/main/AndroidManifest.xml`: `android:label="Grocli"`
- `ios/Runner/Info.plist`: Display name and bundle name updated

## Bundle/Package Identifiers

Ensure consistency across platforms:

- **Android**: `com.grocli.app` (applicationId)
- **iOS**: `com.grocli.app` (bundle identifier)
- **Firebase**: Must match these identifiers

## Firebase Configuration

All Firebase configuration has been set up for the **new** package names:

- `google-services.json.template`: Shows `com.grocli.app`
- `GoogleService-Info.plist.template`: Shows `com.grocli.app`
- `lib/firebase_options.dart`: Configured with correct identifiers

When you download actual config files from Firebase Console, ensure they match:
- Android app package: `com.grocli.app`
- iOS app bundle ID: `com.grocli.app`

## Existing Installs

If you have the app installed with the old package name:

1. Uninstall the old version
2. Build and install with new package:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

The app will be installed as a new app (different package name).

## Code References

All code references have been updated:
- ✅ Import in `test/widget_test.dart`: `package:grocli/main.dart`
- ✅ Main app widget: `GrocliApp`

## Summary

| Component | Old Value | New Value |
|-----------|-----------|-----------|
| Android Package | `com.example.testing_repo` | `com.grocli.app` |
| iOS Bundle ID | (not set) | `com.grocli.app` |
| App Name (Android) | "testing_repo" | "Grocli" |
| App Name (iOS) | "Testing Repo" | "Grocli" |
| Main Widget | `MyApp` | `GrocliApp` |
| Package Name | `testing_repo` | `grocli` |

---

**Migration Status**: Complete  
**Action Required**: None (optional cleanup of old package directory)
