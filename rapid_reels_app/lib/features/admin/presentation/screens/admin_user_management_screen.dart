import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Customers'),
            Tab(text: 'Providers'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
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
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() => _selectedFilter = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'All', child: Text('All')),
                    const PopupMenuItem(value: 'Active', child: Text('Active')),
                    const PopupMenuItem(value: 'Inactive', child: Text('Inactive')),
                    const PopupMenuItem(value: 'Verified', child: Text('Verified')),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomersTab(),
                _buildProvidersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    return StreamBuilder<List<FirebaseUserModel>>(
      stream: _firestore.streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load users',
              style: TextStyle(color: Colors.red[400]),
            ),
          );
        }
        final all = snapshot.data ?? const [];
        // Filter to customers only
        var customers = all.where((u) => u.userType == 'customer').toList();

        // Search filter
        final query = _searchController.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          customers = customers.where((u) {
            final name = u.fullName.toLowerCase();
            final email = (u.email ?? '').toLowerCase();
            final phone = (u.phoneNumber ?? '').toLowerCase();
            return name.contains(query) ||
                email.contains(query) ||
                phone.contains(query);
          }).toList();
        }

        // Status filter
        if (_selectedFilter == 'Active') {
          customers = customers.where((u) => u.isActive).toList();
        } else if (_selectedFilter == 'Inactive') {
          customers = customers.where((u) => !u.isActive).toList();
        } else if (_selectedFilter == 'Verified') {
          customers = customers.where((u) => u.isVerified).toList();
        }

        if (customers.isEmpty) {
          return const Center(
            child: Text(
              'No customers found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final u = customers[index];
            final userMap = {
              'id': u.userId,
              'name': u.fullName,
              'email': u.email ?? '—',
              'phone': u.phoneNumber ?? '—',
              'status': u.isActive ? 'active' : 'inactive',
            };
            return _buildUserCard(userMap, isProvider: false);
          },
        );
      },
    );
  }

  Widget _buildProvidersTab() {
    return StreamBuilder<List<FirebaseProviderModel>>(
      stream: _firestore.streamAllProviders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load providers',
              style: TextStyle(color: Colors.red[400]),
            ),
          );
        }

        var providers = snapshot.data ?? const [];

        // Search
        final query = _searchController.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          providers = providers.where((p) {
            final business = p.businessName.toLowerCase();
            final owner = p.ownerName.toLowerCase();
            final email = p.email.toLowerCase();
            final phone = p.phoneNumber.toLowerCase();
            return business.contains(query) ||
                owner.contains(query) ||
                email.contains(query) ||
                phone.contains(query);
          }).toList();
        }

        // Filter by status / verification
        if (_selectedFilter == 'Active') {
          providers = providers.where((p) => p.isActive).toList();
        } else if (_selectedFilter == 'Inactive') {
          providers = providers.where((p) => !p.isActive).toList();
        } else if (_selectedFilter == 'Verified') {
          providers = providers.where((p) => p.isVerified).toList();
        }

        if (providers.isEmpty) {
          return const Center(
            child: Text(
              'No providers found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            return _buildProviderCard(provider);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {required bool isProvider}) {
    final isActive = user['status'] == 'active';
    final name = (user['name'] ?? '').toString().trim();
    final email = (user['email'] ?? '—').toString();
    final phone = (user['phone'] ?? '—').toString();
    final avatarLetter =
        name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown user',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Details')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'status',
                child: Text(isActive ? 'Deactivate' : 'Activate'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (value) {
              // Handle action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(FirebaseProviderModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isVerified ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: provider.profileImage.isNotEmpty
                    ? NetworkImage(provider.profileImage)
                    : null,
                child: provider.profileImage.isEmpty
                    ? Text(
                        provider.businessName.isNotEmpty
                            ? provider.businessName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.businessName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (provider.isVerified)
                          const Icon(Icons.verified, color: Colors.green, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.ownerName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating} (${provider.totalReviews} reviews)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: provider.isVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.isVerified ? 'Verified' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: provider.isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProviderStat('Events', '${provider.totalEventsCompleted}'),
              ),
              Expanded(
                child: _buildProviderStat('Reels', '${provider.totalReelsDelivered}'),
              ),
              Expanded(
                child: _buildProviderStat('Rating', '${provider.rating}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View details
                  },
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 12),
              if (!provider.isVerified)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Verify provider
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verify'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

