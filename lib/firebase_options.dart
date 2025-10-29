import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForWebPlatform123456789',
    appId: '1:1234567890:web:demo123456789abcdef',
    messagingSenderId: '1234567890',
    projectId: 'demo-project-id',
    authDomain: 'demo-project-id.firebaseapp.com',
    storageBucket: 'demo-project-id.appspot.com',
    measurementId: 'G-DEMO123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForAndroid123456789',
    appId: '1:1234567890:android:demo123456789abcdef',
    messagingSenderId: '1234567890',
    projectId: 'demo-project-id',
    storageBucket: 'demo-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForIOS123456789',
    appId: '1:1234567890:ios:demo123456789abcdef',
    messagingSenderId: '1234567890',
    projectId: 'demo-project-id',
    storageBucket: 'demo-project-id.appspot.com',
    iosBundleId: 'com.example.testingRepo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForMacOS123456789',
    appId: '1:1234567890:ios:demo123456789abcdef',
    messagingSenderId: '1234567890',
    projectId: 'demo-project-id',
    storageBucket: 'demo-project-id.appspot.com',
    iosBundleId: 'com.example.testingRepo',
  );
}
