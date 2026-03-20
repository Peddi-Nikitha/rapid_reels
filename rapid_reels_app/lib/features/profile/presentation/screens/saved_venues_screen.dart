import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class SavedVenuesScreen extends ConsumerWidget {
  SavedVenuesScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';
    final userProfileAsync = ref.watch(userProfileProvider(userId));

    return userProfileAsync.when(
      data: (userProfile) {
        final addresses = userProfile?.savedAddresses ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text(
              'My Venues',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: addresses.isEmpty
              ? const EmptyState(
                  title: 'No Saved Venues',
                  message: 'No saved venues yet',
                  icon: Icons.location_on_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return _buildAddressCard(
                      context,
                      address,
                      index,
                      ref,
                      userId,
                      addresses,
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Add New Venue',
                onPressed: () => _addNewVenue(context, userId, addresses),
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
        appBar: AppBar(title: const Text('My Venues')),
        body: const Center(child: Text('Error loading addresses')),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    SavedAddress address,
    int index,
    WidgetRef ref,
    String userId,
    List<SavedAddress> addresses,
  ) {
    final label = address.label.isNotEmpty ? address.label : 'Address';
    final fullAddress = '${address.address}, ${address.city}';
    final city = address.city;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fullAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditVenueDialog(context, userId, addresses, address);
                  } else if (value == 'delete') {
                    _showDeleteConfirm(
                      context,
                      userId,
                      addresses,
                      address.addressId,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_city, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                city,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (address.pincode.isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  address.pincode,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    String userId,
    List<SavedAddress> addresses,
    String addressId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this venue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updated = addresses
                    .where((a) => a.addressId != addressId)
                    .toList(growable: false);

                await _firestoreService.updateUser(
                  userId,
                  {
                    'savedAddresses': updated.map((a) => a.toMap()).toList(),
                  },
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venue deleted')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditVenueDialog(
    BuildContext context,
    String userId,
    List<SavedAddress> addresses,
    SavedAddress address,
  ) {
    final labelController = TextEditingController(text: address.label);
    final addressController = TextEditingController(text: address.address);
    final cityController = TextEditingController(text: address.city);
    final pincodeController = TextEditingController(text: address.pincode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Venue'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final uuid = const Uuid().v4();
                final updatedAddress = SavedAddress(
                  addressId: address.addressId.isNotEmpty
                      ? address.addressId
                      : uuid,
                  label: labelController.text.trim(),
                  address: addressController.text.trim(),
                  city: cityController.text.trim(),
                  pincode: pincodeController.text.trim(),
                  // Saved venue coordinates are not currently used in UX; keep safe default.
                  coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
                );

                final updated = addresses.map((a) {
                  if (a.addressId == address.addressId) return updatedAddress;
                  return a;
                }).toList(growable: false);

                await _firestoreService.updateUser(
                  userId,
                  {
                    'savedAddresses':
                        updated.map((a) => a.toMap()).toList(),
                  },
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venue updated')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNewVenue(
    BuildContext context,
    String userId,
    List<SavedAddress> addresses,
  ) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final pincodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add New Venue'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final uuid = const Uuid().v4();
                final newAddress = SavedAddress(
                  addressId: uuid,
                  label: labelController.text.trim(),
                  address: addressController.text.trim(),
                  city: cityController.text.trim(),
                  pincode: pincodeController.text.trim(),
                  // Coordinates are optional in current UX; keep safe defaults.
                  coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
                );

                final updated = [...addresses, newAddress];

                await _firestoreService.updateUser(
                  userId,
                  {
                    'savedAddresses':
                        updated.map((a) => a.toMap()).toList(),
                  },
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venue added successfully!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add venue: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
