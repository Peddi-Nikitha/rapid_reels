import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Video controllers for slides 1 and 3
  VideoPlayerController? _videoController1;
  VideoPlayerController? _videoController3;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.videocam_rounded,
      backgroundImage: 'assets/videos/rapidreel_1slide.mp4',
      fallbackImage: 'assets/images/onboarding_1.jpg',
      isAsset: true,
      isVideo: true,
    ),
    OnboardingData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.flash_on_rounded,
      backgroundImage: 'assets/images/rapidreel_2slide.jpeg',
      fallbackImage: 'assets/images/splash_screen.jpg',
      isAsset: true,
      isVideo: false,
      bannerText: AppStrings.onboardingBanner2,
    ),
    OnboardingData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.celebration_rounded,
      backgroundImage: 'assets/videos/rapidreel_3slide.mp4',
      fallbackImage: 'assets/images/onboarding_1.jpg',
      isAsset: true,
      isVideo: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeVideos();
  }
  
  Future<void> _initializeVideos() async {
    try {
      // Initialize video controller for slide 1
      _videoController1 = VideoPlayerController.asset('assets/videos/rapidreel_1slide.mp4');
      await _videoController1!.initialize();
      _videoController1!.setLooping(true);
      _videoController1!.setVolume(0.0); // Mute videos
      if (_currentPage == 0 && mounted) {
        _videoController1!.play();
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize video 1: $e');
      _videoController1?.dispose();
      _videoController1 = null;
    }
    
    try {
      // Initialize video controller for slide 3
      _videoController3 = VideoPlayerController.asset('assets/videos/rapidreel_3slide.mp4');
      await _videoController3!.initialize();
      _videoController3!.setLooping(true);
      _videoController3!.setVolume(0.0); // Mute videos
    } catch (e) {
      debugPrint('❌ Failed to initialize video 3: $e');
      _videoController3?.dispose();
      _videoController3 = null;
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _videoController1?.dispose();
    _videoController3?.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Manage video playback based on current page
    if (page == 0 && _videoController1 != null && _videoController1!.value.isInitialized) {
      _videoController1!.play();
      if (_videoController3 != null && _videoController3!.value.isPlaying) {
        _videoController3!.pause();
      }
    } else if (page == 2 && _videoController3 != null && _videoController3!.value.isInitialized) {
      _videoController3!.play();
      if (_videoController1 != null && _videoController1!.value.isPlaying) {
        _videoController1!.pause();
      }
    } else {
      // Pause all videos when on image slide
      if (_videoController1 != null && _videoController1!.value.isPlaying) {
        _videoController1!.pause();
      }
      if (_videoController3 != null && _videoController3!.value.isPlaying) {
        _videoController3!.pause();
      }
    }
    
    // Restart animation for new page
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _skip() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image for current page
          _buildBackgroundImage(_currentPage),
          
          // Gradient overlay
          _buildGradientOverlay(),
          
          // Content
          Stack(
            children: [
              // Skip button - Elegant and compact
              SafeArea(
                child: _buildSkipButton(),
              ),
              
              // Banner for slide 2 (Car) - positioned at top below status bar
              if (_currentPage == 1)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: _buildCarBanner(),
                ),
              
              // Page view with text overlay
              SafeArea(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Bottom section with dots and button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: _buildBottomSection(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadImageWithFallback(String imagePath, String? fallbackImage) {
    // Only use local asset images - reject any URLs
    if (imagePath.startsWith('http://') || 
        imagePath.startsWith('https://') ||
        imagePath.startsWith('www.') ||
        imagePath.contains('://')) {
      debugPrint('❌ REJECTED: URL detected, using local assets only: $imagePath');
      if (fallbackImage != null && 
          !fallbackImage.startsWith('http') && 
          !fallbackImage.startsWith('https') &&
          !fallbackImage.contains('://')) {
        return _loadAssetImage(fallbackImage, null);
      }
      return _buildErrorPlaceholder();
    }
    
    // Load local asset image
    return _loadAssetImage(imagePath, fallbackImage);
  }

  Widget _loadAssetImage(String imagePath, String? fallbackImage) {
    return Image.asset(
      imagePath,
      key: ValueKey('img_$imagePath'),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: false,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Failed to load image: $imagePath');
        debugPrint('Error: $error');
        // Try fallback image if available
        if (fallbackImage != null && !fallbackImage.startsWith('http')) {
          debugPrint('🔄 Trying fallback: $fallbackImage');
          return Image.asset(
            fallbackImage,
            key: ValueKey('fallback_$fallbackImage'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: false,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Fallback also failed: $fallbackImage - $error');
              // Show gradient instead of error icon
              return Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              );
            },
          );
        }
        // Show gradient instead of error icon
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
    );
  }

  Widget _buildBackgroundImage(int pageIndex) {
    final page = _pages[pageIndex];
    final imagePath = page.backgroundImage;
    final fallbackImage = page.fallbackImage;
    final isAsset = page.isAsset;
    final isVideo = page.isVideo;
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: isVideo && isAsset
          ? _buildVideoPlayer(pageIndex)
          : isAsset
              ? _loadImageWithFallback(imagePath, fallbackImage)
              : Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Text(
                      'Local Images Only',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildVideoPlayer(int pageIndex) {
    VideoPlayerController? controller;
    
    if (pageIndex == 0) {
      controller = _videoController1;
    } else if (pageIndex == 2) {
      controller = _videoController3;
    }
    
    if (controller == null || !controller.value.isInitialized) {
      // Show loading or fallback while video initializes
      final page = _pages[pageIndex];
      return _loadImageWithFallback(
        page.fallbackImage ?? 'assets/images/onboarding_1.jpg',
        null,
      );
    }
    
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _skip,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                AppStrings.skip,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots indicator - positioned between text and button
          _buildDotsIndicator(),
          
          const SizedBox(height: 20),
          
          // Get Started button
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => _buildDot(index == _currentPage),
      ),
    );
  }

  Widget _buildNextButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _nextPage,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'Get Started',
            style: AppTypography.buttonLarge.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Stack(
      children: [
        // Text overlay positioned at bottom left
        Positioned(
          bottom: 140,
          left: 24,
          right: 24,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Large and prominent
                  Text(
                    data.title,
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle - Refined typography
                  Text(
                    data.subtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade700,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Car icon on left
          Icon(
            Icons.directions_car,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              AppStrings.onboardingBanner2,
              style: AppTypography.displaySmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Car icon on right
          Icon(
            Icons.directions_car,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String backgroundImage;
  final String? fallbackImage;
  final bool isAsset;
  final bool isVideo;
  final String? bannerText;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundImage,
    this.fallbackImage,
    this.isAsset = false,
    this.isVideo = false,
    this.bannerText,
  });
}

