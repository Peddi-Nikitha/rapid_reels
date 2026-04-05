import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/constants/app_cities.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_offer_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../providers/presentation/screens/provider_details_screen.dart';
import '../../../../shared/widgets/glass_surface_card.dart';
import '../../../../shared/widgets/premium_home_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// After showing the offer popup, suppress again for this long.
  static const Duration _homePromoCooldown = Duration(days: 7);
  static const String _kOfferLastShownMs = 'home_offer_last_shown_ms';
  static const String _kLegacyOfferSeen = 'home_offer_seen';

  bool _isWithinHomePromoCooldown(int? lastShownMs) {
    if (lastShownMs == null) return false;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(lastShownMs),
        ) <
        _homePromoCooldown;
  }

  Future<int?> _offerLastShownMs(SharedPreferences prefs) async {
    final existing = prefs.getInt(_kOfferLastShownMs);
    if (existing != null) return existing;
    final legacy = prefs.getBool(_kLegacyOfferSeen) ?? false;
    if (legacy) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_kOfferLastShownMs, now);
      return now;
    }
    return null;
  }

  int _currentBannerIndex = 0;
  int _currentReviewIndex = 0;
  String _selectedCity = 'Detecting...';
  bool _showOfferPopup = false;
  /// First active offer for the home promo modal (image + copy from Firestore).
  FirebaseOfferModel? _promoPopupOffer;

  // Location and nearby providers state
  final _firestoreService = FirestoreService();

  // Firebase-driven promotional banner content.
  List<Map<String, String>> _bannerItems = [];

  // Firebase-driven customer reviews (formatted for existing review UI).
  List<Map<String, dynamic>> _cityReviews = [];

  List<FirebaseProviderModel> _nearbyProviders = [];
  bool _isLoadingVenues = false;
  List<FirebaseProviderModel> _featuredProviders = [];
  bool _isLoadingProviders = false;
  List<FirebaseReelModel> _trendingReels = [];
  final Map<String, bool> _likedReels = {};

  /// Minimum rating for nearby + featured provider strips; `null` = no floor.
  double? _providerRatingMin = 3.5;

  List<String> get _cities => AppCities.customerFilterCities;

  @override
  void initState() {
    super.initState();
    _checkOfferPopup();
    // Get location first, then load saved city as fallback
    _getCurrentLocation();
    _loadFeaturedProviders();
    _loadTrendingReels();
    _loadHomeBanners();
    _loadPromoPopupOffer();
  }

  Future<void> _loadPromoPopupOffer() async {
    try {
      final offers = await _firestoreService.getActiveOffers();
      if (!mounted) return;
      setState(() {
        _promoPopupOffer = offers.isNotEmpty ? offers.first : null;
      });
    } catch (e) {
      debugPrint('Error loading promo popup offer: $e');
    }
  }

  String _promoDiscountLine(FirebaseOfferModel o) {
    final d = o.discount;
    final t = o.type.toLowerCase();
    if (t.contains('percentage') || (d.percentage != null && d.percentage! > 0)) {
      return '${d.percentage!.toStringAsFixed(0)}% off your booking';
    }
    if (d.amount != null && d.amount! > 0) {
      return '£${d.amount!.toStringAsFixed(0)} off your booking';
    }
    return 'Limited-time offer';
  }

  Future<void> _loadTrendingReels() async {
    try {
      final reels = await _firestoreService.getDiscoverReels(limit: 10);
      if (!mounted) return;
      final uid = ref.read(currentUserProvider)?.uid;
      setState(() {
        _trendingReels = reels;
        if (uid != null) {
          final ids = reels.map((r) => r.reelId).toSet();
          _likedReels.removeWhere((k, _) => !ids.contains(k));
          for (final r in reels) {
            _likedReels[r.reelId] = r.isLikedByUser(uid);
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _loadHomeBanners() async {
    if (!mounted) return;
    setState(() {
      _bannerItems = [];
      _currentBannerIndex = 0;
    });
    try {
      final fallbackImages = [
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
      ];

      final offers = await _firestoreService.getActiveOffers();
      final top = offers.take(2).toList();

      final mapped = <Map<String, String>>[];
      for (var i = 0; i < top.length; i++) {
        final offer = top[i];
        final desc = (offer.description ?? '').trim();
        final text =
            desc.isNotEmpty ? '${offer.title}\n$desc' : offer.title;
        mapped.add({
          'text': text,
          'imageUrl': (offer.imageUrl ?? '').trim().isNotEmpty
              ? (offer.imageUrl ?? '')
              : fallbackImages[i % fallbackImages.length],
        });
      }

      if (!mounted) return;
      setState(() {
        _bannerItems = mapped;
        _currentBannerIndex = 0;
      });
    } catch (e) {
      debugPrint('Error loading home banners: $e');
      if (!mounted) return;
      setState(() {
        _bannerItems = [];
        _currentBannerIndex = 0;
      });
    }
  }

  Future<void> _checkOfferPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = await _offerLastShownMs(prefs);
      if (_isWithinHomePromoCooldown(lastShown)) return;
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _showOfferPopup = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking offer: $e');
    }
  }


  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _selectedCity = 'Detecting location...';
    });
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        _handleLocationError('Location services are disabled. Please enable location services.');
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied by user');
          _handleLocationError('Location permission denied. Showing default location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        _handleLocationError('Location permission denied. Please enable it in app settings.');
        return;
      }

      // Get current position
      debugPrint('Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        debugPrint('Location obtained: ${position.latitude}, ${position.longitude}');
        
        // Reverse geocode to get city name
        await _getCityFromLocation(position.latitude, position.longitude);
        
        // Load nearby providers with detected city
        _loadNearbyVenues();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _handleLocationError('Unable to detect location. Using default.');
    }
  }

  Future<void> _getCityFromLocation(double latitude, double longitude) async {
    try {
      debugPrint('Reverse geocoding location: $latitude, $longitude');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String? cityName = placemark.locality ?? 
                          placemark.subAdministrativeArea ?? 
                          placemark.administrativeArea ??
                          placemark.name;
        
        // If city name is available, use it; otherwise try to find a better match
        if (cityName != null && cityName.isNotEmpty) {
          // Clean up city name (remove extra spaces, etc.)
          cityName = cityName.trim();
          
          // Check if it matches any of our known cities
          String? matchedCity = _findMatchingCity(cityName);
          
          final finalCityName = matchedCity ?? cityName;
          
          debugPrint('Detected city: $finalCityName');
          
          if (mounted && finalCityName.isNotEmpty) {
            setState(() {
              _selectedCity = finalCityName;
            });
            _loadFeaturedProviders();
            // Save detected city to preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selected_city', finalCityName);
            await prefs.setDouble('last_latitude', latitude);
            await prefs.setDouble('last_longitude', longitude);
          }
        } else {
          debugPrint('City name not found in placemark');
          _loadFallbackCity();
        }
      } else {
        debugPrint('No placemarks found');
        _loadFallbackCity();
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      _loadFallbackCity();
    }
  }

  String? _findMatchingCity(String cityName) {
    // Try to match with known cities (case-insensitive)
    for (String city in _cities) {
      if (cityName.toLowerCase().contains(city.toLowerCase()) || 
          city.toLowerCase().contains(cityName.toLowerCase())) {
        return city;
      }
    }
    return null;
  }

  void _loadFallbackCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('selected_city');
      
      if (savedCity != null && savedCity.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedCity = savedCity;
          });
          _loadFeaturedProviders();
          _loadNearbyVenues();
        }
      } else {
        // Use default city
        if (mounted) {
          setState(() {
            _selectedCity = 'Siddipet';
          });
          _loadFeaturedProviders();
          _loadNearbyVenues();
        }
      }
    } catch (e) {
      debugPrint('Error loading fallback city: $e');
      if (mounted) {
        setState(() {
          _selectedCity = 'Siddipet';
        });
      }
    }
  }

  void _handleLocationError(String message) {
    debugPrint(message);
    _loadFallbackCity();
  }

  Future<void> _loadFeaturedProviders() async {
    if (!mounted) return;
    setState(() => _isLoadingProviders = true);
    try {
      final city = _selectedCity;
      final effectiveCity = (city == 'Detecting...' || city.startsWith('Detecting'))
          ? null
          : city;
      var list = await _firestoreService.getFeaturedProviders(city: effectiveCity);
      if (_providerRatingMin != null) {
        list = list.where((p) => p.rating >= _providerRatingMin!).toList();
      }
      if (!mounted) return;
      setState(() {
        _featuredProviders = list;
        _isLoadingProviders = false;
      });
      _loadCityReviews();
    } catch (e) {
      debugPrint('Error loading featured providers: $e');
      if (mounted) {
        setState(() {
          _featuredProviders = [];
          _isLoadingProviders = false;
        });
      }
    }
  }

  Future<void> _loadCityReviews() async {
    if (!mounted) return;
    final city = _selectedCity.trim();
    if (city.isEmpty || city == 'Detecting...' || city.startsWith('Detecting')) {
      return;
    }

    setState(() {
      _cityReviews = [];
      _currentReviewIndex = 0;
    });

    try {
      final approved = await _firestoreService.getApprovedPublicReviews(limit: 80);
      if (!mounted) return;

      final providerIds = approved.map((r) => r.providerId).toSet().toList();
      final providers = await Future.wait(
        providerIds.map((id) => _firestoreService.getProvider(id)),
      );

      final providerById = <String, FirebaseProviderModel?>{};
      for (var i = 0; i < providerIds.length; i++) {
        providerById[providerIds[i]] = providers[i];
      }

      final cityLower = city.toLowerCase();

      final formatted = <Map<String, dynamic>>[];
      for (final review in approved) {
        final provider = providerById[review.providerId];
        final providerCity =
            (provider?.location.city ?? '').toLowerCase().trim();
        if (providerCity != cityLower) continue;

        final rating = review.rating > 0 ? review.rating : review.categories.averageRating;
        final reviewText = (review.comment ??
                review.title ??
                review.response ??
                '')
            .toString()
            .trim();

        final reviewerName = (provider?.businessName ??
                provider?.ownerName ??
                'Customer')
            .toString()
            .trim();

        final reviewerImage = provider?.profileImage ?? '';
        final reviewerRole = (provider?.eventTypes.isNotEmpty ?? false)
            ? provider!.eventTypes.first
            : 'Customer';

        if (reviewText.isEmpty) continue;

        formatted.add({
          'rating': rating,
          'review': reviewText,
          'reviewerName': reviewerName.isNotEmpty ? reviewerName : 'Customer',
          'reviewerRole': reviewerRole,
          'reviewerImage': reviewerImage,
        });

        if (formatted.length >= 10) break;
      }

      if (!mounted) return;
      setState(() {
        _cityReviews = formatted;
      });
    } catch (e) {
      debugPrint('Error loading city reviews: $e');
      if (!mounted) return;
      setState(() {
        _cityReviews = [];
      });
    }
  }

  Future<void> _loadNearbyVenues() async {
    if (!mounted) return;
    
    setState(() => _isLoadingVenues = true);
    
    try {
      final city = _selectedCity;
      // Avoid querying with placeholder text
      final effectiveCity = (city == 'Detecting...' || city.startsWith('Detecting'))
          ? null
          : city;

      debugPrint('Loading nearby photography providers for city: $effectiveCity');

      final providers = await _firestoreService.getProviders(
        city: effectiveCity,
        eventTypes: const ['photography', 'photo', 'studio'],
        minRating: _providerRatingMin,
        isActive: true,
        verificationStatus: 'approved',
      );

      if (!mounted) return;
      setState(() {
        _nearbyProviders = providers;
        _isLoadingVenues = false;
      });
    } catch (e) {
      debugPrint('Error loading nearby providers: $e');
      if (mounted) {
        setState(() {
          _isLoadingVenues = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: PremiumHomeBackground()),
          SafeArea(
            child: CustomScrollView(
          slivers: [
            // Header Section - Clean & Simplified
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar - Greeting, City Selector, and Notification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Greeting and City Selector Combined
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.greeting,
                                      style: AppTypography.captionLarge.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedCity,
                                      style: AppTypography.headlineMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Compact City Selector
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showCityPicker(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: GlassSurfaceCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    blurSigma: 8,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Notification Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: GlassSurfaceCard(
                                borderRadius: BorderRadius.circular(22),
                                blurSigma: 8,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_outlined,
                                      size: 22,
                                      color: AppColors.textPrimary,
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.surface,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Title
                    Text(
                      AppStrings.homeTitle,
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Promotional banner — one grouped section (carousel + dots + Book Now)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassSurfaceCard(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.homeBannerSectionTitle,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CarouselSlider(
                        items: (_bannerItems.isNotEmpty
                            ? _bannerItems
                                .map(
                                  (b) => _buildPromoBanner(
                                    b['text'] ?? '',
                                    b['imageUrl'] ?? '',
                                  ),
                                )
                                .toList()
                            : [
                                _buildPromoBanner(
                                  'Your reel\'s ready\nbefore the vibe fades.',
                                  'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
                                ),
                                _buildPromoBanner(
                                  'Capture memories\nthat last forever.',
                                  'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
                                ),
                              ]),
                        options: CarouselOptions(
                          height: 160,
                          viewportFraction: 0.92,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 600),
                          enlargeCenterPage: false,
                          onPageChanged: (index, reason) {
                            setState(() => _currentBannerIndex = index);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _bannerItems.isNotEmpty ? _bannerItems.length : 2,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentBannerIndex == index ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentBannerIndex == index
                                  ? AppColors.primary
                                  : AppColors.textTertiary
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHomeBookNowButton(),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Trending Reels Section - Refined
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.trendingReels,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('${AppRoutes.discover}/trending'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            AppStrings.viewAll,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _trendingReels.length,
                      itemBuilder: (context, index) {
                        final reel = _trendingReels[index];
                        return _buildTrendingReelCard(reel, index);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(child: _buildProviderRatingFilterStrip()),

            // Nearby Vendors Section - Location Based
            SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Nearby Photography Studios',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (_nearbyProviders.isNotEmpty)
                            TextButton(
                              onPressed: () => context.push(AppRoutes.discover),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              child: Text(
                                AppStrings.viewAll,
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingVenues)
                      SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (_nearbyProviders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.cardBackground.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_off_rounded,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No photography studios found nearby',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _nearbyProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _nearbyProviders[index];
                            return _buildProviderCard(provider);
                          },
                        ),
                      ),
                  ],
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Featured Providers Section - Refined
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Featured Providers',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.discover),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            AppStrings.viewAll,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: _isLoadingProviders
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _featuredProviders.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    'No providers in $_selectedCity yet',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _featuredProviders.length,
                                itemBuilder: (context, index) {
                                  final provider = _featuredProviders[index];
                                  return _buildProviderCard(provider);
                                },
                              ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Customer Reviews Section - City Based
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'What Our Customers Say',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Review Card with PageView
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentReviewIndex = index;
                        });
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildReviewCard(_selectedCity, index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentReviewIndex == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentReviewIndex == index
                              ? AppColors.primary
                              : AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Illustration Section with Branding
                  _buildBrandingSection(_selectedCity),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
            ),
          ),
          if (_showOfferPopup)
            Positioned.fill(
              child: _buildOfferPopup(),
            ),
        ],
      ),
    );
  }

  /// Primary booking CTA below the promo banner (replaces the old Quick Actions row).
  Widget _buildHomeBookNowButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBookingDialog(),
        borderRadius: BorderRadius.circular(18),
        child: GlassSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: BorderRadius.circular(18),
          gradient: AppColors.primaryGradient,
          borderColor: AppColors.homeGlowCyan.withValues(alpha: 0.45),
          boxShadow: [
            BoxShadow(
              color: AppColors.homeGlowCyan.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_rounded, color: AppColors.onPrimary, size: 26),
              const SizedBox(width: 12),
              Text(
                AppStrings.bookNow,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(String text, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeGlowMagenta.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Network Image Background
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.error_outline, color: Colors.white),
              ),
            ),
            // Refined Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.homeGlowCyan.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Text Content - Refined
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewReel(FirebaseReelModel reel, int index) {
    if (index < 0 || index >= _trendingReels.length) return;
    context
        .push(
      AppRoutes.reelPlayer,
      extra: {
        'reelId': reel.reelId,
        'reels': List<FirebaseReelModel>.from(_trendingReels),
        'initialIndex': index,
      },
    )
        .then((_) {
      if (mounted) _loadTrendingReels();
    });
  }

  void _mergeTrendingReel(FirebaseReelModel? fresh) {
    if (fresh == null || !mounted) return;
    final uid = ref.read(currentUserProvider)?.uid;
    setState(() {
      final i = _trendingReels.indexWhere((r) => r.reelId == fresh.reelId);
      if (i >= 0) _trendingReels[i] = fresh;
      if (uid != null) _likedReels[fresh.reelId] = fresh.isLikedByUser(uid);
    });
  }

  Future<void> _handleReelLike(FirebaseReelModel reel) async {
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like reels.')),
      );
      return;
    }

    final reelId = reel.reelId;
    final previousLiked =
        _likedReels[reelId] ?? reel.isLikedByUser(userId);
    setState(() => _likedReels[reelId] = !previousLiked);

    try {
      final backendLiked = await _firestoreService.toggleReelLike(
        reelId: reelId,
        userId: userId,
      );
      if (!mounted) return;
      final fresh = await _firestoreService.getReel(reelId);
      setState(() {
        _likedReels[reelId] = backendLiked;
        if (fresh != null) {
          final i = _trendingReels.indexWhere((r) => r.reelId == reelId);
          if (i >= 0) _trendingReels[i] = fresh;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _likedReels[reelId] = previousLiked);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like right now.')),
      );
    }
  }

  Future<void> _showCommentBottomSheet(FirebaseReelModel reel) async {
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment on reels.')),
      );
      return;
    }

    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a comment',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final commentText = controller.text.trim();
                    if (commentText.isEmpty) return;

                    try {
                      await _firestoreService.addReelComment(
                        reelId: reel.reelId,
                        userId: userId,
                        commentText: commentText,
                      );
                      if (!mounted) return;
                      final fresh = await _firestoreService.getReel(reel.reelId);
                      _mergeTrendingReel(fresh);
                      Navigator.of(sheetContext).pop();
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not post comment right now.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _handleReelShare(FirebaseReelModel reel) async {
    final deepLink = 'https://rapidreels.app/reel/${reel.reelId}';
    await Clipboard.setData(ClipboardData(text: deepLink));

    try {
      await _firestoreService.incrementReelShares(reel.reelId);
      if (!mounted) return;
      final fresh = await _firestoreService.getReel(reel.reelId);
      _mergeTrendingReel(fresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update share count right now.')),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reel link copied. Share it with others.')),
    );
  }

  Widget _buildTrendingReelCard(FirebaseReelModel reel, int index) {
    final reelId = reel.reelId;
    final uid = ref.read(currentUserProvider)?.uid;
    final isLiked = _likedReels.containsKey(reelId)
        ? _likedReels[reelId]!
        : (uid != null && reel.isLikedByUser(uid));
    final localLikes = reel.likes;
    final localComments = reel.analytics.comments;
    final localShares = reel.shares;

    return GestureDetector(
      onTap: () => _viewReel(reel, index),
      child: GlassSurfaceCard(
        margin: const EdgeInsets.only(right: 12),
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 140,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 179, maxHeight: 179),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 108,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getEventColorForType(reel.eventType).withValues(alpha: 0.5),
                                _getEventColorForType(reel.eventType),
                              ],
                            ),
                          ),
                        ),
                        if (reel.thumbnailUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: reel.thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                _getEventColorForType(reel.eventType).withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            reel.title.isNotEmpty ? reel.title : '${reel.eventType} Reel',
                            style: AppTypography.captionLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 9,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                _formatViews(reel.views),
                                style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildReelActionChip(
                              icon: isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              count: localLikes,
                              onTap: () => _handleReelLike(reel),
                              iconColor: isLiked ? Colors.redAccent : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            _buildReelActionChip(
                              icon: Icons.comment_outlined,
                              count: localComments,
                              onTap: () => _showCommentBottomSheet(reel),
                            ),
                            const SizedBox(width: 6),
                            _buildReelActionChip(
                              icon: Icons.share_outlined,
                              count: localShares,
                              onTap: () => _handleReelShare(reel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelActionChip({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 11,
                color: iconColor ?? AppColors.textSecondary,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  _formatViews(count),
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(FirebaseProviderModel provider) {
    final initials = provider.businessName.length >= 2
        ? provider.businessName.substring(0, 2).toUpperCase()
        : (provider.businessName.isNotEmpty ? provider.businessName.toUpperCase() : 'PR');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailsScreen(providerId: provider.providerId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: GlassSurfaceCard(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 280,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(
                      color: AppColors.cardBackground.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: provider.profileImage.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: provider.profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _providerInitialsFallback(initials),
                            errorWidget: (context, url, error) =>
                                _providerInitialsFallback(initials),
                          ),
                        )
                      : _providerInitialsFallback(initials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.businessName,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF1DA1F2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${provider.totalReviews} reviews',
                              style: AppTypography.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${provider.totalEventsCompleted}+ events',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _providerInitialsFallback(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Color _getEventColorForType(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return AppColors.wedding;
      case 'birthday':
        return AppColors.birthday;
      case 'engagement':
        return AppColors.engagement;
      case 'corporate':
        return AppColors.corporate;
      case 'other':
        return AppColors.other;
      default:
        return AppColors.primary;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._cities.map((city) {
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(city),
                  trailing: _selectedCity == city
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
                      _currentReviewIndex = 0; // Reset review index when city changes
                    });
                    _loadFeaturedProviders();
                    _loadNearbyVenues();
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderRatingFilterStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider rating',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ratingChoiceChip('Any', null),
                const SizedBox(width: 8),
                _ratingChoiceChip('3.5+', 3.5),
                const SizedBox(width: 8),
                _ratingChoiceChip('4+', 4.0),
                const SizedBox(width: 8),
                _ratingChoiceChip('4.5+', 4.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingChoiceChip(String label, double? value) {
    final selected = _providerRatingMin == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool next) {
        if (!next) return;
        _onProviderRatingFilterChanged(value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.35),
      labelStyle: TextStyle(
        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  void _onProviderRatingFilterChanged(double? min) {
    setState(() => _providerRatingMin = min);
    _loadNearbyVenues();
    _loadFeaturedProviders();
  }

  void _showBookingDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Book',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your event type to get started',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickBookCard('Wedding', Icons.favorite, AppColors.wedding),
                  _buildQuickBookCard('Birthday', Icons.cake, AppColors.birthday),
                  _buildQuickBookCard('Engagement', Icons.diamond, AppColors.engagement),
                  _buildQuickBookCard('Corporate', Icons.business, AppColors.corporate),
                  _buildQuickBookCard('Other', Icons.more_horiz, AppColors.other),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickBookCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateToBooking(title);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.3),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBooking(String eventType) {
    final eventTypeMap = {
      'Wedding': 'wedding',
      'Birthday': 'birthday',
      'Engagement': 'engagement',
      'Corporate': 'corporate',
      'Other': 'other',
      'Brand Collaboration': 'brand',
    };
    
    final eventTypeKey = eventTypeMap[eventType] ?? eventType.toLowerCase();
    
    debugPrint('Navigating to package selection with eventType: $eventTypeKey');
    
    try {
      context.push(
        AppRoutes.packageSelection,
        extra: {'eventType': eventTypeKey},
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback: try with go_router directly
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Get city-based review data
  Map<String, dynamic> _getCityReview(String city, int index) {
    if (_cityReviews.isNotEmpty) {
      return _cityReviews[index % _cityReviews.length];
    }
    final allCityReviews = {
      'Siddipet': [
        {
          'rating': 4.5,
          'review': 'The partner team was incredibly professional and punctual. They made the entire shoot smooth and stress-free.',
          'reviewerName': 'Sai Ram',
          'reviewerRole': 'Brand Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=12',
        },
        {
          'rating': 5.0,
          'review': 'Excellent service! The reels were ready in record time and the quality was outstanding.',
          'reviewerName': 'Ravi Kumar',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=13',
        },
        {
          'rating': 4.8,
          'review': 'Amazing experience! Professional team and beautiful output. Highly recommended!',
          'reviewerName': 'Lakshmi Devi',
          'reviewerRole': 'Engagement Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=14',
        },
      ],
      'Hyderabad': [
        {
          'rating': 5.0,
          'review': 'Amazing service! The reels were delivered before the event ended. Highly recommend!',
          'reviewerName': 'Priya Sharma',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=47',
        },
        {
          'rating': 4.9,
          'review': 'Professional team with excellent editing skills. The final output was beyond expectations!',
          'reviewerName': 'Amit Verma',
          'reviewerRole': 'Corporate Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=48',
        },
        {
          'rating': 5.0,
          'review': 'Best service in Hyderabad! Quick delivery and amazing quality. Will definitely use again.',
          'reviewerName': 'Sunita Reddy',
          'reviewerRole': 'Birthday Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=49',
        },
      ],
      'Warangal': [
        {
          'rating': 4.8,
          'review': 'Professional team with great attention to detail. The final output exceeded our expectations.',
          'reviewerName': 'Rajesh Kumar',
          'reviewerRole': 'Corporate Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=33',
        },
        {
          'rating': 4.9,
          'review': 'Excellent service! The team was punctual and the reels were delivered on time.',
          'reviewerName': 'Meera Singh',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=34',
        },
        {
          'rating': 5.0,
          'review': 'Outstanding quality and super fast delivery. Made our event truly special!',
          'reviewerName': 'Vikram Rao',
          'reviewerRole': 'Engagement Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=35',
        },
      ],
      'Karimnagar': [
        {
          'rating': 4.7,
          'review': 'Quick delivery and excellent quality. The team captured all the special moments beautifully.',
          'reviewerName': 'Anjali Reddy',
          'reviewerRole': 'Birthday Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=20',
        },
        {
          'rating': 4.8,
          'review': 'Great experience! Professional team and beautiful reels. Highly recommended!',
          'reviewerName': 'Suresh Kumar',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=21',
        },
        {
          'rating': 5.0,
          'review': 'Amazing service! The reels were ready before we expected. Excellent quality!',
          'reviewerName': 'Kavitha Devi',
          'reviewerRole': 'Brand Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=22',
        },
      ],
      'Visakhapatnam': [
        {
          'rating': 5.0,
          'review': 'Outstanding service! The reels were cinematic and ready in no time. Truly impressed!',
          'reviewerName': 'Vikram Singh',
          'reviewerRole': 'Engagement Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=15',
        },
        {
          'rating': 4.9,
          'review': 'Best in Visakhapatnam! Professional team and amazing output quality.',
          'reviewerName': 'Priyanka Naidu',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=16',
        },
        {
          'rating': 4.8,
          'review': 'Excellent service! Quick delivery and beautiful reels. Highly satisfied!',
          'reviewerName': 'Ramesh Babu',
          'reviewerRole': 'Corporate Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=17',
        },
      ],
      'Mumbai': [
        {
          'rating': 4.9,
          'review': 'Best in the business! Professional, creative, and lightning fast delivery.',
          'reviewerName': 'Neha Patel',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=45',
        },
        {
          'rating': 5.0,
          'review': 'Outstanding quality! The team was professional and the reels were amazing.',
          'reviewerName': 'Rahul Shah',
          'reviewerRole': 'Brand Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=46',
        },
        {
          'rating': 4.8,
          'review': 'Great service! Quick delivery and excellent editing. Highly recommended!',
          'reviewerName': 'Pooja Desai',
          'reviewerRole': 'Birthday Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=44',
        },
      ],
      'Chennai': [
        {
          'rating': 4.6,
          'review': 'Great experience from start to finish. The team was friendly and the output was fantastic.',
          'reviewerName': 'Arjun Menon',
          'reviewerRole': 'Corporate Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=28',
        },
        {
          'rating': 4.8,
          'review': 'Excellent service! Professional team and beautiful reels. Very satisfied!',
          'reviewerName': 'Divya Iyer',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=29',
        },
        {
          'rating': 5.0,
          'review': 'Amazing quality and super fast delivery. Made our event truly memorable!',
          'reviewerName': 'Karthik Raman',
          'reviewerRole': 'Engagement Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=30',
        },
      ],
      'Bangalore': [
        {
          'rating': 4.8,
          'review': 'Excellent service! The reels were ready before we even expected. Highly professional team.',
          'reviewerName': 'Sneha Iyer',
          'reviewerRole': 'Brand Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=52',
        },
        {
          'rating': 4.9,
          'review': 'Outstanding quality! The team was punctual and the output exceeded expectations.',
          'reviewerName': 'Rohit Nair',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=53',
        },
        {
          'rating': 5.0,
          'review': 'Best service in Bangalore! Quick delivery and amazing quality. Will use again!',
          'reviewerName': 'Ananya Rao',
          'reviewerRole': 'Birthday Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=54',
        },
      ],
      'Vijayawada': [
        {
          'rating': 4.7,
          'review': 'Amazing quality and super fast delivery. Made our event memorable with beautiful reels.',
          'reviewerName': 'Kiran Rao',
          'reviewerRole': 'Wedding Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=38',
        },
        {
          'rating': 4.8,
          'review': 'Excellent service! Professional team and beautiful output. Highly recommended!',
          'reviewerName': 'Srinivas Reddy',
          'reviewerRole': 'Corporate Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=39',
        },
        {
          'rating': 5.0,
          'review': 'Outstanding quality! The reels were ready in record time. Truly impressed!',
          'reviewerName': 'Lakshmi Priya',
          'reviewerRole': 'Engagement Event',
          'reviewerImage': 'https://i.pravatar.cc/150?img=40',
        },
      ],
    };

    final cityReviews = allCityReviews[city] ?? allCityReviews['Siddipet']!;
    return cityReviews[index % cityReviews.length];
  }

  // Build Review Card
  Widget _buildReviewCard(String city, int index) {
    final review = _getCityReview(city, index);
    final rating = review['rating'] as double;

    return GlassSurfaceCard(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              if (index < rating.floor()) {
                return const Icon(
                  Icons.star_rounded,
                  color: AppColors.homeGlowLime,
                  size: 24,
                );
              } else if (index < rating) {
                return const Icon(
                  Icons.star_half_rounded,
                  color: AppColors.homeGlowLime,
                  size: 24,
                );
              } else {
                return Icon(
                  Icons.star_outline_rounded,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                  size: 24,
                );
              }
            }),
          ),
          const SizedBox(height: 16),
          // Review Text
          Text(
            review['review'] as String,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Reviewer Info
          Row(
            children: [
              // Profile Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(
                    color: AppColors.cardBackground.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: review['reviewerImage'] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary,
                      child: Center(
                        child: Text(
                          (review['reviewerName'] as String).substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary,
                      child: Center(
                        child: Text(
                          (review['reviewerName'] as String).substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Reviewer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['reviewerName'] as String,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['reviewerRole'] as String,
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
          ),
    );
  }

  // Build Branding Section with Illustration
  Widget _buildBrandingSection(String city) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassSurfaceCard(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            Text(
              'Serving $city with\nInstant Reels',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildIllustrationIcon(Icons.videocam_rounded),
                _buildIllustrationIcon(Icons.camera_alt_rounded),
                _buildIllustrationIcon(Icons.movie_creation_rounded),
                _buildIllustrationIcon(Icons.play_circle_outline_rounded),
                _buildIllustrationIcon(Icons.favorite_border_rounded),
                _buildIllustrationIcon(Icons.share_rounded),
                _buildIllustrationIcon(Icons.rocket_launch_rounded),
                _buildIllustrationIcon(Icons.thumb_up_outlined),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Rapid Reels',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crafted with ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Icon(
                  Icons.favorite,
                  color: AppColors.homeGlowMagenta.withValues(alpha: 0.95),
                  size: 18,
                ),
                Text(
                  ' in India',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build Illustration Icon
  Widget _buildIllustrationIcon(IconData icon) {
    return Icon(
      icon,
      color: AppColors.homeGlowCyan.withValues(alpha: 0.45),
      size: 32,
    );
  }

  // Build Offer Popup
  Widget _buildOfferPopup() {
    final offer = _promoPopupOffer;
    final imageUrl = (offer?.imageUrl ?? '').trim();
    final title = offer?.title.trim().isNotEmpty == true
        ? offer!.title
        : 'Special offer';
    final subtitle = offer != null
        ? _promoDiscountLine(offer)
        : 'Get 20% off on your first booking';
    final desc = (offer?.description ?? '').trim();
    final code = (offer?.code ?? 'FLASH20').trim();

    return GestureDetector(
      onTap: () {
        setState(() {
          _showOfferPopup = false;
        });
        _saveOfferSeen();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.sizeOf(context).height * 0.88,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 168,
                          width: double.infinity,
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 800,
                                  filterQuality: FilterQuality.high,
                                  placeholder: (context, url) => Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildOfferPopupImageFallback(),
                                )
                              : _buildOfferPopupImageFallback(),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 22),
                              onPressed: () {
                                setState(() => _showOfferPopup = false);
                                _saveOfferSeen();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              desc,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.cardBackground
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Code ',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SelectableText(
                                  code,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _showOfferPopup = false);
                                _saveOfferSeen();
                                _showBookingDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Book now',
                                style: AppTypography.buttonLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _showOfferPopup = false);
                              _saveOfferSeen();
                            },
                            child: Text(
                              'Maybe later',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferPopupImageFallback() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.95),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.appName,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOfferSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _kOfferLastShownMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error saving offer seen: $e');
    }
  }
}

