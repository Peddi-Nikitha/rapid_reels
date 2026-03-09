import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/mock/mock_packages.dart';
import '../../../../shared/widgets/package_card.dart';
import '../../../../shared/widgets/custom_button.dart';

class PackageSelectionScreen extends StatefulWidget {
  final String eventType;

  const PackageSelectionScreen({
    super.key,
    required this.eventType,
  });

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  int _currentIndex = 2; // Default to Gold (most popular)
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    debugPrint('PackageSelectionScreen initialized with eventType: ${widget.eventType}');
    debugPrint('Total packages available: ${MockPackages.allPackages.length}');
  }

  @override
  Widget build(BuildContext context) {
    final selectedPackage = MockPackages.allPackages[_currentIndex];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Choose Package',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Perfect Package',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Swipe to explore different packages',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Package Carousel
                  SizedBox(
                    height: 500, // Fixed height to prevent overflow
                    child: MockPackages.allPackages.isEmpty
                        ? const Center(
                            child: Text(
                              'No packages available',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: MockPackages.allPackages.length,
                            itemBuilder: (context, index, realIndex) {
                              final package = MockPackages.allPackages[index];
                              final isPopular = package.packageId == 'pkg_gold';
                              final isSelected = index == _currentIndex;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: PackageCard(
                                  package: package,
                                  isSelected: isSelected,
                                  isPopular: isPopular,
                                  onTap: () {
                                    _carouselController.animateToPage(index);
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 500, // Fixed height
                              viewportFraction: 0.88,
                              initialPage: 2, // Start with Gold
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.15,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: MockPackages.allPackages.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentIndex == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentIndex == entry.key
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Benefits Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Why Choose Rapid Reels?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildBenefitItem(
                          Icons.flash_on_rounded,
                          'Instant Delivery',
                          'Get your reels while the event is still happening',
                        ),
                        _buildBenefitItem(
                          Icons.hd_rounded,
                          'Premium Quality',
                          'Professional editing with 4K quality',
                        ),
                        _buildBenefitItem(
                          Icons.share_rounded,
                          'Easy Sharing',
                          'Share directly to Instagram, WhatsApp, and more',
                        ),
                        _buildBenefitItem(
                          Icons.verified_user_rounded,
                          'Verified Professionals',
                          'Experienced videographers and editors',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Button Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected Package Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPackage.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '£${selectedPackage.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Continue Button
                  CustomButton(
                    text: 'Continue with ${selectedPackage.name}',
                    onPressed: () {
                      debugPrint('Continue button pressed');
                      debugPrint('Event Type: ${widget.eventType}');
                      debugPrint('Package ID: ${selectedPackage.packageId}');
                      try {
                        context.push(
                          AppRoutes.eventDetails,
                          extra: {
                            'eventType': widget.eventType,
                            'packageId': selectedPackage.packageId,
                          },
                        );
                      } catch (e) {
                        debugPrint('Navigation error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
