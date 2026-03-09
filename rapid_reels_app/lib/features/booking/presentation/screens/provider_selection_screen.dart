import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../booking/data/models/service_provider_model.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/provider_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/empty_state.dart';

class ProviderSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ProviderSelectionScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<ProviderSelectionScreen> createState() => _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends State<ProviderSelectionScreen> {
  final _mockData = MockDataService();
  bool _isLoading = true;
  String _sortBy = 'rating'; // rating, price, distance
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.bookingData['venueCity'] as String?;
    
    // Get providers - use city if available, otherwise show all providers
    // This handles cases like "home" or custom venue entries
    List<ServiceProvider> providers;
    if (city != null && city.isNotEmpty) {
      providers = _mockData.getProvidersByCity(city);
    } else {
      // If no city (e.g., "home" or custom venue), show all available providers
      providers = _mockData.getAllProviders()
          .where((p) => p.isActive && p.isVerified)
          .toList();
    }

    // Apply filters
    if (_minRating > 0) {
      providers = providers.where((p) => p.rating >= _minRating).toList();
    }

    // Apply sorting
    if (_sortBy == 'rating') {
      providers.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'price') {
      providers.sort((a, b) {
        if (a.packages.isEmpty || b.packages.isEmpty) return 0;
        final aMinPrice = a.packages.map((p) => p.price).reduce((a, b) => a < b ? a : b);
        final bMinPrice = b.packages.map((p) => p.price).reduce((a, b) => a < b ? a : b);
        return aMinPrice.compareTo(bMinPrice);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Select Provider',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${providers.length} providers found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                _buildSortChip('Rating', 'rating', Icons.star),
                const SizedBox(width: 8),
                _buildSortChip('Price', 'price', Icons.currency_rupee),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 3,
                    itemBuilder: (context, index) => const ShimmerProviderCard(),
                  )
                : providers.isEmpty
                    ? EmptyState(
                        icon: Icons.person_search,
                        title: 'No Providers Found',
                        message: city != null && city.isNotEmpty
                            ? 'No providers available in $city at the moment'
                            : 'No providers available at the moment',
                        buttonText: 'Change Location',
                        onButtonPressed: () => context.pop(),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProviders,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final provider = providers[index];
                            return ProviderCard(
                              provider: provider,
                              onTap: () {
                                final updatedData = Map<String, dynamic>.from(widget.bookingData);
                                updatedData['providerId'] = provider.providerId;
                                
                                context.push(
                                  AppRoutes.providerPortfolio,
                                  extra: {
                                    'provider': provider,
                                    'bookingData': updatedData,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Minimum Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppColors.primary,
                label: _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Any',
                onChanged: (value) {
                  setModalState(() {
                    _minRating = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

