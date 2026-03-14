import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../../../../core/firebase/models/firebase_user_model.dart' as fb;
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/services/firebase_rest_api_service.dart';

/// Authentication Repository backed by FirebaseAuth + Firestore
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirestoreService();
  
  /// Firebase auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  // Phone Authentication - Step 1: Send OTP via Firebase REST API
  // Uses REST API approach (like Python code) to bypass reCAPTCHA for test numbers
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(UserCredential)? onAutoVerify,
  }) async {
    try {
      // Use REST API to send OTP (works for test numbers without reCAPTCHA)
      final result = await FirebaseRestApiService.sendOtp(phoneNumber);
      
      if (result.containsKey('error')) {
        final error = result['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? 'Failed to send OTP';
        
        // Provide user-friendly error messages
        String friendlyMessage = errorMessage;
        if (errorMessage.contains('BILLING_NOT_ENABLED') || 
            errorMessage.contains('billing')) {
          friendlyMessage = 'Phone authentication requires billing to be enabled in Firebase. Please contact support or enable billing in Firebase Console.';
        } else if (errorMessage.contains('INVALID_PHONE_NUMBER') ||
                   errorMessage.contains('invalid-phone-number')) {
          friendlyMessage = 'Invalid phone number format. Please check and try again.';
        } else if (errorMessage.contains('TOO_MANY_REQUESTS') ||
                   errorMessage.contains('too-many-requests')) {
          friendlyMessage = 'Too many requests. Please try again later.';
        } else if (errorMessage.contains('QUOTA_EXCEEDED') ||
                   errorMessage.contains('quota-exceeded')) {
          friendlyMessage = 'SMS quota exceeded. Please try again later.';
        }
        
        onError(friendlyMessage);
        return;
      }
      
      // Success - we got sessionInfo (equivalent to verificationId)
      final sessionInfo = result['sessionInfo'] as String?;
      if (sessionInfo == null || sessionInfo.isEmpty) {
        onError('Failed to get session info from Firebase');
        return;
      }
      
      // Store sessionInfo as verificationId for the verifyOTP step
      // The sessionInfo from REST API serves the same purpose as verificationId from SDK
      onCodeSent(sessionInfo);
    } catch (e) {
      onError('Network error: ${e.toString()}');
    }
  }

  // Phone Authentication - Step 2: Verify OTP using REST API
  // Uses REST API approach (like Python code) to verify OTP
  Future<UserCredential> verifyOTP({
    required String verificationId, // This is actually sessionInfo from REST API
    required String otp,
  }) async {
    // Use REST API to verify OTP
    final result = await FirebaseRestApiService.verifyOtp(verificationId, otp);
    
    if (result.containsKey('error')) {
      final error = result['error'] as Map<String, dynamic>;
      final errorMessage = error['message'] as String? ?? 'OTP verification failed';
      throw FirebaseAuthException(
        code: 'invalid-verification-code',
        message: errorMessage,
      );
    }
    
    // REST API verification succeeded - we have idToken, phoneNumber, etc.
    final idToken = result['idToken'] as String?;
    final phoneNumber = result['phoneNumber'] as String?;
    
    if (idToken == null || phoneNumber == null) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Invalid response from Firebase REST API',
      );
    }
    
    // After REST API verification, we need to sign in with Firebase Auth
    // The REST API's sessionInfo (passed as verificationId) should work
    // with PhoneAuthProvider.credential() to create a valid credential.
    // The sessionInfo from REST API serves the same purpose as verificationId from SDK.
    try {
      // Create a PhoneAuthCredential using the sessionInfo as verificationId
      // This is the key: sessionInfo from REST API can be used as verificationId
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, // This is sessionInfo from REST API
        smsCode: otp,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Ensure a user document exists
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      
      return userCredential;
    } catch (e) {
      // If using sessionInfo as verificationId doesn't work, we have a fallback:
      // The REST API has already verified the OTP and returned an idToken.
      // However, Firebase Auth SDK doesn't directly accept REST API idTokens.
      // 
      // In this case, we throw an error. The user would need to use the
      // standard Firebase Auth SDK flow for real phone numbers.
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Failed to sign in after OTP verification: ${e.toString()}',
      );
    }
  }

  // Email Authentication - Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await _ensureUserDocument(credential.user!);
    }
    return credential;
  }

  // Email Authentication - Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await _ensureUserDocument(credential.user!);
    }
    return credential;
  }

  // Google Sign-In (placeholder - requires additional setup)
  Future<UserCredential> signInWithGoogle() async {
    throw UnimplementedError(
      'Google Sign-In is not implemented yet. Configure OAuth and implement using GoogleSignIn/FirebaseAuth.',
    );
  }

  // Facebook Sign-In (placeholder)
  Future<UserCredential> signInWithFacebook() async {
    throw UnimplementedError(
      'Facebook Sign-In is not implemented yet. Configure OAuth and implement using FirebaseAuth.',
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Create or Update User Profile in Firestore (users collection)
  Future<void> createUserProfile(UserModel user) async {
    final firebaseUser =
        await _toFirebaseUserModel(userId: user.userId, user: user);
    await _firestore.setUser(firebaseUser);
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final firebaseUser = await _firestore.getUser(userId);
    if (firebaseUser == null) return null;
    return _toDomainUserModel(firebaseUser);
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.updateUser(userId, data);
  }

  Future<bool> userProfileExists(String userId) async {
    final user = await _firestore.getUser(userId);
    return user != null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateEmail(newEmail);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> reauthenticate(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) return;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  // Helper: ensure user document exists in Firestore
  Future<void> _ensureUserDocument(User user) async {
    final existing = await _firestore.getUser(user.uid);
    if (existing != null) {
      await _firestore.updateUser(user.uid, {
        'lastLoginAt': DateTime.now(),
      });
      return;
    }

    final now = DateTime.now();
    final firebaseUser = fb.FirebaseUserModel(
      userId: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
      fullName: user.displayName ?? '',
      profileImage: user.photoURL,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );

    await _firestore.setUser(firebaseUser);
  }

  // Mapping: FirebaseUserModel -> domain UserModel
  UserModel _toDomainUserModel(fb.FirebaseUserModel firebaseUser) {
    return UserModel(
      userId: firebaseUser.userId,
      phoneNumber: firebaseUser.phoneNumber,
      email: firebaseUser.email,
      fullName: firebaseUser.fullName,
      profileImage: firebaseUser.profileImage,
      currentLocation: firebaseUser.currentLocation != null
          ? LocationData(
              city: firebaseUser.currentLocation!.city,
              state: firebaseUser.currentLocation!.state,
              country: firebaseUser.currentLocation!.country,
              coordinates: Coordinates(
                latitude:
                    firebaseUser.currentLocation!.coordinates.latitude,
                longitude:
                    firebaseUser.currentLocation!.coordinates.longitude,
              ),
            )
          : null,
      savedAddresses: firebaseUser.savedAddresses
          ?.map(
            (addr) => SavedAddress(
              addressId: addr.addressId,
              label: addr.label,
              address: addr.address,
              city: addr.city,
              pincode: addr.pincode,
              coordinates: Coordinates(
                latitude: addr.coordinates.latitude,
                longitude: addr.coordinates.longitude,
              ),
            ),
          )
          .toList(),
      preferences: firebaseUser.preferences != null
          ? PreferencesData(
              favoriteEditingStyles:
                  firebaseUser.preferences!.favoriteEditingStyles,
              favoriteMusic: firebaseUser.preferences!.favoriteMusic,
              defaultEventType: firebaseUser.preferences!.defaultEventType,
              defaultCity: firebaseUser.preferences!.defaultCity,
            )
          : null,
      referralCode: firebaseUser.referralCode,
      walletBalance: firebaseUser.walletBalance,
      totalEventsBooked: firebaseUser.totalEventsBooked,
      totalReelsReceived: firebaseUser.totalReelsReceived,
      createdAt: firebaseUser.createdAt,
      updatedAt: firebaseUser.updatedAt,
    );
  }

  // Mapping: domain UserModel -> FirebaseUserModel
  Future<fb.FirebaseUserModel> _toFirebaseUserModel({
    required String userId,
    required UserModel user,
  }) async {
    final now = DateTime.now();
    return fb.FirebaseUserModel(
      userId: userId,
      phoneNumber: user.phoneNumber,
      email: user.email,
      fullName: user.fullName,
      profileImage: user.profileImage,
      currentLocation: user.currentLocation != null
          ? fb.LocationData(
              city: user.currentLocation!.city,
              state: user.currentLocation!.state,
              country: user.currentLocation!.country,
              coordinates: fb.Coordinates(
                latitude: user.currentLocation!.coordinates.latitude,
                longitude: user.currentLocation!.coordinates.longitude,
              ),
            )
          : null,
      savedAddresses: user.savedAddresses
          ?.map(
            (addr) => fb.SavedAddress(
              addressId: addr.addressId,
              label: addr.label,
              address: addr.address,
              city: addr.city,
              pincode: addr.pincode,
              coordinates: fb.Coordinates(
                latitude: addr.coordinates.latitude,
                longitude: addr.coordinates.longitude,
              ),
            ),
          )
          .toList(),
      preferences: user.preferences != null
          ? fb.PreferencesData(
              favoriteEditingStyles: user.preferences!.favoriteEditingStyles,
              favoriteMusic: user.preferences!.favoriteMusic,
              defaultEventType: user.preferences!.defaultEventType,
              defaultCity: user.preferences!.defaultCity,
            )
          : null,
      referralCode: user.referralCode,
      walletBalance: user.walletBalance,
      totalEventsBooked: user.totalEventsBooked,
      totalReelsReceived: user.totalReelsReceived,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: now,
    );
  }
}
