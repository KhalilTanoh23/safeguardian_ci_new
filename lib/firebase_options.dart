import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyForDevelopmentOnly',
    appId: '1:123456789012:android:dummyappid123456789',
    messagingSenderId: '123456789012',
    projectId: 'safeguardian-ci-dev',
    storageBucket: 'safeguardian-ci-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyForDevelopmentOnly',
    appId: '1:123456789012:ios:dummyappid123456789',
    messagingSenderId: '123456789012',
    projectId: 'safeguardian-ci-dev',
    storageBucket: 'safeguardian-ci-dev.appspot.com',
    iosBundleId: 'com.example.safeguardian_ci_new',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyForDevelopmentOnly',
    appId: '1:123456789012:web:dummyappid123456789',
    messagingSenderId: '123456789012',
    projectId: 'safeguardian-ci-dev',
    authDomain: 'safeguardian-ci-dev.firebaseapp.com',
    storageBucket: 'safeguardian-ci-dev.appspot.com',
    measurementId: 'G-DUMMYMEASUREMENT',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyForDevelopmentOnly',
    appId: '1:123456789012:macos:dummyappid123456789',
    messagingSenderId: '123456789012',
    projectId: 'safeguardian-ci-dev',
    storageBucket: 'safeguardian-ci-dev.appspot.com',
    iosBundleId: 'com.example.safeguardian_ci_new',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyForDevelopmentOnly',
    appId: '1:123456789012:windows:dummyappid123456789',
    messagingSenderId: '123456789012',
    projectId: 'safeguardian-ci-dev',
    storageBucket: 'safeguardian-ci-dev.appspot.com',
  );
}
