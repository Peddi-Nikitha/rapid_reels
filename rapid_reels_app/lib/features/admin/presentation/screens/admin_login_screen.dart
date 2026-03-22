import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/admin/admin_route_cache.dart';
import '../../../../core/admin/static_admin_session_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/router/router_refresh_notifier.dart';
import '../../../../core/session/user_session_cleanup.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';

/// Allowed admin emails; each must exist in Firebase Auth (Email/Password) with this
/// password, and `users/{uid}` in Firestore must have `userType` admin or superadmin.
const String kAdminLoginPassword = 'brave123';

/// Either spelling is accepted (avoid typos / old saved autofill).
const Set<String> kAdminLoginEmailsLowercase = {
  'braveadmin@rapidreels.com',
  'bravehearts@rapidreels.com',
};

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _staticAuthOk(String email, String password) {
    return kAdminLoginEmailsLowercase.contains(email.trim().toLowerCase()) &&
        password == kAdminLoginPassword;
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Sign-in failed (${e.code}).';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_staticAuthOk(email, password)) {
      Helpers.showSnackBar(
        context,
        'Incorrect email or password.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          _authErrorMessage(e),
          isError: true,
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Sign-in failed: $e',
          isError: true,
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    AdminRouteCache.invalidate();
    final isAdmin = await AdminRouteCache.isCurrentUserAdmin();
    if (!isAdmin) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (uid != null) {
        invalidateUserSessionProviders(ref, uid);
      }
      if (mounted) {
        Helpers.showSnackBar(
          context,
          uid == null
              ? 'Could not verify admin role.'
              : 'This account is not an admin. In Firestore, set userType to admin or superadmin on users/$uid.',
          isError: true,
        );
      }
      return;
    }

    ref.read(staticAdminSessionProvider.notifier).state = false;
    appRouterAuthRefresh.refresh();
    if (mounted) context.go(AppRoutes.adminDashboard);
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
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Admin sign in',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your admin email and password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: null,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
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
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _login,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'Back to customer login',
                      style: TextStyle(color: AppColors.textSecondary),
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
