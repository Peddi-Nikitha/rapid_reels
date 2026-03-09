import '../models/user_model.dart';
import '../../../../core/mock/mock_users.dart';

/// Mock Authentication Repository
/// No Firebase - Pure static mock implementation
class AuthRepository {
  // Simulated current user
  static String? _currentUserId;
  
  // Mock auth state stream
  Stream<MockUser?> get authStateChanges {
    return Stream.value(_currentUserId != null ? MockUser(uid: _currentUserId!) : null);
  }

  MockUser? get currentUser => _currentUserId != null ? MockUser(uid: _currentUserId!) : null;

  // Phone Authentication - Step 1: Send OTP (Mock)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(dynamic)? onAutoVerify,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate OTP sent successfully
    const mockVerificationId = 'mock_verification_id_12345';
    onCodeSent(mockVerificationId);
  }

  // Phone Authentication - Step 2: Verify OTP (Mock)
  Future<MockUserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if user already exists based on phone number
    // For new users, generate a unique ID that doesn't exist in mock data
    // In real app, this would check Firebase Auth
    
    // For testing: Use a new user ID that doesn't exist in mock data
    // This simulates a new user registration
    // Change 'new_user_999' to 'user_001' to test existing user flow
    _currentUserId = 'new_user_999'; // New user ID (doesn't exist in mock data)
    
    return MockUserCredential(user: MockUser(uid: _currentUserId!));
  }

  // Email Authentication - Sign In (Mock)
  Future<MockUserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUserId = 'user_001';
    return MockUserCredential(user: MockUser(uid: _currentUserId!));
  }

  // Email Authentication - Sign Up (Mock)
  Future<MockUserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUserId = 'user_001';
    return MockUserCredential(user: MockUser(uid: _currentUserId!));
  }

  // Google Sign-In (Mock)
  Future<MockUserCredential> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUserId = 'user_001';
    return MockUserCredential(user: MockUser(uid: _currentUserId!));
  }

  // Facebook Sign-In (Mock)
  Future<MockUserCredential> signInWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUserId = 'user_001';
    return MockUserCredential(user: MockUser(uid: _currentUserId!));
  }

  // Sign Out (Mock)
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUserId = null;
  }

  // Create or Update User Profile (Mock)
  Future<void> createUserProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock mode, we just simulate success
  }

  // Get User Profile (Mock)
  Future<UserModel?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return from mock data
    return MockUsers.getUserById(userId);
  }

  // Update User Profile (Mock)
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock mode, we just simulate success
  }

  // Check if User Profile Exists (Mock)
  Future<bool> userProfileExists(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockUsers.getUserById(userId) != null;
  }

  // Send Password Reset Email (Mock)
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate email sent
  }

  // Update Email (Mock)
  Future<void> updateEmail(String newEmail) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate email updated
  }

  // Update Password (Mock)
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate password updated
  }

  // Re-authenticate (Mock)
  Future<void> reauthenticate(String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate re-authentication
  }

  // Delete Account (Mock)
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUserId = null;
  }

  // Link with Google (Mock)
  Future<MockUserCredential> linkWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockUserCredential(user: MockUser(uid: _currentUserId ?? 'user_001'));
  }

  // Link with Facebook (Mock)
  Future<MockUserCredential> linkWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockUserCredential(user: MockUser(uid: _currentUserId ?? 'user_001'));
  }

  // Unlink Provider (Mock)
  Future<MockUser> unlinkProvider(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUser(uid: _currentUserId ?? 'user_001');
  }
}

// Mock classes to replace Firebase classes
class MockUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  MockUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });
}

class MockUserCredential {
  final MockUser? user;
  
  MockUserCredential({this.user});
}
