import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';

/// Firebase Initialization Service
/// Handles Firebase setup and configuration
class FirebaseInitService {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Initialize Firebase Core for the current platform using options
      // defined in firebase_options.dart
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;

      // Initialize Crashlytics (only in release mode)
      if (!kDebugMode) {
        _crashlytics = FirebaseCrashlytics.instance;
        
        // Pass all uncaught errors to Crashlytics
        FlutterError.onError = (errorDetails) {
          _crashlytics?.recordFlutterFatalError(errorDetails);
        };
        
        // Pass all uncaught asynchronous errors to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics?.recordError(error, stack, fatal: true);
          return true;
        };
      }

      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      // Do not rethrow here; allow the app to continue so UI can load
      // even if Firebase isn't available (e.g., during development).
    }
  }

  /// Get Analytics instance
  static FirebaseAnalytics? get analytics => _analytics;

  /// Get Crashlytics instance
  static FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Log custom event
  ///
  /// Firebase Analytics expects `Map<String, Object>?` for parameters,
  /// so we safely cast from a nullable map with nullable values.
  static Future<void> logEvent(String name, Map<String, Object?>? parameters) async {
    try {
      final castParams = parameters == null
          ? null
          : Map<String, Object>.from(parameters);

      await _analytics?.logEvent(name: name, parameters: castParams);
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    String? userType,
    String? city,
  }) async {
    try {
      if (userId != null) {
        await _analytics?.setUserId(id: userId);
      }
      if (userType != null) {
        await _analytics?.setUserProperty(name: 'user_type', value: userType);
      }
      if (city != null) {
        await _analytics?.setUserProperty(name: 'city', value: city);
      }
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  /// Log error to Crashlytics
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      if (!kDebugMode && _crashlytics != null) {
        await _crashlytics!.recordError(
          error,
          stackTrace,
          reason: reason,
          fatal: fatal,
        );
      }
    } catch (e) {
      print('Error logging to Crashlytics: $e');
    }
  }

  /// Set custom key for Crashlytics
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (!kDebugMode && _crashlytics != null) {
        await _crashlytics!.setCustomKey(key, value);
      }
    } catch (e) {
      print('Error setting custom key: $e');
    }
  }
}

