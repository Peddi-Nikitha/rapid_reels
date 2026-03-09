import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/mock/mock_packages.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';

class PackageCustomizationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PackageCustomizationScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<PackageCustomizationScreen> createState() => _PackageCustomizationScreenState();
}

class _PackageCustomizationScreenState extends State<PackageCustomizationScreen> {
  int _additionalReels = 0;
  bool _includeDrone = false;
  String _editingStyle = 'cinematic';
  String _musicPreference = 'bollywood';
  String _colorGrading = 'warm';

  double get _additionalCost {
    double cost = 0;
    cost += _additionalReels * 1500; // ₹1500 per additional reel
    cost += _includeDrone ? 3000 : 0; // ₹3000 for drone
    return cost;
  }

  double get _basePrice {
    final packageId = widget.bookingData['packageId'];
    final package = MockPackages.getPackageById(packageId);
    return package?.price.toDouble() ?? 0;
  }

  double get _totalPrice => _basePrice + _additionalCost;

  @override
  Widget build(BuildContext context) {
    final packageId = widget.bookingData['packageId'];
    final package = MockPackages.getPackageById(packageId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Customize Package'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                package?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${_basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(package?.duration ?? 0) ~/ 60} hours • ${package?.reelsCount == -1 ? "Unlimited" : package?.reelsCount} reels',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Add-ons',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Additional Reels
                  _buildAddonCard(
                    icon: Icons.add_circle_outline,
                    title: 'Additional Reels',
                    description: 'Add more instant reels to your package',
                    price: 1500,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _additionalReels > 0
                              ? () => setState(() => _additionalReels--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.primary,
                        ),
                        Text(
                          _additionalReels.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _additionalReels++),
                          icon: const Icon(Icons.add_circle),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  
                  // Drone Footage
                  _buildAddonCard(
                    icon: Icons.flight,
                    title: 'Drone Footage',
                    description: 'Add stunning aerial shots to your coverage',
                    price: 3000,
                    child: Switch(
                      value: _includeDrone,
                      onChanged: (value) => setState(() => _includeDrone = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Editing Style
                  _buildPreferenceSection(
                    'Editing Style',
                    ['cinematic', 'vintage', 'modern', 'classic'],
                    _editingStyle,
                    (value) => setState(() => _editingStyle = value),
                  ),
                  
                  // Music Preference
                  _buildPreferenceSection(
                    'Music Preference',
                    ['bollywood', 'edm', 'classical', 'romantic'],
                    _musicPreference,
                    (value) => setState(() => _musicPreference = value),
                  ),
                  
                  // Color Grading
                  _buildPreferenceSection(
                    'Color Grading',
                    ['warm', 'cool', 'vibrant', 'neutral'],
                    _colorGrading,
                    (value) => setState(() => _colorGrading = value),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Price & Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (_additionalCost > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Base Price:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₹${_basePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add-ons:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '+₹${_additionalCost.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${_totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Review Booking',
                    onPressed: () {
                      final updatedData = Map<String, dynamic>.from(widget.bookingData);
                      updatedData['additionalReels'] = _additionalReels;
                      updatedData['includeDrone'] = _includeDrone;
                      updatedData['editingStyle'] = _editingStyle;
                      updatedData['musicPreference'] = _musicPreference;
                      updatedData['colorGrading'] = _colorGrading;
                      updatedData['additionalCost'] = _additionalCost;
                      updatedData['totalAmount'] = _totalPrice;
                      
                      context.push(AppRoutes.bookingSummary, extra: updatedData);
                    },
                    icon: Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonCard({
    required IconData icon,
    required String title,
    required String description,
    required double price,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(option[0].toUpperCase() + option.substring(1)),
              selected: isSelected,
              onSelected: (selected) => onChanged(option),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

