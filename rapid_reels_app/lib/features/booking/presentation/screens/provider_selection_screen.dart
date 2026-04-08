import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/booking/date_availability.dart';
import '../../../../core/constants/app_cities.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../shared/widgets/customer_provider_availability_calendar.dart';
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
  final TextEditingController _areaSearchController = TextEditingController();
  bool _isLoading = true;
  String _sortBy = 'distance'; // rating, price, distance
  double _minRating = 0;
  double _selectedRadiusKm = 10;
  static const double _minRadiusKm = 1;
  static const double _maxRadiusKm = 50;
  /// `__auto__` = venue + saved city; `__all__` = no city filter; else a city from [AppCities].
  String _cityFilterMode = '__auto__';
  List<FirebaseProviderModel>? _cachedProviders;
  double? _searchOriginLat;
  double? _searchOriginLng;
  String? _resolvedSearchCity;
  String? _resolvedSearchLabel;
  Timer? _searchDebounce;

  double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  bool _hasValidCoordinates(sp.ServiceProvider p) {
    return p.location.latitude.abs() > 0.0001 || p.location.longitude.abs() > 0.0001;
  }

  bool _matchesAreaText(sp.ServiceProvider p, String areaText) {
    final q = areaText.trim().toLowerCase();
    if (q.isEmpty) return false;
    final city = p.location.city.toLowerCase();
    final address = p.location.address.toLowerCase();
    final state = p.location.state.toLowerCase();
    final areas = p.serviceAreas.map((e) => e.toLowerCase()).join(' ');
    return city.contains(q) ||
        q.contains(city) ||
        address.contains(q) ||
        state.contains(q) ||
        areas.contains(q);
  }

  @override
  void initState() {
    super.initState();
    _searchOriginLat = (widget.bookingData['venueLatitude'] as num?)?.toDouble();
    _searchOriginLng = (widget.bookingData['venueLongitude'] as num?)?.toDouble();
    final venueAddress = widget.bookingData['venueAddress']?.toString().trim() ?? '';
    if (venueAddress.isNotEmpty) {
      _areaSearchController.text = venueAddress;
      _resolvedSearchLabel = venueAddress;
    }
    _loadProviders();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _areaSearchController.dispose();
    super.dispose();
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
              bankName: p.bankDetails!.bankName,
              countryCode: p.bankDetails!.countryCode,
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
  Future<void> _loadProviders({String? cityHint}) async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final eventType = widget.bookingData['eventType'] as String?;
      final eventTypes =
          eventType != null && eventType.isNotEmpty ? [eventType] : null;
      final minR = _minRating > 0 ? _minRating : null;

      String? cityForQuery;
      if (_cityFilterMode == '__auto__') {
        String? city = cityHint ?? _resolvedSearchCity ?? widget.bookingData['venueCity'] as String?;
        if (city == null || city.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          city = prefs.getString('selected_city');
        }
        cityForQuery = city;
      } else if (_cityFilterMode == '__all__') {
        cityForQuery = null;
      } else {
        cityForQuery = _cityFilterMode;
      }

      var providers = await _firestoreService.getProviders(
        city: cityForQuery,
        isActive: true,
        isVerified: true,
        verificationStatus: 'approved',
        eventTypes: eventTypes,
        minRating: minR,
      );

      if (providers.isEmpty && _cityFilterMode == '__auto__') {
        providers = await _firestoreService.getProviders(
          isActive: true,
          isVerified: true,
          verificationStatus: 'approved',
          eventTypes: eventTypes,
          minRating: minR,
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

  Future<void> _resolveAndSearchArea(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return;
    try {
      final locations = await locationFromAddress(trimmed);
      if (locations.isEmpty) return;
      final first = locations.first;
      final placemarks = await placemarkFromCoordinates(
        first.latitude,
        first.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final city = placemark?.locality?.trim().isNotEmpty == true
          ? placemark!.locality!.trim()
          : (placemark?.subAdministrativeArea?.trim().isNotEmpty == true
              ? placemark!.subAdministrativeArea!.trim()
              : null);
      if (!mounted) return;
      setState(() {
        _searchOriginLat = first.latitude;
        _searchOriginLng = first.longitude;
        _resolvedSearchCity = city;
        _resolvedSearchLabel = trimmed;
      });
      await _loadProviders(cityHint: city);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find that area. Try a nearby landmark.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build provider list from Firebase providers cached in state (loaded in _loadProviders)
    final venueLat = _searchOriginLat;
    final venueLng = _searchOriginLng;

    List<sp.ServiceProvider> providers = (_cachedProviders ?? [])
        .map(_mapFirebaseToServiceProvider)
        .where((p) => p.isActive && p.isVerified)
        .toList();

    // Safety fallback: keep this screen bookable even if backend list is empty.
    if (providers.isEmpty) {
      var mockList = MockProviders.allProviders
          .where((p) => p.isActive && p.isVerified)
          .toList();
      if (_cityFilterMode != '__auto__' && _cityFilterMode != '__all__') {
        mockList = mockList
            .where((p) => p.location.city == _cityFilterMode)
            .toList();
      }
      if (_minRating > 0) {
        mockList = mockList.where((p) => p.rating >= _minRating).toList();
      }
      providers = mockList;
    }

    final distanceByProvider = <String, double>{};
    if (venueLat != null && venueLng != null) {
      final areaText = _areaSearchController.text;
      providers = providers.where((p) {
        if (!_hasValidCoordinates(p)) {
          // Provider without geo-point: fallback to text/city/service-area matching.
          return _matchesAreaText(p, areaText) ||
              (_resolvedSearchCity != null &&
                  _matchesAreaText(p, _resolvedSearchCity!));
        }
        final d = _distanceKm(
          venueLat,
          venueLng,
          p.location.latitude,
          p.location.longitude,
        );
        distanceByProvider[p.providerId] = d;
        final providerMaxRadius = p.serviceRadius > 0
            ? p.serviceRadius.toDouble()
            : _maxRadiusKm;
        return d <= _selectedRadiusKm && d <= providerMaxRadius;
      }).toList();
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
    } else if (_sortBy == 'distance') {
      providers.sort((a, b) {
        final ad = distanceByProvider[a.providerId] ?? double.infinity;
        final bd = distanceByProvider[b.providerId] ?? double.infinity;
        return ad.compareTo(bd);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _areaSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search area (e.g., Siddipet, Hyderabad, London)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () => _resolveAndSearchArea(_areaSearchController.text),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                      _resolveAndSearchArea(value);
                    });
                  },
                  onSubmitted: _resolveAndSearchArea,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${providers.length} providers found',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    _buildSortChip('Rating', 'rating', Icons.star),
                    const SizedBox(width: 8),
                    _buildSortChip('Price', 'price', Icons.currency_rupee),
                    const SizedBox(width: 8),
                    _buildSortChip('Distance', 'distance', Icons.near_me),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _locationFilterSummary(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (venueLat != null && venueLng != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search radius: ${_selectedRadiusKm.toStringAsFixed(0)} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Slider(
                        value: _selectedRadiusKm,
                        min: _minRadiusKm,
                        max: _maxRadiusKm,
                        divisions: (_maxRadiusKm - _minRadiusKm).toInt(),
                        label: '${_selectedRadiusKm.toStringAsFixed(0)} km',
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _selectedRadiusKm = value);
                        },
                      ),
                    ],
                  ),
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
                              distanceKm: distanceByProvider[provider.providerId],
                              onTap: () async {
                                final updatedData =
                                    Map<String, dynamic>.from(widget.bookingData);
                                updatedData['providerId'] = provider.providerId;
                                final eventDate = updatedData['eventDate'];
                                if (eventDate is DateTime &&
                                    _cachedProviders != null) {
                                  try {
                                    final fbModel = _cachedProviders!.firstWhere(
                                      (p) => p.providerId == provider.providerId,
                                    );
                                    final occupied =
                                        await _firestoreService
                                            .getProviderOccupiedDateKeys(
                                      provider.providerId,
                                    );
                                    if (!mounted) return;
                                    if (!isDateAvailableForProvider(
                                      fbModel,
                                      eventDate,
                                      occupied,
                                    )) {
                                      final picked =
                                          await showPickAvailableBookingDateDialog(
                                        context: context,
                                        providerId: provider.providerId,
                                        initialDate: eventDate,
                                      );
                                      if (picked == null) return;
                                      final occ2 = await _firestoreService
                                          .getProviderOccupiedDateKeys(
                                              provider.providerId);
                                      if (!mounted) return;
                                      if (!isDateAvailableForProvider(
                                        fbModel,
                                        picked,
                                        occ2,
                                      )) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'That date is not available. Pick another.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      updatedData['eventDate'] = picked;
                                    }
                                  } catch (_) {
                                    // Missing in cache — continue to portfolio; summary/CF will enforce.
                                  }
                                }
                                if (!mounted) return;
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

  String _locationFilterSummary() {
    final areaLabel = _resolvedSearchLabel?.trim() ?? '';
    if (areaLabel.isNotEmpty) {
      return 'Near $areaLabel | Radius: ${_selectedRadiusKm.toInt()} km';
    }
    switch (_cityFilterMode) {
      case '__auto__':
        return 'Location: booking venue / saved city';
      case '__all__':
        return 'Location: all cities';
      default:
        return 'Location: $_cityFilterMode';
    }
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
    var tempCity = _cityFilterMode;
    var tempRating = _minRating;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: tempCity,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: '__auto__',
                        child: Text('Match booking & saved city'),
                      ),
                      const DropdownMenuItem(
                        value: '__all__',
                        child: Text('All locations'),
                      ),
                      ...AppCities.customerFilterCities.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() => tempCity = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Minimum rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Slider(
                value: tempRating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppColors.primary,
                label: tempRating > 0 ? tempRating.toStringAsFixed(1) : 'Any',
                onChanged: (value) {
                  setModalState(() => tempRating = value);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cityFilterMode = tempCity;
                      _minRating = tempRating;
                    });
                    Navigator.pop(context);
                    _loadProviders();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply filters',
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

