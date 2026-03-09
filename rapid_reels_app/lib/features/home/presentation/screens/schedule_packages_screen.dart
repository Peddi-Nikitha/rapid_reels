import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';

class SchedulePackagesScreen extends StatefulWidget {
  const SchedulePackagesScreen({super.key});

  @override
  State<SchedulePackagesScreen> createState() => _SchedulePackagesScreenState();
}

class _SchedulePackagesScreenState extends State<SchedulePackagesScreen> {
  int _currentIndex = 0;
  String _selectedCity = 'Siddipet';
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'Hourly Package',
      'description': 'Capture your all your special moments in a timeless memory',
      'image': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
      'duration': '2-4 hours',
      'price': 'Starting at ₹8,000',
    },
    {
      'title': 'One Day Package',
      'description': 'Get focused, high-quality coverage for any event or project, delivered with precision.',
      'image': 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
      'duration': 'Full Day',
      'price': 'Starting at ₹25,000',
    },
    {
      'title': 'Premium Package',
      'description': 'Unlimited reels with live station and cinematic editing for your most important events.',
      'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
      'duration': '10+ hours',
      'price': 'Starting at ₹45,000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('selected_city');
      if (savedCity != null && savedCity.isNotEmpty) {
        setState(() {
          _selectedCity = savedCity;
        });
      }
    } catch (e) {
      debugPrint('Error loading city: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button and Greeting
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hi, ${_selectedCity.toLowerCase()}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Main Title
                  Text(
                    'Everything here that you are looking for!',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Package Cards Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPackageCard(_packages[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _packages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index
                        ? AppColors.primary
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    return GestureDetector(
      onTap: () {
        // Navigate to package details or booking
        context.push(
          AppRoutes.packageSelection,
          extra: {'eventType': 'wedding'},
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface.withValues(alpha: 0.8),
                  AppColors.surface.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.cardBackground.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: package['image'] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Arrow Icon (Top)
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Package Title
                      Text(
                        package['title'] as String,
                        style: AppTypography.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        package['description'] as String,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
    );
  }
}

