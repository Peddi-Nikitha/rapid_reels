import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../firebase_options.dart';

/// Firebase REST API Service for Phone OTP Authentication
/// 
/// This service uses Firebase Identity Toolkit REST API directly,
/// similar to the Python implementation. For test phone numbers
/// added in Firebase Console, it uses a dummy reCAPTCHA token.
/// 
/// IMPORTANT: For the REST API to send OTPs WITHOUT a browser reCAPTCHA,
/// you MUST add test phone numbers in Firebase Console:
///   Authentication > Sign-in method > Phone > Scroll to "Phone numbers for testing"
///   Example: +91XXXXXXXXXX  →  123456
/// 
/// These test numbers bypass reCAPTCHA entirely and are perfect for testing.
/// Real phone numbers require a reCAPTCHA token (browser-only).
class FirebaseRestApiService {
  // Get API key from Firebase options
  static String get _apiKey {
    return DefaultFirebaseOptions.currentPlatform.apiKey;
  }

  static const String _sendOtpUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode';
  static const String _verifyOtpUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber';

  /// Sends an OTP via Firebase REST API
  /// 
  /// phoneNumber must be in E.164 format, e.g. +919876543210
  /// 
  /// NOTE: Firebase REST API requires a reCAPTCHA token for real numbers.
  /// For test phone numbers added in Firebase Console the token is ignored —
  /// pass a dummy string. For real numbers use a browser-based flow instead.
  /// 
  /// Returns a map containing:
  /// - 'sessionInfo': String (required for verification)
  /// - 'error': Map (if error occurred)
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final url = Uri.parse('$_sendOtpUrl?key=$_apiKey');
      
      final payload = {
        'phoneNumber': phoneNumber,
        'recaptchaToken': 'test-recaptcha-token', // Only works for Firebase test numbers
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData.containsKey('sessionInfo')) {
        return responseData;
      } else {
        // Return error response
        return {
          'error': responseData['error'] ?? {'message': 'Unknown error occurred'},
        };
      }
    } catch (e) {
      return {
        'error': {
          'message': 'Network error: ${e.toString()}',
        },
      };
    }
  }

  /// Verifies the OTP code against the sessionInfo returned by sendOtp
  /// 
  /// Returns a map containing:
  /// - 'idToken': String (Firebase ID token)
  /// - 'localId': String (User ID)
  /// - 'phoneNumber': String
  /// - 'refreshToken': String
  /// - 'error': Map (if error occurred)
  static Future<Map<String, dynamic>> verifyOtp(
    String sessionInfo,
    String otpCode,
  ) async {
    try {
      final url = Uri.parse('$_verifyOtpUrl?key=$_apiKey');
      
      final payload = {
        'sessionInfo': sessionInfo,
        'code': otpCode,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData.containsKey('idToken')) {
        return responseData;
      } else {
        // Return error response
        return {
          'error': responseData['error'] ?? {'message': 'Unknown error occurred'},
        };
      }
    } catch (e) {
      return {
        'error': {
          'message': 'Network error: ${e.toString()}',
        },
      };
    }
  }

}

