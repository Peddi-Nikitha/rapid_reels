// GENERATED MANUALLY based on your Firebase project configuration.
// If you later run `flutterfire configure`, it may overwrite this file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// DefaultFirebaseOptions is used by Firebase.initializeApp to provide
// per-platform configuration.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS Firebase configuration has been removed. '
          'Please configure Firebase for iOS if needed.',
        );
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  // Web configuration (from your new Firebase project)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAuzYnTH6DhyFewO57ITLXa2CJB7B1IX4',
    appId: '1:583858856130:web:YOUR_WEB_APP_ID', // Update when web app is added
    messagingSenderId: '583858856130',
    projectId: 'rapidreelnew-de86a',
    authDomain: 'rapidreelnew-de86a.firebaseapp.com',
    storageBucket: 'rapidreelnew-de86a.firebasestorage.app',
  );

  // Android configuration (from google-services.json - NEW PROJECT rapidreelnew-de86a)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAuzYnTH6DhyFewO57ITLXa2CJB7B1IX4',
    appId: '1:583858856130:android:e97b44940bea547f1e5b5b',
    messagingSenderId: '583858856130',
    projectId: 'rapidreelnew-de86a',
    storageBucket: 'rapidreelnew-de86a.firebasestorage.app',
  );

  // iOS configuration removed - Firebase is not connected for iOS

  // For now, desktop platforms reuse the web config.
  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}


