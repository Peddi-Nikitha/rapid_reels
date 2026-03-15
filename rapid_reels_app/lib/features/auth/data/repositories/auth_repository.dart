import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../../../../core/firebase/models/firebase_user_model.dart' as fb;
import '../../../../core/firebase/services/firestore_service.dart';

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

  // Phone Authentication - Step 1: Send OTP
  // Uses Firebase Auth SDK which properly handles reCAPTCHA for real devices
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(UserCredential)? onAutoVerify,
  }) async {
    final completer = Completer<void>();

    try {
      // Force reCAPTCHA v2 flow for better compatibility
      await _firebaseAuth.setSettings(
        forceRecaptchaFlow: true,
      );
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // Android only: SMS retrieved and verified automatically
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerify != null) {
            try {
              final result = await _firebaseAuth.signInWithCredential(credential);
              onAutoVerify(result);
            } catch (e) {
              debugPrint('[Auth] Auto sign-in failed: $e');
            }
          }
          if (!completer.isCompleted) completer.complete();
        },
        
        // OTP SMS sent successfully
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
          if (!completer.isCompleted) completer.complete();
        },
        
        // Error occurred
        verificationFailed: (FirebaseAuthException e) {
          String friendlyMessage = _getFriendlyError(e);
          onError(friendlyMessage);
          if (!completer.isCompleted) completer.completeError(e);
        },
        
        // Auto-retrieval timed out; verificationId still valid for manual entry
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout is not an error - verificationId is still valid
          // User can manually enter the OTP
          if (!completer.isCompleted) completer.complete();
        },
      );

      await completer.future; // Wait for codeSent before returning
    } catch (e) {
      if (e is! FirebaseAuthException) {
        onError('Failed to send OTP: ${e.toString()}');
      }
    }
  }
  
  // Helper method for user-friendly error messages
  String _getFriendlyError(FirebaseAuthException e) {
    final errorMessage = e.message?.toLowerCase() ?? '';
    
    // Check for Play Integrity / reCAPTCHA errors
    if (errorMessage.contains('play integrity') || 
        errorMessage.contains('missing a valid app identifier') ||
        errorMessage.contains('recaptcha') ||
        e.code == 'missing-client-identifier') {
      return 'App verification failed. Please ensure:\n'
          '1. SHA-1/SHA-256 fingerprints are added in Firebase Console\n'
          '2. Wait 10-15 minutes after adding fingerprints\n'
          '3. Rebuild the app completely\n'
          'OR use a test phone number added in Firebase Console';
    }
    
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Use format: +919876543210';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'billing-not-enabled':
        return 'Phone auth needs Firebase Blaze plan. Enable billing in Firebase Console.';
      case 'captcha-check-failed':
        return 'Verification failed. Please try again or use a test phone number.';
      case 'missing-client-identifier':
        return 'App not verified. Add SHA-1 fingerprint in Firebase Console → Project Settings → Your apps → Android app.';
      default:
        return e.message ?? 'Failed to send OTP. Please try again.';
    }
  }

  // Phone Authentication - Step 2: Verify OTP
  // Uses Firebase Auth SDK to verify OTP with the verificationId from step 1
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      // Create a PhoneAuthCredential using the verificationId and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      // Sign in with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Ensure a user document exists
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Re-throw Firebase Auth exceptions with friendly messages
      throw FirebaseAuthException(
        code: e.code,
        message: _getFriendlyError(e),
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'verification-failed',
        message: 'Failed to verify OTP: ${e.toString()}',
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
