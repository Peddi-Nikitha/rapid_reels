import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final FocusNode _otpFocusNode = FocusNode();
  int _timerSeconds = 30;
  late Timer _timer;
  bool _canResend = false;
  bool _isLoading = false;
  String? _currentVerificationId;
  int _rateLimitSeconds = 0;
  Timer? _rateLimitTimer;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
    // Focus OTP field after route transition so keyboard opens without an extra tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _rateLimitTimer?.cancel();
    _otpFocusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startRateLimitTimer() {
    // Set cooldown period to 3 minutes (180 seconds)
    _rateLimitSeconds = 180;
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rateLimitSeconds > 0) {
        setState(() {
          _rateLimitSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _rateLimitSeconds = 0;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
      final verified = await ref.read(authNotifierProvider.notifier).verifyOTP(
            _currentVerificationId ?? widget.verificationId,
            smsCode,
          );

      setState(() => _isLoading = false);

      if (!verified) {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Authentication failed. Please try again.',
            isError: true,
          );
        }
        return;
      }

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));

        // Prefer Firebase after sign-in — Riverpod can lag one frame behind authStateChanges.
        final user =
            FirebaseAuth.instance.currentUser ?? ref.read(currentUserProvider);
        if (user == null) {
          debugPrint('User is null after OTP verification');
          if (mounted) {
            Helpers.showSnackBar(
              context,
              'Authentication failed. Please try again.',
              isError: true,
            );
          }
          return;
        }

        try {
          final profileExists = await ref
              .read(authNotifierProvider.notifier)
              .userProfileExists(user.uid);

          debugPrint('User ID: ${user.uid}');
          debugPrint('Profile exists: $profileExists');

          if (profileExists) {
            debugPrint('Navigating to home screen');
            if (mounted) {
              context.go(AppRoutes.home);
            }
          } else {
            debugPrint('Navigating to profile setup screen');
            if (mounted) {
              context.go(AppRoutes.profileSetup);
            }
          }
        } catch (e) {
          debugPrint('Error checking profile: $e');
          if (mounted) {
            context.go(AppRoutes.profileSetup);
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
    if (!_canResend || _isLoading || _rateLimitSeconds > 0) return;

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
        String errorMessage = e.toString();
        
        // Remove "Exception: " prefix if present
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        // Check for rate limiting error
        if (errorMessage.contains('Too many attempts') || 
            errorMessage.contains('too-many-requests') ||
            errorMessage.contains('wait a few minutes')) {
          _startRateLimitTimer();
          errorMessage = 'Too many attempts. Please wait ${_formatTime(_rateLimitSeconds)} before trying again.';
        }
        
        Helpers.showSnackBar(
          context,
          errorMessage,
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
                focusNode: _otpFocusNode,
                autofocus: true,
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
                child: Column(
                  children: [
                    TextButton(
                      onPressed: (_canResend && !_isLoading && _rateLimitSeconds == 0) 
                          ? _resendOTP 
                          : null,
                      child: Text(
                        _rateLimitSeconds > 0
                            ? 'Wait ${_formatTime(_rateLimitSeconds)}'
                            : _canResend
                                ? AppStrings.resendOTP
                                : 'Resend OTP in $_timerSeconds s',
                        style: TextStyle(
                          color: (_canResend && _rateLimitSeconds == 0)
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_rateLimitSeconds > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Too many attempts. Please wait.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

