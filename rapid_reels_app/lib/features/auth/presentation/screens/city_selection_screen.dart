import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  String? _selectedCity;

  final List<CityData> _cities = [
    CityData(
      name: 'Visakhapatnam',
      displayName: 'Visakhap...',
      imagePath: 'assets/images/cities/Visakhapatnam_transparent.png',
    ),
    CityData(
      name: 'Mumbai',
      displayName: 'Mumbai',
      imagePath: 'assets/images/cities/Mumbai_transparent.png',
    ),
    CityData(
      name: 'Hyderabad',
      displayName: 'Hyderab...',
      imagePath: 'assets/images/cities/Hyderabad_transparent.png',
    ),
    CityData(
      name: 'Chennai',
      displayName: 'Chennai',
      imagePath: 'assets/images/cities/Chennai_transparent.png',
    ),
    CityData(
      name: 'Bangalore',
      displayName: 'Banglore',
      imagePath: 'assets/images/cities/Bangalore_transparent.png',
    ),
    CityData(
      name: 'Vijayawada',
      displayName: 'Vijayawa...',
      imagePath: 'assets/images/cities/Vijayawada_transparent.png',
    ),
    CityData(
      name: 'Warangal',
      displayName: 'Warangal',
      imagePath: 'assets/images/cities/Warangal_transparent.png',
    ),
  ];

  Future<void> _onCitySelected(String cityName) async {
    setState(() {
      _selectedCity = cityName;
    });
    
    // Save city preference to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_city', cityName);
    } catch (e) {
      debugPrint('Error saving city: $e');
    }
    
    // Navigate to home with selected city
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1F1A), // Dark reddish-brown top bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              final isSelected = _selectedCity == city.name;
              
              return _buildCityCard(city, isSelected);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(CityData city, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCitySelected(city.name),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 0,
            maxHeight: double.infinity,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary,
                    width: 2,
                  )
                : Border.all(
                    color: AppColors.cardBackground.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // City Image - Full background, centered
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  city.imagePath,
                  fit: BoxFit.contain, // Show full illustration
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textTertiary,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Very subtle gradient overlay only at bottom for text readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.75, 1.0],
                  ),
                ),
              ),
              
              // City name at bottom left
              Positioned(
                left: 12,
                bottom: 12,
                child: Text(
                  city.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
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

class CityData {
  final String name;
  final String displayName;
  final String imagePath;

  CityData({
    required this.name,
    required this.displayName,
    required this.imagePath,
  });
}
