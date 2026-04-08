import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ProviderBusinessProfileScreen extends StatefulWidget {
  const ProviderBusinessProfileScreen({super.key});

  @override
  State<ProviderBusinessProfileScreen> createState() => _ProviderBusinessProfileScreenState();
}

class _ProviderBusinessProfileScreenState extends State<ProviderBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _teamSizeController = TextEditingController();
  
  String? _selectedProfileImage;
  List<String> _selectedCoverImages = [];
  List<String> _selectedEventTypes = [];
  List<String> _selectedEquipment = [];
  bool _isSaving = false;

  final _auth = FirebaseAuth.instance;
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();
  
  final List<String> _availableEventTypes = [
    'Wedding',
    'Birthday',
    'Engagement',
    'Corporate',
    'Brand',
  ];
  final List<String> _availableEquipment = const [
    'Drone',
    'Camera',
    'iPhone',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _teamSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Business Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Business Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help customers discover your services',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              
              // Profile Image
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectProfileImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: ProviderAppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: ProviderAppColors.primary, width: 2),
                        ),
                        child: _selectedProfileImage != null
                            ? ClipOval(
                                child: Image.network(
                                  _selectedProfileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.grey[600], size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _selectProfileImage,
                      child: const Text('Upload Profile Photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Cover Images
              const Text(
                'Cover Images (3-5 recommended)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedCoverImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedCoverImages.length) {
                      return GestureDetector(
                        onTap: _selectCoverImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: ProviderAppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!, width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, color: Colors.grey[600]),
                              const SizedBox(height: 4),
                              Text(
                                'Add',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(_selectedCoverImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCoverImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Bio
              CustomTextField(
                controller: _bioController,
                label: 'Business Bio',
                hint: 'Tell customers about your services and experience',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business bio';
                  }
                  if (value.length < 50) {
                    return 'Bio must be at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Event Types
              const Text(
                'Event Types You Cover',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableEventTypes.map((type) {
                  final isSelected = _selectedEventTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEventTypes.add(type);
                        } else {
                          _selectedEventTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: ProviderAppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: ProviderAppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              const Text(
                'Available Equipment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableEquipment.map((item) {
                  final isSelected = _selectedEquipment.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipment.add(item);
                        } else {
                          _selectedEquipment.remove(item);
                        }
                      });
                    },
                    selectedColor: ProviderAppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: ProviderAppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Address
              CustomTextField(
                controller: _addressController,
                label: 'Business Address',
                hint: 'Enter your business address',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'City',
                      prefixIcon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'State',
                      prefixIcon: Icons.map,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _pincodeController,
                label: 'Pincode',
                hint: 'Enter pincode',
                prefixIcon: Icons.pin,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pincode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _teamSizeController,
                label: 'Team Size',
                hint: 'Number of team members',
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter team size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Continue',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _handleContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isSaving = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('providers')
          .child(user.uid)
          .child('profile.jpg');

      await ref.putData(await picked.readAsBytes());
      final url = await ref.getDownloadURL();

      await _firestoreService.updateProvider(user.uid, {
        'profileImage': url,
      });

      setState(() {
        _selectedProfileImage = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile photo: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectCoverImages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final pickedList = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedList.isEmpty) return;

    setState(() => _isSaving = true);

    final storage = FirebaseStorage.instance;
    final urls = <String>[];

    try {
      for (final file in pickedList) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = storage
            .ref()
            .child('providers')
            .child(user.uid)
            .child('covers')
            .child('$fileName.jpg');

        await ref.putData(await file.readAsBytes());
        urls.add(await ref.getDownloadURL());
      }

      await _firestoreService.updateProvider(user.uid, {
        'coverImages': urls,
      });

      setState(() {
        _selectedCoverImages.addAll(urls);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload cover images: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEventTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one event type')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as provider')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final teamSize = int.tryParse(_teamSizeController.text.trim()) ?? 1;
      double latitude = 0.0;
      double longitude = 0.0;
      final fullAddress =
          '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()}, ${_pincodeController.text.trim()}';
      try {
        final locations = await locationFromAddress(fullAddress);
        if (locations.isNotEmpty) {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        }
      } catch (_) {
        // Keep default coordinates; provider search has city fallback.
      }

      await _firestoreService.updateProvider(user.uid, {
        'bio': _bioController.text.trim(),
        'eventTypes': _selectedEventTypes.map((e) => e.toLowerCase()).toList(),
        'location': {
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'coordinates': {
            'latitude': latitude,
            'longitude': longitude,
          },
        },
        'teamSize': teamSize,
        'equipment': _selectedEquipment.map((e) => e.toLowerCase()).toList(),
      });

      if (!mounted) return;
      context.push(AppRoutes.providerPortfolioUpload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save business profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

