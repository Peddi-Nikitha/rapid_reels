import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;

  String? _pendingProfileImageUrl;
  bool _isUploadingProfileImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initFromUser(FirebaseUserModel? user, String? authEmail, String? authPhone) {
    if (user == null) return;
    _nameController.text = user.fullName;
    _emailController.text = user.email ?? authEmail ?? '';
    _phoneController.text = user.phoneNumber ?? authPhone ?? '';
    _cityController.text = user.currentLocation?.city ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';
    final userProfileAsync = ref.watch(userProfileProvider(userId));

    return userProfileAsync.when(
      data: (userProfile) {
        if (currentUser != null && _nameController.text.isEmpty && userProfile != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initFromUser(userProfile, currentUser.email, currentUser.phoneNumber);
          });
        } else if (currentUser != null && userProfile == null && _nameController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nameController.text = currentUser.displayName ?? '';
            _emailController.text = currentUser.email ?? '';
            _phoneController.text = currentUser.phoneNumber ?? '';
          });
        }

        final user = userProfile;
        final profileImage = user?.profileImage ?? currentUser?.photoURL;
        final effectiveProfileImage = _pendingProfileImageUrl ?? profileImage;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: effectiveProfileImage != null && effectiveProfileImage.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(effectiveProfileImage),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: effectiveProfileImage == null || effectiveProfileImage.isEmpty
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : null,
                            ),
                            child: effectiveProfileImage == null || effectiveProfileImage.isEmpty
                                ? const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _cityController,
                      labelText: 'City',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Phone number cannot be changed. Contact support if needed.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: () => _saveChanges(userId),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Error loading profile')),
      ),
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadProfilePicture(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadProfilePicture(ImageSource.gallery);
              },
            ),
            if (_isUploadingProfileImage) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadProfilePicture(ImageSource source) async {
    if (_isUploadingProfileImage) return;

    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    setState(() => _isUploadingProfileImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _isUploadingProfileImage = false);
        return;
      }

      final uuid = const Uuid().v4();
      final ext = _extractFileExtension(picked);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_pics/$userId/$uuid.$ext');

      if (kIsWeb) {
        final Uint8List bytes = await picked.readAsBytes();
        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/$ext'),
        );
      } else {
        final file = File(picked.path);
        await storageRef.putFile(file);
      }
      final downloadUrl = await storageRef.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _pendingProfileImageUrl = downloadUrl;
        _isUploadingProfileImage = false;
      });

      _showSnackBar('Profile picture selected. Tap "Save Changes" to apply.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingProfileImage = false);
      _showSnackBar('Failed to upload profile picture: $e');
    }
  }

  String _extractFileExtension(XFile picked) {
    final source = picked.name.isNotEmpty ? picked.name : picked.path;
    final dot = source.lastIndexOf('.');
    if (dot == -1 || dot == source.length - 1) return 'jpg';
    return source.substring(dot + 1).toLowerCase();
  }

  Future<void> _saveChanges(String userId) async {
    if (!_formKey.currentState!.validate() || userId.isEmpty) return;
    final success = await ref.read(authNotifierProvider.notifier).updateUserProfile(
          userId,
          {
            'fullName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            if (_pendingProfileImageUrl != null)
              'profileImage': _pendingProfileImageUrl,
            if (_cityController.text.trim().isNotEmpty)
              'currentLocation': {
                'city': _cityController.text.trim(),
                'state': '',
                'country': '',
                'coordinates': {'latitude': 0.0, 'longitude': 0.0},
              },
          },
        );
    if (mounted) {
      _showSnackBar(success ? 'Profile updated successfully!' : 'Failed to update profile');
      if (success) {
        _pendingProfileImageUrl = null;
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
