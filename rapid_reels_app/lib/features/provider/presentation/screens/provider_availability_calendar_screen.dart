import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderAvailabilityCalendarScreen extends StatefulWidget {
  const ProviderAvailabilityCalendarScreen({super.key});

  @override
  State<ProviderAvailabilityCalendarScreen> createState() => _ProviderAvailabilityCalendarScreenState();
}

class _ProviderAvailabilityCalendarScreenState extends State<ProviderAvailabilityCalendarScreen> {
  final Map<String, Map<String, dynamic>> _weeklySchedule = {
    'Monday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Tuesday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Wednesday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Thursday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Friday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Saturday': {'isOpen': true, 'startTime': '09:00', 'endTime': '18:00'},
    'Sunday': {'isOpen': false, 'startTime': '09:00', 'endTime': '18:00'},
  };

  final Set<DateTime> _blockedDates = {};

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
          'Availability Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Your Availability',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your weekly schedule and block unavailable dates',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Weekly Schedule
            const Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._weeklySchedule.entries.map((entry) {
              return _buildDaySchedule(entry.key, entry.value);
            }).toList(),
            
            const SizedBox(height: 32),
            
            // Blocked Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Blocked Dates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showDatePicker,
                  icon: const Icon(Icons.add),
                  label: const Text('Block Date'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_blockedDates.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        'No blocked dates',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _blockedDates.map((date) {
                  return Chip(
                    label: Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() => _blockedDates.remove(date));
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Complete Setup',
              onPressed: _handleComplete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, Map<String, dynamic> schedule) {
    final isOpen = schedule['isOpen'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: (value) {
              setState(() {
                schedule['isOpen'] = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          if (isOpen) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${schedule['startTime']} - ${schedule['endTime']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _blockedDates.add(picked);
      });
    }
  }

  void _handleComplete() {
    // Show verification pending screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Registration Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            const Text(
              'Your provider account has been created successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your account is pending verification. You will receive a notification once verified.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.providerVerification);
            },
            child: const Text('View Status'),
          ),
        ],
      ),
    );
  }
}

