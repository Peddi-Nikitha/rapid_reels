import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/admin/admin_access_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_offer_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class AdminOffersManagementScreen extends ConsumerStatefulWidget {
  const AdminOffersManagementScreen({super.key});

  @override
  ConsumerState<AdminOffersManagementScreen> createState() =>
      _AdminOffersManagementScreenState();
}

class _AdminOffersManagementScreenState
    extends ConsumerState<AdminOffersManagementScreen> {
  final _firestoreService = FirestoreService();
  final _uuid = const Uuid();
  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  String? _error;
  List<FirebaseOfferModel> _offers = [];
  bool _scheduledOffersLoad = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final access = ref.read(hasAdminPanelAccessProvider);
    if (access == null) {
      return;
    }
    if (!access) {
      setState(() {
        _offers = [];
        _isLoading = false;
        _error = 'You do not have access to Offers Management.';
      });
      return;
    }

    try {
      final offers = await _firestoreService.getOffersForAdmin(limit: 200);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleField(
    FirebaseOfferModel offer, {
    required String field,
    required bool value,
  }) async {
    if (ref.read(hasAdminPanelAccessProvider) != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      return;
    }
    await _firestoreService.updateOffer(offer.offerId, {field: value});
    await _loadOffers();
  }

  Future<String?> _pickAndUploadBannerImage() async {
    try {
      if (ref.read(hasAdminPanelAccessProvider) != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login as admin first')),
          );
        }
        return null;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in with the admin account to upload banners.'),
            ),
          );
        }
        return null;
      }

      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final ext = _extractFileExtension(picked);
      final fileName = '${_uuid.v4()}.$ext';
      final path = 'admin_banners/$uid/$fileName';
      final storageRef = FirebaseStorage.instance.ref().child(path);

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

      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Banner upload failed: $e')),
        );
      }
      return null;
    }
  }

  String _extractFileExtension(XFile picked) {
    final source = picked.name.isNotEmpty ? picked.name : picked.path;
    final dot = source.lastIndexOf('.');
    if (dot == -1 || dot == source.length - 1) return 'jpg';
    return source.substring(dot + 1).toLowerCase();
  }

  void _showEditDialog(FirebaseOfferModel offer) {
    final titleController = TextEditingController(text: offer.title);
    final descriptionController =
        TextEditingController(text: offer.description ?? '');
    final imageController = TextEditingController(text: offer.imageUrl ?? '');
    final eventTypesController = TextEditingController(
      text: offer.applicableEventTypes?.join(', ') ?? '',
    );

    bool isActive = offer.isActive;
    bool isPublic = offer.isPublic;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Edit Offer'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final imageUrl = await _pickAndUploadBannerImage();
                          if (imageUrl == null) return;
                          setDialogState(() {
                            imageController.text = imageUrl;
                          });
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Banner Image'),
                      ),
                    ),
                    TextField(
                      controller: eventTypesController,
                      decoration: const InputDecoration(
                        labelText: 'Applicable Event Types (comma separated)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                      title: const Text('Active'),
                    ),
                    SwitchListTile(
                      value: isPublic,
                      onChanged: (v) => setDialogState(() => isPublic = v),
                      title: const Text('Public'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _firestoreService.updateOffer(
                        offer.offerId,
                        {
                          'title': titleController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'imageUrl': imageController.text.trim(),
                          'isActive': isActive,
                          'isPublic': isPublic,
                          'applicableEventTypes': eventTypesController
                              .text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        },
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _loadOffers();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateDialog() {
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();
    final maxUsesController = TextEditingController(text: '10');
    final eventTypesController = TextEditingController();
    bool isActive = true;
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Create Offer'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final imageUrl = await _pickAndUploadBannerImage();
                          if (imageUrl == null) return;
                          setDialogState(() {
                            imageController.text = imageUrl;
                          });
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Banner Image'),
                      ),
                    ),
                    TextField(
                      controller: maxUsesController,
                      decoration:
                          const InputDecoration(labelText: 'Max Uses (int)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: eventTypesController,
                      decoration: const InputDecoration(
                        labelText: 'Applicable Event Types (comma separated)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                      title: const Text('Active'),
                    ),
                    SwitchListTile(
                      value: isPublic,
                      onChanged: (v) => setDialogState(() => isPublic = v),
                      title: const Text('Public'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final maxUses = int.tryParse(maxUsesController.text.trim()) ?? 10;
                      final offerId = _uuid.v4();

                      final applicableEventTypes = eventTypesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final now = DateTime.now();

                      final offer = FirebaseOfferModel(
                        offerId: offerId,
                        code: codeController.text.trim(),
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        type: 'discount_percentage',
                        discount: OfferDiscount(percentage: 10),
                        validity: OfferValidity(
                          startDate: now,
                          endDate: now.add(const Duration(days: 30)),
                        ),
                        eligibility: OfferEligibility(
                          maxUsesPerUser: null,
                        ),
                        maxUses: maxUses,
                        usedCount: 0,
                        isActive: isActive,
                        isPublic: isPublic,
                        imageUrl: imageController.text.trim().isEmpty
                            ? null
                            : imageController.text.trim(),
                        applicableEventTypes: applicableEventTypes.isEmpty
                            ? null
                            : applicableEventTypes,
                        applicablePackages: null,
                        createdAt: now,
                        expiresAt: null,
                        metadata: null,
                      );

                      await _firestoreService.createOffer(offer);
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _loadOffers();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Create failed: $e')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOfferBannerImage(String? imageUrl) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: Colors.grey.shade300,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 160,
      placeholder: (context, _) => ColoredBox(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) => ColoredBox(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(hasAdminPanelAccessProvider);
    if (access == true && !_scheduledOffersLoad) {
      _scheduledOffersLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadOffers();
      });
    }

    if (access == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Offers Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (access == false) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Offers Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'You do not have access to this screen.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Offers Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _offers.isEmpty
                  ? const Center(child: Text('No offers found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _offers.length,
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          color: AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 160,
                                width: double.infinity,
                                child: _buildOfferBannerImage(offer.imageUrl),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                offer.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Code: ${offer.code}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              _showEditDialog(offer);
                                            } else if (value == 'delete') {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        AppColors.surface,
                                                    title: const Text(
                                                        'Delete Offer'),
                                                    content: const Text(
                                                      'Are you sure you want to delete this offer?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                true),
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirmed != true) return;
                                              await _firestoreService
                                                  .deleteOffer(offer.offerId);
                                              await _loadOffers();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (offer.description != null &&
                                        offer.description!.trim().isNotEmpty)
                                      Text(
                                        offer.description!,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SwitchListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: const Text('Active'),
                                            value: offer.isActive,
                                            onChanged: (v) async {
                                              await _toggleField(
                                                offer,
                                                field: 'isActive',
                                                value: v,
                                              );
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: SwitchListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: const Text('Public'),
                                            value: offer.isPublic,
                                            onChanged: (v) async {
                                              await _toggleField(
                                                offer,
                                                field: 'isPublic',
                                                value: v,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

