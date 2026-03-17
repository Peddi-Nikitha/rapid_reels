import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class ProviderLoginScreen extends StatefulWidget {
  const ProviderLoginScreen({super.key});

  @override
  State<ProviderLoginScreen> createState() => _ProviderLoginScreenState();
}

class _ProviderLoginScreenState extends State<ProviderLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedCountryCode = '+91';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();

      // 1) Find provider by phone number in Firestore (handles multiple formats internally)
      final provider = await _firestoreService.getProviderByPhone(
        phone,
        countryCode: _selectedCountryCode,
      );
      if (provider == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Provider not found. Please check your phone number or register first.',
            isError: true,
          );
        }
        return;
      }

      // 2) Ensure admin has approved this provider
      if (provider.verificationStatus != 'approved' || !provider.isActive) {
        setState(() => _isLoading = false);
        if (mounted) {
          final status = provider.verificationStatus;
          String message;
          if (status == 'pending') {
            message = 'Your provider account is pending admin approval.';
          } else if (status == 'rejected') {
            message = 'Your provider account was rejected. Please contact support.';
          } else {
            message = 'Your provider account is not active. Please contact support.';
          }
          Helpers.showSnackBar(
            context,
            message,
            isError: true,
          );
        }
        return;
      }

      // 3) Sign in with email/password using provider's email
      await _auth.signInWithEmailAndPassword(
        email: provider.email,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 4) Navigate to provider dashboard for this providerId
      context.go('${AppRoutes.providerDashboard}/${provider.providerId}');
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = 'Login failed. Please try again.';
      if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for these credentials.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      }
      if (mounted) {
        Helpers.showSnackBar(
          context,
          message,
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Unexpected error: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    // TODO: Implement real Google Sign-In for providers if needed.
    Helpers.showSnackBar(
      context,
      'Google Sign-In for providers is not available yet. Please use phone & password.',
      isError: true,
    );
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
                      Icons.business_center,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Welcome Back, Provider!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Sign in to manage your bookings and earnings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
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
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(country['flag']!),
                                  const SizedBox(width: 8),
                                  Text(country['code']!),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCountryCode = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone number field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '9876543210',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        validator: Validators.validatePhone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                      Helpers.showSnackBar(
                        context,
                        'Forgot password feature coming soon',
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign-In button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 24);
                      },
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.providerRegistration);
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Back to customer login
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: Text(
                      'Login as Customer',
                      style: TextStyle(color: Colors.grey[600]),
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

