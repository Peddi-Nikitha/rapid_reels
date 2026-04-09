import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/admin/admin_route_cache.dart';
import '../../../../core/admin/static_admin_session_provider.dart';
import '../../../../core/router/router_refresh_notifier.dart';
import '../../../../core/session/user_session_cleanup.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';

class ProviderLoginScreen extends ConsumerStatefulWidget {
  const ProviderLoginScreen({super.key});

  @override
  ConsumerState<ProviderLoginScreen> createState() =>
      _ProviderLoginScreenState();
}

class _ProviderLoginScreenState extends ConsumerState<ProviderLoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResettingPassword = false;
  bool _obscurePassword = true;
  String _selectedCountryCode = '+44';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, String>> _countryCodes = [
    {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
  ];

  bool get _identifierIsEmail =>
      _identifierController.text.trim().contains('@');

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _providerGateMessage(FirebaseProviderModel provider) {
    if (provider.verificationStatus == 'rejected') {
      return 'Your provider account was rejected. Please contact support.';
    }
    if (!provider.isActive && provider.verificationStatus != 'pending') {
      return 'Your provider account is not active. Please contact support.';
    }
    return null;
  }

  Future<void> _signOutAndInvalidate(String? uid) async {
    try {
      await _auth.signOut();
    } catch (_) {}
    if (uid != null && uid.isNotEmpty) {
      invalidateUserSessionProviders(ref, uid);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = _identifierController.text.trim();
      final password = _passwordController.text;

      if (id.contains('@')) {
        await _loginWithEmail(id, password);
      } else {
        await _loginWithPhone(id, password);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(
        context,
        _mapAuthError(e),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(
        context,
        'Unexpected error: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No user found for these credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'Sign-in failed (${e.code}).';
    }
  }

  Future<void> _loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;

    AdminRouteCache.invalidate();
    final isAdmin = await AdminRouteCache.isCurrentUserAdmin();
    if (isAdmin) {
      ref.read(staticAdminSessionProvider.notifier).state = false;
      appRouterAuthRefresh.refresh();
      if (mounted) context.go(AppRoutes.adminDashboard);
      return;
    }

    final uid = _auth.currentUser?.uid;
    final provider =
        uid != null ? await _firestoreService.getProvider(uid) : null;

    if (provider == null) {
      await _signOutAndInvalidate(uid);
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'This account is not registered as a provider. Use the customer sign-in if you have a personal account.',
          isError: true,
        );
      }
      return;
    }

    final gate = _providerGateMessage(provider);
    if (gate != null) {
      await _signOutAndInvalidate(uid);
      if (mounted) {
        Helpers.showSnackBar(context, gate, isError: true);
      }
      return;
    }

    if (mounted) {
      context.go('${AppRoutes.providerPortal}/${provider.providerId}/home');
    }
  }

  Future<void> _loginWithPhone(String phone, String password) async {
    final provider = await _firestoreService.getProviderByPhone(
      phone,
      countryCode: _selectedCountryCode,
    );
    if (provider == null) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Provider not found. Please check your phone number or register first.',
          isError: true,
        );
      }
      return;
    }

    final gate = _providerGateMessage(provider);
    if (gate != null) {
      if (mounted) {
        Helpers.showSnackBar(context, gate, isError: true);
      }
      return;
    }

    await _auth.signInWithEmailAndPassword(
      email: provider.email,
      password: password,
    );

    if (!mounted) return;
    context.go('${AppRoutes.providerPortal}/${provider.providerId}/home');
  }

  Future<void> _signInWithGoogle() async {
    Helpers.showSnackBar(
      context,
      'Google Sign-In for providers is not available yet. Please use phone & password.',
      isError: true,
    );
  }

  Future<void> _forgotPassword() async {
    final id = _identifierController.text.trim();
    if (id.isEmpty) {
      Helpers.showSnackBar(
        context,
        _identifierIsEmail
            ? 'Enter your email first.'
            : 'Enter your registered phone number first.',
        isError: true,
      );
      return;
    }

    setState(() => _isResettingPassword = true);

    try {
      if (id.contains('@')) {
        final email = id.trim();
        if (Validators.validateEmail(email) != null) {
          if (!mounted) return;
          Helpers.showSnackBar(
            context,
            'Enter a valid email address.',
            isError: true,
          );
          return;
        }
        await _auth.sendPasswordResetEmail(email: email);
        if (!mounted) return;
        Helpers.showSnackBar(
          context,
          'Password reset link sent to $email',
        );
        return;
      }

      final provider = await _firestoreService.getProviderByPhone(
        id,
        countryCode: _selectedCountryCode,
      );

      if (provider == null) {
        if (!mounted) return;
        Helpers.showSnackBar(
          context,
          'No provider account found for this phone number.',
          isError: true,
        );
        return;
      }

      final email = provider.email.trim();
      if (email.isEmpty) {
        if (!mounted) return;
        Helpers.showSnackBar(
          context,
          'No email found for this provider account. Please contact support.',
          isError: true,
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      Helpers.showSnackBar(
        context,
        'Password reset link sent to $email',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Could not send reset link. Please try again.';
      if (e.code == 'invalid-email') {
        message = 'Provider email is invalid. Please contact support.';
      } else if (e.code == 'user-not-found') {
        message = 'No login account found for this provider email.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }
      Helpers.showSnackBar(
        context,
        message,
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(
        context,
        'Unable to process forgot password right now.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  String? _validateIdentifier(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) {
      return 'This field is required';
    }
    if (t.contains('@')) {
      return Validators.validateEmail(t);
    }
    return Validators.validatePhone(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: ProviderAppColors.primaryGradient,
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

                Text(
                  'Welcome Back, Provider!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ProviderAppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 48),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ProviderAppColors.searchBarFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ProviderAppColors.outline,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: ProviderAppColors.textTertiary,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ProviderAppColors.textPrimary,
                          ),
                          dropdownColor: ProviderAppColors.surfaceElevated,
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
                    Expanded(
                      child: TextFormField(
                        controller: _identifierController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Provider phone',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(
                            _identifierIsEmail
                                ? Icons.email_outlined
                                : Icons.phone,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: ProviderAppColors.searchBarFill,
                        ),
                        validator: _validateIdentifier,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: ProviderAppColors.searchBarFill,
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (_isLoading || _isResettingPassword)
                        ? null
                        : _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 32),

                ProviderGradientButton(
                  onPressed: _isLoading ? null : _login,
                  loading: _isLoading,
                  label: 'Sign In',
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: Divider(color: ProviderAppColors.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          color: ProviderAppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: ProviderAppColors.outline)),
                  ],
                ),
                const SizedBox(height: 24),

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
                    label: Text(
                      'Sign in with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ProviderAppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProviderAppColors.textPrimary,
                      side: const BorderSide(color: ProviderAppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          color: ProviderAppColors.textTertiary,
                        ),
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

                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go(AppRoutes.roleSelection);
                    },
                    child: Text(
                      'Choose account type',
                      style: GoogleFonts.poppins(
                        color: ProviderAppColors.textTertiary,
                      ),
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
