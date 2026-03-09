import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderPortfolioUploadScreen extends StatefulWidget {
  const ProviderPortfolioUploadScreen({super.key});

  @override
  State<ProviderPortfolioUploadScreen> createState() => _ProviderPortfolioUploadScreenState();
}

class _ProviderPortfolioUploadScreenState extends State<ProviderPortfolioUploadScreen> {
  final List<Map<String, dynamic>> _portfolioItems = [];

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
          'Portfolio Upload',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Showcase Your Work',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload sample reels and photos to attract customers',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  
                  // Upload Area
                  if (_portfolioItems.isEmpty)
                    GestureDetector(
                      onTap: _addPortfolioItem,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 64, color: AppColors.primary),
                            const SizedBox(height: 16),
                            const Text(
                              'Upload Reels or Photos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add portfolio items',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _portfolioItems.length,
                      itemBuilder: (context, index) {
                        final item = _portfolioItems[index];
                        return _buildPortfolioItem(item, index);
                      },
                    ),
                  
                  if (_portfolioItems.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _addPortfolioItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add More Items'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Continue Button
          if (_portfolioItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Continue',
                onPressed: _handleContinue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(Map<String, dynamic> item, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(item['thumbnail'] as String),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _portfolioItems.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['eventType'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.play_circle, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item['duration'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addPortfolioItem() {
    setState(() {
      _portfolioItems.add({
        'thumbnail': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
        'eventType': 'Wedding',
        'duration': '0:45',
      });
    });
  }

  void _handleContinue() {
    if (_portfolioItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one portfolio item')),
      );
      return;
    }

    context.push(AppRoutes.providerServiceAreas);
  }
}

