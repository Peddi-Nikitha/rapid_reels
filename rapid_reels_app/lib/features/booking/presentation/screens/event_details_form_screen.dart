import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class EventDetailsFormScreen extends StatefulWidget {
  final String eventType;
  final String packageId;

  const EventDetailsFormScreen({
    super.key,
    required this.eventType,
    required this.packageId,
  });

  @override
  State<EventDetailsFormScreen> createState() => _EventDetailsFormScreenState();
}

class _EventDetailsFormScreenState extends State<EventDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _specialRequirementsController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 100;
  int _duration = 4; // hours
  final List<String> _selectedKeyMoments = [];

  final List<String> _keyMomentOptions = [
    'Bride Entry',
    'Groom Entry',
    'Ring Exchange',
    'Varmala Ceremony',
    'First Dance',
    'Cake Cutting',
    'Family Photos',
    'Couple Photos',
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Event Details'),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildProgressDot(true),
                _buildProgressLine(true),
                _buildProgressDot(true),
                _buildProgressLine(false),
                _buildProgressDot(false),
                _buildProgressLine(false),
                _buildProgressDot(false),
              ],
            ),
          ),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us about your event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Event Name
                    CustomTextField(
                      label: 'Event Name',
                      hint: 'e.g., Rajesh & Priya Wedding',
                      controller: _eventNameController,
                      prefixIcon: Icons.celebration,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDate != null
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(_selectedDate!)
                                              : 'Select date',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _selectedDate != null
                                                ? AppColors.textPrimary
                                                : AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedTime != null
                                              ? _selectedTime!.format(context)
                                              : 'Select time',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _selectedTime != null
                                                ? AppColors.textPrimary
                                                : AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Guest Count Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expected Guest Count',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '$_guestCount guests',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _guestCount.toDouble(),
                          min: 10,
                          max: 1000,
                          divisions: 99,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.surface,
                          onChanged: (value) {
                            setState(() {
                              _guestCount = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Duration Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coverage Duration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [2, 4, 6, 10].map((hours) {
                            final isSelected = _duration == hours;
                            return ChoiceChip(
                              label: Text('$hours hours'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _duration = hours;
                                });
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Key Moments
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Key Moments to Capture',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select the important moments you want captured',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _keyMomentOptions.map((moment) {
                            final isSelected = _selectedKeyMoments.contains(moment);
                            return FilterChip(
                              label: Text(moment),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedKeyMoments.add(moment);
                                  } else {
                                    _selectedKeyMoments.remove(moment);
                                  }
                                });
                              },
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Special Requirements
                    CustomTextField(
                      label: 'Special Requirements (Optional)',
                      hint: 'Any specific requirements or requests...',
                      controller: _specialRequirementsController,
                      maxLines: 4,
                      prefixIcon: Icons.note_alt,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Button
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
              child: CustomButton(
                text: 'Select Venue',
                onPressed: _handleContinue,
                icon: Icons.arrow_forward,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : AppColors.surface,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select event date')),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select event time')),
        );
        return;
      }
      
      context.push(
        AppRoutes.venueSelection,
        extra: {
          'eventType': widget.eventType,
          'packageId': widget.packageId,
          'eventName': _eventNameController.text,
          'eventDate': _selectedDate,
          'eventTime': _selectedTime,
          'guestCount': _guestCount,
          'duration': _duration,
          'keyMoments': _selectedKeyMoments,
          'specialRequirements': _specialRequirementsController.text,
        },
      );
    }
  }
}

