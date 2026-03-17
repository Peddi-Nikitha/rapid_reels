import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';

class AdminProviderVerificationScreen extends ConsumerStatefulWidget {
  const AdminProviderVerificationScreen({super.key});

  @override
  ConsumerState<AdminProviderVerificationScreen> createState() => _AdminProviderVerificationScreenState();
}

class _AdminProviderVerificationScreenState extends ConsumerState<AdminProviderVerificationScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Pending';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final pendingStream = firestore.streamPendingProviders();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Provider Verification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'Verified', child: Text('Verified')),
              const PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
              const PopupMenuItem(value: 'All', child: Text('All')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search providers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Stats + List powered by Firestore stream
          Expanded(
            child: StreamBuilder<List<FirebaseProviderModel>>(
              stream: pendingStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading providers: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final pendingProviders = snapshot.data ?? [];
                final searchQuery = _searchController.text.toLowerCase();
                final filtered = pendingProviders.where((p) {
                  if (searchQuery.isEmpty) return true;
                  return p.businessName.toLowerCase().contains(searchQuery) ||
                      p.ownerName.toLowerCase().contains(searchQuery) ||
                      p.email.toLowerCase().contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No pending verifications', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('Pending', '${filtered.length}', Colors.orange),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final provider = filtered[index];
                          return _buildProviderVerificationCard(provider);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProviderVerificationCard(FirebaseProviderModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(provider.profileImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.businessName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.ownerName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Verification Checklist
          const Text(
            'Verification Checklist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem('Business Profile', true),
          _buildCheckItem('Portfolio Upload', true),
          _buildCheckItem('Service Areas', true),
          _buildCheckItem('Documents Upload', true),
          _buildCheckItem('Availability Calendar', true),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showProviderDetails(provider);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _rejectProvider(provider);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _verifyProvider(provider);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Verify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String item, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: completed ? Colors.white : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showProviderDetails(FirebaseProviderModel provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(provider.businessName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Owner: ${provider.ownerName}'),
              const SizedBox(height: 8),
              Text('Email: ${provider.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${provider.phoneNumber}'),
              const SizedBox(height: 8),
              Text('Location: ${provider.location.city}'),
              const SizedBox(height: 8),
              Text('Service Areas: ${provider.serviceAreas.join(", ")}'),
              const SizedBox(height: 8),
              Text('Event Types: ${provider.eventTypes.join(", ")}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _verifyProvider(FirebaseProviderModel provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Verify Provider'),
        content: Text('Are you sure you want to verify ${provider.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirestoreService().updateProviderVerificationStatus(
                  providerId: provider.providerId,
                  status: 'approved',
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${provider.businessName} verified successfully!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error verifying provider: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _rejectProvider(FirebaseProviderModel provider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reject Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              try {
                await FirestoreService().updateProviderVerificationStatus(
                  providerId: provider.providerId,
                  status: 'rejected',
                  rejectionReason: reason,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${provider.businessName} rejected')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error rejecting provider: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

