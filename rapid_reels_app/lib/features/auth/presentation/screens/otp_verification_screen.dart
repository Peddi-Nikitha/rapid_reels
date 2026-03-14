import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/helpers.dart';
import '../providers/auth_provider.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = 30;
  late Timer _timer;
  bool _canResend = false;
  bool _isLoading = false;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _timerSeconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() => _canResend = true);
        _timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    String smsCode = _otpController.text.trim();

    if (smsCode.length != 6) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Please enter complete 6-digit OTP',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId ?? widget.verificationId,
        smsCode: smsCode,
      );

      // Sign the user in
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => _isLoading = false);

      if (mounted) {
        // Wait a moment for user state to update
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if user profile exists
        final user = ref.read(currentUserProvider);
        if (user != null) {
          try {
            final profileExists = await ref
                .read(authNotifierProvider.notifier)
                .userProfileExists(user.uid);

            debugPrint('User ID: ${user.uid}');
            debugPrint('Profile exists: $profileExists');

            if (profileExists) {
              // Existing user - go to home screen
              debugPrint('Navigating to home screen');
              if (mounted) {
                context.go(AppRoutes.home);
              }
            } else {
              // New user - go to profile setup screen
              debugPrint('Navigating to profile setup screen');
              if (mounted) {
                context.go(AppRoutes.profileSetup);
              }
            }
          } catch (e) {
            debugPrint('Error checking profile: $e');
            // If check fails, assume new user and go to profile setup
            if (mounted) {
              context.go(AppRoutes.profileSetup);
            }
          }
        } else {
          // User is null, show error
          debugPrint('User is null after OTP verification');
          if (mounted) {
            Helpers.showSnackBar(
              context,
              'Authentication failed. Please try again.',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Show user-friendly error message
        String errorMessage = 'Invalid OTP! Please try again.';
        if (e.toString().contains('invalid-verification-code')) {
          errorMessage = 'Invalid OTP code. Please check and try again.';
        } else if (e.toString().contains('session-expired')) {
          errorMessage = 'OTP session expired. Please request a new code.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _isLoading = true;
      _canResend = false;
    });

    try {
      final verificationId = await ref
          .read(authNotifierProvider.notifier)
          .verifyPhone(widget.phoneNumber);

      setState(() => _isLoading = false);

      if (verificationId != null) {
        _currentVerificationId = verificationId;
        _startTimer();
        if (mounted) {
          Helpers.showSnackBar(context, AppStrings.otpSent);
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Failed to resend OTP. Please try again.',
            isError: true,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(
          context,
          e.toString(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.verifyOTP),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                AppStrings.verifyOTP,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // OTP Input Field
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    letterSpacing: 8,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBackground.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBackground.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
                onSubmitted: (_) => _verifyOtp(),
              ),
              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify & Login'),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: _canResend && !_isLoading ? _resendOTP : null,
                  child: Text(
                    _canResend
                        ? AppStrings.resendOTP
                        : 'Resend OTP in $_timerSeconds s',
                    style: TextStyle(
                      color: _canResend
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

