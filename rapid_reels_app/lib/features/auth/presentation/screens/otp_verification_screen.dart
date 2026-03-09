import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      } else {
        setState(() => _canResend = true);
        return false;
      }
    });
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();

    if (otp.length != 6) {
      Helpers.showSnackBar(
        context,
        'Please enter complete OTP',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .verifyOTP(widget.verificationId, otp);

      setState(() => _isLoading = false);

      if (success && mounted) {
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
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Invalid OTP. Please try again.',
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

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      final verificationId = await ref
          .read(authNotifierProvider.notifier)
          .verifyPhone(widget.phoneNumber);

      setState(() => _isLoading = false);

      if (verificationId != null) {
        _startResendTimer();
        if (mounted) {
          Helpers.showSnackBar(context, AppStrings.otpSent);
          // Update verification ID
          // Note: This would need to be passed back or stored in state
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOTPField(index),
                ),
              ),
              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify OTP'),
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
                        : 'Resend OTP in $_resendTimer seconds',
                    style: TextStyle(
                      color: _canResend
                          ? AppColors.primary
                          : AppColors.textTertiary,
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

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          } else if (value.isNotEmpty && index == 5) {
            _focusNodes[index].unfocus();
            // Auto-verify when all fields are filled
            _verifyOTP();
          }
        },
      ),
    );
  }
}

