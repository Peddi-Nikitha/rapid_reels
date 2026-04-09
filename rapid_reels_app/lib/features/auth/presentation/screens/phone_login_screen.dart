import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  int _rateLimitSeconds = 0;
  Timer? _rateLimitTimer;

  // Common country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
  ];

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    _phoneController.dispose();
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

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if rate limited
    if (_rateLimitSeconds > 0) {
      Helpers.showSnackBar(
        context,
        'Please wait ${_formatTime(_rateLimitSeconds)} before trying again.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    String phoneNumber = '$_selectedCountryCode${_phoneController.text}';

    try {
      final verificationId = await ref
          .read(authNotifierProvider.notifier)
          .verifyPhone(phoneNumber);

      setState(() => _isLoading = false);

      if (verificationId != null && mounted) {
        // Navigate to OTP verification screen
        context.push(
          AppRoutes.otpVerification,
          extra: {
            'verificationId': verificationId,
            'phoneNumber': phoneNumber,
          },
        );
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Failed to send OTP. Please try again.',
            isError: true,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Extract user-friendly error message
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
        
        // Show specific message for billing errors
        if (errorMessage.contains('BILLING_NOT_ENABLED') || 
            errorMessage.contains('billing') ||
            errorMessage.contains('billing-not-enabled')) {
          errorMessage = 'Phone authentication requires billing to be enabled in Firebase Console. Please enable billing to use this feature.';
        }
        
        Helpers.showSnackBar(
          context,
          errorMessage,
          isError: true,
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .signInWithGoogle();

      setState(() => _isLoading = false);

      if (success && mounted) {
        // Check if user profile exists
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final profileExists = await ref
              .read(authNotifierProvider.notifier)
              .userProfileExists(user.uid);

          if (profileExists) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.profileSetup);
          }
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Google Sign-In failed',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo/Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  AppStrings.welcomeTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  AppStrings.welcomeSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // Phone number input with country code selector
                Row(
                  children: [
                    // Country code dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cardBackground.withValues(alpha: 0.5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      country['flag']!,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      country['code']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCountryCode = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone number input
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: AppStrings.phoneNumberLabel,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        validator: Validators.validatePhone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _rateLimitSeconds > 0) ? null : _sendOTP,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : _rateLimitSeconds > 0
                            ? Text('Wait ${_formatTime(_rateLimitSeconds)}')
                            : const Text(AppStrings.sendOTP),
                  ),
                ),
                // Rate limit message
                if (_rateLimitSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Too many attempts. Please wait ${_formatTime(_rateLimitSeconds)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Divider with OR
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 32),
                    label: const Text('Continue with Google'),
                  ),
                ),
                const SizedBox(height: 40),

                // Terms and Privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go(AppRoutes.roleSelection),
                  child: const Text(
                    'Choose account type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

