import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EventTypeSelectionScreen extends StatelessWidget {
  const EventTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Select Event Type'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What are you celebrating?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your event type to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildEventTypeCard(
                context,
                icon: '💍',
                title: 'Wedding',
                description: 'Capture your special day with cinematic reels',
                price: 'Starting from ₹25,000',
                color: AppColors.wedding,
                eventType: 'wedding',
              ),
              
              _buildEventTypeCard(
                context,
                icon: '🎂',
                title: 'Birthday Party',
                description: 'Make birthdays memorable with instant reels',
                price: 'Starting from ₹8,000',
                color: AppColors.birthday,
                eventType: 'birthday',
              ),
              
              _buildEventTypeCard(
                context,
                icon: '💑',
                title: 'Engagement',
                description: 'Beautiful moments of your engagement ceremony',
                price: 'Starting from ₹15,000',
                color: AppColors.engagement,
                eventType: 'engagement',
              ),
              
              _buildEventTypeCard(
                context,
                icon: '🏢',
                title: 'Corporate Event',
                description: 'Professional coverage for corporate functions',
                price: 'Starting from ₹20,000',
                color: AppColors.corporate,
                eventType: 'corporate',
              ),
              
              _buildEventTypeCard(
                context,
                icon: '🤝',
                title: 'Brand Collaboration',
                description: 'High-quality content for brand events',
                price: 'Starting from ₹30,000',
                color: AppColors.brand,
                eventType: 'brand',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required String price,
    required Color color,
    required String eventType,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.packageSelection, extra: {'eventType': eventType});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

