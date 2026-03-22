import '../firebase/models/firebase_user_model.dart';

/// Matches [firestore.rules] `isAdmin()` — `userType in ['admin', 'superadmin']`.
bool isFirestoreAdmin(FirebaseUserModel? user) {
  if (user == null) return false;
  final t = user.userType;
  return t == 'admin' || t == 'superadmin';
}
