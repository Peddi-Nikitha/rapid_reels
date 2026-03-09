import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/auth_provider.dart';
import '../../data/models/user_model.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user or use a default user ID
      final user = ref.read(currentUserProvider);
      final userId = user?.uid ?? 'new_user_999';
      final phoneNumber = user?.phoneNumber ?? '';

      // Create user profile
      final fullName = _nameController.text.trim();
      final userProfile = UserModel(
        userId: userId,
        phoneNumber: phoneNumber,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : '',
        fullName: fullName,
        profileImage: null,
        currentLocation: LocationData(
          city: 'Unknown',
          state: 'Unknown',
          country: 'India',
          coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
        ),
        referralCode: _generateReferralCode(fullName),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(authNotifierProvider.notifier)
          .createUserProfile(userProfile);

      setState(() => _isLoading = false);

      if (success && mounted) {
        // Navigate to city selection screen
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.go(AppRoutes.citySelection);
          }
        });
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Failed to create profile',
            isError: true,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        debugPrint('Profile setup error: $e');
        // Even if there's an error, navigate to city selection for better UX
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.go(AppRoutes.citySelection);
          }
        });
      }
    }
  }

  String _generateReferralCode(String name) {
    final cleanName = name.replaceAll(' ', '').toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    return '${cleanName.substring(0, cleanName.length > 6 ? 6 : cleanName.length)}$timestamp';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Greeting
                Text(
                  'Hi, You!',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'We want to know more about you!',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Name
                _buildLabel('Enter your Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  validator: (value) => Validators.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 24),

                // Email
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email ID',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Continue Button
                _buildContinueButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }


  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _isLoading ? null : _completeProfile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Continue',
                      style: AppTypography.buttonLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

