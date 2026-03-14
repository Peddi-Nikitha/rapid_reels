import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firestore_service.dart';

/// Global Firebase & Firestore providers
///
/// These can be used across the app to access FirebaseAuth and FirestoreService
/// via Riverpod.

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
