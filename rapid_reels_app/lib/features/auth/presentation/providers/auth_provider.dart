import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/admin/admin_route_cache.dart';
import '../../../../core/router/router_refresh_notifier.dart';
import '../../../../core/session/user_session_cleanup.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider (Stream of Firebase User)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Current User Provider — must depend on live auth signals. The repository instance never
// changes, so without these watches Riverpod keeps a stale null after sign-in. We watch
// [authNotifierProvider] so OTP/email flows that update the notifier invalidate this
// immediately; [authStateProvider] covers stream-driven updates (sign-out, token refresh).
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  ref.watch(authNotifierProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Phone Authentication - Send OTP
  Future<String?> verifyPhone(String phoneNumber) async {
    state = const AsyncValue.loading();
    String? verificationId;
    String? errorMessage;
    
    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (String id) {
        verificationId = id;
        state = AsyncValue.data(_authRepository.currentUser);
      },
      onError: (String error) {
        errorMessage = error;
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
    
    // If verificationId is still null and we captured an error message,
    // throw it so UI can display the actual Firebase error instead of a
    // generic "Failed to send OTP" message.
    if (verificationId == null && errorMessage != null) {
      throw Exception(errorMessage);
    }

    return verificationId;
  }

  // Phone Authentication - Verify OTP
  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      state = const AsyncValue.loading();
      final credential = await _authRepository.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );
      state = AsyncValue.data(credential.user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  // Email Sign In
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final credential = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(credential.user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  // Email Sign Up
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final credential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(credential.user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      final credential = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(credential.user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  // Sign Out — clears local Riverpod caches for the signed-out uid so Firestore
  // streams do not keep a PERMISSION_DENIED error for the next login.
  Future<void> signOut([WidgetRef? ref]) async {
    final uid = _authRepository.currentUser?.uid;
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
    AdminRouteCache.invalidate();
    appRouterAuthRefresh.refresh();
    if (ref != null && uid != null) {
      invalidateUserSessionProviders(ref, uid);
    }
  }

  // Create User Profile
  Future<bool> createUserProfile(UserModel user) async {
    try {
      await _authRepository.createUserProfile(user);
      return true;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Log the full error for debugging
      if (e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('PERMISSION_DENIED: Firestore security rules need to be deployed!');
        debugPrint('See FIRESTORE_SECURITY_RULES_SETUP.md for instructions');
      }
      return false;
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _authRepository.updateUserProfile(userId, data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if profile exists
  Future<bool> userProfileExists(String userId) async {
    return await _authRepository.userProfileExists(userId);
  }

  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// User Profile Data Notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;
  final String userId;

  UserProfileNotifier(this._authRepository, this.userId)
      : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authRepository.getUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _authRepository.updateUserProfile(userId, data);
      await _loadUserProfile();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// User Profile Notifier Provider
final userProfileNotifierProvider = StateNotifierProvider.family<
    UserProfileNotifier, AsyncValue<UserModel?>, String>((ref, userId) {
  return UserProfileNotifier(ref.watch(authRepositoryProvider), userId);
});

