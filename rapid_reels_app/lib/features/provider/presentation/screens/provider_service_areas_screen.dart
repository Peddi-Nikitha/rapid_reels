import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderServiceAreasScreen extends StatefulWidget {
  const ProviderServiceAreasScreen({super.key});

  @override
  State<ProviderServiceAreasScreen> createState() => _ProviderServiceAreasScreenState();
}

class _ProviderServiceAreasScreenState extends State<ProviderServiceAreasScreen> {
  final List<String> _availableCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Surat',
  ];
  
  final Set<String> _selectedCities = {};
  double _serviceRadius = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Service Areas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure Service Areas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select cities where you provide services',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Service Radius
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Radius',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_serviceRadius.toInt()} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _serviceRadius,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _serviceRadius = value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10 km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('100 km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // City Selection
            const Text(
              'Select Cities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableCities.map((city) {
                final isSelected = _selectedCities.contains(city);
                return FilterChip(
                  label: Text(city),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCities.add(city);
                      } else {
                        _selectedCities.remove(city);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  avatar: isSelected
                      ? const Icon(Icons.check_circle, size: 18, color: AppColors.primary)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Map Preview (Placeholder)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'Map Preview',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Service areas will be highlighted on map',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Continue',
              onPressed: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one city')),
      );
      return;
    }

    context.push(AppRoutes.providerDocumentUpload);
  }
}

