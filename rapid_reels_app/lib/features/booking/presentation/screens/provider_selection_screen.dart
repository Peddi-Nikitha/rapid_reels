import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/mock/mock_providers.dart';
import '../../../booking/data/models/service_provider_model.dart' as sp;
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/provider_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

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
  final _firestoreService = FirestoreService();
  bool _isLoading = true;
  String _sortBy = 'rating'; // rating, price, distance
  double _minRating = 0;
  List<FirebaseProviderModel>? _cachedProviders;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  sp.ServiceProvider _mapFirebaseToServiceProvider(FirebaseProviderModel p) {
    return sp.ServiceProvider(
      providerId: p.providerId,
      businessName: p.businessName,
      ownerName: p.ownerName,
      email: p.email,
      phoneNumber: p.phoneNumber,
      profileImage: p.profileImage,
      coverImages: p.coverImages,
      bio: p.bio,
      eventTypes: p.eventTypes,
      packages: p.packages
          .map((x) => sp.PackageOffering(
                packageId: x.packageId,
                name: x.name,
                price: x.price,
                duration: x.duration,
                reelsCount: x.reelsCount,
                editingStyle: x.editingStyle,
                deliveryTime: x.deliveryTime,
                highlightVideo: x.highlightVideo,
                liveReelStation: x.liveReelStation,
                features: x.features,
              ))
          .toList(),
      portfolio: p.portfolio
          .map((x) => sp.PortfolioItem(
                reelId: x.reelId,
                eventType: x.eventType,
                thumbnailUrl: x.thumbnailUrl,
                videoUrl: x.videoUrl,
                duration: x.duration,
                views: x.views,
                likes: x.likes,
              ))
          .toList(),
      location: sp.ProviderLocation.fromMap({
        'address': p.location.address,
        'city': p.location.city,
        'state': p.location.state,
        'pincode': p.location.pincode,
        'coordinates': {
          'latitude': p.location.latitude,
          'longitude': p.location.longitude,
        },
      }),
      serviceAreas: p.serviceAreas,
      serviceRadius: p.serviceRadius,
      teamSize: p.teamSize,
      equipment: p.equipment,
      rating: p.rating,
      totalReviews: p.totalReviews,
      totalEventsCompleted: p.totalEventsCompleted,
      totalReelsDelivered: p.totalReelsDelivered,
      averageDeliveryTime: p.averageDeliveryTime,
      availability: p.availability.map(
        (k, v) => MapEntry(
          k,
          sp.DayAvailability(
            isOpen: v.isOpen,
            slots: v.slots
                .map((s) => sp.TimeSlot(
                      startTime: s.startTime,
                      endTime: s.endTime,
                      slotDuration: s.slotDuration,
                    ))
                .toList(),
          ),
        ),
      ),
      blockedDates: p.blockedDates
          .map((d) => sp.BlockedDate(
                date: d.date,
                reason: d.reason,
                bookingId: d.bookingId,
              ))
          .toList(),
      bankDetails: p.bankDetails != null
          ? sp.BankDetails(
              accountNumber: p.bankDetails!.accountNumber,
              ifscCode: p.bankDetails!.ifscCode,
              accountHolderName: p.bankDetails!.accountHolderName,
              upiId: p.bankDetails!.upiId,
            )
          : null,
      commissionRate: p.commissionRate,
      isVerified: p.isVerified,
      isActive: p.isActive,
      isFeatured: p.isFeatured,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }
  Future<void> _loadProviders() async {
    try {
      // Prefer city from booking data; fall back to last detected/saved city from home screen.
      String? city = widget.bookingData['venueCity'] as String?;
      if (city == null || city.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        city = prefs.getString('selected_city');
      }
      final eventType = widget.bookingData['eventType'] as String?;
      var providers = await _firestoreService.getProviders(
        city: city,
        isActive: true,
        isVerified: true,
        verificationStatus: 'approved',
        eventTypes: eventType != null && eventType.isNotEmpty ? [eventType] : null,
      );

      // Fallback: if location/event-filtered query returns nothing, show all bookable providers.
      if (providers.isEmpty) {
        providers = await _firestoreService.getProviders(
          isActive: true,
          isVerified: true,
          verificationStatus: 'approved',
        );
      }
      if (!mounted) return;
      setState(() {
        _cachedProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load providers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build provider list from Firebase providers cached in state (loaded in _loadProviders)
    List<sp.ServiceProvider> providers = (_cachedProviders ?? [])
        .map(_mapFirebaseToServiceProvider)
        .where((p) => p.isActive && p.isVerified)
        .toList();

    // Safety fallback: keep this screen bookable even if backend list is empty.
    if (providers.isEmpty) {
      providers = MockProviders.allProviders
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

