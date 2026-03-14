import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/mock/mock_venues.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../providers/presentation/screens/provider_details_screen.dart';
import 'schedule_packages_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBannerIndex = 0;
  int _currentReviewIndex = 0;
  String _selectedCity = 'Detecting...';
  int _onboardingStep = 0;
  bool _showOnboarding = false;
  bool _showOfferPopup = false;
  
  // Location and nearby venues state
  final _mockData = MockDataService();
  LatLng _currentLocation = const LatLng(18.1023, 78.8514); // Default: Siddipet
  List<Venue> _nearbyVenues = [];
  bool _isLoadingVenues = false;

  final List<String> _cities = [
    // Indian Cities
    'Siddipet',
    'Hyderabad',
    'Warangal',
    'Karimnagar',
    'Visakhapatnam',
    'Mumbai',
    'Chennai',
    'Bangalore',
    'Vijayawada',
    'Delhi',
    'Kolkata',
    'Pune',
    // UK Cities
    'London',
    'Manchester',
    'Birmingham',
    'Liverpool',
    'Leeds',
    'Glasgow',
    'Edinburgh',
    'Bristol',
    'Cardiff',
    'Belfast',
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _checkOfferPopup();
    // Get location first, then load saved city as fallback
    _getCurrentLocation();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('home_onboarding_seen') ?? false;
      if (!hasSeenOnboarding) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _showOnboarding = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking onboarding: $e');
    }
  }

  Future<void> _checkOfferPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOffer = prefs.getBool('home_offer_seen') ?? false;
      if (!hasSeenOffer) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _showOfferPopup = true;
          });
        }
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
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        debugPrint('Location obtained: ${position.latitude}, ${position.longitude}');
        
        // Reverse geocode to get city name
        await _getCityFromLocation(position.latitude, position.longitude);
        
        // Load nearby venues with detected location
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
        }
      } else {
        // Use default city
        if (mounted) {
          setState(() {
            _selectedCity = 'Siddipet';
          });
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
    _loadNearbyVenues();
  }

  void _loadNearbyVenues() {
    if (!mounted) return;
    
    setState(() => _isLoadingVenues = true);
    
    try {
      // Increase radius to 25km to find more venues
      final allVenues = _mockData.getNearbyVenues(
        _currentLocation.latitude,
        _currentLocation.longitude,
        radiusKm: 25.0,
      );

      // Only keep photography studios for homepage nearby section
      final photographyVenues = allVenues.where((venue) {
        return venue.venueType == 'photography';
      }).toList();

      debugPrint('Loading nearby photography venues for location: ${_currentLocation.latitude}, ${_currentLocation.longitude}');
      debugPrint('Found ${photographyVenues.length} nearby photography venues');

      if (mounted) {
        setState(() {
          _nearbyVenues = photographyVenues;
          _isLoadingVenues = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading nearby venues: $e');
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.cardBackground.withValues(alpha: 0.5),
                                        width: 0.5,
                                      ),
                                    ),
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
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardBackground.withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              ),
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

            // Quick Actions - Equal-sized Horizontal Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.add_circle_rounded,
                        label: AppStrings.bookNow,
                        onTap: () => _showBookingDialog(),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.calendar_today_rounded,
                        label: AppStrings.schedule,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchedulePackagesScreen(),
                            ),
                          );
                        },
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Bookings',
                        onTap: () => context.push(AppRoutes.myEvents),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Refer',
                        onTap: () => _showReferralDialog(),
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Promotional Carousel - Refined
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CarouselSlider(
                      items: [
                        _buildPromoBanner(
                          'Your reel\'s ready\nbefore the vibe fades.',
                          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
                        ),
                        _buildPromoBanner(
                          'Capture memories\nthat last forever.',
                          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
                        ),
                      ],
                      options: CarouselOptions(
                        height: 160,
                        viewportFraction: 0.92,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration: const Duration(milliseconds: 600),
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          setState(() => _currentBannerIndex = index);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Refined Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentBannerIndex == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentBannerIndex == index
                              ? AppColors.primary
                              : AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ],
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
                          onPressed: () {},
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
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: MockDataService().getTrendingReels().length,
                      itemBuilder: (context, index) {
                        final reel = MockDataService().getTrendingReels()[index];
                        return _buildTrendingReelCard(reel);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

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
                          if (_nearbyVenues.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _showSnackbar('View all nearby photography studios');
                              },
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
                    else if (_nearbyVenues.isEmpty)
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
                          itemCount: _nearbyVenues.length,
                          itemBuilder: (context, index) {
                            final venue = _nearbyVenues[index];
                            return _buildVenueCard(venue);
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
                          onPressed: () => _showSnackbar('View all providers'),
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: MockDataService().getProvidersByCity(_selectedCity).length,
                      itemBuilder: (context, index) {
                        final provider = MockDataService().getProvidersByCity(_selectedCity)[index];
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
          // Onboarding Tutorial Overlay
          if (_showOnboarding) _buildOnboardingOverlay(),
          // Offer Popup
          if (_showOfferPopup) _buildOfferPopup(),
        ],
      ),
    );
  }

  // Unified Action Button Builder - Equal-sized horizontal buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surface.withValues(alpha: 0.7),
                          AppColors.surface.withValues(alpha: 0.5),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.cardBackground.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isPrimary ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: isPrimary
                        ? AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
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

  Widget _buildTrendingReelCard(dynamic reel) {
    return GestureDetector(
      onTap: () {
        _showSnackbar('Playing ${reel.eventType} reel...');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 140,
            constraints: const BoxConstraints(
              minHeight: 179,
              maxHeight: 179,
            ),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface.withValues(alpha: 0.7),
                  AppColors.surface.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardBackground.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video thumbnail - Reduced height to fit
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 108, // Reduced from 112 to 108
                width: double.infinity,
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
                child: Stack(
                  children: [
                    // Thumbnail image if available
                    if (reel.thumbnailUrl != null)
                      CachedNetworkImage(
                        imageUrl: reel.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, url, error) => Container(
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
                      ),
                    // Overlay
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
                    // Play Icon
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
                          size: 22, // Reduced from 24 to 22
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content - Ultra compact to prevent overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 6, 7, 6), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        reel.title ?? '${reel.eventType} Reel',
                        style: AppTypography.captionLarge.copyWith( // Changed from titleSmall to captionLarge
                          color: AppColors.textPrimary,
                          fontSize: 11, // Explicit smaller size
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3), // Reduced from 4 to 3
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 9, // Reduced from 10 to 9
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2), // Reduced from 3 to 2
                        Flexible(
                          child: Text(
                            _formatViews(reel.views),
                            style: AppTypography.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9, // Explicit smaller size
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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

  Widget _buildProviderCard(dynamic provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailsScreen(
                providerId: provider.providerId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.7),
                    AppColors.surface.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.cardBackground.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar - Refined
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
                          placeholder: (context, url) => Container(
                            color: AppColors.primary,
                            child: Center(
                              child: Text(
                                provider.businessName.substring(0, 2).toUpperCase(),
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
                                provider.businessName.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          provider.businessName.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Content - Refined (Fixed overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:                                     Text(
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
                color: AppColors.textTertiary,
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return GestureDetector(
      onTap: () {
        _showSnackbar('Viewing ${venue.name}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface.withValues(alpha: 0.7),
                  AppColors.surface.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardBackground.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: venue.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: venue.imageUrl!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
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
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.business_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                ),
                // Venue Details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.address,
                              style: AppTypography.captionMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (venue.rating != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.rating!.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (venue.reviewCount != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${venue.reviewCount})',
                                style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              color.withOpacity(0.3),
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

  void _showReferralDialog() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Refer & Earn',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Invite friends and earn ₹100 for each referral!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Referral Code',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'RAPID001',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackbar('Sharing referral code...');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToBooking(String eventType) {
    final eventTypeMap = {
      'Wedding': 'wedding',
      'Birthday': 'birthday',
      'Engagement': 'engagement',
      'Corporate': 'corporate',
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get city-based review data
  Map<String, dynamic> _getCityReview(String city, int index) {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.7),
                AppColors.surface.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cardBackground.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              if (index < rating.floor()) {
                return const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 24,
                );
              } else if (index < rating) {
                return const Icon(
                  Icons.star_half_rounded,
                  color: AppColors.primary,
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
        ),
      ),
    );
  }

  // Build Branding Section with Illustration
  Widget _buildBrandingSection(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        children: [
          // Illustration Placeholder - City-based text
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                // City-based message
                Text(
                  'Serving $city with\nInstant Reels',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                // Decorative Icons
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Branding Text
          Column(
            children: [
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
                  const Icon(
                    Icons.favorite,
                    color: AppColors.primary,
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
        ],
      ),
    );
  }

  // Build Illustration Icon
  Widget _buildIllustrationIcon(IconData icon) {
    return Icon(
      icon,
      color: AppColors.textTertiary.withValues(alpha: 0.3),
      size: 32,
    );
  }

  // Build Onboarding Tutorial Overlay
  Widget _buildOnboardingOverlay() {
    final steps = [
      {
        'title': 'Quick Actions',
        'description': 'Use these buttons to book events, view schedule, check bookings, and refer friends',
        'position': 'top',
      },
      {
        'title': 'Trending Reels',
        'description': 'Browse popular reels from recent events in your city',
        'position': 'middle',
      },
      {
        'title': 'Customer Reviews',
        'description': 'See what our customers say about our services',
        'position': 'bottom',
      },
    ];

    if (_onboardingStep >= steps.length) {
      _completeOnboarding();
      return const SizedBox.shrink();
    }

    final step = steps[_onboardingStep];

    return GestureDetector(
      onTap: () {
        setState(() {
          _onboardingStep++;
        });
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step['title'] as String,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  step['description'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_onboardingStep > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _onboardingStep--;
                          });
                        },
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(),
                    Row(
                      children: List.generate(
                        steps.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _onboardingStep == index
                                ? AppColors.primary
                                : AppColors.textTertiary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_onboardingStep < steps.length - 1) {
                          setState(() {
                            _onboardingStep++;
                          });
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _onboardingStep < steps.length - 1 ? 'Next' : 'Got it',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('home_onboarding_seen', true);
      if (mounted) {
        setState(() {
          _showOnboarding = false;
        });
      }
    } catch (e) {
      debugPrint('Error saving onboarding: $e');
    }
  }

  // Build Offer Popup
  Widget _buildOfferPopup() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOfferPopup = false;
        });
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _showOfferPopup = false;
                        });
                        _saveOfferSeen();
                      },
                    ),
                  ),
                  const Icon(
                    Icons.local_offer_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Special Offer!',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get 20% OFF on your first booking',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use code: FLASH20',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showOfferPopup = false;
                        });
                        _saveOfferSeen();
                        _showBookingDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: AppTypography.buttonLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showOfferPopup = false;
                      });
                      _saveOfferSeen();
                    },
                    child: Text(
                      'Maybe Later',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveOfferSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('home_offer_seen', true);
    } catch (e) {
      debugPrint('Error saving offer seen: $e');
    }
  }
}

